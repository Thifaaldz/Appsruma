package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
	"strconv"
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
		Title   string `json:"title" binding:"required"`
		Content string `json:"content" binding:"required"`
		Date    string `json:"date"`
		Icon    string `json:"icon"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	date := time.Now()
	if input.Date != "" {
		parsed, err := time.Parse("2006-01-02", input.Date)
		if err == nil {
			date = parsed
		}
	}

	announcement := models.Announcement{
		OwnerID: userID.(uint),
		Title:   input.Title,
		Content: input.Content,
		Date:    date,
		Icon:    input.Icon,
	}

	if err := ctrl.announcementRepo.Create(&announcement); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pengumuman"})
		return
	}

	c.JSON(http.StatusCreated, announcement)
}

// GetAnnouncements returns announcements - for owner: only their own; for tenant: all
func (ctrl *AnnouncementController) GetAnnouncements(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var announcements []models.Announcement
	var err error

	if role == "owner" {
		announcements, err = ctrl.announcementRepo.FindByOwnerID(userID.(uint))
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

	if err := ctrl.announcementRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus pengumuman"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pengumuman berhasil dihapus"})
}
