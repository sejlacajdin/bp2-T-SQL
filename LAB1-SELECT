use AdventureWorks2014
go

--Zadatak 1 
select ProductID, Name, Color, ListPrice
from Production.Product
where Name like '[ST]%' and Color in ('Blue','Black') and (ListPrice between 100 and 1000)
order by ListPrice desc 

--Zadatak 2 
select SalesOrderNumber,convert(nvarchar,OrderDate,104) as 'Datum narudžbe', TotalDue
from Sales.SalesOrderHeader
where (OrderDate between '2011-07-01' and '2011-12-31') and TotalDue>100000

--Zadatak 3 
select isnull(Title,'N/A'), FirstName+' '+LastName as 'Ime i prezime'
from Person.Person
where MiddleName is null


--Zadatak 4 
select top 10 right(LoginID,len(LoginID)-CHARINDEX('\',LoginID,0)) as 'Korisničko ime',JobTitle, HireDate, DATEDIFF(year,BirthDate,getdate()) as 'Starost', DATEDIFF(year,HireDate,GETDATE()) as 'Staž'
from HumanResources.Employee
where JobTitle like '%[Mm]anager%'
order by Starost desc


--Zadatak 5
select top 10 ProductID, cast(OrderQty as nvarchar)+ ' kom.' as 'Količina',cast(round(UnitPrice,2) as nvarchar)+' KM' as 'Cijena', cast(round(OrderQty*UnitPrice,2) as nvarchar)+' KM' as 'Iznos'
from Sales.SalesOrderDetail
order by OrderQty*UnitPrice desc
