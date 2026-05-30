package controllers

import (
	"net/http"
	"ruma/config"
	"ruma/models"
	"ruma/repositories"
	"ruma/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

type PaymentController struct {
	paymentRepo repositories.PaymentRepository
}

func NewPaymentController(paymentRepo repositories.PaymentRepository) *PaymentController {
	return &PaymentController{paymentRepo: paymentRepo}
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

	payments, err := ctrl.paymentRepo.FindByTenantID(uint(tenantID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenant payments"})
		return
	}
	c.JSON(http.StatusOK, payments)
}
