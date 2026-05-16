package models

import (
	"time"

	"gorm.io/gorm"
)

type Payment struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	TenantID    uint           `json:"tenant_id"`
	Tenant      Tenant         `gorm:"foreignKey:TenantID" json:"tenant"`
	Amount      float64        `json:"amount"`
	PaymentDate time.Time      `json:"payment_date"`
	Status      string         `gorm:"size:20" json:"status"` // pending, paid, cancelled
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}
