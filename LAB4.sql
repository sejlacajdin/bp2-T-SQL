--Zadatak 1
--a)
use NORTHWND
go
select E.FirstName+' '+E.LastName as 'Ime uposlenika', count(O.EmployeeID) as 'Ukupan broj narudžbi'
from Employees as E join Orders as O on E.EmployeeID= O.EmployeeID
group by E.FirstName,E.LastName
order by [Ukupan broj narudžbi] desc

--b)
select E.FirstName+' '+E.LastName as 'Ime uposlenika', count(O.EmployeeID) as 'Ukupan broj narudžbi'
from Employees as E join Orders as O on E.EmployeeID=O.EmployeeID
where month(O.OrderDate)='7' and year(O.OrderDate)='1997'
group by E.FirstName, E.LastName
having count(O.EmployeeID)>=5
order by [Ukupan broj narudžbi] desc

--Zadatak 2 
use NORTHWND
go
select S.CompanyName, S.Phone,P.ProductName, sum(OD.Quantity) as Prodano
from Suppliers as S join Products as P on S.SupplierID=P.SupplierID join [Order Details] as OD 
on P.ProductID=OD.ProductID
where P.UnitsInStock=0
group by S.CompanyName, S.Phone, P.ProductName, P.QuantityPerUnit

--Zadatak 3 
use pubs
go
select P.pub_name, S.stor_name, T.title, sum(T.price*SA.qty) as 'Zarada' 
from stores as S join sales as SA on S.stor_id=SA.stor_id join titles as T
on SA.title_id=T.title_id join publishers as P on P.pub_id=T.pub_id
where P.pub_name like 'New Moon Books'
group by P.pub_name, S.stor_name, T.title
order by S.stor_name, T.title  

--Zadatak 4 
use AdventureWorks2014
go
select P.FirstName, P.LastName, count(SOH.CustomerID) as 'Ukupan broj narudžbi', isnull(sum(SOD.OrderQty),0) 'Kupljeni proizvodi',
       CRC.Name as Region, A.City
from Sales.Customer as C join Person.Person as P on C.PersonID=P.BusinessEntityID
    left join Sales.SalesOrderHeader as SOH on C.CustomerID=SOH.CustomerID 
	left join Sales.SalesOrderDetail as SOD on SOH.SalesOrderID=SOD.SalesOrderID
	 join Person.StateProvince as ST on C.TerritoryID=ST.TerritoryID 
	 join Person.CountryRegion as CRC on ST.CountryRegionCode=CRC.CountryRegionCode 
	 join Person.Address as A on ST.StateProvinceID=A.StateProvinceID
where CRC.Name= 'United States' or A.City= 'Montreal'
group by P.FirstName, P.LastName,CRC.Name , A.City


--Zadatak 5 
use AdventureWorks2014
go
select P.FirstName, SOH.SalesOrderNumber, SOH.OrderDate, CC.CardNumber, CC.CardType
from Sales.Customer as C join Person.Person as P on C.PersonID=P.BusinessEntityID
	  join Sales.PersonCreditCard as PCC on P.BusinessEntityID=PCC.BusinessEntityID
	  join Sales.CreditCard as CC on PCC.CreditCardID=CC.CreditCardID
	    join Sales.SalesOrderHeader as SOH on CC.CreditCardID= SOH.CreditCardID
where P.FirstName= 'Jordan' and P.LastName='Green' 
