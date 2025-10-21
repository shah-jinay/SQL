--JINAY SHAH---
USE Northwind
GO

--SELECT statement: 
--1. SELECT all columns and rows

SELECT *
FROM Employees

--2. SELECT a list of columns

SELECT e.EmployeeID, e.FirstName, e.LastName, e.Title, e.Country
FROM Employees AS e


--avoid using SELECT *

--1. Unnecessary data
--2. Naming conflicts

SELECT *
FROM Employees

SELECT * 
FROM Customers

SELECT *
FROM Employees e JOIN Orders o On e.EmployeeID = o.EmployeeID JOIN Customers c ON c.CustomerID = o.CustomerID


--3. SELECT DISTINCT Value: 
--list all the cities that employees are located at

SELECT DISTINCT City, Country
FROM Employees


--4. SELECT combined with plain text: retrieve the full name of employees

SELECT FirstName + ' ' + LastName AS FullName
FROM Employees


--identifiers: names we give to db, tables, columns, sp.

--1. Regular Identifier:
    --First Character: a-z, A-Z, @, #
            --@: decalre a variable

            DECLARE @today DATETIME
            SELECT @today = GETDATE()
            PRINT @today

            --# : temp tables
                --#: local temp table
                --##: global temp table

    --subsequent character: a-z, A-Z, 0-9, @, #, _, $
    --Identifiers must not be a sql reserved word both upppercase or lowercase 

--2. Demilited Identifier: [], " "

SELECT FirstName + ' ' + LastName AS "Full Name"
FROM Employees


--WHERE statement: is used to filter the record 
--1. equal =
--Customers who are from Germany

SELECT c.ContactName, c.Country
FROM Customers AS c
WHERE c.Country = 'Germany'


--Product which price is $18

SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice = 18


--2. Customers who are not from UK

SELECT c.ContactName, c.Country
FROM Customers AS c
WHERE c.Country != 'UK'

SELECT c.ContactName, c.Country
FROM Customers AS c
WHERE c.Country <> 'UK'


--IN Operator: 
--E.g: Orders that ship to USA AND Canada

SELECT OrderID, CustomerID, ShipCountry
FROM Orders 
WHERE ShipCountry = 'USA' OR ShipCountry = 'Canada'

SELECT OrderID, CustomerID, ShipCountry
FROM Orders 
WHERE ShipCountry IN ('USA', 'Canada')


--BETWEEN Operator: 
--1. retreive products whose price is between 20 and 30.

SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice >=20 AND UnitPrice <=30

SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 20 AND 30


--NOT Operator: 
-- list orders that does not ship to USA or Canada

SELECT OrderID, CustomerID, ShipCountry
FROM Orders 
WHERE ShipCountry NOT IN ('USA', 'Canada')


SELECT OrderID, CustomerID, ShipCountry
FROM Orders 
WHERE NOT ShipCountry  IN ('USA', 'Canada')

SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice NOT BETWEEN 20 AND 30

SELECT ProductName, UnitPrice
FROM Products
WHERE not UnitPrice BETWEEN 20 AND 30


--NULL Value: 
--check which employees' region information is empty

SELECT FirstName, LastName, Region
FROM Employees
WHERE Region IS NULL


--exclude the employees whose region is null

SELECT FirstName, LastName, Region
FROM Employees
WHERE Region IS Not NULL


--Null in numerical operation

CREATE TABLE TestSalary(EId int primary key identity(1,1), Salary money, Comm money)
INSERT INTO TestSalary VALUES(2000, 500), (2000, NULL),(1500, 500),(2000, 0),(NULL, 500),(NULL,NULL)

SELECT *
FROM TestSalary

SELECT EId, Salary, Comm,  ISNUll(Salary, 0) + ISNULL(Comm, 0) AS TotalCompensation
FROM TestSalary


--LIKE Operator: create a search expression

--1. Work with % wildcard character: used to subsitute 0 or more characters

--retrieve all the employees whose last name starts with D

SELECT FirstName, LastName
FROM Employees
WHERE LastName LIKE 'D%'


--2. Work with [] and % to search in ranges: 

--find customers whose postal code starts with number between 0 and 3

SELECT ContactName, PostalCode
FROM Customers
WHERE PostalCode LIKE '[0-3]%'

--3. Work with NOT: 

