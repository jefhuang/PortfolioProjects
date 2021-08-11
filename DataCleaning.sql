-- Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

-- Converting DateTime format to Date

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populating Property Address data
-- some rows have null PropertyAddress but have matching ParcelIDs with other rows
-- populate NULL fields with the matching address

Select *
from PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Update the query to fill in nulls

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
-- Substrings
-- Separating by delimiter ( comma , )

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



Select * 
From PortfolioProject.dbo.NashvilleHousing

-- Cleaning OwnerAddress with ParseName


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'),3)
,PARSENAME(Replace(OwnerAddress, ',', '.'),2)
,PARSENAME(Replace(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NashvilleHousing

-- Apply changes

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3)

Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
 
Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitcity = PARSENAME(Replace(OwnerAddress, ',', '.'),2)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1)

-- Realized I could have done this in fewer lines by adding columns all at once and setting columns all at once

Select *
From PortfolioProject.dbo.NashvilleHousing



-- Changing Y and N to Yes and No in Sold as Vacant column

Select Distinct(SoldAsVacant), Count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldasVacant = 'N' THEN 'No'
		ELSE SoldasVacant
		END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldasVacant = 'N' THEN 'No'
		ELSE SoldasVacant
		END
From PortfolioProject.dbo.NashvilleHousing




-- Deleting Duplicates

WITH RowNUMCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID) row_num
	
From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate


