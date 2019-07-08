use AdventureWorks2014
go

--a)
select P.FirstName+' '+P.LastName as 'Employee', convert(varchar,E.HireDate,104) as 'Hire date', EA.EmailAddress, sum(SOD.OrderQty*SOD.UnitPrice) as 'Zarada'
from HumanResources.Employee as E join Person.Person as P on E.BusinessEntityID=P.BusinessEntityID
     join Person.EmailAddress as EA on P.BusinessEntityID=EA.BusinessEntityID join Sales.SalesPerson as SP 
	 on E.BusinessEntityID=SP.BusinessEntityID join Sales.SalesOrderHeader as SOH 
	 on SP.BusinessEntityID=SOH.SalesPersonID join Sales.SalesTerritory as ST 
	 on SOH.TerritoryID=ST.TerritoryID join Sales.SalesOrderDetail as SOD 
	 on SOH.SalesOrderID=SOD.SalesOrderID
where ST.[Group] like 'Europe' and month(SOH.OrderDate)=1 and year(SOH.OrderDate)=2014
group by P.FirstName,P.LastName, E.HireDate,EA.EmailAddress
order by Zarada desc

--b)
select P.FirstName,P.LastName, CC.CardType,CC.CardNumber, sum(SOH.SubTotal) as 'Ukupno'
from Person.Person as P join Sales.PersonCreditCard as PCC on P.BusinessEntityID=PCC.BusinessEntityID
     join Sales.CreditCard as CC on PCC.CreditCardID=CC.CreditCardID
	 join Sales.SalesOrderHeader as SOH on CC.CreditCardID=SOH.CreditCardID
group by P.FirstName,P.LastName, CC.CardType,CC.CardNumber
having count(SOH.CreditCardID)>20

--1
use master
go
create database IB1600065
on primary 
(name='IB1600065',filename='E:\DBMS\Data\IB1600065.mdf')
log on
(name='IB1600065_log',filename='E:\DBMS\Log\IB1600065_log.ldf')

--2
use IB1600065
go
create table Kandidati(
KandidatID int not null identity(1,1) primary key,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null,
JMBG nvarchar(13) not null constraint UQ_JMBG unique,
DatumRodjenja date not null, 
MjestoRodjenja nvarchar(30), 
Telefon nvarchar(20),
Email nvarchar(50) constraint UQ_Email unique);
go
create table Testovi(
TestID int not null identity(1,1) constraint PK_Test primary key,
Datum datetime not null, 
Naziv nvarchar(50) not null, 
Oznaka nvarchar(10) not null constraint UQ_Oznaka unique,
Oblast nvarchar(50) not null, 
MaxBrojBodova int not null, 
Opis nvarchar(250)
);
go

create table RezultatiTesta(
Polozio bit not null, 
OsvojeniBodovi decimal(18,2) not null,
Napomena nvarchar(max), 
KandidatID int not null constraint FK_Kandidat foreign key(KandidatID) references Kandidati(KandidatID),
TestID int not null constraint FK_Testovi foreign key(TestID) references Testovi(TestID),
constraint FK_RezultatiTesta primary key(KandidatID,TestID)
); 
go

--3
insert into Kandidati(Ime,Prezime, JMBG,DatumRodjenja,MjestoRodjenja,Telefon,Email)
select top 10 P.FirstName, P.LastName, right(REPLACE(C.rowguid,'-',0),13), C.ModifiedDate, A.City,PP.PhoneNumber, EA.EmailAddress
from AdventureWorks2014.Person.Person as P join AdventureWorks2014.Sales.Customer as C 
    on P.BusinessEntityID=C.PersonID join AdventureWorks2014.Person.BusinessEntityAddress as BEA
	on P.BusinessEntityID=BEA.BusinessEntityID join AdventureWorks2014.Person.Address as A 
	on BEA.AddressID=A.AddressID join AdventureWorks2014.Person.PersonPhone as PP 
	on P.BusinessEntityID=PP.BusinessEntityID join AdventureWorks2014.Person.EmailAddress as EA 
	on P.BusinessEntityID=EA.BusinessEntityID

