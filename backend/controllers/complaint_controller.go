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

type ComplaintController struct {
	complaintRepo repositories.ComplaintRepository
}

func NewComplaintController(complaintRepo repositories.ComplaintRepository) *ComplaintController {
	return &ComplaintController{complaintRepo: complaintRepo}
}

func (ctrl *ComplaintController) GetAllComplaints(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "owner" {
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenant details"})
			return
		}
		if len(tenantIDs) == 0 {
			c.JSON(http.StatusOK, []models.Complaint{})
			return
		}
		var complaints []models.Complaint
		if err := config.DB.Preload("Tenant.User").Where("tenant_id IN ?", tenantIDs).Find(&complaints).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch complaints"})
			return
		}
		c.JSON(http.StatusOK, complaints)
		return
	} else if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		var complaints []models.Complaint
		if err := config.DB.Preload("Tenant.User").Where("tenant_id = ?", tenant.ID).Find(&complaints).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch complaints"})
			return
		}
		c.JSON(http.StatusOK, complaints)
		return
	}

	complaints, err := ctrl.complaintRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch complaints"})
		return
	}
	c.JSON(http.StatusOK, complaints)
}

func (ctrl *ComplaintController) CreateComplaint(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var complaint models.Complaint
	if err := c.ShouldBindJSON(&complaint); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		complaint.TenantID = tenant.ID
	}

	if err := ctrl.complaintRepo.Create(&complaint); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create complaint"})
		return
	}
	c.JSON(http.StatusCreated, complaint)
}

func (ctrl *ComplaintController) UpdateComplaintStatus(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var statusData struct {
		Status string `json:"status" binding:"required"`
	}

	if err := c.ShouldBindJSON(&statusData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	complaint, err := ctrl.complaintRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Complaint not found"})
		return
	}

	if role == "owner" {
		tenantIDs, err := utils.GetOwnerTenantIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify tenant details"})
			return
		}
		allowed := false
		for _, tid := range tenantIDs {
			if tid == complaint.TenantID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	} else if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil || complaint.TenantID != tenant.ID {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	complaint.Status = statusData.Status
	if err := ctrl.complaintRepo.Update(complaint); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update complaint status"})
		return
	}

	c.JSON(http.StatusOK, complaint)
}
