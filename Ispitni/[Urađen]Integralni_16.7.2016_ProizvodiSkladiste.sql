use master
go
--1
create database IB160065
go

use IB160065
go

create table Proizvodi(
ProizvodID int not null identity(1,1) constraint PK_Proizvod primary key,
Sifra nvarchar(10) not null constraint UQ_Sifra unique,
Naziv nvarchar(50) not null,
Cijena decimal(18,2) not null);

create table Skladista(
SkladisteID int not null identity(1,1) constraint PK_Skladiste primary key,
Naziv nvarchar(50) not null,
Oznaka nvarchar(10) not null constraint UQ_Oznaka unique,
Lokacija nvarchar(50) not null);


create table SkladisteProizvodi(
ProizvodID int not null constraint FK_Proizvod foreign key references Proizvodi(ProizvodID),
SkladisteID int not null constraint FK_Skladiste foreign key references Skladista(SkladisteID),
constraint PK_ProizvodiSkladiste primary key(ProizvodID,SkladisteID),
Stanje decimal(18,2) not null);

--2 
--a)
insert into Skladista (Naziv, Oznaka, Lokacija)
values('Skladiste1','SK1','Mostar'),
      ('Skladiste2','SK2','Sarajevo'),
	  ('Skladiste3','SK3','Zenica')

select* from Skladista

--b)
insert into Proizvodi(Sifra,Naziv,Cijena)
select top 10 P.ProductNumber,P.Name, P.ListPrice
from AdventureWorks2014.Production.Product as P join AdventureWorks2014.Production.ProductSubcategory as PS 
     on P.ProductSubcategoryID=PS.ProductSubcategoryID join AdventureWorks2014.Production.ProductCategory as PC
	 on PS.ProductCategoryID=PC.ProductCategoryID left join AdventureWorks2014.Sales.SalesOrderDetail as SOD
	 on P.ProductID=SOD.ProductID
where PC.Name like 'Bikes'
group by P.ProductNumber,P.Name, P.ListPrice,PC.Name
order by sum(SOD.OrderQty) desc

select* from Proizvodi

--c)
insert into SkladisteProizvodi(SkladisteID,ProizvodID,Stanje)
select 1, ProizvodID, 100
from Proizvodi

insert into SkladisteProizvodi(SkladisteID,ProizvodID,Stanje)
select 2, ProizvodID, 100
from Proizvodi

insert into SkladisteProizvodi(SkladisteID,ProizvodID,Stanje)
select 3, ProizvodID, 100
from Proizvodi

select* from SkladisteProizvodi


--3
create proc proc_povecajStanje
(  @Proizvod nvarchar(50), 
   @Skladiste nvarchar(50),
   @Kolicina int)
as 
begin
update SkladisteProizvodi 
set Stanje=Stanje+@Kolicina
where SkladisteProizvodi.ProizvodID= (select P.ProizvodID
		from Proizvodi as P
		where @Proizvod like P.Naziv) and 
		SkladisteID=(select S.SkladisteID
		from Skladista as S
		where @Skladiste=S.Naziv)
end;

exec proc_povecajStanje 'Mountain-200 Black, 38','Skladiste1', 250

select *
from SkladisteProizvodi as SK join Proizvodi as P on SK.ProizvodID=P.ProizvodID
where P.Naziv='Mountain-200 Black, 38'

--4
--a)
create nonclustered index IX_Proizvodi on Proizvodi(Sifra,Naziv)
include(Cijena)
--b)
select Sifra,Naziv,Cijena
from Proizvodi
--c) 
alter index IX_Proizvodi on Proizvodi
disable;

--5
create view view_ProizvodSkladiste
as
select P.Sifra,P.Naziv as Proizvod,P.Cijena,S.Oznaka,S.Naziv as Skladiste, S.Lokacija, SP.Stanje
from Proizvodi as P join SkladisteProizvodi as SP on P.ProizvodID=SP.ProizvodID
     join Skladista as S on SP.SkladisteID=S.SkladisteID

--6
create proc proc_ZalihaNaSkladistima
@Sifra nvarchar(10)
as 
begin 
select Sifra, Proizvod, Cijena, sum(Stanje) as 'Stanje na zalihama'
from view_ProizvodSkladiste
where Sifra=@Sifra
group by Sifra,Proizvod,Cijena
end;

exec proc_ZalihaNaSkladistima 'BK-M68B-38'

--7
create proc proc_UnesiProizvod
(
@Sifra nvarchar(10),
@Naziv nvarchar(50),
@Cijena decimal(18,2)
)
as
begin 
insert into Proizvodi (Sifra,Naziv, Cijena)
values(@Sifra,@Naziv,@Cijena)

insert into SkladisteProizvodi 
values((select P.ProizvodID from Proizvodi as P
where P.Naziv=@Naziv and P.Sifra=@Sifra and P.Cijena=@Cijena),1,0),
     ((select P.ProizvodID from Proizvodi as P
where P.Naziv=@Naziv and P.Sifra=@Sifra and P.Cijena=@Cijena),2,0),
((select P.ProizvodID from Proizvodi as P
where P.Naziv=@Naziv and P.Sifra=@Sifra and P.Cijena=@Cijena),3,0)
end;

exec proc_UnesiProizvod '1234', 'Cokolada', '2.5'

select* from SkladisteProizvodi as SP join Proizvodi as P 
             on SP.ProizvodID=P.ProizvodID
			 where P.Sifra='1234'

--8
create proc proc_DeleteProizvod
@Sifra nvarchar(10)
as 
begin 
delete from SkladisteProizvodi
where ProizvodID=(select ProizvodID
                  from Proizvodi 
				  where Sifra=@Sifra)
delete from Proizvodi
where Sifra=@Sifra
end;

exec proc_DeleteProizvod '1234'
select* from SkladisteProizvodi 

--9
create proc proc_PretragaViewa
( @Sifra nvarchar(10)=null,
  @Oznaka nvarchar(10)=null,
  @Lokacija nvarchar(50)=null)
as
begin
select* from view_ProizvodSkladiste
where (@Sifra is null or @Sifra=Sifra) and (@Oznaka is null or @Oznaka=Oznaka) and (@Lokacija is null or @Lokacija=Lokacija)
end;

select* from Proizvodi
select* from Skladista
exec proc_PretragaViewa 
exec proc_PretragaViewa @Sifra='BK-M68B-42'
exec proc_PretragaViewa @Sifra='BK-M68B-42', @Oznaka='SK2'
exec proc_PretragaViewa  @Sifra='BK-M68B-42', @Lokacija='Sarajevo'
exec proc_PretragaViewa  @Sifra='BK-M68B-42',@Oznaka='SK2', @Lokacija='Sarajevo'

--10
backup database IB160065
to disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB160065.bak'

backup database IB160065
to disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB160065_diff.bak'
with differential