insert into Testovi (Datum,Naziv,Oznaka,Oblast,MaxBrojBodova)
values (GETDATE(),'Baze podataka 2','BP2', 'SQL', 80),
       (GETDATE(),'Programiranje 3','PR3', 'OOP', 100),
	    (GETDATE(),'Statistika','SIV', 'Dinamika', 70)

go
--4
create proc usp_RezultatiTesta_Insert
( @Polozio bit,
  @OsvojeniBodovi decimal(18,2),
  @Napomena nvarchar(max)=null,
  @KandidatID int,
  @TestID int)
as
begin
 insert into RezultatiTesta(Polozio,OsvojeniBodovi,Napomena,KandidatID,TestID)
 values (@Polozio, @OsvojeniBodovi, @Napomena, @KandidatID,@TestID)
end;
go

select* from Kandidati

exec usp_RezultatiTesta_Insert 1,65,'', 1,1
exec usp_RezultatiTesta_Insert 1,87,'', 2,1
exec usp_RezultatiTesta_Insert 0,45,'', 3,2
exec usp_RezultatiTesta_Insert 1,76,'', 4,1
exec usp_RezultatiTesta_Insert 0,33,'', 4,3
exec usp_RezultatiTesta_Insert 1,66,'', 1,3
exec usp_RezultatiTesta_Insert 1,91,'', 2,2
exec usp_RezultatiTesta_Insert 0,53,'', 1,2
exec usp_RezultatiTesta_Insert 1,55,'', 7,1
exec usp_RezultatiTesta_Insert 0,12,'', 10,1
go

--5
create view view_Rezultati_Testiranja
as
select K.Ime, K.Prezime, K.JMBG, K.Telefon, K.Email, T.Datum, T.Naziv, T.Oznaka, T.Oblast, T.MaxBrojBodova,
       RT.Polozio, RT.OsvojeniBodovi, substring(cast(RT.OsvojeniBodovi/T.MaxBrojBodova*100 as nvarchar),0,charindex('.',cast(RT.OsvojeniBodovi/T.MaxBrojBodova*100 as nvarchar))) +' %' as 'Procentualni rezultat testa'
from Kandidati as K join RezultatiTesta as RT on K.KandidatID=RT.KandidatID
     join Testovi as T on RT.TestID=T.TestID
go

--6
create proc usp_RezultatiTesta_SelectByOznaka(
 @OznakaTesta nvarchar(10),
 @Polozio bit)
as
begin 
select Ime, Prezime, [Procentualni rezultat testa]
from view_Rezultati_Testiranja 
where Oznaka=@OznakaTesta and Polozio=@Polozio
end;
go

exec usp_RezultatiTesta_SelectByOznaka 'BP2',0
go

--7
create proc usp_RezultatiTesta_Update(
 @KandidatID int,
 @TestID int,
 @RezultatTestiranja decimal(18,2))
as 
begin
update RezultatiTesta
set OsvojeniBodovi=@RezultatTestiranja
where KandidatID=@KandidatID and TestID=@TestID 
end;
go

exec usp_RezultatiTesta_Update 1,1,72

select * from RezultatiTesta where KandidatID=1

--8
create proc usp_Testovi_Delete
 @TestID int 
as 
begin 
delete from RezultatiTesta
where TestID=@TestID

delete from Testovi
where TestID=@TestID
end;
go

exec usp_Testovi_Delete 1
go
--9
create trigger tr_delete_RezultatiTesta
on RezultatiTesta instead of delete as 
begin
print N'Nedozvoljena operacija!'
rollback;
end;


delete from RezultatiTesta 
where TestID=2

--10
backup database IB1600065
to disk='E:\DBMS\Backup'

