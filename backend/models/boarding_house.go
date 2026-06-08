package models

import (
	"time"

	"gorm.io/gorm"
)

type BoardingHouse struct {
	ID               uint           `gorm:"primaryKey" json:"id"`
	OwnerID          uint           `json:"owner_id"`
	Owner            User           `gorm:"foreignKey:OwnerID" json:"owner"`
	Name             string         `gorm:"size:100" json:"name"`
	Address          string         `gorm:"type:text" json:"address"`
	ImageUrl         string         `gorm:"type:text" json:"image_url"`
	ImageUrls        StringList     `gorm:"type:text" json:"image_urls"`
	DefaultRoomPrice float64        `json:"default_room_price"`
	Rooms            []Room         `json:"rooms"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
	DeletedAt        gorm.DeletedAt `gorm:"index" json:"-"`
}
