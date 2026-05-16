package repositories

import (
	"ruma/config"
	"ruma/models"
)

type ComplaintRepository interface {
	Create(complaint *models.Complaint) error
	FindAll() ([]models.Complaint, error)
	FindByID(id uint) (*models.Complaint, error)
	Update(complaint *models.Complaint) error
	FindByTenantID(tenantID uint) ([]models.Complaint, error)
}

type complaintRepository struct{}

func NewComplaintRepository() ComplaintRepository {
	return &complaintRepository{}
}

func (r *complaintRepository) Create(complaint *models.Complaint) error {
	return config.DB.Create(complaint).Error
}

func (r *complaintRepository) FindAll() ([]models.Complaint, error) {
	var complaints []models.Complaint
	err := config.DB.Preload("Tenant.User").Find(&complaints).Error
	return complaints, err
}

func (r *complaintRepository) FindByID(id uint) (*models.Complaint, error) {
	var complaint models.Complaint
	err := config.DB.Preload("Tenant.User").First(&complaint, id).Error
	return &complaint, err
}

func (r *complaintRepository) Update(complaint *models.Complaint) error {
	return config.DB.Save(complaint).Error
}

func (r *complaintRepository) FindByTenantID(tenantID uint) ([]models.Complaint, error) {
	var complaints []models.Complaint
	err := config.DB.Where("tenant_id = ?", tenantID).Find(&complaints).Error
	return complaints, err
}
