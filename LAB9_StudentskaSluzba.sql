--1. Kreirati bazu podatka sa jednim data i jednim log fajlom. Imenovati je StudentskaSluzba. Prilikom kreiranje baze podataka za data fajl postaviti sljedeće parametre:
--Lokacija: C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA
--Veličina: inicijalno 5 MB,  maksimalna veličina neograničena
--Uvećanje: 10%
 
--Za Log fajl postaviti sljedeće paramtre:
--Lokacija: C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA
--Veličina: inicijalno 2 MB,  maksimalna veličina neograničena
--Uvećanje: 10%

create database StudentskaSluzba 
on primary 
(name='StudentskaSluzba_data', filename='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\StudentskaSluzba.mdf',size=5MB, maxsize=unlimited, filegrowth=10%)
log on
(name='StudentskaSluzba_log', filename='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\StudentskaSluzba.ldf',size=2MB, maxsize=unlimited,filegrowth=10%)


--2. Koristeći SQL::DDL komande kreirati sljedeće tabele i osigurati referencijalni integritet:
--Edukatori (Ime, Prezime, Titula, Email, Status, Slika)
--Predmeti (Naziv, Oznaka, ECTS [int])
--EdukatoriPredmeti (Edukator, Predmet, BrojSati)

use StudentskaSluzba
go

create table Edukatori(
EdukatorID int not null identity(1,1)  constraint  PK_Edukator primary key,
Ime nvarchar(35) not null,
Prezime nvarchar(35) not null,
Titula nvarchar(10),
Status bit default 1,
Slika varbinary(max)
);

create table Predmeti(
PredmetID int not null identity(1,1) constraint PK_Predmet primary key,
Naziv nvarchar(30) not null,
Oznaka nvarchar(5) not null,
ECTS int not null);

create table EdukatoriPredmeti(
EdukatorID int not null constraint FK_Edukator foreign key references Edukatori(EdukatorID),
PredmetID int not null constraint FK_Predmet foreign key references Predmeti(PredmetID),
BrojSati int not null,
primary key(EdukatorID,PredmetID)
);
 
--3. Također, kreirati tabelu Fakulteti (FakultetID,Naziv) i povezati je sa prethodno kreiranim tabelama Edukatori i EdukatoriPredmeti.
--Za polje ECTS u tabeli Predmeti izmijeniti tip podatka u DECIMAL.
create table Fakulteti(
FakultetID int not null identity(1,1) constraint FK_Fakultet primary key,
Naziv nvarchar(30) not null constraint UQ_Naziv unique nonclustered,
);

alter table Edukatori 
add FakultetID int not null constraint FK_Fakultet foreign key references Fakulteti(FakultetID)

alter table EdukatoriPredmeti
add FakultetID int not null  foreign key(FakultetID) references Fakulteti(FakultetID)

alter table Predmeti
alter column ECTS decimal(18,2)
--4. Uraditi INSERT podataka u tabele Fakulteti i Predmeti. Dodati 3 fakulteta i 3 predmeta

insert into Fakulteti(Naziv)
values ('FIT'), ('Mašinski fakultet') ,('Elektrotehnički fakultet')

select* from Fakulteti

insert into Predmeti(Naziv, Oznaka,ECTS)
values ('Uvod u baze podataka','UBP',5), 
       ('Sistemi za upravljanje bazama','DBMS',8),
	   ('Programiranje 2','PR2',8.5)

select* from Predmeti

--5. Kreirati INSERT, UPDATE i DELETE procedure za tabelu Edukatori, proslijediti sve parametre
create proc proc_Edukatori_Insert
( 
	@Ime nvarchar(35),
	@Prezime nvarchar(35),
	@Titula nvarchar(10),
	@Status bit=1,
	@Slika varbinary(max)=NULL,
	@FakuletID int
)
 as 
 begin
 insert into Edukatori(Ime, Prezime,Titula,Status,Slika, FakultetID)
 values (@Ime, @Prezime,@Titula, @Status, @Slika, @FakuletID)
 end;

 exec proc_Edukatori_Insert 'Jasmin','Azemović','profesor',1,null,1
 exec proc_Edukatori_Insert @Ime='Test', @Prezime='Test', @Titula='Test', @FakuletID=2

 select* from Edukatori

 create proc proc_Edukatori_Update
 (
   @EdukatorID int,
   @Ime nvarchar(35),
   @Prezime nvarchar(35),
   @Titula nvarchar(10),
   @Status bit=1, 
   @Slika varbinary(max)=NULL,
	@FakuletID int
 )
 as
 begin
 update Edukatori 
 set Ime= @Ime,
	Prezime=@Prezime,
	Titula=@Titula,
	Status=@Status,
	Slika=@Slika,
	FakultetID=@FakuletID
	where EdukatorID=@EdukatorID
 end;

 exec proc_Edukatori_Update 1, 'Jasmin', 'Azemović', 'prof.', 0,null,1

 create proc proc_Edukatori_Delete
 @EdukatorID int
 as
 begin
   delete from Edukatori 
   where EdukatorID=@EdukatorID
 end;

 exec proc_Edukatori_Delete 2

