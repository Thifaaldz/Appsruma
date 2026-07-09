package controllers

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"ruma/config"
	"ruma/models"
	"ruma/repositories"
	"ruma/utils"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

type PaymentController struct {
	paymentRepo repositories.PaymentRepository
}

func NewPaymentController(paymentRepo repositories.PaymentRepository) *PaymentController {
	return &PaymentController{paymentRepo: paymentRepo}
}

func (ctrl *PaymentController) authorizePaymentAccess(c *gin.Context, payment *models.Payment) bool {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil || tenant.ID != payment.TenantID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return false
		}
		return true
	}

	if role == "owner" {
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify tenant details"})
			return false
		}
		for _, tid := range tenantIDs {
			if tid == payment.TenantID {
				return true
			}
		}
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return false
	}

	return true
}

func paymentIDFromOrderID(orderID string) (uint, error) {
	parts := strings.Split(orderID, "-")
	if len(parts) < 3 || parts[0] != "RUMA" || parts[1] != "PAY" {
		return 0, fmt.Errorf("invalid order format")
	}
	paymentIDVal, err := strconv.Atoi(parts[2])
	if err != nil {
		return 0, fmt.Errorf("invalid payment ID")
	}
	return uint(paymentIDVal), nil
}

// getBillingPeriodLabel returns Indonesian month-year label for a given date
func getBillingPeriodLabel(t time.Time) string {
	months := []string{
		"", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
		"Juli", "Agustus", "September", "Oktober", "November", "Desember",
	}
	return fmt.Sprintf("%s %d", months[t.Month()], t.Year())
}

// getRoomPrice returns the room price, falling back to boarding house default
func getRoomPrice(tenant *models.Tenant) float64 {
	amount := tenant.Room.Price
	if amount <= 0 {
		var bh models.BoardingHouse
		if err := config.DB.First(&bh, tenant.Room.BoardingHouseID).Error; err == nil {
			amount = bh.DefaultRoomPrice
		}
	}
	return amount
}

// CreateFirstBill creates the first pending payment when a tenant is added.
// The tenant is NOT counted as "paid" - they must pay through Midtrans.
func CreateFirstBill(tenant *models.Tenant) error {
	amount := getRoomPrice(tenant)
	if amount <= 0 {
		return nil
	}

	dueDate := tenant.CheckInDate
	overdueDate := dueDate.AddDate(0, 0, 10)
	billingPeriod := getBillingPeriodLabel(dueDate)

	payment := models.Payment{
		TenantID:      tenant.ID,
		Amount:        amount,
		DueDate:       dueDate,
		OverdueDate:   overdueDate,
		BillingPeriod: billingPeriod,
		PaymentDate:   dueDate,
		Status:        "pending",
	}

	return config.DB.Create(&payment).Error
}

