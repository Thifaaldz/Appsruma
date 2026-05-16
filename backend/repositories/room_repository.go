package repositories

import (
	"ruma/config"
	"ruma/models"
)

type RoomRepository interface {
	Create(room *models.Room) error
	FindAll() ([]models.Room, error)
	FindByID(id uint) (*models.Room, error)
	Update(room *models.Room) error
	Delete(id uint) error
}

type roomRepository struct{}

func NewRoomRepository() RoomRepository {
	return &roomRepository{}
}

func (r *roomRepository) Create(room *models.Room) error {
	return config.DB.Create(room).Error
}

func (r *roomRepository) FindAll() ([]models.Room, error) {
	var rooms []models.Room
	err := config.DB.Find(&rooms).Error
	return rooms, err
}

func (r *roomRepository) FindByID(id uint) (*models.Room, error) {
	var room models.Room
	err := config.DB.First(&room, id).Error
	return &room, err
}

func (r *roomRepository) Update(room *models.Room) error {
	return config.DB.Save(room).Error
}

func (r *roomRepository) Delete(id uint) error {
	return config.DB.Delete(&models.Room{}, id).Error
}
