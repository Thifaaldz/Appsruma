package models

import (
	"time"

	"gorm.io/gorm"
)

type Tenant struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	UserID       uint           `json:"user_id"`
	User         User           `gorm:"foreignKey:UserID" json:"user"`
	RoomID       uint           `json:"room_id"`
	Room         Room           `gorm:"foreignKey:RoomID" json:"room"`
	Phone        string         `gorm:"size:20" json:"phone"`
	Gender       string         `gorm:"size:10" json:"gender"`
	BillingDay   int            `json:"billing_day"` // Tanggal tagihan bulanan (1-28)
	CheckInDate  time.Time      `json:"check_in_date"`
	CheckOutDate time.Time      `json:"check_out_date"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}
