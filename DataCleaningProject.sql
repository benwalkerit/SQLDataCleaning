/*
Cleaning Data in SQL Queries
*/

SELECT * FROM PortfolioCleaningProject..DataSet

/*
Standadize Date Format
*/

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioCleaningProject..DataSet

UPDATE PortfolioCleaningProject..DataSet
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PortfolioCleaningProject..DataSet
ADD SaleDateConverted Date;

UPDATE PortfolioCleaningProject..DataSet
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT * FROM PortfolioCleaningProject..DataSet
/*
Populate Property Address data
*/

SELECT * FROM PortfolioCleaningProject..DataSet
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioCleaningProject..DataSet a
JOIN PortfolioCleaningProject..DataSet b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioCleaningProject..DataSet a
JOIN PortfolioCleaningProject..DataSet b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT * FROM PortfolioCleaningProject..DataSet

/*
Splitting PropertyAddress into individual columns, Addres, City.
*/
SELECT PropertyAddress FROM PortfolioCleaningProject..DataSet

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioCleaningProject..DataSet

ALTER TABLE PortfolioCleaningProject..DataSet
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioCleaningProject..DataSet
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE PortfolioCleaningProject..DataSet
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioCleaningProject..DataSet
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM PortfolioCleaningProject..DataSet

/*
Splitting OwnerAddress into individual columns, Addres, City, State.
*/
SELECT OwnerAddress FROM PortfolioCleaningProject..DataSet

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as City
, PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as State
FROM PortfolioCleaningProject..DataSet

ALTER TABLE PortfolioCleaningProject..DataSet
ADD OwnerSplitAddress Nvarchar(255);

UPDATE PortfolioCleaningProject..DataSet
SET PropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioCleaningProject..DataSet
ADD OwnerSplitCity Nvarchar(255);

UPDATE PortfolioCleaningProject..DataSet
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE PortfolioCleaningProject..DataSet
ADD OwnerSplitState Nvarchar(255);

UPDATE PortfolioCleaningProject..DataSet
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT * FROM PortfolioCleaningProject..DataSet

/*
Change Y and N to Yes and No in "Sold as Vacant" field
*/
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioCleaningProject..DataSet
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioCleaningProject..DataSet

UPDATE PortfolioCleaningProject..DataSet
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

/*
Remove Duplicates
*/
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDateConverted,
		LegalReference
		ORDER BY
			UniqueID
			) row_num
FROM PortfolioCleaningProject..DataSet
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE  row_num > 1
--ORDER BY PropertySplitAddress

--SELECT *
--FROM RowNumCTE
--WHERE  row_num > 1
--ORDER BY PropertySplitAddress
 
/*
Remove Unused columns
*/

SELECT * 
FROM PortfolioCleaningProject..DataSet

ALTER TABLE PortfolioCleaningProject..DataSet
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict;

