package repositories

import (
	"ruma/config"
	"ruma/models"

	"gorm.io/gorm"
)

type AnnouncementRepository interface {
	Create(announcement *models.Announcement) error
	FindByOwnerID(ownerID uint) ([]models.Announcement, error)
	FindByOwnerAndBoardingHouse(ownerID uint, boardingHouseID uint) ([]models.Announcement, error)
	FindForTenant(boardingHouseID uint, userID uint) ([]models.Announcement, error)
	FindAll() ([]models.Announcement, error)
	FindByID(id uint) (*models.Announcement, error)
	Delete(id uint) error
}

type announcementRepository struct{}

func NewAnnouncementRepository() AnnouncementRepository {
	return &announcementRepository{}
}

func preloadAnnouncementTargetUser(db *gorm.DB) *gorm.DB {
	return db.Select("id", "name", "email", "phone", "role")
}

func (r *announcementRepository) Create(announcement *models.Announcement) error {
	return config.DB.Create(announcement).Error
}

func (r *announcementRepository) FindByOwnerID(ownerID uint) ([]models.Announcement, error) {
	var announcements []models.Announcement
	err := config.DB.
		Preload("TargetUser", preloadAnnouncementTargetUser).
		Where("owner_id = ?", ownerID).
		Order("date desc").
		Find(&announcements).Error
	return announcements, err
}

func (r *announcementRepository) FindByOwnerAndBoardingHouse(ownerID uint, boardingHouseID uint) ([]models.Announcement, error) {
	var announcements []models.Announcement
	err := config.DB.
		Preload("TargetUser", preloadAnnouncementTargetUser).
		Where("owner_id = ? AND boarding_house_id = ?", ownerID, boardingHouseID).
		Order("date desc").
		Find(&announcements).Error
	return announcements, err
}

func (r *announcementRepository) FindForTenant(boardingHouseID uint, userID uint) ([]models.Announcement, error) {
	var announcements []models.Announcement
	err := config.DB.
		Where(
			`boarding_house_id = ? AND (
				(
					(target_type = ? OR target_type = ? OR target_type = '' OR target_type IS NULL)
					AND (target_user_id IS NULL OR target_user_id = 0)
				)
				OR target_user_id = ?
			)`,
			boardingHouseID,
			"boarding_house",
			"kos",
			userID,
		).
		Order("date desc").
		Find(&announcements).Error
	return announcements, err
}

func (r *announcementRepository) FindAll() ([]models.Announcement, error) {
	var announcements []models.Announcement
	err := config.DB.
		Preload("TargetUser", preloadAnnouncementTargetUser).
		Order("date desc").
		Find(&announcements).Error
	return announcements, err
}

func (r *announcementRepository) FindByID(id uint) (*models.Announcement, error) {
	var announcement models.Announcement
	err := config.DB.
		Preload("TargetUser", preloadAnnouncementTargetUser).
		First(&announcement, id).Error
	return &announcement, err
}

func (r *announcementRepository) Delete(id uint) error {
	return config.DB.Delete(&models.Announcement{}, id).Error
}
