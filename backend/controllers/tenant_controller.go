package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
	"strconv"

	"github.com/gin-gonic/gin"
)

type TenantController struct {
	tenantRepo repositories.TenantRepository
}

func NewTenantController(tenantRepo repositories.TenantRepository) *TenantController {
	return &TenantController{tenantRepo: tenantRepo}
}

func (ctrl *TenantController) GetAllTenants(c *gin.Context) {
	tenants, err := ctrl.tenantRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenants"})
		return
	}
	c.JSON(http.StatusOK, tenants)
}

func (ctrl *TenantController) GetTenantByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	tenant, err := ctrl.tenantRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tenant not found"})
		return
	}
	c.JSON(http.StatusOK, tenant)
}

func (ctrl *TenantController) CreateTenant(c *gin.Context) {
	var tenant models.Tenant
	if err := c.ShouldBindJSON(&tenant); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := ctrl.tenantRepo.Create(&tenant); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create tenant"})
		return
	}
	c.JSON(http.StatusCreated, tenant)
}

func (ctrl *TenantController) UpdateTenant(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var tenant models.Tenant
	if err := c.ShouldBindJSON(&tenant); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	tenant.ID = uint(id)

	if err := ctrl.tenantRepo.Update(&tenant); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update tenant"})
		return
	}
	c.JSON(http.StatusOK, tenant)
}

func (ctrl *TenantController) DeleteTenant(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := ctrl.tenantRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete tenant"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Tenant deleted"})
}
