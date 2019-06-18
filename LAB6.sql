--Zadatak 1 
use NORTHWND
go
select P.ProductName, 
(select max(OD.Quantity)
 from [Order Details] as OD
 where OD.ProductID=P.ProductID)  as 'Maksimalna količina prodaje'
from Products as P
order by P.ProductName

--Zadatak 2 
use NORTHWND
go  
select C.CompanyName, C.ContactName, C.City, C.Phone
from Customers as C
where 10000< (select sum(OD.Quantity*OD.UnitPrice)
              from Orders as O join [Order Details] as OD on O.OrderID=OD.OrderID
			  where C.CustomerID=O.CustomerID)

--Zadatak 3 (4. najveća plata)
use AdventureWorks2014
go
select top 1 EPH.Rate
from  (
select top 4 E.Rate
from HumanResources.EmployeePayHistory as E
order by E.Rate desc) as EPH
order by EPH.Rate asc
