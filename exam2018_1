--1 kreirati bazu sa default postavkama
create database IB160065
go
--2a kreirati tabele 
use IB160065
go

create table Autori(
AutorID nvarchar(11) constraint PK_Autori primary key,
Prezime nvarchar(25) not null,
Ime nvarchar(25) not null,
Telefon nvarchar(20) default null,
DatumKreiranjaZapisa date not null default getdate(),
DatumModifikovanjaZapisa date default null
);

create table Izdavaci(
IzdavacID nvarchar(4) constraint PK_Izdavac primary key,
Naziv nvarchar(100) constraint UQ_Naziv unique not null,
Biljeske nvarchar(1000) default 'Lorem ipsum',
DatumKreiranjaZapisa date not null default sysdatetime(),
DatumModifikovanjaZapisa date default null
);

use IB160065
go

create table Naslovi(
NaslovID nvarchar(6) primary key,
IzdavacID nvarchar(4) constraint FK_Naslovi_Izdavac foreign key references Izdavaci(IzdavacID),
Naslov nvarchar(100) not null,
Cijena money,
DatumIzdavanja date not null default sysdatetime(),
DatumKreiranjaZapisa date not null default sysdatetime(),
DatumModifikovanjaZapisa date default null
);

create table NasloviAutori(
AutorID nvarchar(11) constraint FK_Autori foreign key references Autori(AutorID),
NaslovID nvarchar(6) constraint FK_Naslov foreign key references Naslovi(NaslovID),
DatumKreiranjaZapisa date not null default sysdatetime(),
DatumModifikovanjaZapisa date default null,
constraint PK_NasloviAutori primary key (AutorID,NaslovID)
);

--2b putem podupita importovati podatke u tabele iz baze pubs
insert into Autori(AutorID,Prezime,Ime,Telefon)
select  au.au_id,au.au_lname, au.au_fname,phone
from pubs.dbo.authors as au
where au_id in ( select a.au_id
from pubs.dbo.authors as a)
order by newid()

select* from Autori
delete from Autori

insert into Izdavaci(IzdavacID,Naziv,Biljeske)
select P.pub_id, P.pub_name,  cast(PI.pr_info as nvarchar(100))
from pubs.dbo.publishers  as P join pubs.dbo.pub_info as PI
on P.pub_id=PI.pub_id
order by newid()

select* from Izdavaci

insert into Naslovi(NaslovID,IzdavacID,Naslov,Cijena,DatumIzdavanja)
select title_id, pub_id, title, price,pubdate
from pubs.dbo.titles

select* from Naslovi

insert into NasloviAutori(AutorID,NaslovID)
select au_id, title_id
from pubs.dbo.titleauthor

select* from NasloviAutori

--2c kreirati tabelu Gradovi, importovati podatke u tabelu Gradovi iz baze pubs i modifikovati tabelu Autori, te dodati spoljni ključ prema tabeli Gradovi
create table Gradovi(
GradID int identity(5,5) constraint PK_Grad primary key,
Naziv nvarchar(100) not null constraint UQ_NazivGradovi unique,
DatumKreiranjaZapisa date not null default sysdatetime(),
DatumModifikovanjaZapisa date default null
);

insert into Gradovi(Naziv)
select distinct city 
from pubs.dbo.authors
where city is not null

select* from Gradovi

alter table Autori 
add GradID int constraint FK_GradAutori foreign key references Gradovi(GradID)

select* from Autori
--2d kreirati uskladištene procedure za setovanje grada u tabeli Autori
create procedure proc_ModifikacijaAutora_Gradovi
as 
begin
update Autori 
set GradID = (select GradID
            from Gradovi 
		    where Naziv='San Francisco')
where AutorID in (select top 10 AutorID
                  from Autori)
end;

exec proc_ModifikacijaAutora_Gradovi
go

select *from Autori 
go


create proc proc_ModifikacijaAutora_Berkeley
as 
begin
update Autori 
set GradID= (select GradID
             from Gradovi
			 where Naziv='Berkeley') 
where GradID is null 
end;

