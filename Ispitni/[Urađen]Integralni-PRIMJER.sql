use master 
go
--1
create database IB160065 
go

use IB160065
go

create table Studenti(
StudentID int not null identity(1,1) constraint PK_Student primary key,
BrojDosijea nvarchar(10) not null constraint UQ_BrojDosijea unique nonclustered,
Ime nvarchar(35) not null,
Prezime nvarchar(35) not null,
GodinaStudija int not null,
NacinStudiranja nvarchar(10) not null default 'Redovan',
Email nvarchar(50) 
);

create table Predmeti(
PredmetID int not null identity(1,1) constraint PK_Predmet primary key,
Naziv nvarchar(100) not null,
Oznaka nvarchar(10) not null constraint UQ_Oznaka unique );

create table Ocjene(
StudentID int not null constraint FK_Student foreign key references Studenti(StudentID),
PredmetID int not null constraint FK_Predmet foreign key references Predmeti(PredmetID),
constraint PK_StudentPredmet primary key(StudentID,PredmetID),
Ocjena int not null,
Bodovi decimal not null,
DatumPolaganja date not null);

--2
insert into Predmeti(Naziv,Oznaka)
values ('Baze podataka 2','BP2'), 
	   ('Programiranje 1','PR1'),
	   ('Web razvoj i dizajn','WRD')

select* from Predmeti

insert into Studenti(BrojDosijea,Ime,Prezime,GodinaStudija,Email)
select C.AccountNumber, P.FirstName, P.LastName,2, EA.EmailAddress
from AdventureWorks2014.Sales.Customer as C join AdventureWorks2014.Person.Person as P 
on C.PersonID=P.BusinessEntityID join AdventureWorks2014.Person.EmailAddress as EA 
on P.BusinessEntityID=EA.BusinessEntityID

select* from Studenti

--3
create proc proc_Ocjene_Insert
( 
	@StudentID int, 
	@PredmetID int,
	@Ocjena int,
	@Bodovi decimal(18,2),
	@DatumPolaganja date
)
as
begin
insert into Ocjene(StudentID,PredmetID,Ocjena,Bodovi,DatumPolaganja)
values (@StudentID,@PredmetID, @Ocjena,@Bodovi,@DatumPolaganja)
end;

select* from Studenti
select* from Predmeti

declare @datum date=getdate()
exec proc_Ocjene_Insert 11,1,10,99,@DatumPolaganja= @datum
exec proc_Ocjene_Insert 12,2,10,99, @datum
exec proc_Ocjene_Insert 13,3,8,69, @datum
exec proc_Ocjene_Insert 14,1,9,93, @datum
exec proc_Ocjene_Insert 18,2,6,63, @datum

select* from Ocjene

--4
--Import/Export Wizard

--5
--a)
 create nonclustered index IX_Person_LastFirstName on Person.Person 
 (LastName, FirstName) include (Title)
 --b)
 select FirstName,LastName,Title
 from Person.Person
 where FirstName like '%ye%'

 --c)
 alter index IX_Person_LastFirstName on Person.Person
 disable;
--d)
create clustered index IX_CreditCard on Sales.CreditCard (CreditCardID)
--e)
create nonclustered index IX_CR_CardNumber on Sales.CreditCard (CardNumber)
include (ExpMonth,ExpYear)

--6
create view view_Person_Vista as 
select  P.LastName, P.FirstName, CC.CardNumber, CC.CardType
from Person.Person as P join Sales.PersonCreditCard AS PCC 
on P.BusinessEntityID=PCC.BusinessEntityID join Sales.CreditCard as CC
on PCC.CreditCardID=CC.CreditCardID
where CC.CardType='Vista' and P.Title is null

--7
 backup database IB160065 to
 disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB160065.bak'

 backup database IB160065 to 
 disk='C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\IB160065_diff.bak'
 with differential

--8
create login Student
with password='test'

create user Sejla for login Student

--9
create proc proc_Pretraga_ViewPerson 
(	
	@FirstName nvarchar(50)=null,
	@LastName nvarchar(50)=null,
	@CardNumber nvarchar(25)=null
)
as 
begin
   select * 
   from view_Person_Vista
   where (LastName = @LastName OR LastName LIKE @LastName + '%' OR @LastName IS NULL)
          AND (FirstName = @FirstName OR FirstName LIKE @FirstName + '%' OR @FirstName IS NULL)
          AND (CardNumber = @CardNumber OR @CardNumber IS NULL)
end;

select* from view_Person_Vista

exec proc_Pretraga_ViewPerson
exec proc_Pretraga_ViewPerson @LastName='Gu'
exec proc_Pretraga_ViewPerson @LastName='Gutierrez'
exec proc_Pretraga_ViewPerson @LastName='Gutierrez', @FirstName='Andy'
exec proc_Pretraga_ViewPerson @LastName='Gutierrez',@FirstName='Andy',@CardNumber='11118540184148'

--10
create proc proc_CreditCard_Delete
 @CardNumber nvarchar(25)
as
begin

delete from Sales.PersonCreditCard
where CreditCardID= (select CreditCardID
					 from Sales.CreditCard
					 where CardNumber=@CardNumber)

delete from Sales.CreditCard
where CardNumber=@CardNumber
end;

select* from Sales.CreditCard where  CardNumber='77774915718248'
select* from Sales.PersonCreditCard as PCC join Sales.CreditCard as CC on PCC.CreditCardID=CC.CreditCardID
where CC.CardNumber='77774915718248'

exec proc_CreditCard_Delete '77774915718248'
