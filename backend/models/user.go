package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	Name      string         `gorm:"size:100" json:"name"`
	Email     string         `gorm:"unique;size:100" json:"email"`
	Password  string         `json:"password"`
	Role      string         `gorm:"size:20" json:"role"` // superadmin, owner, admin, tenant
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}
