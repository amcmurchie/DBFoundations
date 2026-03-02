--*************************************************************************--
-- Title: Assignment06
-- Author: Alicia McMurchie
-- Desc: This file demonstrates how to use Views
-- Change Log: Alicia McMurchie, 3/1/2026, created views
-- 2017-01-01,Randal Root,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AMcMurchie')
	 Begin 
	  Alter Database [Assignment06DB_AMcMurchie] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AMcMurchie;
	 End
	Create Database Assignment06DB_AMcMurchie;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AMcMurchie;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
GO

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
-- SELECT * FROM Categories;
-- SELECT * FROM Products;
-- SELECT * FROM Inventories;
-- SELECT * FROM Employees;

CREATE VIEW vCategories
	WITH SCHEMABINDING
		AS SELECT CategoryID, CategoryName 
			FROM dbo.Categories;
GO

CREATE VIEW vProducts
	WITH SCHEMABINDING
		AS SELECT ProductID, ProductName, CategoryID, UnitPrice
			FROM dbo.Products;
GO

CREATE VIEW vInventories
	WITH SCHEMABINDING
		AS SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
			FROM dbo.Inventories;
GO

CREATE VIEW vEmployees
	WITH SCHEMABINDING
		AS SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
			FROM dbo.Employees;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories TO [public]; 
DENY SELECT ON Products TO [public]; 
DENY SELECT ON Inventories TO [public]; 
DENY SELECT ON Employees TO [public]; 
GO

GRANT SELECT ON vCategories TO [public]; 
GRANT SELECT ON vProducts TO [public]; 
GRANT SELECT ON vInventories TO [public]; 
GRANT SELECT ON vEmployees TO [public]; 
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Order by in view requires TOP designation
-- For all of these, I've started by using the SELECT statement and then added on the CREATE VIEW after confirming that the SELECT statement returns the correct values

CREATE VIEW vProductsByCategories
		AS
			SELECT TOP 10000 CategoryName, ProductName, UnitPrice 
				FROM vProducts JOIN vCategories
					ON vProducts.CategoryID = vCategories.CategoryID
						ORDER BY CategoryName, ProductName;
GO

-- SELECT * FROM vProductsByCategories;


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- This question uses a different ORDER BY statement than the question in Assignment 5, so I've changed the columns on which the results are ordered

CREATE VIEW vInventoriesByProductsByDates
		AS
			SELECT TOP 10000 ProductName, InventoryDate, [Count]
				FROM vInventories JOIN vProducts
					ON vInventories.ProductID = vProducts.ProductID
						ORDER BY ProductName, InventoryDate, [Count];
GO

-- SELECT * FROM vInventoriesByProductsByDates;

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE VIEW vInventoriesByEmployeesByDates
		AS
			SELECT TOP 10000 vInventories.InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName AS [EmployeeName]
				FROM vInventories JOIN vEmployees
					ON vInventories.EmployeeID = vEmployees.EmployeeID
						GROUP BY InventoryDate, EmployeeFirstName, EmployeeLastName
							ORDER BY InventoryDate;
GO

-- SELECT * FROM vInventoriesByEmployeesByDates;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategories
	AS
		SELECT TOP 10000 vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count
			FROM vCategories JOIN vProducts 
				ON vCategories.CategoryID = vProducts.CategoryID
			JOIN vInventories 
				ON vProducts.ProductID = vInventories.ProductID
					ORDER BY CategoryName, ProductName, InventoryDate, [Count]; 
GO

-- SELECT * FROM vInventoriesByProductsByCategories;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployees
	AS
		SELECT TOP 10000 vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count, EmployeeFirstName + ' ' + EmployeeLastName AS [EmployeeName]
			FROM vCategories JOIN vProducts 
				ON vCategories.CategoryID = vProducts.CategoryID
			JOIN vInventories 
				ON vProducts.ProductID = vInventories.ProductID
			JOIN vEmployees
				ON vInventories.EmployeeID = vEmployees.EmployeeID
					ORDER BY InventoryDate, CategoryName, ProductName, EmployeeFirstName;