exec proc_ModifikacijaAutora_Berkeley
go

select* from Autori

--3 kreiranje pogleda 
create view view_autori_izdavaci
as 
select A.Prezime+' '+A.Ime as 'Ime i prezime autora', G.Naziv as Grad, N.Naslov, N.Cijena, I.Naziv as Izdavac, I.Biljeske
from Autori as A join Gradovi as G on A.GradID=G.GradID join NasloviAutori as NA 
on A.AutorID=NA.AutorID join Naslovi as N on NA.NaslovID=N.NaslovID join Izdavaci as I 
on N.IzdavacID=I.IzdavacID
where (N.Cijena>10 and N.Cijena is not null) and I.Naziv like '_%&%_' and G.Naziv like 'San Francisco'

select* from view_autori_izdavaci
go

--4 modifikovanje tabele Autori 
alter table Autori 
add Email nvarchar(100) default null
go

--5 kreirati procedure za modifikaciju kolone Email u tabeli Autori
create proc proc_autori_emailAdresa_sanFrancisco
as 
begin
update Autori 
set Email = Ime+'.'+Prezime+'@fit.ba' 
where GradID= ( select GradID 
                from Gradovi 
				where Naziv='San Francisco')
end;


exec proc_autori_emailAdresa_sanFrancisco
go 

select* from Autori
go


create proc proc_autori_emailAdresa_berkeley
as 
begin
update Autori 
set Email=Prezime+'.'+Ime+'@fit.ba'
where GradID=(select GradID
              from Gradovi
			  where Naziv='Berkeley') 
end;

exec proc_autori_emailAdresa_berkeley
go

select* from Autori
go

use IB160065
go

--6 kreirati lokalnu privremenu tabelu i popuniti je podacima iz baze AdventureWorks2014
select isnull(P.Title,'N/A') as Title, P.LastName, P.FirstName, E.EmailAddress,PP.PhoneNumber, CC.CardNumber, P.FirstName+'.'+P.LastName as UserName,
lower(replace(right(newid(),16),'-','7')) as Password
into #tempAdventureWorks
from AdventureWorks2014.Person.Person as P join AdventureWorks2014.Person.EmailAddress as E 
on P.BusinessEntityID=E.BusinessEntityID join AdventureWorks2014.Person.PersonPhone as PP 
on P.BusinessEntityID=PP.BusinessEntityID left join AdventureWorks2014.Sales.PersonCreditCard as PCC 
on P.BusinessEntityID=PCC.BusinessEntityID left join AdventureWorks2014.Sales.CreditCard as CC
on PCC.CreditCardID=CC.CreditCardID
order by P.LastName asc, P.FirstName asc 


select* from dbo.#tempAdventureWorks

--7 kreirati indeks nad temp tabelom
create nonclustered index IX_UserName on dbo.#tempAdventureWorks(UserName)
include(LastName, FirstName)

select *
from dbo.#tempAdventureWorks
where UserName like 'B%' and (FirstName like 'A%' or LastName like '[BS]%')
go

--8 kreirati proceduru za brisanje podataka iz temp tabele
create procedure proc_delete_nocreditcard
as
begin
  delete from dbo.#tempAdventureWorks
  where CardNumber is null 
end;

exec proc_delete_nocreditcard


--9 backup baze na default lokaciju servera
backup database IB160065 
to DISK='IB160065.bak'

drop table dbo.#tempAdventureWorks
go

use IB160065 
go

--10a kreirati proceduru za brisanje svih zapisa iz svih tabela
create proc proc_deleteAllData
as 
begin
 delete from NasloviAutori
 delete from Naslovi
 delete from Autori 
 delete from Izdavaci
 delete from Gradovi 
end;


exec proc_deleteAllData
go

select* from Autori
select* from Naslovi
select* from Izdavaci
select* from NasloviAutori
select* from Gradovi

use master 
go

--10b restore rezervne kopije 
restore database IB160065
from disk='IB160065.bak'
with replace 

use IB160065
go

select* from Autori
select* from Naslovi
select* from Izdavaci
select* from NasloviAutori
select* from Gradovi