// EnsureNextBillGenerated checks if the next billing cycle needs a new bill.
// Logic:
//   - If no payments exist, create first bill on check-in date
//   - If latest payment is still pending, don't create another
//   - If latest is paid, check if it's time for next month's bill
//   - Mark overdue bills (pending + past overdue_date)
func EnsureNextBillGenerated(tenantID uint) error {
	var tenant models.Tenant
	if err := config.DB.Preload("Room").First(&tenant, tenantID).Error; err != nil {
		return err
	}

	var payments []models.Payment
	if err := config.DB.Where("tenant_id = ?", tenantID).Order("due_date desc").Find(&payments).Error; err != nil {
		return err
	}

	now := time.Now()

	// Mark overdue payments
	for i := range payments {
		if payments[i].Status == "pending" && now.After(payments[i].OverdueDate) {
			payments[i].Status = "overdue"
			config.DB.Save(&payments[i])
		}
	}

	// If no payments exist, create the first one
	if len(payments) == 0 {
		return CreateFirstBill(&tenant)
	}

	// Get billing day from tenant
	billingDay := tenant.BillingDay
	if billingDay <= 0 {
		billingDay = tenant.CheckInDate.Day()
	}
	// Clamp billing day to 28 to avoid month-end issues
	if billingDay > 28 {
		billingDay = 28
	}

	// Find the latest payment by due date
	latest := payments[0]

	// If there's still a pending or overdue payment, don't create another
	for _, p := range payments {
		if p.Status == "pending" || p.Status == "overdue" {
			return nil
		}
	}

	// All existing payments are paid. Generate next month's bill.
	// Next due date is the billing day in the month after the latest payment
	nextDueDate := time.Date(
		latest.DueDate.Year(),
		latest.DueDate.Month()+1,
		billingDay,
		0, 0, 0, 0,
		latest.DueDate.Location(),
	)

	// Only generate if we're within 10 days before or after the next due date
	// (or if the due date has already passed)
	genWindowStart := nextDueDate.AddDate(0, 0, -10)
	if now.After(genWindowStart) {
		// Check that this period doesn't already have a bill
		periodLabel := getBillingPeriodLabel(nextDueDate)
		var count int64
		config.DB.Model(&models.Payment{}).
			Where("tenant_id = ? AND billing_period = ?", tenantID, periodLabel).
			Count(&count)
		if count > 0 {
			return nil
		}

		amount := getRoomPrice(&tenant)
		if amount <= 0 {
			return nil
		}

		overdueDate := nextDueDate.AddDate(0, 0, 10)
		nextPayment := models.Payment{
			TenantID:      tenantID,
			Amount:        amount,
			DueDate:       nextDueDate,
			OverdueDate:   overdueDate,
			BillingPeriod: periodLabel,
			PaymentDate:   nextDueDate,
			Status:        "pending",
		}
		return config.DB.Create(&nextPayment).Error
	}

	return nil
}

func (ctrl *PaymentController) GetAllPayments(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "owner" {
		// Optional filter: ?boarding_house_id=X
		bhIDStr := c.Query("boarding_house_id")

		var tenantIDs []uint
		if bhIDStr != "" {
			// Verify ownership
			bhID, err := strconv.Atoi(bhIDStr)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid boarding_house_id"})
				return
			}
			var count int64
			config.DB.Model(&models.BoardingHouse{}).Where("id = ? AND owner_id = ?", uint(bhID), userID.(uint)).Count(&count)
			if count == 0 {
				c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
				return
			}
			var roomIDs []uint
			config.DB.Model(&models.Room{}).Where("boarding_house_id = ?", uint(bhID)).Pluck("id", &roomIDs)
			if len(roomIDs) > 0 {
				config.DB.Model(&models.Tenant{}).Where("room_id IN ?", roomIDs).Pluck("id", &tenantIDs)
			}
		} else {
			var err error
			tenantIDs, err = utils.GetOwnerTenantIDs(userID.(uint))
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenant details"})
				return
			}
		}
		if len(tenantIDs) == 0 {
			c.JSON(http.StatusOK, []models.Payment{})
			return
		}
		for _, tid := range tenantIDs {
			EnsureNextBillGenerated(tid)
		}
		var payments []models.Payment
		if err := config.DB.Preload("Tenant.User").Preload("Tenant.Room.BoardingHouse").Where("tenant_id IN ?", tenantIDs).Order("due_date desc").Find(&payments).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
			return
		}
		ctrl.syncPendingPaymentsWithMidtrans(payments)
		c.JSON(http.StatusOK, payments)
		return
	} else if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		EnsureNextBillGenerated(tenant.ID)
		var payments []models.Payment
		if err := config.DB.Preload("Tenant.User").Preload("Tenant.Room.BoardingHouse").Where("tenant_id = ?", tenant.ID).Order("due_date desc").Find(&payments).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
			return
		}
		ctrl.syncPendingPaymentsWithMidtrans(payments)
		c.JSON(http.StatusOK, payments)
		return
	}

	payments, err := ctrl.paymentRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
		return
	}
	ctrl.syncPendingPaymentsWithMidtrans(payments)
	c.JSON(http.StatusOK, payments)
}

func (ctrl *PaymentController) CreatePayment(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var payment models.Payment
	if err := c.ShouldBindJSON(&payment); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		payment.TenantID = tenant.ID
	} else if role == "owner" {
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify tenant details"})
			return
		}
		allowed := false
		for _, tid := range tenantIDs {
			if tid == payment.TenantID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Tenant does not belong to your boarding house"})
			return
		}
	}

	if err := ctrl.paymentRepo.Create(&payment); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create payment"})
		return
	}
	c.JSON(http.StatusCreated, payment)
}

