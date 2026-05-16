package main

import (
	"fmt"
	"os"
	"ruma/config"
	"ruma/models"
	"ruma/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	// Initialize database
	config.ConnectDatabase()

	// Auto migration
	err := config.DB.AutoMigrate(
		&models.User{},
		&models.BoardingHouse{},
		&models.Room{},
		&models.Tenant{},
		&models.Payment{},
		&models.Complaint{},
	)
	if err != nil {
		fmt.Println("Migration failed:", err)
	}

	r := gin.Default()

	// Setup routes
	routes.SetupRoutes(r)

	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Println("Server running on port", port)
	if err := r.Run(":" + port); err != nil {
		panic(err)
	}
}
