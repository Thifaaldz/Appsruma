package controllers

import (
	"net/http"
	"ruma/config"
	"ruma/models"
	"ruma/services"
	"ruma/utils"
	"strconv"

	"github.com/gin-gonic/gin"
)

type AuthController struct {
	authService services.AuthService
}

type UpdateMeRequest struct {
	Name         string `json:"name"`
	Phone        string `json:"phone"`
	Gender       string `json:"gender"`
	BirthDate    string `json:"birth_date"`
	Address      string `json:"address"`
	ProfileImage string `json:"profile_image"`
}

func NewAuthController(authService services.AuthService) *AuthController {
	return &AuthController{authService: authService}
}

func (ctrl *AuthController) GetTenantUsers(c *gin.Context) {
	userID, _ := c.Get("user_id")
	role, _ := c.Get("role")

	var users []models.User

	if role == "owner" {
		var roomIDs []uint
		bhIDStr := c.Query("boarding_house_id")
		if bhIDStr != "" {
			bhID, err := strconv.Atoi(bhIDStr)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid boarding_house_id"})
				return
			}
			owns, verifyErr := utils.OwnerOwnsBoardingHouse(userID.(uint), uint(bhID))
			if verifyErr != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify boarding house"})
				return
			}
			if !owns {
				c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
				return
			}
			if err := config.DB.Model(&models.Room{}).
				Where("boarding_house_id = ?", uint(bhID)).
				Pluck("id", &roomIDs).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rooms"})
				return
			}
		} else {
			var err error
			roomIDs, err = utils.GetOwnerRoomIDs(userID.(uint))
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch rooms"})
				return
			}
		}

		if len(roomIDs) == 0 {
			c.JSON(http.StatusOK, []models.User{})
			return
		}

		var userIDs []uint
		if err := config.DB.Model(&models.Tenant{}).
			Where("room_id IN ?", roomIDs).
			Pluck("user_id", &userIDs).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch tenants"})
			return
		}
		if len(userIDs) == 0 {
			c.JSON(http.StatusOK, []models.User{})
			return
		}
		if err := config.DB.Where("role = ? AND id IN ?", "tenant", userIDs).Find(&users).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch users"})
			return
		}
	} else if role == "tenant" {
		if err := config.DB.Where("role = ? AND id = ?", "tenant", userID.(uint)).Find(&users).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch users"})
			return
		}
	} else {
		if err := config.DB.Where("role = ?", "tenant").Find(&users).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch users"})
			return
		}
	}

	for i := range users {
		users[i].Password = ""
	}
	c.JSON(http.StatusOK, users)
}

func (ctrl *AuthController) GetMe(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var user models.User
	if err := config.DB.First(&user, userID.(uint)).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	user.Password = ""
	c.JSON(http.StatusOK, user)
}

func (ctrl *AuthController) UpdateMe(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req UpdateMeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := config.DB.First(&user, userID.(uint)).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	if req.Name != "" {
		user.Name = req.Name
	}
	user.Phone = req.Phone
	user.Gender = req.Gender
	user.BirthDate = req.BirthDate
	user.Address = req.Address
	user.ProfileImage = req.ProfileImage

	if err := config.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal memperbarui profile"})
		return
	}

	user.Password = ""
	c.JSON(http.StatusOK, user)
}

func (ctrl *AuthController) Register(c *gin.Context) {
	var user models.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := ctrl.authService.Register(&user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to register user"})
		return
	}

	user.Password = ""
	c.JSON(http.StatusOK, gin.H{"message": "Registration successful", "user": user})
}

func (ctrl *AuthController) Login(c *gin.Context) {
	var loginData struct {
		Email    string `json:"email" binding:"required"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&loginData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	token, err := ctrl.authService.Login(loginData.Email, loginData.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := config.DB.Where("email = ?", loginData.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}
	user.Password = ""

	c.JSON(http.StatusOK, gin.H{"token": token, "user": user})
}
