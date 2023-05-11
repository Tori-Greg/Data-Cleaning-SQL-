-- Data cleaning for NashvilleHousing

-- Standardise date format 
Select SaleDate, CONVERT(Date, SaleDate)
from Portfolio_Projects..NashvilleHousing

Update NashvilleHousing
Set Saledate = CONVERT(Date, Saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

---------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data
Select *
From Portfolio_Projects.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Projects.dbo.NashvilleHousing a
JOIN Portfolio_Projects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Projects.dbo.NashvilleHousing a
JOIN Portfolio_Projects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out address into individual columns (Address, City, State)

SELECT PropertyAddress from Portfolio_Projects.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM Portfolio_Projects.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add Propertysplitcity Nvarchar(255);

Update NashvilleHousing 
SET Propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * 
FROM Portfolio_Projects.dbo.NashvilleHousing

-- An alternative approach to achieving column split: Using OwnerAddress column
Select OwnerAddress
FROM Portfolio_Projects.dbo.NashvilleHousing

select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Projects.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add StreetName Nvarchar(255);
Update NashvilleHousing 
SET StreetName = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add CityName Nvarchar(255);
Update NashvilleHousing 
SET CityName = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add StateName Nvarchar(255);
Update NashvilleHousing 
SET StateName = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "SoldAsVacant" field
Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Projects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select	SoldAsVacant,
	Case When SoldAsVacant ='Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End
FROM Portfolio_Projects.dbo.NashvilleHousing

Update NashvilleHousing 
SET SoldAsVacant = Case When SoldAsVacant ='Y' then 'Yes'
		 When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio_Projects.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From Portfolio_Projects.dbo.NashvilleHousing

--Delete unused columns
Select *
From Portfolio_Projects.dbo.NashvilleHousing


ALTER TABLE Portfolio_Projects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




