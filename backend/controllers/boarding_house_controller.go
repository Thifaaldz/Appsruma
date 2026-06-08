package controllers

import (
	"log"
	"net/http"
	"ruma/config"
	"ruma/models"
	"ruma/repositories"
	"ruma/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

type BoardingHouseController struct {
	bhRepo repositories.BoardingHouseRepository
}

type BoardingHouseUpdateRequest struct {
	Name                string   `json:"name"`
	Address             string   `json:"address"`
	ImageUrl            string   `json:"image_url"`
	ImageUrls           []string `json:"image_urls"`
	DefaultRoomPrice    float64  `json:"default_room_price"`
	DefaultRoomPriceAlt float64  `json:"defaultRoomPrice"`
}

func NewBoardingHouseController(bhRepo repositories.BoardingHouseRepository) *BoardingHouseController {
	return &BoardingHouseController{bhRepo: bhRepo}
}

func (ctrl *BoardingHouseController) GetMyBoardingHouses(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "owner" {
		bhs, err := ctrl.bhRepo.FindByOwnerID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch boarding houses"})
			return
		}
		c.JSON(http.StatusOK, bhs)
		return
	} else if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusOK, []models.BoardingHouse{})
			return
		}
		var room models.Room
		if err := config.DB.First(&room, tenant.RoomID).Error; err != nil {
			c.JSON(http.StatusOK, []models.BoardingHouse{})
			return
		}
		bh, err := ctrl.bhRepo.FindByID(room.BoardingHouseID)
		if err != nil {
			c.JSON(http.StatusOK, []models.BoardingHouse{})
			return
		}
		c.JSON(http.StatusOK, []models.BoardingHouse{*bh})
		return
	}

	// Admin/superadmin sees all
	bhs, err := ctrl.bhRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch boarding houses"})
		return
	}
	c.JSON(http.StatusOK, bhs)
}

func (ctrl *BoardingHouseController) GetBoardingHouseByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	bh, err := ctrl.bhRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Boarding house not found"})
		return
	}

	if role == "owner" && bh.OwnerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	c.JSON(http.StatusOK, bh)
}

func (ctrl *BoardingHouseController) CreateBoardingHouse(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req BoardingHouseUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		log.Printf("CreateBoardingHouse bind error: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.Name == "" || req.Address == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Nama kos dan alamat wajib diisi"})
		return
	}

	price := req.DefaultRoomPrice
	if price <= 0 {
		price = req.DefaultRoomPriceAlt
	}
	if price <= 0 {
		price = 1500000
	}
	log.Printf(
		"CreateBoardingHouse owner_id=%d name=%q default_room_price=%.0f image_count=%d",
		userID.(uint),
		req.Name,
		price,
		len(req.ImageUrls),
	)

	bh := models.BoardingHouse{
		OwnerID:          userID.(uint),
		Name:             req.Name,
		Address:          req.Address,
		ImageUrl:         req.ImageUrl,
		ImageUrls:        models.StringList(req.ImageUrls),
		DefaultRoomPrice: price,
	}
	if bh.ImageUrl == "" && len(bh.ImageUrls) > 0 {
		bh.ImageUrl = bh.ImageUrls[0]
	}

	if bh.DefaultRoomPrice <= 0 {
		bh.DefaultRoomPrice = 1500000
	}

	if err := ctrl.bhRepo.Create(&bh); err != nil {
		log.Printf("CreateBoardingHouse database error: %v", err)
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error":  "Failed to create boarding house",
				"detail": err.Error(),
			},
		)
		return
	}
	c.JSON(http.StatusCreated, bh)
}

func (ctrl *BoardingHouseController) UpdateBoardingHouse(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	existing, err := ctrl.bhRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Boarding house not found"})
		return
	}

	if role == "owner" && existing.OwnerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	var req BoardingHouseUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updated := *existing
	if req.Name != "" {
		updated.Name = req.Name
	}
	if req.Address != "" {
		updated.Address = req.Address
	}
	if req.ImageUrl != "" {
		updated.ImageUrl = req.ImageUrl
	}
	if len(req.ImageUrls) > 0 {
		updated.ImageUrls = models.StringList(req.ImageUrls)
	}
	price := req.DefaultRoomPrice
	if price <= 0 {
		price = req.DefaultRoomPriceAlt
	}
	if price > 0 {
		updated.DefaultRoomPrice = price
	}
	log.Printf(
		"UpdateBoardingHouse id=%d owner_id=%d payload_price=%.0f payload_price_alt=%.0f old_price=%.0f new_price=%.0f",
		id,
		userID.(uint),
		req.DefaultRoomPrice,
		req.DefaultRoomPriceAlt,
		existing.DefaultRoomPrice,
		updated.DefaultRoomPrice,
	)
	if updated.DefaultRoomPrice <= 0 {
		updated.DefaultRoomPrice = 1500000
	}
	if updated.ImageUrl == "" && len(updated.ImageUrls) > 0 {
		updated.ImageUrl = updated.ImageUrls[0]
	}

	updateData := map[string]interface{}{
		"name":               updated.Name,
		"address":            updated.Address,
		"image_url":          updated.ImageUrl,
		"image_urls":         updated.ImageUrls,
		"default_room_price": updated.DefaultRoomPrice,
	}

	tx := config.DB.Model(&models.BoardingHouse{}).
		Where("id = ?", uint(id)).
		Updates(updateData)
	if tx.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update boarding house"})
		return
	}
	log.Printf("UpdateBoardingHouse id=%d rows_affected=%d", id, tx.RowsAffected)

	if existing.DefaultRoomPrice != updated.DefaultRoomPrice {
		roomTx := config.DB.Model(&models.Room{}).
			Where("boarding_house_id = ?", uint(id)).
			Updates(map[string]interface{}{
				"price":             updated.DefaultRoomPrice,
				"use_default_price": true,
			})
		if roomTx.Error != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update default room prices"})
			return
		}
		log.Printf(
			"UpdateBoardingHouse id=%d updated_room_prices=%d",
			id,
			roomTx.RowsAffected,
		)
	}

	if fresh, err := ctrl.bhRepo.FindByID(uint(id)); err == nil {
		fresh.OwnerID = userID.(uint)
		log.Printf(
			"UpdateBoardingHouse id=%d fresh_default_room_price=%.0f",
			id,
			fresh.DefaultRoomPrice,
		)
		c.JSON(http.StatusOK, fresh)
		return
	}

	updated.ID = uint(id)
	updated.OwnerID = userID.(uint)
	c.JSON(http.StatusOK, updated)
}

func (ctrl *BoardingHouseController) DeleteBoardingHouse(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	existing, err := ctrl.bhRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Boarding house not found"})
		return
	}

	if role == "owner" && existing.OwnerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	if err := ctrl.bhRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete boarding house"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Boarding house deleted"})
}
