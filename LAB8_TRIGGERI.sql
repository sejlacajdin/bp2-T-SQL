-- Kreiranje DML triggera 

create database Test23 
go

use Test23
go

create table Kupci 
(	
	KupacID int primary key identity (1,1),
	Ime nvarchar(50),
	Prezime nvarchar(50),
	Adresa nvarchar(100)
);

create table KupciAudit
(
	AuditID int primary key identity(1,1),
	KupacID int, 
	Ime nvarchar(50),
	Prezime nvarchar(50),
	Adresa nvarchar(100),
	Komanda nvarchar(10),
	Korisnik nvarchar(50),
	Datum datetime
);

--Kreiranje trigera koji prati insert u tabelu kupci 
create trigger tr_Kupci_Insert
on Kupci after insert as 
insert into KupciAudit (KupacID, Ime,Prezime,Adresa,Komanda,Korisnik,Datum)
select i.KupacID, i.Ime,i.Prezime,i.Adresa,'insert',SYSTEM_USER, GETDATE()
from inserted as i

insert into Kupci (Ime,Prezime,Adresa)
values ('Jasmin','Azemovic','FIT')
insert into Kupci (Ime, Prezime,Adresa)
values ('Admir', 'Šehidić','FIT')

select* from Kupci
select* from KupciAudit

-- DML after update trigger
create trigger tr_Kupci_Update
on Kupci after update as 
insert into KupciAudit(KupacID, Ime,Prezime,Adresa,Komanda,Korisnik,Datum)
select d.KupacID, d.Ime, d.Prezime, d.Adresa, 'update', SYSTEM_USER, GETDATE()
from deleted as d


update Kupci set Ime='Neko' where KupacID=2

select* from Kupci
select* from KupciAudit


create trigger tr_Kupci_Delete 
on Kupci after delete as 
insert into KupciAudit(KupacID,Ime,Prezime,Adresa,Komanda,Korisnik,Datum)
select d.KupacID,d.Ime,d.Prezime, d.Adresa, 'delete', SYSTEM_USER, GETDATE()
from deleted as d 


delete from Kupci where KupacID=2

select* from Kupci
select* from KupciAudit


create trigger tr_IUD
on Kupci after insert, update, delete as 
if exists (select* from inserted) and not exists (select* from deleted)
begin
insert into KupciAudit(KupacID,Ime, Prezime, Adresa, Komanda, Korisnik, Datum)
               select i.KupacID, i.Ime, i.Prezime, i.Adresa, 'insert', SYSTEM_USER, GETDATE()
from inserted as i
end
if exists( select* from inserted) and exists (select* from deleted)
begin
insert into KupciAudit(KupacID, Ime,Prezime, Adresa, Komanda, Korisnik,Datum)
select d.KupacID,d.Ime, d.Prezime, d.Adresa, 'update', system_user, GETDATE()
from deleted as d
end

if exists (select* from deleted) and not exists(select* from inserted)
begin
insert into KupciAudit(KupacID,Ime,Prezime,Adresa,Komanda,Korisnik,Datum)
select d.KupacID,d.Ime, d.Prezime, d.Adresa, 'delete', SYSTEM_USER,GETDATE()
from deleted as d
end

delete from KupciAudit

select* from Kupci
select* from KupciAudit

insert into Kupci values ('Admir', 'Šehidić','FIT')

update Kupci set Ime='Neko' where KupacID=3

delete from Kupci where KupacID=3

-- instead of trigger 
create trigger tr_Kupci_IO_Delete 
on Kupci instead of delete as 
begin
insert into KupciAudit(KupacID,Ime,Prezime,Adresa,Komanda,Korisnik,Datum)
select d.KupacID, d.Ime,d.Prezime, d.Adresa, 'delete', SYSTEM_USER,GETDATE()
from deleted as d 
end;

delete from Kupci where KupacID=1

select* from Kupci
select* from KupciAudit
