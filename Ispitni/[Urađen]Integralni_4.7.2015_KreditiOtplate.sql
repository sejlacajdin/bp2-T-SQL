--KVALIFIKACIJSKI ZADACI
--a)
use master 
go

use AdventureWorks2014
go

select P.FirstName, P.LastName, SOH.OrderDate, PP.Name
from Sales.Customer as C join Person.Person as P on C.PersonID=P.BusinessEntityID
     join Sales.SalesOrderHeader as SOH on C.CustomerID=SOH.CustomerID
	 join Sales.SalesOrderDetail as SOD on SOH.SalesOrderID=SOD.SalesOrderID
	 join Production.Product as PP on SOD.ProductID=PP.ProductID
where month(SOH.OrderDate)=5 and year(SOH.OrderDate)=2014 and PP.Name='Front Brakes' and SOD.OrderQty>5

--b) 
select top 5 P.Name,  sum(SOD.OrderQty) 'Kolicina prodaje'
from Production.Product as P join [Production].[ProductSubcategory] as PS on P.ProductSubcategoryID=PS.ProductSubcategoryID
     join Sales.SalesOrderDetail as SOD on P.ProductID=SOD.ProductID 
	 join Sales.SalesOrderHeader as SOH on SOD.SalesOrderID=SOH.SalesOrderID 
	 join Sales.SalesTerritory as ST on SOH.TerritoryID=ST.TerritoryID
where PS.Name='Mountain Bikes' and ST.Name='Canada'
group by P.Name 
order by 2 desc


--1
create database IB123321
on primary 
(name='IB123321', filename='E:\DBMS\Data\IB123321.mdf')
log on
(name='IB123321_log', filename='E:\DBMS\Log\IB123321_log.ldf')

--2
use IB123321
go

create table Klijenti(
KlijentID int not null identity(1,1) constraint PK_Klijent primary key,
JMBG nvarchar(13) not null constraint UQ_JMBG unique,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null,
Adresa nvarchar(100) not null,
Telefon nvarchar(20) not null, 
Email nvarchar(50) constraint UQ_Email unique,
Kompanija nvarchar(50));

create table Krediti(
KreditID int not null identity(1,1) constraint PK_Kredit primary key,
KlijentID int not null constraint FK_Klijent foreign key references Klijenti(KlijentID),
Datum date not null,
Namjena nvarchar(50) not null,
Iznos decimal(18,2) not null,
BrojRata int not null,
Osiguran bit not null,
Opis nvarchar(max));

create table Otplate(
OtplateID int not null identity(1,1) constraint PK_Otplate primary key,
KreditID int not null constraint FK_Kredit foreign key references Krediti(KreditID),
Datum date not null,
Iznos decimal(18,2) not null,
Rata int not null,
Opis nvarchar(max));

--3
insert into Klijenti
select top 10 right(REPLACE(C.rowguid,'-',1),13), P.FirstName, P.LastName, A.AddressLine1, PP.PhoneNumber, EA.EmailAddress,'FIT'
from AdventureWorks2014.Sales.Customer as C join AdventureWorks2014.Person.Person as P 
on C.PersonID=P.BusinessEntityID join AdventureWorks2014.Person.BusinessEntityAddress as BA
on P.BusinessEntityID=BA.BusinessEntityID join AdventureWorks2014.Person.Address as A
on BA.AddressID=A.AddressID join AdventureWorks2014.Person.PersonPhone as PP 
on P.BusinessEntityID=PP.BusinessEntityID join AdventureWorks2014.Person.EmailAddress as EA 
on P.BusinessEntityID=EA.BusinessEntityID

select* from Klijenti

insert into Krediti
values (1,getdate(), 'Stambeni Kredit', 25000, 96, 1, 'Opis1'),
       (2, '11.01.1990', 'Stambeni Kredit', 50000, 108, 0, ' '),
       (3, '11.01.1990', 'Stambeni Kredit', 125000, 132, 1, ' ')
	  
--4
create proc usp_Otplate_Insert
(@KreditID int, 
@Datum date,
@Iznos decimal(18,2),
@Rata int)
as 
begin
insert into Otplate (KreditID,Datum,Iznos,Rata)
values(@KreditID,@Datum,@Iznos, @Rata) 
end;

declare @datum date=getdate()
exec usp_Otplate_Insert 3, @datum,500,25
exec usp_Otplate_Insert 2, @datum,100,12
exec usp_Otplate_Insert 1, @datum,340,23
exec usp_Otplate_Insert 3, @datum,900,3
exec usp_Otplate_Insert 2, @datum,670,10


select* from Otplate

--5
create view view_Krediti_Otplate 
as
select K.JMBG,K.Ime,  K.Prezime, K.Adresa, K.Telefon, K.Email, KR.Datum, KR.Namjena, KR.Iznos,
       count(O.KreditID) 'Broj otplaćenih rata', sum(O.Iznos) 'Ukupan otplaćeni iznos'
from Klijenti as K join Krediti as KR on K.KlijentID=KR.KlijentID
     join Otplate as O on KR.KreditID=O.KreditID
group by K.JMBG,K.Ime,  K.Prezime, K.Adresa, K.Telefon, K.Email, KR.Datum, KR.Namjena, KR.Iznos

--6
create proc usp_Krediti_Otplate_SelectByJMBG
@JMBG nvarchar(13)
as
begin
select [Broj otplaćenih rata], [Ukupan otplaćeni iznos]
from view_Krediti_Otplate 
where JMBG=@JMBG
end;

exec usp_Krediti_Otplate_SelectByJMBG '16A8F99D59794'

--7
alter proc usp_Otplate_Update
( @OtplateID int,
@KreditID int,
  @Datum date,
  @Iznos decimal(18,2),
  @Rata int)
as
begin 
update Otplate
set Datum=@Datum, KreditID=@KreditID, Iznos=@Iznos, Rata=@Rata
where OtplateID=@OtplateID
end;

select* from Otplate

declare @dat date= getdate()
exec usp_Otplate_Update 1,3, @dat, 234,1

--8
create proc usp_Krediti_Delete
@KreditID int
as 
begin
delete from Otplate
where KreditID=@KreditID

delete from Krediti
where KreditID=@KreditID 
end;

exec usp_Krediti_Delete 2
--9
create trigger tr_Otplate_IO_Delete
on Otplate instead of delete as 
begin
 print'Nedozovljeno brisanje'
 rollback;
end;


delete from Otplate
where OtplateID=1

--10
backup database IB123321
to disk='E:\DBMS\Backup\IB123321.bak'
