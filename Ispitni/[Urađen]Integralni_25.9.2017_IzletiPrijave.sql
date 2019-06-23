use master
go

--1) 1. Kroz SQL kod napraviti bazu podataka koja nosi ime vašeg broja dosijea, a zatim u svojoj bazi podataka kreirati
--tabele sa sljedećom strukturom:
--a) Klijenti
--i. Ime, polje za unos 50 karaktera (obavezan unos)
--ii. Prezime, polje za unos 50 karaktera (obavezan unos)
--iii. Drzava, polje za unos 50 karaktera (obavezan unos)
--iv. Grad, polje za unos 50 karaktera (obavezan unos)
--v. Email, polje za unos 50 karaktera (obavezan unos)
--vi. Telefon, polje za unos 50 karaktera (obavezan unos)
--b) Izleti
--i. Sifra, polje za unos 10 karaktera (obavezan unos)
--ii. Naziv, polje za unos 100 karaktera (obavezan unos)
--iii. DatumPolaska, polje za unos datuma (obavezan unos)
--iv. DatumPovratka, polje za unos datuma (obavezan unos)
--v. Cijena, polje za unos decimalnog broja (obavezan unos)
--vi. Opis, polje za unos dužeg teksta (nije obavezan unos)
--c) Prijave
--i. Datum, polje za unos datuma i vremena (obavezan unos)
--ii. BrojOdraslih polje za unos cijelog broja (obavezan unos)
--iii. BrojDjece polje za unos cijelog broja (obavezan unos)
--Napomena: Na izlet se može prijaviti više klijenata, dok svaki klijent može prijaviti više izleta. Prilikom prijave
--klijent je obavezan unijeti broj odraslih i broj djece koji putuju u sklopu izleta.

create database IB140045
go

use IB140045
go

create table Klijenti(
KlijentID int not null identity(1,1) constraint PK_Klijent primary key,
Ime nvarchar(50) not null,
Prezime nvarchar(50) not null,
Drzava nvarchar(50) not null,
Grad nvarchar(50) not null,
Email nvarchar(50) not null,
Telefon nvarchar(50) not null
);

create table Izleti(
IzletID int not null identity(1,1) constraint PK_Izlet primary key,
Sifra nvarchar(10) not null,
Naziv nvarchar(100) not null,
DatumPolaska date not null,
DatumPovratka date not null,
Cijena decimal(18,2) not null,
Opis nvarchar(max));

create table Prijave(
KlijentID int not null constraint FK_Klijent foreign key references Klijenti(KlijentID),
IzletID int not null constraint FK_Izlet foreign key references Izleti(IzletID),
constraint PK_KlijentIzlet primary key(KlijentID,IzletID),
Datum datetime not null,
BrojOdraslih int not null,
BrojDjece int not null
);

 
--2)
/*Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeće podatke:
a) U tabelu Klijenti prebaciti sve uposlenike koji su radili u odjelu prodaje (Sales)
i. FirstName -> Ime
ii. LastName -> Prezime
iii. CountryRegion (Name) -> Drzava
iv. Addresss (City) -> Grad
v. EmailAddress (EmailAddress) -> Email (Između imena i prezime staviti tačku)
vi. PersonPhone (PhoneNumber) -> Telefon
b) U tabelu Izleti dodati 3 izleta (proizvoljno)*/
insert into Klijenti (Ime,Prezime,Drzava,Grad,Email,Telefon)
select P.FirstName, P.LastName, CR.Name, A.City, P.FirstName+'.'+P.LastName+'@gmail.com' as Email, PP.PhoneNumber
from AdventureWorks2014.HumanResources.Employee as E join AdventureWorks2014.Person.Person as P
     on E.BusinessEntityID=P.BusinessEntityID join AdventureWorks2014.Person.BusinessEntityAddress as BEA
	 on P.BusinessEntityID=BEA.BusinessEntityID join AdventureWorks2014.Person.Address as A 
	 on BEA.AddressID=A.AddressID join AdventureWorks2014.Person.StateProvince as SP 
	 on A.StateProvinceID=SP.StateProvinceID join AdventureWorks2014.Person.CountryRegion as CR 
	 on SP.CountryRegionCode=CR.CountryRegionCode join AdventureWorks2014.Person.PersonPhone as PP
	 on P.BusinessEntityID=PP.BusinessEntityID join AdventureWorks2014.HumanResources.EmployeeDepartmentHistory as EDH
	 on E.BusinessEntityID=EDH.BusinessEntityID join AdventureWorks2014.HumanResources.Department as D 
	 on EDH.DepartmentID=D.DepartmentID
where  D.Name like 'Sales'


insert into Izleti (Sifra,Naziv,DatumPolaska,DatumPovratka,Cijena)
values ('Izlet1','Boracko','11.11.2018',GETDATE(),50),
       ('Izlet2','Ramsko','07.07.2018',getdate(),75),
	   ('Izlet3','Sarajevo','01.06.2018',GETDATE(),90)

--3)Kreirati uskladištenu proceduru za unos nove prijave. Proceduri nije potrebno proslijediti parametar Datum.
--Datum se uvijek postavlja na trenutni. Koristeći kreiranu proceduru u tabelu Prijave dodati 10 prijava.
create proc proc_NovaPrijava
( @ImeKlijenta nvarchar(20),
  @PrezimeKlijenta nvarchar(20),
  @Izlet nvarchar(50),
  @BrojOdraslih int,
  @BrojDjece int)
as 
begin 
insert into Prijave (KlijentID,IzletID,Datum,BrojOdraslih,BrojDjece)
values ((select KlijentID from Klijenti where Ime=@ImeKlijenta and Prezime=@PrezimeKlijenta),
        (select IzletID from Izleti where Naziv=@Izlet),GETDATE(),@BrojOdraslih,@BrojDjece)
