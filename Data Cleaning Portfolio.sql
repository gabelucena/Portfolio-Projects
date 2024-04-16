-- Cleaning Data in SQL Queries

Select *
From Portfolio_Project..NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted
From Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address Data

Select *
From Portfolio_Project..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project..NashvilleHousing a
JOIN Portfolio_Project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_Project..NashvilleHousing a
JOIN Portfolio_Project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking ou Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Portfolio_Project..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

Select OwnerAddress 
from Portfolio_Project..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from Portfolio_Project..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END
From Portfolio_Project..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
	END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From Portfolio_Project..NashvilleHousing
)

DELETE
From RowNumCTE
where row_num > 1

-- Delete UnusedColumns

ALTER TABLE Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
