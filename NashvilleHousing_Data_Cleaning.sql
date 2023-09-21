/*

Cleaning Data in SQL Queries

*/
Select *
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------

--		Standardize Date Format 
Select SaleDate, Convert(Date, SaleDate)
From PortfolioProject..NashvilleHousing;

-- Methode N°2

Update PortfolioProject..NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate);
--										Updated methode	Doesn't work sometimes

Alter Table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;
---			The Alter function goes along with the Update function

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert ( Date, SaleDate);

--
Select SaleDateConverted, convert(Date, SaleDate) DateSale
From PortfolioProject..NashvilleHousing;


---			Populate Property Address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is Null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	 On a.ParcelID = b.ParcelID
	 And a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--------
Update a 
set PropertyAddress = ISnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	 On a.ParcelID = b.ParcelID
	 And a.[UniqueID ]<> b.[UniqueID ]

--						Or
Update a
Set PropertyAddress = Isnull(a.PropertyAddress, 'No address')
From PortfolioProject..NashvilleHousing a
	JOin  PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-----------------------------------------------

--Breaking out Address into Individual colmns,Address, City ,State)

------------------------------------------

Select PropertyAddress
From PortfolioProject..NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
From PortfolioProject..NashvilleHousing

Select 
Substring( PropertyAddress, 1,Charindex(',', PropertyAddress)-1) as Address
,Substring( PropertyAddress, Charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing;

--	Because we can't seperate two values from one column without creating twoo other columns

---Adding the first column
Alter Table PortfolioProject..NashvilleHousing 
add PropertySplitAddress Nvarchar(225)

Update PortfolioProject..NashvilleHousing	
set PropertySplitAddress = Substring(PropertyAddress,1, charindex(',' ,PropertyAddress)-1)

----Adding the second column
Alter Table PortfolioProject..NashvilleHousing  
Add PropertySplitCity Nvarchar(225)

Update PortfolioProject..NashvilleHousing 
set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress))

select *
 from PortfolioProject..NashvilleHousing
----------------------------------------------
---Let's do the same process with OwnerAddress but with another method
Select OwnerAddress
From PortfolioProject..NashvilleHousing



Select 
Parsename(OwnerAddress,1)
 From PortfolioProject..NashvilleHousing
 -------Parsename looks for period and forsome reason it kind of going backward, starting to 1 looks like starting to 3!!!
 ----------------
 Select 
Parsename(Replace(OwnerAddress,',', '.'), 3)as Address
,Parsename(Replace(OwnerAddress,',', '.'), 2)as City
,Parsename(Replace(OwnerAddress,',', '.'), 1) as State
 From PortfolioProject..NashvilleHousing

 --Adding into the table

Alter Table PortfolioProject..NashvilleHousing
add OwnerSplitAddress Nvarchar(225)

Update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3) ;


Alter Table PortfolioProject..NashvilleHousing 
Add OwnerSplitCity Nvarchar(225)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',' ,'.'),2) ;


Alter Table PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(225)

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) ;

Select *
from PortfolioProject..NashvilleHousing


--------------------------------------------------
--Change Y and N to Yes and No in 'Sold asVaccant' 

--First let's take a glance at the variable

Select Distinct (SoldAsVacant), Count(SoldASVacant)
From  PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
						When SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant 
						End


--------------------------------------------------------------------
--Remove the Duplicates

With RowNumCTE as (
Select *,
		ROW_NUMBER() Over(
		Partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by UniqueID) row_num

from PortfolioProject..NashvilleHousing
					)
---have a glance on the duplicate
Select *
from RowNumCTE
Where row_num>1 
Order by PropertyAddress
---Now let's get rid of the duplicate
--Delete
--from RowNumCTE
--Where row_num>1 
--order by PropertyAddress



Select *
from PortfolioProject..NashvilleHousing


------------------------------------------
--Let's Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop column PropertyAddress, SaleDate, OwnerAddress,TaxDistrict


