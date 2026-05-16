package models

import (
	"time"

	"gorm.io/gorm"
)

type Tenant struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	UserID      uint           `json:"user_id"`
	User        User           `gorm:"foreignKey:UserID" json:"user"`
	RoomID      uint           `json:"room_id"`
	Room        Room           `gorm:"foreignKey:RoomID" json:"room"`
	Phone       string         `gorm:"size:20" json:"phone"`
	CheckInDate time.Time      `json:"check_in_date"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}
