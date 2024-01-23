/*
AS THIS PROJECT MAINLY FOCUSES ON CLEANING THE DATA FROM GIVEN DATASET BASED ON
DIFFERENT PARAMETERS AND CONDITIONS ACCORDING TO OUR NEED OR REQUIREMENT JUST LIKE 
STANDARDIZE DATE FORMAT, REMOVE DUPLICATE ROWS OR DELETE UNUSED COLUMN BY SELECTING 
APPROPRIATE METHOD

THAT CLEANED DATASET HELPED US FOR FURTHUR ANALYTIC PROCESSING AND ALSO HELPED US TO
VISUALIZE DATA IN A BETTER WAY

---------------  CLEANING DATA IN SQL QUERIES  ------------------

*/

USE [Nashville Housing Data Cleaning];

SELECT *
FROM [Nashville Housing];

-----------------------------------------------------------------

------------------ STANDARDIZE DATE FORMAT --------------------------------

SELECT SaleDate , CONVERT(DATE,SaleDate) AS SaleDateConverted
FROM [Nashville Housing];

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(date,SaleDate);

-- AS UPDATE DON'T WORK HERE, WE DON'T KNOW ANY LOGICAL EXPLANATION
-- WHY THAT THING NOT UPDATED IN TABLE
-- INSTEAD OF UPDATE WE ALSO USE ALTER COMMAND

ALTER TABLE [Nashville Housing] 
ALTER COLUMN SaleDate Date;

SELECT SaleDate
FROM [Nashville Housing];


-------------- POPULATE PROPERTY ADDRESS DATA --------------------------

SELECT *
FROM [Nashville Housing]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

-- IN THAT WE JOIN TABLE BY ITSELF TO CHECK DUPLICATE PROPERTY ADDRESS 
-- AND ACCORDING TO THAT POPULATE IT INTO ITS PLACE

SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,
ISNULL(A.PropertyAddress,B.PropertyAddress) AS [Updated Property Address]
FROM [Nashville Housing] AS A
JOIN [Nashville Housing] AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

-- UPDATING OR POPULATING THE PROPERTY ADDRESS COLUMN

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Nashville Housing] AS A
JOIN [Nashville Housing] AS B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;


------- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS,CITY,STATE) -------

SELECT PropertyAddress
FROM [Nashville Housing];

-- SEPERATE PROPERTY ADDRESS AND CITY FROM IT USING SUBSTRING METHOD

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS [SEPERATE ADDRESS],
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)-1,LEN(PropertyAddress)) AS CITY
FROM [Nashville Housing];

-- UPDATE THAT NEW SEPERATED ADDRESS AND CITY INTO THE TABLE

ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE [Nashville Housing]
ADD PropertySplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)-1,LEN(PropertyAddress));

SELECT *
FROM [Nashville Housing];


-- SEPERATE OWNER ADDRESS INTO ADDRESS, CITY AND STATE USING PARSE METHOD

SELECT OwnerAddress
FROM [Nashville Housing];

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS [SEPERATE ADDRESS],
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS CITY,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS STATE
FROM [Nashville Housing];

-- UPDATE THAT NEW SEPERATED ADDRESS CITY AND STATE INTO THE TABLE

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT *
FROM [Nashville Housing];


---------- CHANGE Y AND N TO YES AND NO IN 'SOLDASVACANT' FIELD ----------------

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2;

-- CHANGING Y TO YES AND N TO NO USING CASE STATEMENTS

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM [Nashville Housing];

-- UPDATING THE VALUES IN THE TABLE

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;


---------------------------- REMOVE DUPLICATES ------------------------------

WITH ROWNUMCTE AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID,
				PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Nashville Housing]
-- ORDER BY ParcelD
)

SELECT *
--DELETE
FROM ROWNUMCTE
WHERE row_num > 1;


--------------------------- DELETE UNUSED COLUMNS ------------------------------

SELECT * 
FROM [Nashville Housing];

-- DELETING UNUSED COLUMNS FROM TABLE USING DROP COMMAND
ALTER TABLE [Nashville Housing]
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict;