use master 
go
--1
create database _IB160065
go
use _IB160065
go

--a)
create table Narudzba(
NarudzbaID int not null constraint PK_Narudzba primary key,
Kupac nvarchar(40),
PunaAdresa nvarchar(80),
DatumNarudzbe date,
Prevoz money,
Uposlenik nvarchar(40),
GradUposlenika nvarchar(30),
DatumZaposlenja date,
BrGodStaza int);

--b)
create table Proizvod(
ProizvodID int not null constraint PK_Proizvod primary key,
NazivProizvoda nvarchar(40),
NazivDobavljaca nvarchar(40),
StanjeNaSklad int,
NarucenaKol int);

--c)
create table DetaljiNarudzbe(
NarudzbaID int not null constraint FK_Narudzba foreign key references Narudzba(NarudzbaID),
ProizvodID int not null constraint FK_Proizvod foreign key references Proizvod(ProizvodID),
constraint PK_NarudzbaProizvod primary key(NarudzbaID,ProizvodID),
CijenaProizvoda money,
Kolicina int not null,
Popust real);

--2
--a)
insert into Narudzba
select O.OrderID, C.CompanyName, C.Address+' - '+C.PostalCode+' - '+C.City, O.OrderDate, O.Freight,
       E. LastName+' '+E.FirstName, E.City, E.HireDate, DATEDIFF(year,E.HireDate,GETDATE())
from NORTHWND.dbo.Orders as O join NORTHWND.dbo.Customers as C on O.CustomerID=C.CustomerID
     join NORTHWND.dbo.Employees as E on O.EmployeeID=E.EmployeeID

--b)
insert into Proizvod 
select P.ProductID, P.ProductName, S.CompanyName, P.UnitsInStock, P.UnitsOnOrder
from NORTHWND.dbo.Products as P join NORTHWND.dbo.Suppliers as S on P.SupplierID=S.SupplierID

--c)
insert into DetaljiNarudzbe
select OD.OrderID,OD.ProductID, round(OD.UnitPrice,0), OD.Quantity, OD.Discount
from NORTHWND.dbo.[Order Details] as OD

--3
--a)
alter table Narudzba 
add SifraUposlenika nvarchar(20) constraint duzina_pass check(len(SifraUposlenika)=15)
--b)
alter table Narudzba nocheck constraint duzina_pass
update N 
set SifraUposlenika= reverse(Na.GradUposlenika+' '+left(Na.DatumZaposlenja,10))
from Narudzba as N join Narudzba as Na on N.NarudzbaID=Na.NarudzbaID

--c)
update Narudzba 
set SifraUposlenika=left(newid(),20)
where GradUposlenika like '%d'
select * from Narudzba where GradUposlenika like '%d'

alter table Narudzba check constraint duzina_pass
--4
create view view_Narudzbe_Detalji
as 
select N.Uposlenik, N.SifraUposlenika, count(P.NazivProizvoda) as 'Ukupan broj proizvoda'
from Narudzba as N join DetaljiNarudzbe as DN on N.NarudzbaID=DN.NarudzbaID
     join Proizvod as P on DN.ProizvodID=P.ProizvodID
where len(N.SifraUposlenika)=20
group by N.Uposlenik, N.SifraUposlenika
having count(P.NazivProizvoda)>2

select* from view_Narudzbe_Detalji
order by [Ukupan broj proizvoda] desc

--5
create proc proc_Narudzbe_SifraUposlenika
as
begin
update N
set N.SifraUposlenika= left(Na.SifraUposlenika,4)
from Narudzba as N join Narudzba as Na on N.NarudzbaID=Na.NarudzbaID
where len(N.SifraUposlenika)=20
end;

exec proc_Narudzbe_SifraUposlenika
go

select * from Narudzba

--6
create view view_Proizvod_Ukupno
as
select P.NazivProizvoda, round(sum((DN.CijenaProizvoda-DN.CijenaProizvoda*DN.Popust)*DN.Kolicina),2) as Ukupno
from Proizvod as P join DetaljiNarudzbe as DN on P.ProizvodID=DN.ProizvodID
where P.NarucenaKol>0
group by P.NazivProizvoda
having round(sum((DN.CijenaProizvoda-DN.CijenaProizvoda*DN.Popust)*DN.Kolicina),2)>10000

select* from view_Proizvod_Ukupno 
order by Ukupno desc

--7
--a)
create view view_Kupac_Proizvod
as
select N.Kupac, P.NazivProizvoda, sum(DN.CijenaProizvoda) as 'Suma po cijeni proizvoda'
from Narudzba as N join DetaljiNarudzbe as DN on N.NarudzbaID=DN.NarudzbaID
     join Proizvod as P on DN.ProizvodID=P.ProizvodID
group by N.Kupac, P.NazivProizvoda
having sum(DN.CijenaProizvoda)> (select avg(CijenaProizvoda)
                                 from DetaljiNarudzbe)

select * from view_Kupac_Proizvod
order by [Suma po cijeni proizvoda] 

--b)
create proc proc_Kupac_SumaPoCijeni
( @Kupac nvarchar(40)=null,
  @NazivProizvoda nvarchar(40)=null,
 @SumaPoCijeni money=null)
as
begin 
select * from view_Kupac_Proizvod
where (Kupac=@Kupac or @Kupac is null) and (NazivProizvoda=@NazivProizvoda or @NazivProizvoda is null) 
      and ([Suma po cijeni proizvoda]=@SumaPoCijeni or @SumaPoCijeni is null)
group by Kupac, NazivProizvoda,[Suma po cijeni proizvoda]
having @SumaPoCijeni> (select avg([Suma po cijeni proizvoda]) from view_Kupac_Proizvod) or @SumaPoCijeni is null
end;

exec proc_Kupac_SumaPoCijeni
exec proc_Kupac_SumaPoCijeni @Kupac='Hanari Carnes'
exec proc_Kupac_SumaPoCijeni @NazivProizvoda='Côte de Blaye'
exec proc_Kupac_SumaPoCijeni @SumaPoCijeni=124

--8
--a)
create nonclustered index ix_Proizvod on Proizvod (NazivDobavljaca) 
include(StanjeNaSklad,NarucenaKol)

select NazivDobavljaca,StanjeNaSklad,NarucenaKol
from Proizvod
where NarucenaKol>5
--b)
alter index ix_Proizvod on Proizvod 
disable;

--9
backup database _IB160065
to disk='_IB160065.bak'

--10
create proc proc_delete_procView
as
begin
 drop view view_Narudzbe_Detalji
 drop proc proc_Narudzbe_SifraUposlenika
 drop view view_Proizvod_Ukupno
 drop view view_Kupac_Proizvod
 drop proc proc_Kupac_SumaPoCijeni
end;

exec proc_delete_procView
go

--11 (Dodatno, nije na ispitu)
use master 
go

restore database _IB160065
from disk='_IB160065.bak'
with replace

use _IB160065
go
