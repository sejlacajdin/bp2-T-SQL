use AdventureWorks2014
go

--Zadatak 1 
select TerritoryID, count(CustomerID) 'Broj kupaca'
from Sales.Customer 
group by TerritoryID
having count(CustomerID)>1000

--Zadatak 2 
select ProductModelID, count(ProductID) 'Ukupan broj proizvoda'
from Production.Product
where ProductModelID is not null and Name like 'S%'
group by ProductModelID
having count(ProductID)>1

--Zadatak 3
select top 10 with ties  ProductID, sum(OrderQty) as 'Ukupna količina prodaje'
from Sales.SalesOrderDetail
group by ProductID
order by [Ukupna količina] desc

--Zadatak 4
select ProductID, round(sum(OrderQty*UnitPrice),2) as 'Ukupna zarada', round(sum(OrderQty*(UnitPrice-UnitPrice*UnitPriceDiscount)),2) as 'Ukupna zarada sa popustom'
from Sales.SalesOrderDetail
where UnitPriceDiscount>0
group by ProductID
order by [Ukupna zarada] desc


--Zadatak 5
select month(OrderDate) as 'Mjesec', min(TotalDue) as 'Minimalna zarada', max(TotalDue) as 'Maksimalna zarada',
       avg(TotalDue) 'Prosječna zarada', sum(TotalDue) 'Ukupna zarada'
from Sales.SalesOrderHeader
where year(OrderDate) like '2013'
group by month(OrderDate)
order by 1
