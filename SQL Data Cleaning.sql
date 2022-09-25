/* Clean Data in SQL */

Select *
From PortfolioProject.dbo.NashvilleHousingData

--Standardize Date Format

Select SaleDate, Convert (Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)

/* Another Option for standardizing date format should the above not work. The original SaleDate column can be deleted at end
should the above have not worked.

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) */



--Populate Propery Address data

Select *
From PortfolioProject.dbo.NashvilleHousingData
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------------


--Breaking out address into indiviudal columns

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add PropertySplitAddress NVARCHAR(255)

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousingData
Add PropertySplitCity NVARCHAR(255)

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousingData


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousingData

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress NVARCHAR(255)

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity NVARCHAR(255)

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState NVARCHAR(255)

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From PortfolioProject.dbo.NashvilleHousingData


--Change Y and N to Yes and No in "Sold as Vacant"

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldasVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
       END
From PortfolioProject.dbo.NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = CASE When SoldasVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
       END

--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() Over (
    PARTITION BY ParcelID, 
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                    UniqueID
                    ) row_num

From PortfolioProject.dbo.NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress


--Delete Unused Columns.

Select *
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
