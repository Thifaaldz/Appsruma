package utils

import (
	"ruma/config"
	"ruma/models"

	"gorm.io/gorm"
)

func GetOrCreateDefaultBoardingHouse(ownerID uint) (uint, error) {
	var bh models.BoardingHouse
	err := config.DB.Where("owner_id = ?", ownerID).First(&bh).Error
	if err == gorm.ErrRecordNotFound {
		bh = models.BoardingHouse{
			OwnerID:          ownerID,
			Name:             "Kosan Saya",
			Address:          "Alamat Kosan",
			ImageUrl:         "https://picsum.photos/400/300",
			ImageUrls:        models.StringList{"https://picsum.photos/400/300"},
			DefaultRoomPrice: 1500000,
		}
		if err := config.DB.Create(&bh).Error; err != nil {
			return 0, err
		}
	} else if err != nil {
		return 0, err
	}
	return bh.ID, nil
}

func GetOwnerRoomIDs(ownerID uint) ([]uint, error) {
	var bhIDs []uint
	if err := config.DB.Model(&models.BoardingHouse{}).Where("owner_id = ?", ownerID).Pluck("id", &bhIDs).Error; err != nil {
		return nil, err
	}
	if len(bhIDs) == 0 {
		return []uint{}, nil
	}
	var roomIDs []uint
	err := config.DB.Model(&models.Room{}).Where("boarding_house_id IN ?", bhIDs).Pluck("id", &roomIDs).Error
	return roomIDs, err
}

func OwnerOwnsBoardingHouse(ownerID uint, boardingHouseID uint) (bool, error) {
	if boardingHouseID == 0 {
		return false, nil
	}
	var count int64
	err := config.DB.Model(&models.BoardingHouse{}).
		Where("id = ? AND owner_id = ?", boardingHouseID, ownerID).
		Count(&count).Error
	return count > 0, err
}

func GetTenantBoardingHouseID(userID uint) (uint, error) {
	tenant, err := GetTenantByUserID(userID)
	if err != nil {
		return 0, err
	}

	var room models.Room
	if err := config.DB.First(&room, tenant.RoomID).Error; err != nil {
		return 0, err
	}

	return room.BoardingHouseID, nil
}

func UserIsTenantInBoardingHouse(userID uint, boardingHouseID uint) (bool, error) {
	if userID == 0 || boardingHouseID == 0 {
		return false, nil
	}
	var count int64
	err := config.DB.Model(&models.Tenant{}).
		Joins("JOIN rooms ON rooms.id = tenants.room_id").
		Where("tenants.user_id = ? AND rooms.boarding_house_id = ?", userID, boardingHouseID).
		Count(&count).Error
	return count > 0, err
}

func GetOwnerTenantIDs(ownerID uint) ([]uint, error) {
	roomIDs, err := GetOwnerRoomIDs(ownerID)
	if err != nil {
		return nil, err
	}
	if len(roomIDs) == 0 {
		return []uint{}, nil
	}
	var tenantIDs []uint
	err = config.DB.Model(&models.Tenant{}).Where("room_id IN ?", roomIDs).Pluck("id", &tenantIDs).Error
	return tenantIDs, err
}

func GetTenantByUserID(userID uint) (*models.Tenant, error) {
	var tenant models.Tenant
	err := config.DB.Where("user_id = ?", userID).First(&tenant).Error
	if err != nil {
		return nil, err
	}
	return &tenant, nil
}
