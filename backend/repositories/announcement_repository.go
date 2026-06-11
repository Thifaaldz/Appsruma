package repositories

import (
	"ruma/config"
	"ruma/models"
)

type AnnouncementRepository interface {
	Create(announcement *models.Announcement) error
	FindByOwnerID(ownerID uint) ([]models.Announcement, error)
	FindAll() ([]models.Announcement, error)
	FindByID(id uint) (*models.Announcement, error)
	Delete(id uint) error
}

type announcementRepository struct{}

func NewAnnouncementRepository() AnnouncementRepository {
	return &announcementRepository{}
}

func (r *announcementRepository) Create(announcement *models.Announcement) error {
	return config.DB.Create(announcement).Error
}

func (r *announcementRepository) FindByOwnerID(ownerID uint) ([]models.Announcement, error) {
	var announcements []models.Announcement
	err := config.DB.Where("owner_id = ?", ownerID).Order("date desc").Find(&announcements).Error
	return announcements, err
}

func (r *announcementRepository) FindAll() ([]models.Announcement, error) {
	var announcements []models.Announcement
	err := config.DB.Order("date desc").Find(&announcements).Error
	return announcements, err
}

func (r *announcementRepository) FindByID(id uint) (*models.Announcement, error) {
	var announcement models.Announcement
	err := config.DB.First(&announcement, id).Error
	return &announcement, err
}

func (r *announcementRepository) Delete(id uint) error {
	return config.DB.Delete(&models.Announcement{}, id).Error
}
