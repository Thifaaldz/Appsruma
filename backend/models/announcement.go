package models

import (
	"time"

	"gorm.io/gorm"
)

type Announcement struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	OwnerID   uint           `json:"owner_id"`
	Owner     User           `gorm:"foreignKey:OwnerID" json:"owner,omitempty"`
	Title     string         `gorm:"size:100" json:"title"`
	Content   string         `gorm:"type:text" json:"content"`
	Date      time.Time      `json:"date"`
	Icon      string         `gorm:"size:50" json:"icon"` // water, electric, repair, info
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
