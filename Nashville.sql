USE Nashville;

SELECT
	*
FROM
	Nashville;
    
#Standardize Date format

UPDATE Nashville
SET Saledate = STR_TO_DATE('4/9/13 12:00 AM', '%m/%d/%y %h:%i %p');

SELECT
	DATE_FORMAT(STR_TO_DATE('4/9/13 12:00 AM', '%m/%d/%y %h:%i %p'), '%Y-%m-%d')
FROM
	Nashville;

UPDATE Nashville
SET Saledate = DATE_FORMAT(Saledate, '%Y-%m-%d');

#Populate Property Address data
SELECT
	*
FROM
	Nashville
WHERE
	PropertyAddress = '';

SELECT
	a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, IF(a.propertyaddress = '', b.propertyaddress, 0)
FROM
	Nashville a
JOIN
	Nashville b ON a.ParcelID = b.ParcelID AND a.uniqueId <> b.uniqueid
WHERE
	a.propertyaddress = '';
    
UPDATE Nashville a JOIN Nashville b ON a.ParcelID = b.ParcelID AND a.uniqueID <> b.uniqueID
SET a.propertyAddress = IF(a.propertyaddress = '', b.propertyaddress, 0)
WHERE
	a.propertyaddress = '';

#Breaking out Address into Individual Columns with a delimiter

SELECT
	SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(PropertyAddress, ',', -1) AS Address
FROM
	Nashville;
    
ALTER TABLE Nashville
Add PropertyAddress2 VARCHAR(255) AFTER PropertyAddress;

UPDATE Nashville
SET PropertyAddress2 = (SELECT SUBSTRING_INDEX(PropertyAddress, ',', -1) AS Address2);
    
UPDATE Nashville
SET PropertyAddress = (SELECT SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address1);

#Similar for Owner address, but with two delimiters
ALTER TABLE Nashville
ADD OwnerAddress2 VARCHAR(255) AFTER OwnerAddress;

ALTER TABLE Nashville
ADD OwnerAddress3 VARCHAR(255) AFTER OwnerAddress2;

SELECT 
	SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OwnerAddress2,
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', -1) AS OwnerAddress3
FROM Nashville;

UPDATE Nashville
SET OwnerAddress3 = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', -1);

UPDATE Nashville
SET OwnerAddress2 = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE Nashville
SET OwnerAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

#Change Y and N to Yes and No in "Sold as Vacant"
SELECT
	DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM
	Nashville
GROUP BY
	SoldAsVacant;
    
SELECT
	SoldAsVacant,
    CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
	END
FROM
	Nashville;
    
UPDATE Nashville
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
	END;

#Delete duplicate columns
With DupeRow AS 
	(SELECT *, ROW_NUMBER() OVER(PARTITION BY
					Parcelid,
                    PropertyAddress,
                    SalePrice,
                    SaleDate,
                    LegalReference
                    ORDER BY UniqueID) row_num
	FROM
		Nashville
	WHERE
		UniqueID IS NOT NULL)
DELETE FROM Nashville USING Nashville JOIN DupeRow ON nashville.uniqueid = duperow.uniqueid
WHERE
	row_num > 1;  #121 duplicate rows
				
#Delete unused columns
ALTER TABLE Nashville
DROP COLUMN TaxDistrict;

