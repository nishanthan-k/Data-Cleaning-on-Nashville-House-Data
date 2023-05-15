-- selecting the database schema
use project;

-- selecting all data in the dataset
SELECT * 
FROM housedata;

-- counting no of rows in the dataset
SELECT count(*) 
FROM housedata;

------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize the Date Format

SELECT SaleDate, DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d') AS formatted_date
FROM housedata;

UPDATE housedata
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%y-%m-%d');

------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate PropertyAddress column

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM housedata a
JOIN housedata b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';

SELECT a.PropertyAddress, b.PropertyAddress
FROM housedata a
JOIN housedata b
	ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = '';


UPDATE housedata a
JOIN (
	SELECT UniqueID, ParcelID, PropertyAddress
	FROM housedata
	WHERE PropertyAddress <> ''
) b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = '';

------------------------------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into individual columns(Address, City, State)

SELECT PropertyAddress
FROM housedata;


-- Spliting the address respect to the comma
SELECT 
	SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress))
FROM housedata;


-- We don't need that comma at the last so we will remove it by adding '-1' to the substring
SELECT 
	SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1)
FROM housedata;

-- see we splited the first comma now it's time to split the next comma 
SELECT
	SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS FirstSplit,
	SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)) AS SecondSplit
FROM housedata;

-- Compare the results
SELECT PropertyAddress,
	SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) AS FirstSplit,
	SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)) AS SecondSplit
FROM housedata;

-- Adding the splitted address result to out dataset
ALTER TABLE housedata
ADD PropertySplitAddress varchar(500);

UPDATE housedata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE housedata
ADD PropertyAddressSplitCity varchar(500);

UPDATE housedata
SET PropertyAddressSplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress));

SELECT * 
FROM housedata;

------------------------------------------------------------------------------------------------------------------------------------------------

-- Split the OwnerAddress as same as PropertyAddress

SELECT OwnerAddress
FROM housedata;

-- Approach 1 to split

SELECT 
	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS address,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS city,
	TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS state
FROM housedata;

-- Approach 2 to split

SELECT
	TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1)) AS address,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2), '.', 1)) AS city,
	TRIM(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1)) AS state
FROM housedata;


-- Adding splitted address to the dataset

ALTER TABLE housedata
ADD OwnerSplitAddress varchar(500);

UPDATE housedata
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE housedata
ADD OwnerAddressSplitCity varchar(500);

UPDATE housedata
SET OwnerAddressSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE housedata
ADD OwnerAddressSplitState varchar(500);

UPDATE housedata
SET OwnerAddressSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));


SELECT *
FROM housedata;

------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in SoldAsVacant colummn

SELECT DISTINCT(SoldAsVacant)
FROM housedata;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
FROM housedata;

UPDATE housedata
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END;
         
SELECT DISTINCT(SoldAsVacant)
FROM housedata;

------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Fetching the duplicate values first
SELECT * FROM (
  SELECT *,
		 ROW_NUMBER() OVER (PARTITION BY ParcelID, 
										 PropertyAddress, 
										 SaleDate, 
										 SalePrice, 
										 LegalReference 
										 ORDER BY UniqueID
						   ) AS row_num
  FROM housedata
) AS subquery
WHERE row_num > 1;


-- Deleting those duplicates
DELETE FROM housedata
WHERE (ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference) IN (
  SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
  FROM (
    SELECT ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference,
      ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
    FROM housedata
  ) AS subquery
  WHERE row_num > 1
);

-- Check again that our dataset contains duplicates or not

SELECT * FROM (
  SELECT *,
		 ROW_NUMBER() OVER (PARTITION BY ParcelID, 
										 PropertyAddress, 
										 SaleDate, 
										 SalePrice, 
										 LegalReference 
										 ORDER BY UniqueID
						   ) AS row_num
  FROM housedata
) AS subquery
WHERE row_num > 1;


SELECT *
FROM housedata;

