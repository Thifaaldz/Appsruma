package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
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
	complaints, err := ctrl.complaintRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch complaints"})
		return
	}
	c.JSON(http.StatusOK, complaints)
}

func (ctrl *ComplaintController) CreateComplaint(c *gin.Context) {
	var complaint models.Complaint
	if err := c.ShouldBindJSON(&complaint); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := ctrl.complaintRepo.Create(&complaint); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create complaint"})
		return
	}
	c.JSON(http.StatusCreated, complaint)
}

func (ctrl *ComplaintController) UpdateComplaintStatus(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
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

	complaint.Status = statusData.Status
	if err := ctrl.complaintRepo.Update(complaint); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update complaint status"})
		return
	}

	c.JSON(http.StatusOK, complaint)
}
