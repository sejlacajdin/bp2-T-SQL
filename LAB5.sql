--Zadatak 1 
use NORTHWND
go
select top 1 C.ContactName, C.Address, C.Phone, cast(sum(OD.UnitPrice*OD.Quantity) as nvarchar)+' KM' 'Ukupno utrošeno'
from Customers as C join Orders As O on C.CustomerID=O.CustomerID 
     join [Order Details] as OD on O.OrderID=OD.OrderID
where C.City='London' and month(O.OrderDate)='2'
group by C.ContactName, C.Address, C.Phone
order by [Ukupno utrošeno] 

--Zadatak 2
use pubs 
go
select E.fname, E.lname, min(S.qty) 'Minimalna količina', max(S.qty) 'Maksimalna količina', avg(S.qty) 'Srednja količina',
       sum(S.qty) 'Ukupno'
from employee as E join publishers as P on E.pub_id=P.pub_id
     join titles as T on P.pub_id=T.pub_id 
	 join sales as S on T.title_id=S.title_id
group by E.fname, E.lname
having sum(S.qty)>100 and avg(S.qty) between 20 and 25

--Zadatak 3
use AdventureWorks2014
go
select distinct P.FirstName, P.LastName, EA.EmailAddress, CC.CardType,CC.CardNumber,CC.ExpYear
from Sales.Customer as C join Person.Person as P on C.PersonID=P.BusinessEntityID
     join Person.EmailAddress as EA on P.BusinessEntityID=EA.BusinessEntityID
	 join Sales.PersonCreditCard as PCC on P.BusinessEntityID= PCC.BusinessEntityID
	 join Sales.CreditCard as CC on PCC.CreditCardID=CC.CreditCardID 
	left join Sales.SalesOrderHeader as SOH on CC.CreditCardID=SOH.CreditCardID
where CC.CardType='Vista' and CC.ExpYear=2008
order by P.LastName