func (ctrl *PaymentController) GetTenantPayments(c *gin.Context) {
	tenantID, _ := strconv.Atoi(c.Param("tenantId"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil || tenant.ID != uint(tenantID) {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	} else if role == "owner" {
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify tenant details"})
			return
		}
		allowed := false
		for _, tid := range tenantIDs {
			if tid == uint(tenantID) {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	EnsureNextBillGenerated(uint(tenantID))

	payments, err := ctrl.paymentRepo.FindByTenantID(uint(tenantID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenant payments"})
		return
	}
	ctrl.syncPendingPaymentsWithMidtrans(payments)
	c.JSON(http.StatusOK, payments)
}

// ConfirmPayment allows a tenant to mark a pending payment as "paid"
func (ctrl *PaymentController) ConfirmPayment(c *gin.Context) {
	paymentID, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	payment, err := ctrl.paymentRepo.FindByID(uint(paymentID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Payment not found"})
		return
	}

	if payment.Status != "pending" && payment.Status != "overdue" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pembayaran ini sudah diproses"})
		return
	}

	if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil || tenant.ID != payment.TenantID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	} else if role == "owner" {
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify tenant details"})
			return
		}
		allowed := false
		for _, tid := range tenantIDs {
			if tid == payment.TenantID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	now := time.Now()
	payment.Status = "paid"
	payment.PaidAt = &now
	payment.PaymentDate = now
	if err := ctrl.paymentRepo.Update(payment); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status pembayaran"})
		return
	}

	c.JSON(http.StatusOK, payment)
}

// PayNextMonth allows a tenant to create a bill for the next month and pay it in advance
func (ctrl *PaymentController) PayNextMonth(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var tenantID uint

	if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		tenantID = tenant.ID
	} else if role == "owner" {
		// Owner can specify tenant_id in body
		var body struct {
			TenantID uint `json:"tenant_id" binding:"required"`
		}
		if err := c.ShouldBindJSON(&body); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify tenant details"})
			return
		}
		allowed := false
		for _, tid := range tenantIDs {
			if tid == body.TenantID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Tenant does not belong to your boarding house"})
			return
		}
		tenantID = body.TenantID
	}

	var tenant models.Tenant
	if err := config.DB.Preload("Room").First(&tenant, tenantID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tenant not found"})
		return
	}

	// Find the latest payment for this tenant
	var payments []models.Payment
	if err := config.DB.Where("tenant_id = ?", tenantID).Order("due_date desc").Find(&payments).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
		return
	}

	// Check if there's still a pending payment - must pay current first
	for _, p := range payments {
		if p.Status == "pending" || p.Status == "overdue" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Anda masih memiliki tagihan yang belum dibayar. Silakan bayar terlebih dahulu."})
			return
		}
	}

	billingDay := tenant.BillingDay
	if billingDay <= 0 {
		billingDay = tenant.CheckInDate.Day()
	}
	if billingDay > 28 {
		billingDay = 28
	}

	// Calculate next month's due date based on latest payment
	var nextDueDate time.Time
	if len(payments) > 0 {
		latest := payments[0]
		nextDueDate = time.Date(
			latest.DueDate.Year(),
			latest.DueDate.Month()+1,
			billingDay,
			0, 0, 0, 0,
			latest.DueDate.Location(),
		)
	} else {
		// No payments yet, next month from check-in
		nextDueDate = time.Date(
			tenant.CheckInDate.Year(),
			tenant.CheckInDate.Month()+1,
			billingDay,
			0, 0, 0, 0,
			tenant.CheckInDate.Location(),
		)
	}

	// Check if this period already exists
	periodLabel := getBillingPeriodLabel(nextDueDate)
	var count int64
	config.DB.Model(&models.Payment{}).
		Where("tenant_id = ? AND billing_period = ?", tenantID, periodLabel).
		Count(&count)
	if count > 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Tagihan untuk periode %s sudah ada", periodLabel)})
		return
	}

	amount := getRoomPrice(&tenant)
	if amount <= 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Harga kamar belum diatur"})
		return
	}

	overdueDate := nextDueDate.AddDate(0, 0, 10)
	nextPayment := models.Payment{
		TenantID:      tenantID,
		Amount:        amount,
		DueDate:       nextDueDate,
		OverdueDate:   overdueDate,
		BillingPeriod: periodLabel,
		PaymentDate:   nextDueDate,
		Status:        "pending",
	}

	if err := config.DB.Create(&nextPayment).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat tagihan bulan depan"})
		return
	}

	c.JSON(http.StatusCreated, nextPayment)
}

