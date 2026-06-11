package models

import (
	"time"

	"gorm.io/gorm"
)

type Room struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	BoardingHouseID uint           `json:"boarding_house_id"`
	BoardingHouse   BoardingHouse  `gorm:"foreignKey:BoardingHouseID" json:"boarding_house"`
	RoomNumber      string         `gorm:"size:20" json:"room_number"`
	Price           float64        `json:"price"`
	Status          string         `gorm:"size:20" json:"status"` // available, occupied, maintenance
	UseDefaultPrice bool           `json:"use_default_price"`
	ImageUrls       StringList     `gorm:"type:text" json:"image_urls"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}
