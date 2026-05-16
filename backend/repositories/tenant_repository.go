package repositories

import (
	"ruma/config"
	"ruma/models"
)

type TenantRepository interface {
	Create(tenant *models.Tenant) error
	FindAll() ([]models.Tenant, error)
	FindByID(id uint) (*models.Tenant, error)
	Update(tenant *models.Tenant) error
	Delete(id uint) error
}

type tenantRepository struct{}

func NewTenantRepository() TenantRepository {
	return &tenantRepository{}
}

func (r *tenantRepository) Create(tenant *models.Tenant) error {
	return config.DB.Create(tenant).Error
}

func (r *tenantRepository) FindAll() ([]models.Tenant, error) {
	var tenants []models.Tenant
	err := config.DB.Preload("User").Preload("Room").Find(&tenants).Error
	return tenants, err
}

func (r *tenantRepository) FindByID(id uint) (*models.Tenant, error) {
	var tenant models.Tenant
	err := config.DB.Preload("User").Preload("Room").First(&tenant, id).Error
	return &tenant, err
}

func (r *tenantRepository) Update(tenant *models.Tenant) error {
	return config.DB.Save(tenant).Error
}

func (r *tenantRepository) Delete(id uint) error {
	return config.DB.Delete(&models.Tenant{}, id).Error
}