// GetSnapToken generates a Midtrans Snap transaction token and redirect URL
func (ctrl *PaymentController) GetSnapToken(c *gin.Context) {
	paymentID, _ := strconv.Atoi(c.Param("id"))
	role, _ := c.Get("role")

	payment, err := ctrl.paymentRepo.FindByID(uint(paymentID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Payment not found"})
		return
	}

	if payment.Status != "pending" && payment.Status != "overdue" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pembayaran ini sudah lunas atau diproses"})
		return
	}

	if role == "tenant" || role == "owner" {
		if !ctrl.authorizePaymentAccess(c, payment) {
			return
		}
	}

	// Fetch full details of the Tenant and User
	var tenant models.Tenant
	config.DB.Preload("User").First(&tenant, payment.TenantID)

	serverKey := os.Getenv("MIDTRANS_SERVER_KEY")
	if serverKey == "" {
		serverKey = "SB-Mid-server-Jw5gV97y0u-0H1x2z3Y4W5V6" // fallback
	}

	// Create unique order ID
	orderID := fmt.Sprintf("RUMA-PAY-%d-%d", payment.ID, time.Now().Unix())

	// Save order ID to payment for tracking
	payment.MidtransOrderID = orderID
	ctrl.paymentRepo.Update(payment)

	// Build Snap Request body
	snapReq := map[string]interface{}{
		"transaction_details": map[string]interface{}{
			"order_id":     orderID,
			"gross_amount": payment.Amount,
		},
		"customer_details": map[string]interface{}{
			"first_name": tenant.User.Name,
			"email":      tenant.User.Email,
			"phone":      tenant.Phone,
		},
		"credit_card": map[string]interface{}{
			"secure": true,
		},
	}

	reqBody, err := json.Marshal(snapReq)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create request body"})
		return
	}

	client := &http.Client{Timeout: 10 * time.Second}
	req, err := http.NewRequest("POST", "https://app.sandbox.midtrans.com/snap/v1/transactions", bytes.NewBuffer(reqBody))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to initialize HTTP request"})
		return
	}

	authHeader := "Basic " + base64.StdEncoding.EncodeToString([]byte(serverKey+":"))
	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Midtrans API connection failed"})
		return
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusCreated && resp.StatusCode != http.StatusOK {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Midtrans failed", "details": string(respBody)})
		return
	}

	var snapResp map[string]interface{}
	if err := json.Unmarshal(respBody, &snapResp); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse Snap response"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token":        snapResp["token"],
		"redirect_url": snapResp["redirect_url"],
		"order_id":     orderID,
	})
}

