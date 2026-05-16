package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
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
	payments, err := ctrl.paymentRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch payments"})
		return
	}
	c.JSON(http.StatusOK, payments)
}

func (ctrl *PaymentController) CreatePayment(c *gin.Context) {
	var payment models.Payment
	if err := c.ShouldBindJSON(&payment); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := ctrl.paymentRepo.Create(&payment); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create payment"})
		return
	}
	c.JSON(http.StatusCreated, payment)
}

func (ctrl *PaymentController) GetTenantPayments(c *gin.Context) {
	tenantID, _ := strconv.Atoi(c.Param("tenantId"))
	payments, err := ctrl.paymentRepo.FindByTenantID(uint(tenantID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenant payments"})
		return
	}
	c.JSON(http.StatusOK, payments)
}
