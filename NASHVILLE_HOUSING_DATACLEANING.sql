


/*
Cleaning Data In SQL
*/
select *
from PORTFOLIOPROJECT..NashvileHousing
;


-- standadize date format

select SaleDateConverted, CONVERT(date,SaleDate)
from PORTFOLIOPROJECT..NashvileHousing

update NashvileHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvileHousing
add SaleDateConverted date;

update NashvileHousing
SET SaleDateConverted = CONVERT(date,SaleDate)


-- populating property address data

select *
from PORTFOLIOPROJECT..NashvileHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PORTFOLIOPROJECT..NashvileHousing a
JOIN PORTFOLIOPROJECT..NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PORTFOLIOPROJECT..NashvileHousing a
JOIN PORTFOLIOPROJECT..NashvileHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- breaking out address into individual columns (address,city,state)

select PropertyAddress
from PORTFOLIOPROJECT..NashvileHousing

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1 ) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

from PORTFOLIOPROJECT..NashvileHousing

ALTER TABLE NashvileHousing
add PropertySplitAddress Nvarchar(255);

update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvileHousing
add PropertySplitCity Nvarchar(255);

update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

select *
from PORTFOLIOPROJECT..NashvileHousing


select OwnerAddress
from PORTFOLIOPROJECT..NashvileHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PORTFOLIOPROJECT..NashvileHousing

ALTER TABLE NashvileHousing
add OwnerSplitAddress Nvarchar(255);

update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvileHousing
add OwnerSplitCity Nvarchar(255);

update NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvileHousing
add OwnerSplitState Nvarchar(255);

update NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from PORTFOLIOPROJECT..NashvileHousing


--change Y and N to Yes and No in "Sold and Vacant" field

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from PORTFOLIOPROJECT..NashvileHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 WHEN SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from PORTFOLIOPROJECT..NashvileHousing

UPDATE NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant= 'Y' THEN 'Yes'
	 WHEN SoldAsVacant= 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END



-- Removing Duplicates

WITH RowNumCTE as(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID 
				) row_num
from PORTFOLIOPROJECT..NashvileHousing
)
select *
from RowNumCTE
where row_num > 1



-- deleting unused columns

select *
from PORTFOLIOPROJECT..NashvileHousing

ALTER TABLE PORTFOLIOPROJECT..NashvileHousing
DROP COLUMN		OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE PORTFOLIOPROJECT..NashvileHousing
DROP COLUMN	SaleDate
