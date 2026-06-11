package controllers

import (
	"net/http"
	"ruma/models"
	"ruma/repositories"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
)

type ExpenseController struct {
	expenseRepo repositories.ExpenseRepository
}

func NewExpenseController(repo repositories.ExpenseRepository) *ExpenseController {
	return &ExpenseController{expenseRepo: repo}
}

func (ctrl *ExpenseController) CreateExpense(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var input struct {
		Title    string  `json:"title" binding:"required"`
		Amount   float64 `json:"amount" binding:"required"`
		Category string  `json:"category"`
		Date     string  `json:"date"`
		Note     string  `json:"note"`
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

	expense := models.Expense{
		OwnerID:  userID.(uint),
		Title:    input.Title,
		Amount:   input.Amount,
		Category: input.Category,
		Date:     date,
		Note:     input.Note,
	}

	if err := ctrl.expenseRepo.Create(&expense); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menyimpan pengeluaran"})
		return
	}

	c.JSON(http.StatusCreated, expense)
}

func (ctrl *ExpenseController) GetMyExpenses(c *gin.Context) {
	userID, _ := c.Get("user_id")

	expenses, err := ctrl.expenseRepo.FindByOwnerID(userID.(uint))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data pengeluaran"})
		return
	}

	c.JSON(http.StatusOK, expenses)
}

func (ctrl *ExpenseController) DeleteExpense(c *gin.Context) {
	userID, _ := c.Get("user_id")
	id, _ := strconv.Atoi(c.Param("id"))

	expense, err := ctrl.expenseRepo.FindByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Pengeluaran tidak ditemukan"})
		return
	}

	if expense.OwnerID != userID.(uint) {
		c.JSON(http.StatusForbidden, gin.H{"error": "Akses ditolak"})
		return
	}

	if err := ctrl.expenseRepo.Delete(uint(id)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus pengeluaran"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Pengeluaran berhasil dihapus"})
}