end;

select* from Klijenti

exec proc_NovaPrijava 'Brian','Welcker','Boracko',2,2
exec proc_NovaPrijava 'Stephen','Jiang','Sarajevo',5,10
exec proc_NovaPrijava 'Michael','Blythe','Boracko',6,3
exec proc_NovaPrijava 'Linda','Mitchell','Ramsko',9,1
exec proc_NovaPrijava 'Jillian','Carson','Ramsko',2,3
exec proc_NovaPrijava 'Garrett','Vargas','Sarajevo',3,3
exec proc_NovaPrijava 'Tsvi','Reiter','Boracko',2,2
exec proc_NovaPrijava 'Pamela','Ansman-Wolfe','Sarajevo',2,4
exec proc_NovaPrijava 'Shu','Ito','Ramsko',4,5
exec proc_NovaPrijava 'José','Saraiva','Sarajevo',10,2
exec proc_NovaPrijava 'Syed','Abbas','Ramsko',4,5


select* from Prijave

--4)Kreirati index koji će spriječiti dupliciranje polja Email u tabeli Klijenti. Obavezno testirati ispravnost kreiranog
--indexa.
create unique nonclustered index IX_DupliciranjeKlijenti on Klijenti ( Email )

update Klijenti 
set Email='Stephen.Jiang@gmail.com'
where KlijentID=1

--5)Svim izletima koji imaju više od 3 prijave cijenu umanjiti za 10%

update Izleti
set Cijena= Cijena-Cijena*0.1
where IzletID in(select IzletID
         from Prijave
		 group by IzletID
		 having COUNT(IzletID)>3)

select* from Izleti

--6)
/*Kreirati view (pogled) koji prikazuje podatke o izletu: šifra, naziv, datum polaska, datum povratka i cijena, te
ukupan broj prijava na izletu, ukupan broj putnika, ukupan broj odraslih i ukupan broj djece. Obavezno prilagoditi
format datuma (dd.mm.yyyy).*/
create view view_Izlet
as 
select I.Sifra, I.Naziv,convert(nvarchar,I.DatumPolaska,104) as 'Datum polaska',convert(nvarchar, I.DatumPovratka,104)as 'Datum povratka', I.Cijena, count(P.KlijentID) as 'Broj prijava', sum(P.BrojOdraslih+P.BrojDjece) as 'Broj putnika',
       sum(P.BrojOdraslih) as 'Broj odraslih', sum(P.BrojDjece) as 'Broj djece'
from Izleti as I join Prijave as P on I.IzletID=P.IzletID 
group by I.Sifra, I.Naziv, I.DatumPolaska, I.DatumPovratka, I.Cijena

select* from view_Izlet

--7)
/*Kreirati uskladištenu proceduru koja će na osnovu unesene šifre izleta prikazivati zaradu od izleta i to sljedeće
kolone: naziv izleta, zarada od odraslih, zarada od djece, ukupna zarada. Popust za djecu se obračunava 50% na
ukupnu cijenu za djecu. Obavezno testirati ispravnost kreirane procedure.*/
create proc proc_IzletZarada
@Sifra nvarchar(10)
as
begin
select I.Naziv, I.Cijena*sum(P.BrojDjece)*0.5 as 'Zarada od djece', I.Cijena*sum(P.BrojOdraslih) as 'Zarada od odraslih',
       I.Cijena*(sum(P.BrojDjece)*0.5+sum(P.BrojOdraslih)) as 'Ukupna zarada'
from Izleti as I join Prijave as P on I.IzletID=P.IzletID
where Sifra=@Sifra
group by I.Naziv, I.Cijena
end;

exec proc_IzletZarada 'Izlet2'

--8)
/*a) Kreirati tabelu IzletiHistorijaCijena u koju je potrebno pohraniti identifikator izleta kojem je cijena izmijenjena,
datum izmjene cijene, staru i novu cijenu. Voditi računa o tome da se jednom izletu može više puta mijenjati
cijena te svaku izmjenu treba zapisati u ovu tabelu.
b) Kreirati trigger koji će pratiti izmjenu cijene u tabeli Izleti te za svaku izmjenu u prethodno kreiranu tabelu
pohraniti podatke izmijeni.
c) Za određeni izlet (proizvoljno) ispisati sljdedeće podatke: naziv izleta, datum polaska, datum povratka,
trenutnu cijenu te kompletnu historiju izmjene cijena tj. datum izmjene, staru i novu cijenu.*/
create table IzletiHistorijaCijena(
HistorijaID int not null identity(1,1) constraint PK_Historija primary key,
IzletID int,
Datum date,
StaraCijena int,
NovaCijena int)

create trigger tr_IzmjenaCijena 
on Izleti after update as 
insert into IzletiHistorijaCijena(IzletID,Datum,StaraCijena,NovaCijena)
select d.IzletID, getdate(), d.Cijena, (select i.Cijena from inserted as i)
from deleted as d

update Izleti
set Cijena=10
where Sifra='Izlet1'


update Izleti
set Cijena=80
where Sifra='Izlet1'

select I.Naziv, I.DatumPolaska,I.DatumPovratka, I.Cijena as 'Trenutna cijena', IHC.Datum, IHC.StaraCijena, IHC.NovaCijena
from Izleti as I join IzletiHistorijaCijena as IHC on I.IzletID=IHC.IzletID 

--9) Obrisati sve klijente koji nisu imali niti jednu prijavu na izlet
delete from Klijenti 
where KlijentID not in (select KlijentID from Prijave)

 --10) Kreirati full i diferencijalni backup baze podataka na lokaciju servera D:\BP2\Backup

 backup database IB140045
 to disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB140045.bak'

 backup database IB140045
 to disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB140045_diff.bak'
 with differential
