package repositories

import (
	"ruma/config"
	"ruma/models"
)

type PaymentRepository interface {
	Create(payment *models.Payment) error
	FindAll() ([]models.Payment, error)
	FindByID(id uint) (*models.Payment, error)
	Update(payment *models.Payment) error
	FindByTenantID(tenantID uint) ([]models.Payment, error)
}

type paymentRepository struct{}

func NewPaymentRepository() PaymentRepository {
	return &paymentRepository{}
}

func (r *paymentRepository) Create(payment *models.Payment) error {
	return config.DB.Create(payment).Error
}

func (r *paymentRepository) FindAll() ([]models.Payment, error) {
	var payments []models.Payment
	err := config.DB.Preload("Tenant.User").Find(&payments).Error
	return payments, err
}

func (r *paymentRepository) FindByID(id uint) (*models.Payment, error) {
	var payment models.Payment
	err := config.DB.Preload("Tenant.User").First(&payment, id).Error
	return &payment, err
}

func (r *paymentRepository) Update(payment *models.Payment) error {
	return config.DB.Save(payment).Error
}

func (r *paymentRepository) FindByTenantID(tenantID uint) ([]models.Payment, error) {
	var payments []models.Payment
	err := config.DB.Where("tenant_id = ?", tenantID).Find(&payments).Error
	return payments, err
}
