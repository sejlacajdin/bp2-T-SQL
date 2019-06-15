--Zadatak 1

use NORTHWND
go
select CompanyName, City, Fax
from Customers
where (CompanyName like '%[rR]estaurant%' or City like 'Madrid') and Fax is not null
order by CompanyName 
 
 --Zadatak 2 

 use NORTHWND
 go
 select CompanyName, ContactName, City
 from Suppliers
 where CompanyName like '[AEP]%' and Country in ('Germany','France')


 --Zadatak 3 
 use pubs 
 go
select title, [type], price, (price- price*0.20) as 'Cijena sa popustom'
from titles
where (price- price*0.20) between 10 and 20
order by type, [Cijena sa popustom] desc

--Zadatak 4 
use AdventureWorks2014
go
select min(ListPrice) as 'Minimalna cijena', max(ListPrice) as 'Maksimalna cijena', avg(ListPrice) as 'Prosječna cijena'
from Production.Product

--Zadatak 5 
--a)
use AdventureWorks2014
go
select top 10 ProductID, sum(OrderQty) as 'Ukupna količina', sum(OrderQty*UnitPrice) as 'Zarada'
from Sales.SalesOrderDetail
group by ProductID
order by [Ukupna količina] desc

--b)
use AdventureWorks2014
go
select ProductID, sum(OrderQty) as 'Ukupna količina', sum(OrderQty*UnitPrice) as 'Zarada'
from Sales.SalesOrderDetail
group by ProductID
having sum(OrderQty*UnitPrice)>30000


--Zadatak 6
use AdventureWorks2014
go
select top 10 with ties ProductSubcategoryID, count(ProductID) as 'Broj proizvoda'
from  Production.Product
where ProductSubcategoryID is not null
group by ProductSubcategoryID
order by [Broj proizvoda] desc

 
--Zadatak 7
select 'Dobrodošli, ' +FirstName+' '+LastName+ ' trenutno vrijeme je: '+right(cast(getdate() as nvarchar),7)
from Person.Person

--Zadatak 8
use NORTHWND
go
select lower(LastName+'.'+FirstName+'@'+City+'.com') as Email,right(replace(substring(REVERSE(cast(Notes as nvarchar)+Title+[Address]),10,15),' ','#'),8) as Lozinka,
       DATEDIFF(year,BirthDate,getdate()) as Starost
from Employees
