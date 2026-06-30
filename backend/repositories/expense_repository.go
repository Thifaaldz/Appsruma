package repositories

import (
	"ruma/config"
	"ruma/models"
)

type ExpenseRepository interface {
	Create(expense *models.Expense) error
	FindByOwnerID(ownerID uint) ([]models.Expense, error)
	FindByOwnerAndBoardingHouse(ownerID uint, boardingHouseID uint) ([]models.Expense, error)
	FindByID(id uint) (*models.Expense, error)
	Update(expense *models.Expense) error
	Delete(id uint) error
}

type expenseRepository struct{}

func NewExpenseRepository() ExpenseRepository {
	return &expenseRepository{}
}

func (r *expenseRepository) Create(expense *models.Expense) error {
	return config.DB.Create(expense).Error
}

func (r *expenseRepository) FindByOwnerID(ownerID uint) ([]models.Expense, error) {
	var expenses []models.Expense
	err := config.DB.Where("owner_id = ?", ownerID).Order("date desc").Find(&expenses).Error
	return expenses, err
}

func (r *expenseRepository) FindByOwnerAndBoardingHouse(ownerID uint, boardingHouseID uint) ([]models.Expense, error) {
	var expenses []models.Expense
	err := config.DB.Where("owner_id = ? AND boarding_house_id = ?", ownerID, boardingHouseID).Order("date desc").Find(&expenses).Error
	return expenses, err
}

func (r *expenseRepository) FindByID(id uint) (*models.Expense, error) {
	var expense models.Expense
	err := config.DB.First(&expense, id).Error
	return &expense, err
}

func (r *expenseRepository) Update(expense *models.Expense) error {
	return config.DB.Save(expense).Error
}

func (r *expenseRepository) Delete(id uint) error {
	return config.DB.Delete(&models.Expense{}, id).Error
}
