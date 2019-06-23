use master
go
--1
create database IB170064 
on primary  
( name='IB170064', filename='E:\BP2\data\IB170064.mdf')
log on 
(name='IB170064_log', filename='E:\BP2\log\IB170064_log.ldf')
go

--2
use IB170064
go

create table Proizvodi(
ProizvodID int not null identity(1,1) constraint PK_Proizvod primary key,
Sifra nvarchar(25) not null constraint UQ_Sifra unique,
Naziv nvarchar(50) not null,
Kategorija nvarchar(50) not null,
Cijena decimal(18,2) not null
);

create table Narudzbe(
NarudzbaID int not null identity(1,1) constraint PK_Narudzba primary key,
BrojNarudzbe nvarchar(25) not null constraint UQ_BrojNarudzbe unique,
Datum date not null,
Ukupno decimal(18,2) not null);

create table StavkeNarudzbe(
ProizvodID int not null constraint FK_Proizvod foreign key references Proizvodi(ProizvodID),
NarudzbaID int not null constraint FK_Narudzba foreign key references Narudzbe(NarudzbaID),
constraint PK_ProizvodNarudzbe primary key(ProizvodID,NarudzbaID),
Kolicina int not null,
Cijena decimal(18,2) not null,
Popust decimal(18,2) not null,
Iznos decimal(18,2) not null);

--3
--a)
set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID,Sifra,Naziv,Kategorija,Cijena)
select distinct P.ProductID, P.ProductNumber, P.Name, PC.Name, P.ListPrice
from AdventureWorks2014.Production.Product as P join AdventureWorks2014.Production.ProductSubcategory as PS
     on P.ProductSubcategoryID=PS.ProductSubcategoryID join AdventureWorks2014.Production.ProductCategory as PC
	 on PS.ProductCategoryID=PC.ProductCategoryID join AdventureWorks2014.Sales.SalesOrderDetail as SOD
	 on P.ProductID=SOD.ProductID join AdventureWorks2014.Sales.SalesOrderHeader as SOH
	 on SOD.SalesOrderID=SOH.SalesOrderID
where year(SOH.OrderDate)=2014
set identity_insert Proizvodi off

--b)
set identity_insert Narudzbe on
insert into Narudzbe (NarudzbaID,BrojNarudzbe,Datum,Ukupno)
select SOH.SalesOrderID,SOH.SalesOrderNumber, SOH.OrderDate, SOH.TotalDue
from AdventureWorks2014.Sales.SalesOrderHeader as SOH
where  year(SOH.OrderDate)=2014
set identity_insert Narudzbe off

--c)
insert into StavkeNarudzbe(ProizvodID,NarudzbaID,Kolicina,Cijena,Popust,Iznos)
select P.ProductID, SOH.SalesOrderID, SOD.OrderQty, SOD.UnitPrice, SOD.UnitPriceDiscount,SOD.LineTotal
from AdventureWorks2014.Sales.SalesOrderDetail as SOD join AdventureWorks2014.Sales.SalesOrderHeader as SOH
    on SOD.SalesOrderID=SOH.SalesOrderID join AdventureWorks2014.Production.Product as P
	on SOD.ProductID=P.ProductID
where year(SOH.OrderDate)=2014

--4
create table Skladista(
SkladisteID int not null identity(1,1) constraint PK_Skladiste primary key,
Naziv nvarchar(30) not null);

create table SkladistaProizvodi(
SkladisteID int not null constraint FK_Skladiste foreign key references Skladista(SkladisteID),
ProizvodID int not null constraint FK_Proizvodi foreign key references Proizvodi(ProizvodID),
constraint PK_SkladisteProizvod primary key(SkladisteID,ProizvodID),
Kolicina int not null);

--5
insert into Skladista
values ('Skladiste1'), ('Skladiste2'),('Skladiste3')

insert into SkladistaProizvodi
select 1, ProizvodID,0
from Proizvodi

insert into SkladistaProizvodi
select 2, ProizvodID,0
from Proizvodi

insert into SkladistaProizvodi
select 3, ProizvodID,0
from Proizvodi

--6
create proc proc_SkladisteKolicina_Update
( @ProizvodID int,
  @SkladisteID int,
  @Kolicina int)
as
begin
update SkladistaProizvodi
set Kolicina+=@Kolicina
where ProizvodID=@ProizvodID and SkladisteID=@SkladisteID
end;

select* from SkladistaProizvodi
exec  proc_SkladisteKolicina_Update 707,1,132

--7
create nonclustered index ix_Proizvodi on Proizvodi (Sifra,Naziv)

select Sifra,Naziv
from Proizvodi
where Naziv='HL Bottom Bracket'

--8
create trigger tr_Proizvodi_BeforeDelete 
on Proizvodi instead of delete as 
begin 
 print('Zabranje brisanje zapisa');
 rollback;
end;

delete from Proizvodi 
where Naziv='HL Bottom Bracket'

--9
create view view_Proizvod 
as 
select P.Sifra, P.Naziv, P.Cijena, sum(SN.Kolicina) 'Ukupna prodana kolicina',
       sum((SN.Cijena-SN.Cijena*SN.Popust)*SN.Kolicina) 'Ukupna zarada'
from Proizvodi as P join StavkeNarudzbe as SN on P.ProizvodID=SN.ProizvodID
group by P.Sifra, P.Naziv, P.Cijena

--10
create proc proc_Proizvodi_Zarada
@Sifra nvarchar(25)=null
as
begin
 select Naziv,[Ukupna prodana kolicina],[Ukupna zarada]
 from view_Proizvod
 where Sifra=@Sifra or @Sifra is null
end;

exec proc_Proizvodi_Zarada
exec proc_Proizvodi_Zarada 'FR-R92B-44'

--11
create login student 
with password='test',
default_database=IB170064

create user Sejla for login student 
grant execute on object::dbo.view_Proizvod to Sejla

--12
backup database IB170064
to disk='E:\BP2\Backup\IB170064.bak'


backup database IB170064
to disk='E:\BP2\Backup\IB170064_diff.bak'
with differential
