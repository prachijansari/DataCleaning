SELECT 
  * 
FROM 
  Projects..NashvilleHousing 

 --Standardize date format 

  --SELECT SaleDate, CONVERT(Date, SaleDate)
  --FROM Projects..NashvilleHousing
  --UPDATE NashvilleHousing
  --SET SaleDate = CONVERT(Date,SaleDate)
ALTER TABLE 
  NashvilleHousing 
ADD 
  SaleDateConverted Date;
UPDATE 
  NashvilleHousing 
SET 
  SaleDateConverted = CONVERT(Date, SaleDate)
  
--Populate Property Address


  --SELECT *
  --FROM Projects..NashvilleHousing
  --WHERE PropertyAddress IS NULL
  --SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  --FROM Projects..NashvilleHousing a
  --JOIN Projects..NashvilleHousing b
  --ON a.ParcelID = b.ParcelID
  --AND a.[UniqueID ] <> b.[UniqueID ]
  --WHERE a.PropertyAddress IS NULL
UPDATE 
  a 
SET 
  PropertyAddress = ISNULL(
    a.PropertyAddress, b.PropertyAddress
  ) 
FROM 
  Projects..NashvilleHousing a 
  JOIN Projects..NashvilleHousing b ON a.ParcelID = b.ParcelID 
  AND a.[UniqueID ] <> b.[UniqueID ] 
WHERE 
  a.PropertyAddress IS NULL 
  
  
--Breaking out addresses into individual columns (PropertyAddress)


SELECT 
  SUBSTRING(
    PropertyAddress, 
    1, 
    CHARINDEX(',', PropertyAddress) -1
  ) AS Address, 
  SUBSTRING(
    PropertyAddress, 
    CHARINDEX(',', PropertyAddress) + 1, 
    LEN(PropertyAddress)
  ) AS Address 
FROM 
  Projects..NashvilleHousing 
ALTER TABLE 
  NashvilleHousing 
ADD 
  PropertySplitAddress NVARCHAR(255);
ALTER TABLE 
  NashvilleHousing 
ADD 
  PropertySplitCity NVARCHAR(255);
UPDATE 
  NashvilleHousing 
SET 
  PropertySplitAddress = SUBSTRING(
    PropertyAddress, 
    1, 
    CHARINDEX(',', PropertyAddress) -1
  ) 
UPDATE 
  NashvilleHousing 
SET 
  PropertySplitCity = SUBSTRING(
    PropertyAddress, 
    CHARINDEX(',', PropertyAddress) + 1, 
    LEN(PropertyAddress)
  ) 
  
  
-- Breaking out addresses into individual columns (OwnerAddress)


SELECT 
  PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    3
  ), 
  PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    2
  ), 
  PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    1
  ) 
FROM 
  Projects..NashvilleHousing 
ALTER TABLE 
  NashvilleHousing 
ADD 
  OwnerSplitAddress NVARCHAR(255);
ALTER TABLE 
  NashvilleHousing 
ADD 
  OwnerSplitCity NVARCHAR(255);
ALTER TABLE 
  NashvilleHousing 
ADD 
  OwnerSplitState NVARCHAR(255);
UPDATE 
  NashvilleHousing 
SET 
  OwnerSplitAddress = PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    3
  ) 
UPDATE 
  NashvilleHousing 
SET 
  OwnerSplitCity = PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    2
  ) 
UPDATE 
  NashvilleHousing 
SET 
  OwnerSplitState = PARSENAME(
    REPLACE(OwnerAddress, ',', '.'), 
    1
  ) 
  
  
  
-- Change Y and N to yes and NO to make the data consistent


SELECT 
  DISTINCT(SoldAsVacant), 
  COUNT(SoldAsVacant) 
FROM 
  Projects..NashvilleHousing 
GROUP BY 
  SoldAsVacant 
ORDER BY 
  2 
SELECT 
  SoldAsVacant, 
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END 
FROM 
  Projects..NashvilleHousing 
UPDATE 
  NashvilleHousing 
SET 
  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END --Remove Duplicates (I would Rather make temp table)
  WITH RowNumCTE AS(
    SELECT 
      *, 
      ROW_NUMBER() OVER(
        PARTITION BY ParcelID, 
        PropertyAddress, 
        SalePrice, 
        SaleDate, 
        LegalReference 
        ORDER BY 
          UniqueID
      ) row_num 
    FROM 
      Projects..NashvilleHousing
  ) 
SELECT 
  * 
FROM 
  RowNumCTE 
WHERE 
  row_num > 1 
  
  
--Delete Unused Columns

ALTER TABLE 
  Projects..NashvilleHousing 
DROP 
  COLUMN OwnerAddress, 
  SaleDate, 
  PropertyAddress, 
  TaxDistrict
