--1. Iz baze podataka AdventureWorks2014 je potrebno, putem podupita,
--importovati određeni broj zapise u tabelu Korisnici (koja će biti kreirana u run-time procesu).
-- Kolone koje su vam potrebne, nalaze se u više tabela.
-- a) Lista potrebnih kolona je: Title, LastName, FirstName, EmailAddress, PhoneNumber, CardNumber  o U koloni Title je potrebno sve
--  NULL vrijednosti zamijeniti sa N/A b) Također, potrebno je da kreirate dvije dodatne kolone prilikom  
--  import procedure: o Kolona UserName koja se sastoji od spojenih FirstName i LastName
--  (tačka se nalazi između) o Kolona Password se generiše tako što: LastName okrenemo
--  reverzno i od drugog slova uzmemo naredna četiri. Sa kolonom FirstName uraditi isto,
--  ali od drugog slova uzeti naredna dva. Iz kolone rowguid (tabela Person) od desetog
--  znaka uzeti narednih šest. o Dobivene tri stringa spojiti u jedan.
--c) Jedini uslov podupita jeste da se uključe one osobe koje imaju kreditnu karticu.

use AdventureWorks2014
go
select isnull(P.Title,'N/A') Title, P.FirstName, P.LastName, EA.EmailAddress, PP.PhoneNumber, CC.CardNumber,
       P.FirstName+'.'+P.LastName as UserName,substring(reverse(P.LastName),2,4)+SUBSTRING(reverse(P.FirstName),2,2)+
	   substring(cast(P.rowguid as nvarchar(40)),10,6) as [Password]
into Korisnici
from Person.Person as P join Person.EmailAddress as EA on P.BusinessEntityID=EA.BusinessEntityID
     join Person.PersonPhone as PP on P.BusinessEntityID=PP.BusinessEntityID 
	 join Sales.PersonCreditCard as PCC on P.BusinessEntityID=PCC.BusinessEntityID 
	 join Sales.CreditCard as CC on PCC.CreditCardID=CC.CreditCardID
where CC.CardNumber is not null

--1a. Iz tabele Korisnici prikazati sve zapise gdje podaci iz
-- kolone PhoneNumber u svome sadržaju nemaju  zagrade () i Title nije N/A  

select*
from Korisnici
where PhoneNumber not like '%(%' and PhoneNumber not like '%)%' and Title<>'N/A' 

--1b. U koloni Title, podatak Ms modifikovati u Ms. Izmjena se odnosi na sve zapise bez ograničenja
 
update Korisnici
set Title='Ms.'
where Title = 'Ms'

-- 1c. Obrisati sve korisnike sa titulom N/A

delete from Korisnici 
where Title='N/A'

--2. Za svakog zaposlenika, iz baze podataka AdventureWorks2014 vaš upit treba
--da vrati sljedeće kolone i podatke: a) LastName i FirstName spojeno (potreban je i alias)
--b) Kolone JobTitle, Gender i HireDate c) U obzir dolaze samo zaposlenici ženskog posla d) Naziv zaposlenja u svome imenu
--treba da sadrži riječ „Technician” (na bilo kojoj poziciji) ili riječ „Network” na početku naziva.
 
USE AdventureWorks2017
GO
select P.LastName+' '+P.FirstName as 'Ime i prezime', E.JobTitle, E.Gender, E.HireDate
from HumanResources.Employee as E join Person.Person as P on E.BusinessEntityID=P.BusinessEntityID
where E.Gender='F' and (E.JobTitle like '%Technician%' or E.JobTitle like 'Network%')

--3. Iz tabele Korisnici, koju ste kreirali u prvom zadatku,
-- upitom prebrojati i prikazati koliko ukupno ima pojedinih   titula.
USE AdventureWorks2017
GO
select count(Title) as 'Mr',
        (select count(Title) from Korisnici where Title like 'Mrs.') as 'Mrs',
		(select count(Title) from Korisnici where Title like 'Ms.') as 'Ms',
		(select count(Title) from Korisnici where Title like 'Sr.') as 'Sr.',
        (select count(Title) from Korisnici where Title like 'Sra.') as 'Sra'
from Korisnici
where  Title like 'Mr.'

 
--4. Za svakog zaposlenika iz baze podataka AdventureWorks2014, vaš upit treba da generiše sljedeće
-- kolone: Email, Lozinku i trenutnu starost uposlenika.  
-- a) Kolona Email se sastoji od spojenog imena i prezimena (odvojeno tačkom) i nastavka @edu.fit.ba (sve su mala slova).
--  b) Kolona Lozinka se generiše tako što spojite NationalIDNumber i LastName, od dobijenog stringa preskočite prva dva znaka
--  i uzmite narednih 8. Unutar stringa, karakter 1 zamijenite sa karakterom @
--  c) Generisati trenutnu starost uposlenika
--   d) Izlaz sortirati od najstarijeg prema najmlađem uposleniku
 
select  lower(P.FirstName+'.'+P.LastName+'@edu.fit.ba') as Email,replace(substring(E.NationalIDNumber+P.LastName,3,8),1,'@') as Password,
DATEDIFF(year,E.BirthDate,getdate()) as Starost
from HumanResources.Employee as E join Person.Person as P on E.BusinessEntityID=P.BusinessEntityID 
order by Starost desc

 
--5. Napisati upit koji za svaki proizvod, iz baze podataka AdventureWorks2014,
--ispisuje sljedeće podatke: Naziv (kategorije, podkategorije i proizvoda),
--boju proizvoda, standardnu cijenu, stvarnu cijenu, veličinu, potreban broj dana za proizvodnju,
-- početak/kraj prodaje i količinu svakog proizvoda na stanju.
-- Generisati novu kolonu koja prikazuje ukupan broj dana prodaje za svaki proizvod. Uslovi su:
--  a) Potreban broj dana za proizvodnju je veći od nula dana b) Proizvod je još uvijek u prodaji
--   c) Ukupan broj dana prodaje je veći od pet dana d) Proizvod mora imati definisani boju
--   e) Količina na stanju treba imati poznatu vrijednost f)
--Izlaz sortirati prema ukupnom broj dana prodaje (opadajući) i količini na stanju (opadajući).
 
 select P.Name as Product,PS.Name as Subcategory, PC.Name as Category, P.Color, P.StandardCost, P.ListPrice, P.Size,
       P.DaysToManufacture, P.SellStartDate, P.SellEndDate,sum(POD.StockedQty) as StockedQty,
	    datediff(DAY,P.SellStartDate,P.SellEndDate) as 'Broj dana prodaje'
from Production.Product as P join Production.ProductSubcategory as PS on P.ProductSubcategoryID=PS.ProductSubcategoryID
     join Production.ProductCategory as PC on PS.ProductCategoryID=PC.ProductCategoryID 
	 join Purchasing.PurchaseOrderDetail as POD on P.ProductID=POD.ProductID
where P.DaysToManufacture>0 and P.SellEndDate is null and P.Color is not null
group by P.Name,PS.Name, PC.Name, P.Color, P.StandardCost, P.ListPrice, P.Size,
       P.DaysToManufacture, P.SellStartDate, P.SellEndDate
order by [Broj dana prodaje] desc, StockedQty desc 
