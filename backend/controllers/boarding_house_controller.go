package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
	"strconv"

	"github.com/gin-gonic/gin"
)

type BoardingHouseController struct {
	bhRepo repositories.BoardingHouseRepository
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

	var bh models.BoardingHouse
	if err := c.ShouldBindJSON(&bh); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	bh.OwnerID = userID.(uint)

	if err := ctrl.bhRepo.Create(&bh); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create boarding house"})
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

	var bh models.BoardingHouse
	if err := c.ShouldBindJSON(&bh); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	bh.ID = uint(id)
	bh.OwnerID = userID.(uint)

	if err := ctrl.bhRepo.Update(&bh); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update boarding house"})
		return
	}
	c.JSON(http.StatusOK, bh)
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