GO

-- SELECT * FROM vInventoriesByProductsByEmployee;

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- The question doesn't mention the Order By that the Assignment 5 question did, but the example seems to be ordered in the same way, so I'm leaving it in

CREATE VIEW vInventoriesForChaiAndChangByEmployees
	AS
		SELECT TOP 10000 vCategories.CategoryName, vProducts.ProductName, vInventories.InventoryDate, vInventories.Count, EmployeeFirstName + ' ' + EmployeeLastName AS [EmployeeName]
			FROM vCategories JOIN vProducts 
				ON vCategories.CategoryID = vProducts.CategoryID
			JOIN vInventories 
				ON vProducts.ProductID = vInventories.ProductID
			JOIN vEmployees
				ON vInventories.EmployeeID = vEmployees.EmployeeID
					WHERE vProducts.ProductID IN (SELECT vProducts.ProductID FROM vProducts WHERE ProductName = 'Chai' OR ProductName = 'Chang')
						ORDER BY InventoryDate, CategoryName, ProductName;
GO

-- SELECT * FROM vInventoriesForChaiAndChangByEmployees;

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Since I'm mostly using Aliases in this one, it looks like I'll only need to reference the view names in the FROM clause

CREATE VIEW vEmployeesByManager
	AS
		SELECT TOP 10000 Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName AS [ManagerName],
			 Employee.EmployeeFirstName + ' ' + Employee.EmployeelastName AS [EmployeeName]
			FROM vEmployees AS Employee JOIN vEmployees AS Manager
				ON Employee.ManagerID = Manager.EmployeeID
					ORDER BY Manager.EmployeeFirstName, Employee.EmployeeFirstName;
GO

-- SELECT * FROM vEmployeesByManager;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- I'm basing my answer off the model, but it doesn't appear to me that the model shows ALL data, because some employees aren't represented in the Inventories table. 
-- I think to show "all data" as in all rows, I would need to use outer joins, but the model appears to show inner joins
-- It looks like I need to immediately alias the Employees view when joining it, too, or the SELECT statement fails

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
	AS
		SELECT TOP 10000 vCategories.CategoryID, vProducts.ProductID, vProducts.ProductName, vProducts.UnitPrice, vInventories.InventoryID, vInventories.InventoryDate, vInventories.Count,
			Employee.EmployeeID, Employee.EmployeeFirstName + ' ' + Employee.EmployeelastName AS [EmployeeName], Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName AS [ManagerName]
				FROM vCategories JOIN vProducts 
					ON vCategories.CategoryID = vProducts.CategoryID
				JOIN vInventories 
					ON vProducts.ProductID = vInventories.ProductID
				JOIN vEmployees AS Employee
					ON vInventories.EmployeeID = Employee.EmployeeID
				JOIN vEmployees AS Manager
						ON Employee.ManagerID = Manager.EmployeeID
					ORDER BY CategoryName, ProductName, InventoryID, Employee.EmployeeFirstName;
GO
			 
-- SELECT * FROM vInventoriesByProductsByCategoriesByEmployees;

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
PRINT 'Note: You will get an error until the views are created!'
SELECT * FROM [dbo].[vCategories]
SELECT * FROM [dbo].[vProducts]
SELECT * FROM [dbo].[vInventories]
SELECT * FROM [dbo].[vEmployees]

SELECT * FROM [dbo].[vProductsByCategories]
SELECT * FROM [dbo].[vInventoriesByProductsByDates]
SELECT * FROM [dbo].[vInventoriesByEmployeesByDates]
SELECT * FROM [dbo].[vInventoriesByProductsByCategories]
SELECT * FROM [dbo].[vInventoriesByProductsByEmployees]
SELECT * FROM [dbo].[vInventoriesForChaiAndChangByEmployees]
SELECT * FROM [dbo].[vEmployeesByManager]
SELECT * FROM [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/