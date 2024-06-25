-- Cleaning data in SQL quaries

select SaleDate, convert(date, SaleDate) as DateUpdated
from PortfolioProject..nashvilehousing

alter table NashvileHousing 
alter column SaleDate Date

-- populate property address

select *
from PortfolioProject..NashvileHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvileHousing a
JOIN PortfolioProject..NashvileHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvileHousing a
JOIN PortfolioProject..NashvileHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyAddress is null

-- Breaking out address into Individual columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvileHousing
--where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as PropertyAddress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvileHousing

alter table NashvileHousing
add PropertySplitAddress Nvarchar(255);

update NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 


alter table NashvileHousing
add PropertySplitCity Nvarchar(255);

update NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
from PortfolioProject..NashvileHousing

--=====OwnerAddress---------

SElect OwnerAddress
from PortfolioProject..NashvileHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address, 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
From PortfolioProject..NashvileHousing


alter table NashvileHousing
add OwnerSplitAddress Nvarchar(255);

update NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


alter table NashvileHousing
add OwnerSplitCity Nvarchar(255);

update NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 


alter table NashvileHousing
add OwnerSplitState Nvarchar(255);

update NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 

select *
From PortfolioProject..NashvileHousing

-- Change Y and N to Yes and No in "Sold as vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject..NashvileHousing
Group by SoldAsvacant
Order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..NashvileHousing

Update NashvileHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates

WITH RowNumCTE as(
select *,
ROW_NUMBER() over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID
					) row_num
From PortfolioProject..NashvileHousing
--Order By ParcelID
)
select * 
from RowNumCTE
where row_num > 1

-- delete Unused columns

select * 
from PortfolioProject..NashvileHousing

alter table NashvileHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress
