package models

import (
	"time"

	"gorm.io/gorm"
)

type Announcement struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	OwnerID         uint           `json:"owner_id"`
	Owner           User           `gorm:"foreignKey:OwnerID" json:"owner,omitempty"`
	BoardingHouseID uint           `json:"boarding_house_id"`
	BoardingHouse   BoardingHouse  `gorm:"foreignKey:BoardingHouseID" json:"boarding_house,omitempty"`
	TargetType      string         `gorm:"size:20;default:boarding_house" json:"target_type"` // boarding_house, user
	TargetUserID    *uint          `json:"target_user_id"`
	TargetUser      *User          `gorm:"foreignKey:TargetUserID" json:"target_user,omitempty"`
	Title           string         `gorm:"size:100" json:"title"`
	Content         string         `gorm:"type:text" json:"content"`
	Date            time.Time      `json:"date"`
	Icon            string         `gorm:"size:50" json:"icon"` // water, electric, repair, info
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}
