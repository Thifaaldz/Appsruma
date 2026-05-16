package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
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
	rooms, err := ctrl.roomRepo.FindAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rooms"})
		return
	}
	c.JSON(http.StatusOK, rooms)
}

func (ctrl *RoomController) GetRoomByID(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	room, err := ctrl.roomRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Room not found"})
		return
	}
	c.JSON(http.StatusOK, room)
}

func (ctrl *RoomController) CreateRoom(c *gin.Context) {
	var room models.Room
	if err := c.ShouldBindJSON(&room); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := ctrl.roomRepo.Create(&room); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create room"})
		return
	}
	c.JSON(http.StatusCreated, room)
}

func (ctrl *RoomController) UpdateRoom(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	var room models.Room
	if err := c.ShouldBindJSON(&room); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	room.ID = uint(id)

	if err := ctrl.roomRepo.Update(&room); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update room"})
		return
	}
	c.JSON(http.StatusOK, room)
}

func (ctrl *RoomController) DeleteRoom(c *gin.Context) {
	id, _ := strconv.Atoi(c.Param("id"))
	if err := ctrl.roomRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete room"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Room deleted"})
}
