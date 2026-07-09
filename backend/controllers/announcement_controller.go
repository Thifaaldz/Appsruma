package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
	"ruma/utils"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

type AnnouncementController struct {
	announcementRepo repositories.AnnouncementRepository
}

func NewAnnouncementController(repo repositories.AnnouncementRepository) *AnnouncementController {
	return &AnnouncementController{announcementRepo: repo}
}

func (ctrl *AnnouncementController) CreateAnnouncement(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var input struct {
		BoardingHouseID uint   `json:"boarding_house_id" binding:"required"`
		TargetType      string `json:"target_type"`
		TargetUserID    *uint  `json:"target_user_id"`
		Title           string `json:"title" binding:"required"`
		Content         string `json:"content" binding:"required"`
		Date            string `json:"date"`
		Icon            string `json:"icon"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	owns, err := utils.OwnerOwnsBoardingHouse(userID.(uint), input.BoardingHouseID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memverifikasi kos"})
		return
	}
	if !owns {
		c.JSON(http.StatusForbidden, gin.H{"error": "Kos tidak terdaftar pada akun Anda"})
		return
	}

	targetType := strings.ToLower(strings.TrimSpace(input.TargetType))
	if targetType == "" {
		if input.TargetUserID != nil && *input.TargetUserID != 0 {
			targetType = "user"
		} else {
			targetType = "boarding_house"
		}
	}
	if targetType != "boarding_house" && targetType != "user" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Target pengumuman tidak valid"})
		return
	}

	var targetUserID *uint
	if targetType == "user" {
		if input.TargetUserID == nil || *input.TargetUserID == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Pilih penghuni tujuan pengumuman"})
			return
		}
		validTenant, tenantErr := utils.UserIsTenantInBoardingHouse(*input.TargetUserID, input.BoardingHouseID)
		if tenantErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memverifikasi penghuni"})
			return
		}
		if !validTenant {
			c.JSON(http.StatusForbidden, gin.H{"error": "Penghuni tidak terdaftar di kos ini"})
			return
		}
		targetUserID = input.TargetUserID
	}

	date := time.Now()
	if input.Date != "" {
		parsed, err := time.Parse("2006-01-02", input.Date)
		if err == nil {
			date = parsed
		}
	}

	announcement := models.Announcement{
		OwnerID:         userID.(uint),
		BoardingHouseID: input.BoardingHouseID,
		TargetType:      targetType,
		TargetUserID:    targetUserID,
		Title:           input.Title,
		Content:         input.Content,
		Date:            date,
		Icon:            input.Icon,
	}

	if err := ctrl.announcementRepo.Create(&announcement); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pengumuman"})
		return
	}

	c.JSON(http.StatusCreated, announcement)
}

// GetAnnouncements returns announcements scoped to the active/owned boarding house.
func (ctrl *AnnouncementController) GetAnnouncements(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var announcements []models.Announcement
	var err error

	if role == "owner" {
		bhIDStr := c.Query("boarding_house_id")
		if bhIDStr != "" {
			bhID, convErr := strconv.Atoi(bhIDStr)
			if convErr != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid boarding_house_id"})
				return
			}
			owns, verifyErr := utils.OwnerOwnsBoardingHouse(userID.(uint), uint(bhID))
			if verifyErr != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memverifikasi kos"})
				return
			}
			if !owns {
				c.JSON(http.StatusForbidden, gin.H{"error": "Akses ditolak"})
				return
			}
			announcements, err = ctrl.announcementRepo.FindByOwnerAndBoardingHouse(userID.(uint), uint(bhID))
		} else {
			announcements, err = ctrl.announcementRepo.FindByOwnerID(userID.(uint))
		}
	} else if role == "tenant" {
		bhID, bhErr := utils.GetTenantBoardingHouseID(userID.(uint))
		if bhErr != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		announcements, err = ctrl.announcementRepo.FindForTenant(bhID, userID.(uint))
	} else {
		announcements, err = ctrl.announcementRepo.FindAll()
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data pengumuman"})
		return
	}

	c.JSON(http.StatusOK, announcements)
}

func (ctrl *AnnouncementController) DeleteAnnouncement(c *gin.Context) {
	userID, _ := c.Get("user_id")
	id, _ := strconv.Atoi(c.Param("id"))

	announcement, err := ctrl.announcementRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pengumuman tidak ditemukan"})
		return
	}

	if announcement.OwnerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Akses ditolak"})
		return
	}

	if bhIDStr := c.Query("boarding_house_id"); bhIDStr != "" {
		bhID, convErr := strconv.Atoi(bhIDStr)
		if convErr != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid boarding_house_id"})
			return
		}
		if announcement.BoardingHouseID != uint(bhID) {
			c.JSON(http.StatusForbidden, gin.H{"error": "Akses ditolak"})
			return
		}
	}

	if err := ctrl.announcementRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus pengumuman"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pengumuman berhasil dihapus"})
}
