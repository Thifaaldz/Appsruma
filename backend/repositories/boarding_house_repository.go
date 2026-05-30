package repositories

import (
	"ruma/config"
	"ruma/models"
)

type BoardingHouseRepository interface {
	Create(bh *models.BoardingHouse) error
	FindAll() ([]models.BoardingHouse, error)
	FindByOwnerID(ownerID uint) ([]models.BoardingHouse, error)
	FindByID(id uint) (*models.BoardingHouse, error)
	Update(bh *models.BoardingHouse) error
	Delete(id uint) error
}

type boardingHouseRepository struct{}

func NewBoardingHouseRepository() BoardingHouseRepository {
	return &boardingHouseRepository{}
}

func (r *boardingHouseRepository) Create(bh *models.BoardingHouse) error {
	return config.DB.Create(bh).Error
}

func (r *boardingHouseRepository) FindAll() ([]models.BoardingHouse, error) {
	var bhs []models.BoardingHouse
	err := config.DB.Preload("Rooms").Find(&bhs).Error
	return bhs, err
}

func (r *boardingHouseRepository) FindByOwnerID(ownerID uint) ([]models.BoardingHouse, error) {
	var bhs []models.BoardingHouse
	err := config.DB.Preload("Rooms").Where("owner_id = ?", ownerID).Find(&bhs).Error
	return bhs, err
}

func (r *boardingHouseRepository) FindByID(id uint) (*models.BoardingHouse, error) {
	var bh models.BoardingHouse
	err := config.DB.Preload("Rooms").First(&bh, id).Error
	return &bh, err
}

func (r *boardingHouseRepository) Update(bh *models.BoardingHouse) error {
	return config.DB.Save(bh).Error
}

func (r *boardingHouseRepository) Delete(id uint) error {
	return config.DB.Delete(&models.BoardingHouse{}, id).Error
}
