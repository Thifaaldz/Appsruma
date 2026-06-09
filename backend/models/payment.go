package models

import (
	"time"

	"gorm.io/gorm"
)

type Payment struct {
	ID              uint           `gorm:"primaryKey" json:"id"`
	TenantID        uint           `json:"tenant_id"`
	Tenant          Tenant         `gorm:"foreignKey:TenantID" json:"tenant"`
	Amount          float64        `json:"amount"`
	DueDate         time.Time      `json:"due_date"`         // Tanggal jatuh tempo
	OverdueDate     time.Time      `json:"overdue_date"`     // Max overdue (DueDate + 10 hari)
	BillingPeriod   string         `gorm:"size:50" json:"billing_period"` // e.g. "Juni 2026"
	Status          string         `gorm:"size:20" json:"status"`  // pending, paid, overdue, cancelled
	MidtransOrderID string         `gorm:"size:100" json:"midtrans_order_id"`
	PaidAt          *time.Time     `json:"paid_at"`          // Waktu pembayaran dikonfirmasi Midtrans
	PaymentDate     time.Time      `json:"payment_date"`     // Legacy: kept for backward compat
	Phone           string         `gorm:"-" json:"phone,omitempty"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`
}