// MidtransWebhook handles notifications sent by Midtrans sandbox/production
// When payment is confirmed (settlement/capture), it:
// 1. Marks payment as "paid"
// 2. Sets PaidAt timestamp → this triggers it to count as owner income
func (ctrl *PaymentController) MidtransWebhook(c *gin.Context) {
	var notification map[string]interface{}
	if err := c.ShouldBindJSON(&notification); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	orderID, ok := notification["order_id"].(string)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid order_id"})
		return
	}

	status, ok := notification["transaction_status"].(string)
	if !ok {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid transaction_status"})
		return
	}

	// Parse Payment ID from order_id: RUMA-PAY-<payment_id>-<unix>
	parts := strings.Split(orderID, "-")
	if len(parts) < 3 || parts[0] != "RUMA" || parts[1] != "PAY" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid order format"})
		return
	}

	paymentIDVal, err := strconv.Atoi(parts[2])
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid payment ID"})
		return
	}

	payment, err := ctrl.paymentRepo.FindByID(uint(paymentIDVal))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Payment not found"})
		return
	}

	if status == "settlement" || status == "capture" {
		if payment.Status != "paid" {
			now := time.Now()
			payment.Status = "paid"
			payment.PaidAt = &now
			payment.PaymentDate = now
			payment.MidtransOrderID = orderID
			ctrl.paymentRepo.Update(payment)
		}
	} else if status == "expire" || status == "cancel" || status == "deny" {
		if payment.Status == "pending" || payment.Status == "overdue" {
			payment.Status = "cancelled"
			ctrl.paymentRepo.Update(payment)
		}
	}

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// checkAndUpdateStatus queries Midtrans status API directly and updates the database
func (ctrl *PaymentController) checkAndUpdateStatus(orderID string) (string, map[string]interface{}, error) {
	serverKey := os.Getenv("MIDTRANS_SERVER_KEY")
	if serverKey == "" {
		serverKey = "SB-Mid-server-Jw5gV97y0u-0H1x2z3Y4W5V6"
	}

	client := &http.Client{Timeout: 5 * time.Second}
	url := fmt.Sprintf("https://api.sandbox.midtrans.com/v2/%s/status", orderID)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", nil, err
	}

	authHeader := "Basic " + base64.StdEncoding.EncodeToString([]byte(serverKey+":"))
	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return "", nil, err
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", nil, err
	}

	var statusResp map[string]interface{}
	if err := json.Unmarshal(respBody, &statusResp); err != nil {
		return "", nil, err
	}

	txStatus, _ := statusResp["transaction_status"].(string)

	parts := strings.Split(orderID, "-")
	if len(parts) >= 3 && parts[0] == "RUMA" && parts[1] == "PAY" {
		paymentIDVal, err := strconv.Atoi(parts[2])
		if err == nil {
			payment, err := ctrl.paymentRepo.FindByID(uint(paymentIDVal))
			if err == nil {
				if txStatus == "settlement" || txStatus == "capture" {
					if payment.Status != "paid" {
						now := time.Now()
						payment.Status = "paid"
						payment.PaidAt = &now
						payment.PaymentDate = now
						payment.MidtransOrderID = orderID
						ctrl.paymentRepo.Update(payment)
					}
				} else if txStatus == "expire" || txStatus == "cancel" || txStatus == "deny" {
					if payment.Status == "pending" || payment.Status == "overdue" {
						payment.Status = "cancelled"
						ctrl.paymentRepo.Update(payment)
					}
				}
			}
		}
	}

	return txStatus, statusResp, nil
}

// syncPendingPaymentsWithMidtrans updates the status of any pending or overdue payments in-place
func (ctrl *PaymentController) syncPendingPaymentsWithMidtrans(payments []models.Payment) {
	for i := range payments {
		if (payments[i].Status == "pending" || payments[i].Status == "overdue") && payments[i].MidtransOrderID != "" {
			txStatus, _, err := ctrl.checkAndUpdateStatus(payments[i].MidtransOrderID)
			if err == nil {
				if txStatus == "settlement" || txStatus == "capture" {
					payments[i].Status = "paid"
					now := time.Now()
					payments[i].PaidAt = &now
					payments[i].PaymentDate = now
				} else if txStatus == "expire" || txStatus == "cancel" || txStatus == "deny" {
					payments[i].Status = "cancelled"
				}
			}
		}
	}
}

// CheckPaymentStatus queries Midtrans status API directly to verify the status
func (ctrl *PaymentController) CheckPaymentStatus(c *gin.Context) {
	orderID := c.Param("orderId") // e.g. RUMA-PAY-1-1628100101

	paymentID, parseErr := paymentIDFromOrderID(orderID)
	if parseErr != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": parseErr.Error()})
		return
	}

	payment, err := ctrl.paymentRepo.FindByID(paymentID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Payment not found"})
		return
	}
	if !ctrl.authorizePaymentAccess(c, payment) {
		return
	}

	_, statusResp, err := ctrl.checkAndUpdateStatus(orderID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, statusResp)
}