SELECT ContactName, PostalCode
FROM Customers
WHERE PostalCode NOT LIKE '[0-3]%'


--4. Work with ^: 

SELECT ContactName, PostalCode
FROM Customers
WHERE PostalCode LIKE '[^0-3]%'

--Customer name starting from letter A but not followed by l-n

SELECT ContactName, PostalCode
FROM Customers 
WHERE ContactName LIKE 'A[^l-n]%'


--ORDER BY statement: 
--1. retrieve all customers except those in Boston and sort by Name

SELECT ContactName, City
FROM Customers
WHERE City != 'Boston'
ORDER BY ContactName 


--2. retrieve product name and unit price, and sort by unit price in descending order

SELECT ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC


--3. Order by multiple columns

SELECT ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC, ProductName DESC

SELECT ProductName, UnitPrice
FROM Products
ORDER BY 2 DESC, 1 DESC



--JOIN: 

--1. INNER JOIN: return the records that have matching values in both tables in the related column. 

--find employees who have deal with any orders


SELECT DISTINCT  e.EmployeeID, e.FirstName + ' '+ e.LastName AS "Full Name "
FROM Employees AS e INNER JOIN Orders AS o ON e.EmployeeID = o.EmployeeID


SELECT DISTINCT  e.EmployeeID, e.FirstName + ' '+ e.LastName AS "Full Name "
FROM Orders o, Employees e
WHERE o.EmployeeID = e.EmployeeID

--get cusotmers information and corresponding order date


SELECT e.EmployeeID, e.FirstName + ' '+ e.LastName AS "Full Name ", o.OrderDate
FROM Employees AS e INNER JOIN Orders AS o ON e.EmployeeID = o.EmployeeID

--join multiple tables:
--get customer name, the corresponding employee who is responsible for this order, and the order date

SELECT e.EmployeeID, e.FirstName + ' '+ e.LastName AS "Full Name ", c.ContactName As CustomerName, o.OrderDate
FROM Employees AS e INNER JOIN Orders AS o ON e.EmployeeID = o.EmployeeID JOIN Customers c ON c.CustomerID = o.CustomerID


--add detailed information about quantity and price, join Order details

SELECT e.EmployeeID, e.FirstName + ' '+ e.LastName AS "Full Name ", c.ContactName As CustomerName, o.OrderDate, od.Quantity, od.UnitPrice
FROM Employees AS e INNER JOIN Orders AS o ON e.EmployeeID = o.EmployeeID JOIN Customers c ON c.CustomerID = o.CustomerID 
JOIN [Order Details] od ON od.OrderID = o.OrderId


--2. OUTER JOIN: 

--1) LEFT OUTER JOIN: return all the records from the left table and matching records from the right table, if we can not find any
                --matching records, then for that row we will return null. 

--list all customers whether they have made any purchase or not

SELECT c.ContactName, o.OrderDate
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID


--JOIN with WHERE: 
--customers who never placed any order

SELECT c.ContactName, o.OrderDate
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderDate IS NULL


--2) RIGHT OUTER JOIN: return all the records from the right table and matching records from the left table, if we can not find any
                --matching records, then for that row we will return null. 

--list all customers whether they have made any purchase or not

SELECT c.ContactName, o.OrderDate
FROM Orders o RIGHT JOIN Customers c ON c.CustomerID = o.CustomerID


--3) FULL OUTER JOIN: returns all the rows from both left and right table even if we can't find the matching values. 


--Match all customers and suppliers by country.

SELECT c.ContactName As CustomerName, s.ContactName As SupplierName, c.Country As CustomerCountry, s.Country As SupplierCountry
FROM Customers c FULL JOIN Suppliers s ON c.Country = s.Country


--3. CROSS JOIN: create cartesian product

--table 1--> 10 rows
--table 2 --> 20 rows
-- cross join table 1 and table 2 --> 200 rows 

SELECT * FROM Customers

SELECT * FROM Orders

SELECT *
FROM Customers CROSS JOIN Orders 


--* SELF JOIN：a table joins with itself. 

SELECT EmployeeID, FirstName, LastName, ReportsTo
FROM Employees

--CEO: Andrew
--Manager: Nancy, Janet, Margaret, Steven, Laura
--Employee: Michael, Robert, Anne

--find emloyees with the their manager name

SELECT e.FirstName + ' ' + e.LastName AS Employee, m.FirstName + ' ' + m.LastName AS Manager 
FROM Employees e LEFT JOIN Employees m ON e.ReportsTo = m.EmployeeID


