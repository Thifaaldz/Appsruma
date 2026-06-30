package models

import (
	"time"

	"gorm.io/gorm"
)

type Expense struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	OwnerID         uint           `json:"owner_id"`
	Owner           User           `gorm:"foreignKey:OwnerID" json:"owner,omitempty"`
	BoardingHouseID uint           `json:"boarding_house_id"`
	Title           string         `gorm:"size:100" json:"title"`
	Amount          float64        `json:"amount"`
	Category        string         `gorm:"size:50" json:"category"` // Makanan & Minuman, Transport, Tagihan, dll
	Date            time.Time      `json:"date"`
	Note            string         `gorm:"type:text" json:"note"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}
