package controllers

import (
	"net/http"
	"ruma/config"
	"ruma/models"
	"ruma/repositories"
	"ruma/utils"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type TenantController struct {
	tenantRepo repositories.TenantRepository
}

type CreateTenantRequest struct {
	UserID       uint   `json:"user_id"`
	RoomID       uint   `json:"room_id" binding:"required"`
	Phone        string `json:"phone"`
	Gender       string `json:"gender"`
	CheckInDate  string `json:"check_in_date"`
	CheckOutDate string `json:"check_out_date"`

	// New User Fields
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

func NewTenantController(tenantRepo repositories.TenantRepository) *TenantController {
	return &TenantController{tenantRepo: tenantRepo}
}

func (ctrl *TenantController) GetAllTenants(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "owner" {
		roomIDs, err := utils.GetOwnerRoomIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch room details"})
			return
		}
		if len(roomIDs) == 0 {
			c.JSON(http.StatusOK, []models.Tenant{})
			return
		}
		var tenants []models.Tenant
		if err := config.DB.Preload("User").Preload("Room").Where("room_id IN ?", roomIDs).Find(&tenants).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenants"})
			return
		}
		c.JSON(http.StatusOK, tenants)
		return
	} else if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		config.DB.Preload("User").Preload("Room").First(tenant)
		c.JSON(http.StatusOK, []models.Tenant{*tenant})
		return
	}

	tenants, err := ctrl.tenantRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenants"})
		return
	}
	c.JSON(http.StatusOK, tenants)
}

func (ctrl *TenantController) GetTenantByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	tenant, err := ctrl.tenantRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tenant not found"})
		return
	}

	if role == "owner" {
		roomIDs, err := utils.GetOwnerRoomIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify room details"})
			return
		}
		allowed := false
		for _, rid := range roomIDs {
			if rid == tenant.RoomID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	} else if role == "tenant" {
		if tenant.UserID != userID.(uint) {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	c.JSON(http.StatusOK, tenant)
}

func (ctrl *TenantController) CreateTenant(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var req CreateTenantRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		println("CreateTenant ShouldBindJSON error:", err.Error())
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	println("CreateTenant request parsed successfully, UserID:", req.UserID, "RoomID:", req.RoomID, "Name:", req.Name, "Email:", req.Email)

	if role == "owner" {
		roomIDs, err := utils.GetOwnerRoomIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify room details"})
			return
		}
		allowed := false
		for _, rid := range roomIDs {
			if rid == req.RoomID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Room does not belong to your boarding house"})
			return
		}
	}

	var targetUserID uint = req.UserID

	// If no UserID provided, register a new Tenant User account first
	if targetUserID == 0 {
		if req.Email == "" || req.Name == "" || req.Password == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Mohon lengkapi data akun (Nama, Email, Password)"})
			return
		}

		// Check if email already exists
		var existingUser models.User
		if err := config.DB.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Email sudah terdaftar"})
			return
		}

		// Hash password
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memproses password"})
			return
		}

		newUser := models.User{
			Name:     req.Name,
			Email:    req.Email,
			Password: string(hashedPassword),
			Role:     "tenant",
		}

		if err := config.DB.Create(&newUser).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal membuat akun penyewa"})
			return
		}
		targetUserID = newUser.ID
	}

	checkIn := time.Now()
	if req.CheckInDate != "" {
		if parsed, err := time.Parse(time.RFC3339, req.CheckInDate); err == nil {
			checkIn = parsed
		} else if parsed, err := time.Parse("2006-01-02T15:04:05.000000", req.CheckInDate); err == nil {
			checkIn = parsed
		} else if parsed, err := time.Parse("2006-01-02T15:04:05.000", req.CheckInDate); err == nil {
			checkIn = parsed
		}
	}

	var checkOut time.Time
	if req.CheckOutDate != "" {
		if parsed, err := time.Parse(time.RFC3339, req.CheckOutDate); err == nil {
			checkOut = parsed
		} else if parsed, err := time.Parse("2006-01-02T15:04:05.000000", req.CheckOutDate); err == nil {
			checkOut = parsed
		} else if parsed, err := time.Parse("2006-01-02T15:04:05.000", req.CheckOutDate); err == nil {
			checkOut = parsed
		}
	}

	// Set billing day from check-in date (tanggal tagihan bulanan)
	billingDay := checkIn.Day()
	if billingDay > 28 {
		billingDay = 28
	}

	tenant := models.Tenant{
		UserID:       targetUserID,
		RoomID:       req.RoomID,
		Phone:        req.Phone,
		Gender:       req.Gender,
		BillingDay:   billingDay,
		CheckInDate:  checkIn,
		CheckOutDate: checkOut,
	}

	if err := ctrl.tenantRepo.Create(&tenant); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan data penghuni"})
		return
	}

	// Automatically mark the Room as occupied
	config.DB.Model(&models.Room{}).Where("id = ?", req.RoomID).Update("status", "occupied")

	// Create first pending bill (NOT paid) - tenant must pay via Midtrans
	// Load room data for price calculation
	config.DB.Preload("Room").First(&tenant, tenant.ID)
	CreateFirstBill(&tenant)

	c.JSON(http.StatusCreated, tenant)
}

func (ctrl *TenantController) UpdateTenant(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	existingTenant, err := ctrl.tenantRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tenant not found"})
		return
	}

	if role == "owner" {
		roomIDs, err := utils.GetOwnerRoomIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify room details"})
			return
		}
		allowed := false
		for _, rid := range roomIDs {
			if rid == existingTenant.RoomID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	var tenant models.Tenant
	if err := c.ShouldBindJSON(&tenant); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	tenant.ID = uint(id)

	if role == "owner" {
		roomIDs, err := utils.GetOwnerRoomIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify room details"})
			return
		}
		allowed := false
		for _, rid := range roomIDs {
			if rid == tenant.RoomID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Room does not belong to your boarding house"})
			return
		}
	}

	if err := ctrl.tenantRepo.Update(&tenant); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update tenant"})
		return
	}
	c.JSON(http.StatusOK, tenant)
}

func (ctrl *TenantController) DeleteTenant(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	existingTenant, err := ctrl.tenantRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Tenant not found"})
		return
	}

	if role == "owner" {
		roomIDs, err := utils.GetOwnerRoomIDs(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify room details"})
			return
		}
		allowed := false
		for _, rid := range roomIDs {
			if rid == existingTenant.RoomID {
				allowed = true
				break
			}
		}
		if !allowed {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	if err := ctrl.tenantRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete tenant"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Tenant deleted"})
}