--6. Uraditi INSERT testnih podataka u tabelu EdukatoriPredmeti a zatim kreirati VIEW nad istom tabelom (prikazati ime i prezime
--edukatora i predmete koje predaje)

select* from Predmeti
insert into EdukatoriPredmeti(EdukatorID,PredmetID,BrojSati, FakultetID)
values (1,3,30,1), 
        (1,4,60,1)

select* from EdukatoriPredmeti

create view view_EdukatoriPredmeti
as
select E.Ime+' '+E.Prezime as 'Edukator', P.Naziv, EP.BrojSati
from EdukatoriPredmeti as EP join Edukatori as E on EP.EdukatorID=E.EdukatorID
join Predmeti as P on EP.PredmetID=P.PredmetID

select* from view_EdukatoriPredmeti

--7. Importovati 10 zapisa iz tabele Customer (baza NORTHWND) u tabelu Edukatori. Uraditi na tri načina: 
--SELECT kao podupit u INSERT komandi 
--SELECT INTO (koristeći temp tabelu)
--Koristeći Import/Export Wizard

--a)
insert into Edukatori (Ime, Prezime, Titula, FakultetID)
select top 10 SUBSTRING(ContactName,0, CHARINDEX(' ',ContactName,0)),SUBSTRING(ContactName, CHARINDEX(' ',ContactName,0)+1,len(ContactName)),left(substring(ContactTitle,0,CHARINDEX(' ',ContactTitle)),10),1
from NORTHWND.dbo.Customers
where CHARINDEX(' ',ContactName,0)<>0 and charindex(' ',ContactTitle)<>0

select* from Edukatori

--b)
select top 10 SUBSTRING(ContactName,0, CHARINDEX(' ',ContactName,0)) as Ime,SUBSTRING(ContactName, CHARINDEX(' ',ContactName,0)+1,len(ContactName)) as Prezime,left(substring(ContactTitle,0,CHARINDEX(' ',ContactTitle)),10) as Titula,1 as FakultetID
into #tempEdukatori
from NORTHWND.dbo.Customers
where CHARINDEX(' ',ContactName,0)<>0 and charindex(' ',ContactTitle)<>0
order by ContactName desc


select* from #tempEdukatori

insert into Edukatori(Ime,Prezime,Titula,FakultetID)
select * from #tempEdukatori

drop table #tempEdukatori


--8. Kreirati proceduru koja će na osnovu proslijeđenog parametra @Prezime vratiti edukatore kojima prezime počinje 
--tekstom koji proslijeđen u parametru 
create proc proc_Edukatori_Prezime
  @Prezime nvarchar(35)
as 
begin
select * 
from Edukatori
where Prezime like @Prezime+'%'
end;

exec proc_Edukatori_Prezime 'A'

--9. Kreirati trigger koji će u tabelu EdukatoriAudit zapisati detalje izmjene podataka nad tabelom Edukatori.
create table EdukatoriAudit(
 AuditID int not null primary key identity(1,1),
 EdukatorID int,
 Ime nvarchar(35),
 Prezime nvarchar(35),
 Titula nvarchar(10),
 Status bit default 1,
 Slika varbinary(max) null,
 Komanda nvarchar(10),
 Korisnik nvarchar(50),
 Datum datetime
);

create trigger tr_Edukatori_Update
on Edukatori after update as 
begin
insert into EdukatoriAudit (EdukatorID,Ime,Prezime,Titula,Status,Slika,Komanda,Korisnik,Datum)
select d.EdukatorID, d.Ime, d.Prezime, d.Titula, d.Status, d.Slika, 'update', SYSTEM_USER, GETDATE() 
from deleted as d
end;

update  Edukatori
set Ime='Jasko' where EdukatorID=1

select* from Edukatori
select* from EdukatoriAudit
