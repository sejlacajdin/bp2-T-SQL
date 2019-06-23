use master

--1
create database IB150005
go

use IB150005
go

create table Klijenti(
KlijentID int not null identity(1,1) constraint PK_Klijent primary key,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null,
Telefon nvarchar(20) not null,
Mail nvarchar(50) not null constraint UQ_Mail unique,
BrojRacuna nvarchar(15) not null,
KorisnickoIme nvarchar(20) not null,
Lozinka nvarchar(20) not null);

create table Transakcije(
TransakcijaID int not null identity(1,1) constraint PK_Transakcija primary key,
Datum datetime not null,
TipTransakcije nvarchar(30) not null,
PosiljalacID int not null constraint FK_Posiljalac foreign key references Klijenti(KlijentID),
PrimalacID int not null constraint FK_Primalac foreign key references Klijenti(KlijentID),
Svrha nvarchar(50) not null,
Iznos decimal(18,2) not null);

--2
--a)
insert  into Klijenti (Ime,Prezime,Telefon,Mail,BrojRacuna,KorisnickoIme,Lozinka)
select top 10 P.FirstName, P.LastName, PP.PhoneNumber, EA.EmailAddress, C.AccountNumber,
       LOWER(P.FirstName+'.'+P.LastName) as 'Korisnicko ime',right(PAS.PasswordHash,8)  as 'Password'
from AdventureWorks2014.Sales.Customer as C join AdventureWorks2014.Person.Person as P 
     on C.PersonID=P.BusinessEntityID join AdventureWorks2014.Person.PersonPhone as PP
	 on P.BusinessEntityID=PP.BusinessEntityID join AdventureWorks2014.Person.EmailAddress as EA
	 on P.BusinessEntityID=EA.BusinessEntityID join AdventureWorks2014.Person.Password as PAS
	 on P.BusinessEntityID=PAS.BusinessEntityID
--b)

select* from Klijenti
insert into Transakcije 
values(getdate(), 'jednostrana' , 361, 362, 'poklon', 500),
(getdate(), 'dvostrana' , 362, 363, 'naknada', 350.50),
(getdate(), 'jednostrana' , 363, 364, 'poklon', 500),
(getdate(), 'dvostrana' , 364, 365, 'poklon', 400),
(getdate(), 'jednostrana' , 365, 366, 'poklon', 25),
(getdate(), 'jednostrana' , 366, 367, 'poklon', 530),
(getdate(), 'jednostrana' , 367, 368, 'poklon', 500),
(getdate(), 'jednostrana' , 368, 369, 'poklon', 500),
(getdate(), 'jednostrana' , 369, 370, 'poklon', 346),
(getdate(), 'jednostrana' , 370, 361, 'poklon', 222)

select* from Transakcije

--3
--a)
create nonclustered index ix_Klijenti on Klijenti (Ime,Prezime)
include (BrojRacuna)
--b)
select Ime,Prezime, BrojRacuna
from Klijenti
where BrojRacuna='AW00011006'
--c)
alter index ix_Klijenti on Klijenti
disable;

--4
create proc proc_KlijentiInsert
(  @Ime nvarchar(30),
   @Prezime nvarchar(30),
   @Telefon nvarchar(20) ,
   @Mail nvarchar(50) ,
   @BrojRacuna nvarchar(15),
   @KorisnickoIme nvarchar(20),
   @Lozinka nvarchar(20)
   )
as
begin
insert into Klijenti
values( @Ime, @Prezime,@Telefon,@Mail, @BrojRacuna, @KorisnickoIme, @Lozinka)
end;

exec proc_KlijentiInsert 'Sejla','Cajdin','060333444','sejla.cajdin@edu.fit.ba','AW00011027','sejla.cajdin','djaods97-.1'

select* from Klijenti

--5
create view view_Transakcija
as
select T.Datum, T.TipTransakcije, (select K.Ime+' '+K.Prezime from Klijenti as K where K.KlijentID=T.PosiljalacID) as 'Posiljalac',
       (select K.BrojRacuna from Klijenti as K where K.KlijentID=T.PosiljalacID) as 'Broj racuna posiljaoca',
      K.Ime+' '+K.Prezime as 'Primalac', K.BrojRacuna as 'Broj racuna primaoca', T.Svrha, T.Iznos
from Transakcije as T join Klijenti as K on T.PrimalacID=K.KlijentID

--6
create proc proc_BrojRacunaTransakcije
 @BrojRacuna nvarchar(15)
as
begin 
select *
from view_Transakcija as T
where  T.[Broj racuna posiljaoca]=@BrojRacuna
end

exec proc_BrojRacunaTransakcije 'AW00011005'

--7
select year(T.Datum) as Godina,sum(T.Iznos) Iznos
from Transakcije as T 
group by year(T.Datum)
order by Godina 

--8
create proc proc_KlijentiDelete
 @KlijentID int
as
begin 

delete from Transakcije 
where @KlijentID in (PosiljalacID,PrimalacID)

delete from Klijenti
where @KlijentID=KlijentID
end;

select* from Transakcije
select* from Klijenti
exec proc_KlijentiDelete 362

--9
create proc proc_PretragaView
( @BrojRacuna nvarchar(15)=null,
  @Prezime nvarchar(30)=null)
as 
begin
select *
from view_Transakcija
where (@BrojRacuna is null or [Broj racuna posiljaoca]=@BrojRacuna) and 
      (@Prezime is null or substring(Posiljalac, CHARINDEX(' ',Posiljalac,0)+1,len(Posiljalac)) =@Prezime)
end;

exec proc_PretragaView
exec proc_PretragaView @BrojRacuna='AW00011008'
exec proc_PretragaView @Prezime='Verhoff'
exec proc_PretragaView @Prezime='Verhoff', @BrojRacuna='AW00011008'


--10
backup database IB150005
to disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB150005.bak'

backup database IB150005
to disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB150005_diff.bak'
with differential
