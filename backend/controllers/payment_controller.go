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

func EnsureNextBillGenerated(tenantID uint) error {
	var tenant models.Tenant
	if err := config.DB.Preload("Room").First(&tenant, tenantID).Error; err != nil {
		return err
	}

	var payments []models.Payment
	if err := config.DB.Where("tenant_id = ?", tenantID).Order("payment_date desc").Find(&payments).Error; err != nil {
		return err
	}

	// If no payments exist, create the first one on check-in date
	if len(payments) == 0 {
		amount := tenant.Room.Price
		if amount <= 0 {
			var bh models.BoardingHouse
			if err := config.DB.First(&bh, tenant.Room.BoardingHouseID).Error; err == nil {
				amount = bh.DefaultRoomPrice
			}
		}
		firstPayment := models.Payment{
			TenantID:    tenantID,
			Amount:      amount,
			PaymentDate: tenant.CheckInDate,
			Status:      "pending",
		}
		return config.DB.Create(&firstPayment).Error
	}

	// Get latest payment
	latest := payments[0]

	// If the latest is still pending, no need to create another pending bill
	if latest.Status == "pending" {
		return nil
	}

	// Latest is paid. Next due date is latest.PaymentDate + 1 month
	nextDueDate := latest.PaymentDate.AddDate(0, 1, 0)
	// New bill generation date is 10 days before nextDueDate
	genDate := nextDueDate.AddDate(0, 0, -10)

	// If today is at or after genDate, generate the next bill
	if time.Now().After(genDate) {
		amount := tenant.Room.Price
		if amount <= 0 {
			var bh models.BoardingHouse
			if err := config.DB.First(&bh, tenant.Room.BoardingHouseID).Error; err == nil {
				amount = bh.DefaultRoomPrice
			}
		}
		nextPayment := models.Payment{
			TenantID:    tenantID,
			Amount:      amount,
			PaymentDate: nextDueDate,
			Status:      "pending",
		}
		return config.DB.Create(&nextPayment).Error
	}

	return nil
}

func (ctrl *PaymentController) GetAllPayments(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "owner" {
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenant details"})
			return
		}
		if len(tenantIDs) == 0 {
			c.JSON(http.StatusOK, []models.Payment{})
			return
		}
		for _, tid := range tenantIDs {
			EnsureNextBillGenerated(tid)
		}
		var payments []models.Payment
		if err := config.DB.Preload("Tenant.User").Where("tenant_id IN ?", tenantIDs).Find(&payments).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
			return
		}
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
		if err := config.DB.Preload("Tenant.User").Where("tenant_id = ?", tenant.ID).Find(&payments).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
			return
		}
		c.JSON(http.StatusOK, payments)
		return
	}

	payments, err := ctrl.paymentRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
		return
	}
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

	if payment.Status != "pending" {
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

	payment.Status = "paid"
	payment.PaymentDate = time.Now()
	if err := ctrl.paymentRepo.Update(payment); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui status pembayaran"})
		return
	}

	c.JSON(http.StatusOK, payment)
}

// GetSnapToken generates a Midtrans Snap transaction token and redirect URL
func (ctrl *PaymentController) GetSnapToken(c *gin.Context) {
	paymentID, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	payment, err := ctrl.paymentRepo.FindByID(uint(paymentID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Payment not found"})
		return
	}

	if payment.Status != "pending" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Pembayaran ini sudah lunas atau diproses"})
		return
	}

	if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil || tenant.ID != payment.TenantID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
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

	// Build Snap Request body
	snapReq := map[string]interface{}{
		"transaction_details": map[string]interface{}{
			"order_id":     orderID,
			"gross_amount": payment.Amount,
		},
		"customer_details": map[string]interface{}{
			"first_name": tenant.User.Name,
			"email":      tenant.User.Email,
			"phone":      payment.Phone,
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
			payment.Status = "paid"
			payment.PaymentDate = time.Now()
			ctrl.paymentRepo.Update(payment)
		}
	} else if status == "expire" || status == "cancel" || status == "deny" {
		if payment.Status == "pending" {
			payment.Status = "cancelled"
			ctrl.paymentRepo.Update(payment)
		}
	}

	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

// CheckPaymentStatus queries Midtrans status API directly to verify the status
func (ctrl *PaymentController) CheckPaymentStatus(c *gin.Context) {
	orderID := c.Param("orderId") // e.g. RUMA-PAY-1-1628100101

	serverKey := os.Getenv("MIDTRANS_SERVER_KEY")
	if serverKey == "" {
		serverKey = "SB-Mid-server-Jw5gV97y0u-0H1x2z3Y4W5V6"
	}

	client := &http.Client{Timeout: 10 * time.Second}
	url := fmt.Sprintf("https://api.sandbox.midtrans.com/v2/%s/status", orderID)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create status request"})
		return
	}

	authHeader := "Basic " + base64.StdEncoding.EncodeToString([]byte(serverKey+":"))
	req.Header.Set("Authorization", authHeader)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to connect to Midtrans API"})
		return
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)
	var statusResp map[string]interface{}
	if err := json.Unmarshal(respBody, &statusResp); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse Midtrans status response"})
		return
	}

	status, _ := statusResp["transaction_status"].(string)

	parts := strings.Split(orderID, "-")
	if len(parts) >= 3 && parts[0] == "RUMA" && parts[1] == "PAY" {
		paymentIDVal, err := strconv.Atoi(parts[2])
		if err == nil {
			payment, err := ctrl.paymentRepo.FindByID(uint(paymentIDVal))
			if err == nil {
				if status == "settlement" || status == "capture" {
					if payment.Status != "paid" {
						payment.Status = "paid"
						payment.PaymentDate = time.Now()
						ctrl.paymentRepo.Update(payment)
					}
				} else if status == "expire" || status == "cancel" || status == "deny" {
					if payment.Status == "pending" {
						payment.Status = "cancelled"
						ctrl.paymentRepo.Update(payment)
					}
				}
			}
		}
	}

	c.JSON(http.StatusOK, statusResp)
}

