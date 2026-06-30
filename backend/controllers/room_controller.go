package controllers

import (
	"net/http"
	"ruma/config"
	"ruma/models"
	"ruma/repositories"
	"ruma/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

type RoomController struct {
	roomRepo repositories.RoomRepository
}

func NewRoomController(roomRepo repositories.RoomRepository) *RoomController {
	return &RoomController{roomRepo: roomRepo}
}

func (ctrl *RoomController) GetAllRooms(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	if role == "owner" {
		// Optional filter: ?boarding_house_id=X
		bhIDStr := c.Query("boarding_house_id")

		var bhIDs []uint
		if bhIDStr != "" {
			// Filter by specific boarding house — verify ownership first
			bhID, err := strconv.Atoi(bhIDStr)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid boarding_house_id"})
				return
			}
			var count int64
			config.DB.Model(&models.BoardingHouse{}).Where("id = ? AND owner_id = ?", uint(bhID), userID.(uint)).Count(&count)
			if count == 0 {
				c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
				return
			}
			bhIDs = []uint{uint(bhID)}
		} else {
			// Ensure they have at least one boarding house (default)
			_, err := utils.GetOrCreateDefaultBoardingHouse(userID.(uint))
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify boarding house"})
				return
			}
			if err := config.DB.Model(&models.BoardingHouse{}).Where("owner_id = ?", userID.(uint)).Pluck("id", &bhIDs).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch boarding houses"})
				return
			}
		}

		var rooms []models.Room
		if len(bhIDs) > 0 {
			if err := config.DB.Where("boarding_house_id IN ?", bhIDs).Find(&rooms).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rooms"})
				return
			}
		} else {
			rooms = []models.Room{}
		}
		c.JSON(http.StatusOK, rooms)
		return
	} else if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Tenant record not found"})
			return
		}
		var rooms []models.Room
		var tenantRoom models.Room
		if err := config.DB.First(&tenantRoom, tenant.RoomID).Error; err == nil {
			config.DB.Where("boarding_house_id = ?", tenantRoom.BoardingHouseID).Find(&rooms)
		}
		if len(rooms) == 0 {
			rooms = append(rooms, tenantRoom)
		}
		c.JSON(http.StatusOK, rooms)
		return
	}

	// Fallback/Admin
	rooms, err := ctrl.roomRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rooms"})
		return
	}
	c.JSON(http.StatusOK, rooms)
}

func (ctrl *RoomController) GetRoomByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	room, err := ctrl.roomRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
		return
	}

	if role == "owner" {
		var count int64
		config.DB.Model(&models.BoardingHouse{}).Where("id = ? AND owner_id = ?", room.BoardingHouseID, userID.(uint)).Count(&count)
		if count == 0 {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	} else if role == "tenant" {
		tenant, err := utils.GetTenantByUserID(userID.(uint))
		if err != nil {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
		var tenantRoom models.Room
		if err := config.DB.First(&tenantRoom, tenant.RoomID).Error; err == nil {
			if tenantRoom.BoardingHouseID != room.BoardingHouseID {
				c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
				return
			}
		} else {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	c.JSON(http.StatusOK, room)
}

func (ctrl *RoomController) CreateRoom(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var room models.Room
	if err := c.ShouldBindJSON(&room); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if role == "owner" {
		// Verify boarding house belongs to this owner
		var bh models.BoardingHouse
		err := config.DB.Where("id = ? AND owner_id = ?", room.BoardingHouseID, userID.(uint)).First(&bh).Error
		if err != nil {
			// Fallback to their default boarding house
			bhID, err := utils.GetOrCreateDefaultBoardingHouse(userID.(uint))
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify boarding house"})
				return
			}
			room.BoardingHouseID = bhID
			if err := config.DB.First(&bh, bhID).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to load default boarding house"})
				return
			}
		}
		if room.UseDefaultPrice {
			room.Price = bh.DefaultRoomPrice
		}
	}

	if err := ctrl.roomRepo.Create(&room); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create room"})
		return
	}
	c.JSON(http.StatusCreated, room)
}

func (ctrl *RoomController) UpdateRoom(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	existingRoom, err := ctrl.roomRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
		return
	}

	if role == "owner" {
		var count int64
		config.DB.Model(&models.BoardingHouse{}).Where("id = ? AND owner_id = ?", existingRoom.BoardingHouseID, userID.(uint)).Count(&count)
		if count == 0 {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	var room models.Room
	if err := c.ShouldBindJSON(&room); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	room.ID = uint(id)

	if role == "owner" {
		var bh models.BoardingHouse
		if err := config.DB.Where("id = ? AND owner_id = ?", room.BoardingHouseID, userID.(uint)).First(&bh).Error; err != nil {
			c.JSON(http.StatusForbidden, gin.H{"error": "Selected boarding house access denied"})
			return
		}
		if room.UseDefaultPrice {
			room.Price = bh.DefaultRoomPrice
		}
	}

	if err := config.DB.Model(&models.Room{}).
		Where("id = ?", uint(id)).
		Updates(map[string]interface{}{
			"boarding_house_id": room.BoardingHouseID,
			"room_number":       room.RoomNumber,
			"price":             room.Price,
			"status":            room.Status,
			"use_default_price": room.UseDefaultPrice,
			"image_urls":        room.ImageUrls,
		}).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update room"})
		return
	}
	c.JSON(http.StatusOK, room)
}

func (ctrl *RoomController) DeleteRoom(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	existingRoom, err := ctrl.roomRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
		return
	}

	if role == "owner" {
		var count int64
		config.DB.Model(&models.BoardingHouse{}).Where("id = ? AND owner_id = ?", existingRoom.BoardingHouseID, userID.(uint)).Count(&count)
		if count == 0 {
			c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
			return
		}
	}

	if err := ctrl.roomRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete room"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Room deleted"})
}