--Batch Directives

CREATE DATABASE AprBatch
USE AprBatch
CREATE TABLE Employee(Id INT, EName VARCHAR(20), Salary MONEY)


------- Write a query that retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, with no filter. --------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product;


------- Write a query that retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, excludes the rows that ListPrice is 0. --------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE ListPrice <> 0;

------- Write a query that retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, the rows that are NULL for the Color column. --------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color IS NULL;

------- Write a query that retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, the rows that are not NULL for the Color column. --------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color IS NOT NULL;

------- Write a query that retrieves the columns ProductID, Name, Color and ListPrice from the Production.Product table, the rows that are not NULL for the column Color, and the column ListPrice has a value greater than zero. --------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Color IS NOT NULL
  AND ListPrice > 0;

------- Write a query that concatenates the columns Name and Color from the Production.Product table by excluding the rows that are null for color. --------
SELECT Name + ' ' + Color AS ProductDescription
FROM Production.Product
WHERE Color IS NOT NULL;
SELECT CONCAT(Name, ' ', Color) AS ProductDescription
FROM Production.Product
WHERE Color IS NOT NULL;

/* Write a query that generates the following result set  from Production.Product:
NAME: LL Crankarm  --  COLOR: Black
NAME: ML Crankarm  --  COLOR: Black
NAME: HL Crankarm  --  COLOR: Black
NAME: Chainring Bolts  --  COLOR: Silver
NAME: Chainring Nut  --  COLOR: Silver
NAME: Chainring  --  COLOR: Black  */
SELECT 
    'NAME: ' + Name + '  --  COLOR: ' + Color AS ProductInfo
FROM Production.Product
WHERE (Name IN ('LL Crankarm', 'ML Crankarm', 'HL Crankarm', 'Chainring Bolts', 'Chainring Nut', 'Chainring'))
  AND Color IS NOT NULL;

SELECT 
    CONCAT('NAME: ', Name, '  --  COLOR: ', Color) AS ProductInfo
FROM Production.Product
WHERE Name IN ('LL Crankarm', 'ML Crankarm', 'HL Crankarm', 'Chainring Bolts', 'Chainring Nut', 'Chainring')
  AND Color IS NOT NULL;

------- Write a query to retrieve the to the columns ProductID and Name from the Production.Product table filtered by ProductID from 400 to 500. --------
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID BETWEEN 400 AND 500;

------- Write a query to retrieve the to the columns  ProductID, Name and color from the Production.Product table restricted to the colors black and blue. --------
SELECT ProductID, Name, Color
FROM Production.Product
WHERE Color IN ('Black', 'Blue');

------- Write a query to get a result set on products that begins with the letter S. --------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE 'S%';

/* Write a query that retrieves the columns Name and ListPrice from the Production.Product table. Your result set should look something like the following. Order the result set by the Name column. 
Name                                               ListPrice
Seat Lug                                              0,00
Seat Post                                             0,00
Seat Stays                                            0,00
Seat Tube                                            0,00
Short-Sleeve Classic Jersey, L           53,99
Short-Sleeve Classic Jersey, M          53,99 */

SELECT Name, ListPrice
FROM Production.Product
ORDER BY Name;


/*  Write a query that retrieves the columns Name and ListPrice from the Production.Product table. Your result set should look something like the following. Order the result set by the Name column. The products name should start with either 'A' or 'S'
Name                                               ListPrice
Adjustable Race                                   0,00
All-Purpose Bike Stand                       159,00
AWC Logo Cap                                      8,99
Seat Lug                                                 0,00
Seat Post                                                0,00 */
SELECT Name, ListPrice
FROM Production.Product
WHERE Name LIKE 'A%' OR Name LIKE 'S%'
ORDER BY Name;

------- Write a query so you retrieve rows that have a Name that begins with the letters SPO, but is then not followed by the letter K. After this zero or more letters can exists. Order the result set by the Name column. --------
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE 'SPO%' 
  AND Name NOT LIKE 'SPOK%'
ORDER BY Name;

------- Write a query that retrieves unique colors from the table Production.Product. Order the results  in descending  manner. --------
SELECT DISTINCT Color
FROM Production.Product
WHERE Color IS NOT NULL
ORDER BY Color DESC;
