-- Cleaning Data in SQL Queries.
select *
From NashvilleHousing;

-- Standizing the Sale Data

SELECT
    SaleDate,
    STR_TO_DATE(SaleDate, '%M %d, %Y') AS SaleDateConverted
FROM NashvilleHousing;

-- Property Address Data

Select *
From NashvilleHousing
-- where propertyaddress= ''
order by parcelid
-- self Join needed

select a.parcelid,a.propertyaddress, b.parcelid,b.propertyaddress,COALESCE(NULLIF(TRIM(a.propertyaddress), ''), b.propertyaddress)
From NashvilleHousing a
Join NashvilleHousing b
on  a.parcelid=b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress= ''


UPDATE NashvilleHousing a
JOIN NashvilleHousing b
  ON a.parcelid = b.parcelid
 AND a.uniqueid <> b.uniqueid
SET a.propertyaddress =
    COALESCE(NULLIF(TRIM(a.propertyaddress), ''), b.propertyaddress)
WHERE TRIM(a.propertyaddress) = '';

-- breaking out address into columns ( address, city, state)

select propertyaddress
From NashvilleHousing
-- where propertyaddress= ''
-- order by parcelid

SELECT
    SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress) - 1) AS address,
    SUBSTRING(propertyaddress, LOCATE(',', propertyaddress)+ 1, length(propertyaddress)) AS address
FROM NashvilleHousing;


-- Add address column
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);

-- Populate address
UPDATE NashvilleHousing
SET PropertySplitAddress =
    SUBSTRING(propertyaddress, 1, LOCATE(',', propertyaddress) - 1);



-- Add city column
ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);

-- Populate city
UPDATE NashvilleHousing
SET PropertySplitCity =
    TRIM(SUBSTRING(propertyaddress, LOCATE(',', propertyaddress) + 1));

select *
from NashvilleHousing


select owneraddress
from NashvilleHousing

SELECT
    owneraddress,
    SUBSTRING_INDEX(owneraddress, ',', 1) AS OwnerStreet,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1)) AS OwnerCity,
    TRIM(SUBSTRING_INDEX(owneraddress, ',', -1)) AS OwnerState
FROM NashvilleHousing;

UPDATE NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(owneraddress, ',', 1);

UPDATE NashvilleHousing
SET OwnerSplitCity =
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1));

UPDATE NashvilleHousing
SET OwnerSplitState =
    TRIM(SUBSTRING_INDEX(owneraddress, ',', -1));

select *
from NashvilleHousing



-- change Y and N to Yes and No in "Sold as Vacant" field

select distinct soldasvacant, count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2


select soldasvacant,
 Case when soldasvacant= 'Y' then "Yes"
      when soldasvacant= 'N' then "No"
      else soldasvacant
      end
from nashvillehousing

update nashvillehousing
set SoldAsVacant= Case when soldasvacant= 'Y' then "Yes"
      when soldasvacant= 'N' then "No"
      else soldasvacant
      end
-- ------------------------------------------------------------------------------------------------ 
-- remove Duplicates
with RownumCTE as (
select *, 
	row_number()over (
    partition by parcelID, 
				PropertyAddress, 
                saleprice,saledate, 
                legalreference
                order by 
					uniqueID
                    )
                    row_num


from nashvillehousing
order by parcelid
)

select *
from RownumCTE
where row_num> 1
-- order by propertyaddress
      
      
WITH RownumCTE AS (
  SELECT uniqueID,
         ROW_NUMBER() OVER (
           PARTITION BY parcelID, PropertyAddress, saleprice, saledate, legalreference
           ORDER BY uniqueID
         ) AS row_num
  FROM nashvillehousing
)
DELETE FROM nashvillehousing
WHERE uniqueID IN (
  SELECT uniqueID
  FROM RownumCTE
  WHERE row_num > 1
);
      
-- ------------------------------------------------------------------------------------------------ 
-- remove unused columns

select *
from nashvillehousing;

alter table nashvillehousing
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress;




      
