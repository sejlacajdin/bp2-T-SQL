--SP INSERT
use NORTHWND
go
create procedure proc_Products_Insert
( 
	@ProductName nvarchar(40),
	@SupplierID int=null,
	@CategoryID int=null,
	@QuantityPerUnit nvarchar(20)=null,
	@UnitPrice money=null,
	@UnitsInStock smallint=null,
	@UnitsOnOrder smallint=null,
	@ReorderLevel smallint=null,
	@Discontinued bit
)
as 
begin 
insert into Products
values(@ProductName,@SupplierID,@CategoryID ,@QuantityPerUnit,@UnitPrice,@UnitsInStock,@UnitsOnOrder,@ReorderLevel,@Discontinued)
end;

exec proc_Products_Insert @ProductName='Coca Cola', 
                          @SupplierID=1,
						  @CategoryID=1,
						  @UnitPrice=5,
						  @UnitsInStock=50,
						  @UnitsOnOrder=0,
						  @Discontinued=1

select * from Products where ProductName like 'Coca%'

--SP UPDATE 
use NORTHWND 
go

create proc proc_Products_Update
( 
    @ProductID int,
	@ProductName nvarchar(40),
	@SupplierID int=null,
	@CategoryID int=null,
	@QuantityPerUnit nvarchar(20)=null,
	@UnitPrice money=null,
	@UnitsInStock smallint=null,
	@UnitsOnOrder smallint=null,
	@ReorderLevel smallint=null,
	@Discontinued bit
)
as 
begin
update Products
set  ProductName=@ProductName,
     SupplierID= @SupplierID,
	 CategoryID= @CategoryID ,
	 QuantityPerUnit= @QuantityPerUnit,
	 UnitPrice= @UnitPrice,
	 UnitsInStock= @UnitsInStock, 
	 UnitsOnOrder= @UnitsOnOrder,
	 ReorderLevel= @ReorderLevel,
	 Discontinued= @Discontinued
	 where ProductID= @ProductID
end;


exec proc_Products_Update  @ProductName='Coca Cola', 
                          @SupplierID=1,
						  @CategoryID=1,
						  @UnitPrice=7,
						  @UnitsInStock=50,
						  @UnitsOnOrder=0,
						  @Discontinued=1,
						  @ProductID=1078

select * from Products where ProductName like 'Coca%'


create proc proc_Products_Delete 
( 
    @ProductID int
)
as 
begin
delete from  Products
	 where ProductID= @ProductID
end;


exec proc_Products_Delete 1078


-- Primjer 1
create procedure proc_OrderDetails_Insert
(
	@OrderID int,
	@ProductID int,
	@UnitePrice money,
	@Quantity smallint, 
	@Discount real
)
as 
begin
   insert into [Order Details]
   values (@OrderID, @ProductID, @UnitePrice, @Quantity, @Discount)

   update Products
   set UnitsInStock-=@Quantity
   where ProductID=@ProductID
end;

exec proc_OrderDetails_Insert 10249,1,2,5,0.1

select* from Orders
select* from [Order Details] where OrderID=10249
select* from Products where ProductID=1


--Primjer 2 
create proc proc_Products_SelectByProductNameOrCategory
( 
	@ProductName nvarchar(40)=null,
	@CategoryID int=null

)
as
begin
   select ProductName, UnitPrice, UnitsInStock, UnitsOnOrder
   from Products
   where (ProductName=@ProductName or @ProductName is null) and (CategoryID=@CategoryID or @CategoryID is null)
end;

exec proc_Products_SelectByProductNameOrCategory 'Chai'

exec proc_Products_SelectByProductNameOrCategory @CategoryID= 2

exec proc_Products_SelectByProductNameOrCategory 'Aniseed Syrup', 2

exec proc_Products_SelectByProductNameOrCategory
