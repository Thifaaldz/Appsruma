package routes

import (
	"ruma/controllers"
	"ruma/middleware"
	"ruma/repositories"
	"ruma/services"

	"github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine) {
	userRepo := repositories.NewUserRepository()
	roomRepo := repositories.NewRoomRepository()
	tenantRepo := repositories.NewTenantRepository()
	paymentRepo := repositories.NewPaymentRepository()
	complaintRepo := repositories.NewComplaintRepository()
	bhRepo := repositories.NewBoardingHouseRepository()

	authService := services.NewAuthService(userRepo)

	authController := controllers.NewAuthController(authService)
	roomController := controllers.NewRoomController(roomRepo)
	tenantController := controllers.NewTenantController(tenantRepo)
	paymentController := controllers.NewPaymentController(paymentRepo)
	complaintController := controllers.NewComplaintController(complaintRepo)
	bhController := controllers.NewBoardingHouseController(bhRepo)

	api := r.Group("/api")
	{
		auth := api.Group("/auth")
		{
			auth.POST("/register", authController.Register)
			auth.POST("/login", authController.Login)
			auth.GET("/tenants", authController.GetTenantUsers)
		}

		// Public webhook for Midtrans
		api.POST("/payments/webhook", paymentController.MidtransWebhook)

		// Protected routes
		protected := api.Group("/")
		protected.Use(middleware.AuthMiddleware())
		{
			protected.GET("/auth/me", authController.GetMe)
			protected.PUT("/auth/me", authController.UpdateMe)

			// Boarding Houses
			bhs := protected.Group("/boarding-houses")
			{
				bhs.GET("", bhController.GetMyBoardingHouses)
				bhs.GET("/:id", bhController.GetBoardingHouseByID)

				ownerOnly := bhs.Group("")
				ownerOnly.Use(middleware.RoleMiddleware("owner", "admin"))
				{
					ownerOnly.POST("", bhController.CreateBoardingHouse)
					ownerOnly.POST("/:id", bhController.UpdateBoardingHouse)
					ownerOnly.PUT("/:id", bhController.UpdateBoardingHouse)
					ownerOnly.DELETE("/:id", bhController.DeleteBoardingHouse)
				}
			}

			// Rooms
			rooms := protected.Group("/rooms")
			{
				rooms.GET("", roomController.GetAllRooms)
				rooms.GET("/:id", roomController.GetRoomByID)

				adminOnly := rooms.Group("")
				adminOnly.Use(middleware.RoleMiddleware("owner", "admin"))
				{
					adminOnly.POST("", roomController.CreateRoom)
					adminOnly.PUT("/:id", roomController.UpdateRoom)
					adminOnly.DELETE("/:id", roomController.DeleteRoom)
				}
			}

			// Tenants
			tenants := protected.Group("/tenants")
			{
				tenants.GET("", tenantController.GetAllTenants)
				tenants.GET("/:id", tenantController.GetTenantByID)

				adminOnly := tenants.Group("")
				adminOnly.Use(middleware.RoleMiddleware("owner", "admin"))
				{
					adminOnly.POST("", tenantController.CreateTenant)
					adminOnly.PUT("/:id", tenantController.UpdateTenant)
					adminOnly.DELETE("/:id", tenantController.DeleteTenant)
				}
			}

			// Payments
			payments := protected.Group("/payments")
			{
				payments.GET("", paymentController.GetAllPayments)
				payments.POST("", paymentController.CreatePayment)
				payments.GET("/tenant/:tenantId", paymentController.GetTenantPayments)
				payments.PUT("/:id/confirm", paymentController.ConfirmPayment)
				payments.POST("/:id/snap-token", paymentController.GetSnapToken)
				payments.GET("/status/:orderId", paymentController.CheckPaymentStatus)
				payments.POST("/pay-next-month", paymentController.PayNextMonth)
			}

			// Complaints
			complaints := protected.Group("/complaints")
			{
				complaints.GET("", complaintController.GetAllComplaints)
				complaints.POST("", complaintController.CreateComplaint)
				complaints.PUT("/:id", complaintController.UpdateComplaintStatus)
			}
		}
	}
}
