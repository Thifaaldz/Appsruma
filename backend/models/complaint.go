package models

import (
	"time"

	"gorm.io/gorm"
)

type Complaint struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	TenantID    uint           `json:"tenant_id"`
	Tenant      Tenant         `gorm:"foreignKey:TenantID" json:"tenant"`
	Title       string         `gorm:"size:100" json:"title"`
	Description string         `gorm:"type:text" json:"description"`
	Status      string         `gorm:"size:20" json:"status"` // pending, in_progress, resolved
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}
