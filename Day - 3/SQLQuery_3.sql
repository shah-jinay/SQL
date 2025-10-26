--aggregation functions + group by 
--subquery 
--union vs. union all 
--window function 
--cte

--temp table: a special type of the table so that we can store the data temporaily. 

--local temp table: #

CREATE TABLE #LocalTemp(
    Num INT
)
DECLARE @Variable INT = 1
WHILE(@Variable <= 10)
BEGIN
    INSERT INTO #LocalTemp(Num) VALUES(@Variable)
    SET @Variable = @Variable + 1
END

SELECT *
FROM #LocalTemp


SELECT * 
FROM tempdb.sys.tables


--global temp table: ##

CREATE TABLE ##GlobalTemp(
    Num INT
)
DECLARE @Variable2 INT = 1
WHILE(@Variable2 <= 10)
BEGIN
    INSERT INTO ##GlobalTemp(Num) VALUES(@Variable2)
    SET @Variable2 = @Variable2 + 1
END

SELECT * 
FROM ##GlobalTemp

DROP TABLE ##GlobalTemp


--table variable: a variable which is of table type

DECLARE @today DATETIME 
SET @today = GETDATE()
PRINT @today

DECLARE @WeekDays TABLE(
    DayNum INT,
    DayAbb VARCHAR(20),
    WeekName VARCHAR(20)
)
INSERT INTO @WeekDays VALUES(1, 'Mon', 'Monday')
INSERT INTO @WeekDays VALUES(2, 'Tue', 'Tuesday')

SELECT * FROM @WeekDays

SELECT * 
FROM tempdb.sys.tables


--temp tables vs. table variables

--1. Both are stored under tempdb database. 
--2. Lifescope: global/ local temp table, table variable--> in a batch
--3. size: data<100 rows--> table variable, data>100 rows--> temp tables
--4. we can use table variable in stored procedures and user defined function but cant use temp table in sp and udf. 


--View: is a virtual table that contains data from one or multiple tables. 

USE AprBatch
GO

SELECT * FROM Employee

INSERT INTO Employee VALUES (1, 'Fred', 2000), (2, 'Laura', 7000), (3, 'Amy', 6000)

CREATE VIEW vwEmp
AS
SELECT Id, EName, Salary
FROM Employee

SELECT * FROM vwEmp

--stored procedure: preprepared sql query that we can save in our database and resue whenever we want to. 

BEGIN
    PRINT 'Hello Anonymous Block'
END


CREATE PROC spHello
AS
BEGIN
    PRINT 'Hello Anonymous Block'
END

EXEC spHello


--sp can be used to prevent sql injection becasue it can take parameters. 


--sql injection: it happens when hackers inject some malicious code into our sql queries and thus destroying our database. 

SELECT Id, Name
FROM User
WHERE Id = 1 UNION SELECT Id, password from user 


SELECT Id, Name
FROM User
WHERE ID = 1 DROP TABLE User


--input

CREATE PROC spAddNumbers
@a INT,
@b INT
AS
BEGIN
    PRINT @a + @b
END

EXEC spAddNumbers 10, 20



--output

CREATE PROC spGetNameAndSalary
@Id  INT,
@EName VARCHAR(20) OUT,
@Salary MONEY OUT
AS
BEGIN
    SELECT @EName = EName, @Salary = Salary
    FROM Employee
    WHERE Id = @Id 
END

BEGIN
    DECLARE @EName VARCHAR(20)
    DECLARE @Salary MONEY
    EXEC spGetNameAndSalary 1, @EName OUT, @Salary OUT
    PRINT @EName
    PRINT @Salary
END




--SP can also return table

CREATE PROC spGetAllEmp
AS
BEGIN
    SELECT * FROM Employee
END

EXEC spGetAllEmp


--trigger: 
--DML trigger
--DDL trigger
--LogOn trigger


--lifescope sp and views: stored in the database forever as long as you do not drop them. 


--FUNCTIONS:
--built in function
--user defined function

CREATE FUNCTION GetTotalRevenue(@price money, @discount real, @quantity int)
RETURNS MONEY
AS 
BEGIN 
    DECLARE @Revenue MONEY
    SET @Revenue = @price * (1 -@discount) * @quantity
    RETURN @Revenue
END


SELECT UnitPrice, Discount, Quantity, dbo.GetTotalRevenue(UnitPrice, Discount,  Quantity) AS Revenue
FROM [Order Details]

--UDF can also return a table

CREATE FUNCTION ExpensiveProduct(@threshold Money)
RETURNS TABLE
AS  
   RETURN SELECT productId, productName, UnitPrice
    FROM Products 
    WHERE UnitPrice > @threshold


SELECT *
FROM dbo.ExpensiveProduct(10)


--sp vs. udf

--1. Usuage: sp--> DML, udf--> for calcutor logic
--2. How to call: sp --> use exec, udf--> use it in sql statements
--3. input/output: sp--> may or may not have input and output but udf may or may not have input but must have output
--4. sp can call a udf but udf can not be used to call stored procedure 


--pagination: we use to divide a large data set into smaller discrete pages; used by web applications

--OFFSET: SKIP
--FETCH NEXT x ROWS: SELECT

SELECT  CustomerID, ContactName, City
FROM Customers
ORDER BY CustomerID
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY


--top vs offset , fetch next
--1. top is used to fetch top several rows but with offset and fetch next, we can fetch from the middle as well. 
--2. Top may be or may not be used with ORDER BY but offset and fetch next must be used with ORDER BY

DECLARE @PageNum INT
SET @PageNum = 5
DECLARE @RowsOfPage INT
SET @RowsOfPage = 10
SELECT CustomerID, ContactName, City
FROM Customers
ORDER BY CustomerID
OFFSET (@PageNum -1) * @RowsOfPage ROWS
FETCH NEXT @RowsOfPage ROWS ONLY


--Normalization: 
--one to many relationship: 
--many to many relationship: junction table
--Student table and class table : enrollment table 


--Constraints

use AprBatch
go

DROP TABLE Employee

CREATE TABLE Employee(
    Id INT PRIMARY KEY, 
    EName VarChar(20) NOT NULL,
    Age INT
)



INSERT INTO Employee VALUES(1, 'Sam', 45)
INSERT INTO Employee VALUES(null, 'Sam', 45)

SELECT * FROM Employee


INSERT INTO Employee VALUES (null, null, null)

DELETE Employee

--primary key vs. unique constraint

--1. unique constraint can accpet one and only null value but pk can not accept any null value. 
--2. One table can have multiple unique keys but only one primary key. 
--3. PK will sort the data by default but unique key will not. 
--4. PK will create a clustered index by default nut unique key will create a non-clustered index. 



INSERT INTO Employee VALUES(5, 'Sam', 45)
INSERT INTO Employee VALUES(3, 'Rita', 35)
INSERT INTO Employee VALUES(1, 'Fred', 25)
INSERT INTO Employee VALUES(2, 'Alex', 27)
INSERT INTO Employee VALUES(4, 'Fiona', 26)

------- 1. List all cities that have both Employees and Customers. --------
SELECT DISTINCT c.City
FROM Customers c
INNER JOIN Employees e
    ON c.City = e.City;

------- 2.      List all cities that have Customers but no Employee. a.      Use sub-query b.      Do not use sub-query --------
SELECT DISTINCT City
FROM Customers
WHERE City NOT IN (SELECT City FROM Employees);

------- 3.      List all products and their total order quantities throughout all orders. --------
SELECT 
    p.ProductName,
    SUM(od.Quantity) AS TotalOrderQuantity
FROM 
    Products p
INNER JOIN 
    [Order Details] od
    ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductName
ORDER BY 
    TotalOrderQuantity DESC;

------- 4.      List all Customer Cities and total products ordered by that city. --------
SELECT 
    c.City,
    SUM(od.Quantity) AS TotalProductsOrdered
FROM 
    Customers c
INNER JOIN 
    Orders o 
    ON c.CustomerID = o.CustomerID
INNER JOIN 
    [Order Details] od 
    ON o.OrderID = od.OrderID
GROUP BY 
    c.City
ORDER BY 
    TotalProductsOrdered DESC;

------- 5.      List all Customer Cities that have at least two customers. --------
SELECT 
    City,
    COUNT(CustomerID) AS NumberOfCustomers
FROM 
    Customers
GROUP BY 
    City
HAVING 
    COUNT(CustomerID) >= 2
ORDER BY 
    NumberOfCustomers DESC;

------- 6.      List all Customer Cities that have ordered at least two different kinds of products. --------
SELECT 
    c.City,
    COUNT(DISTINCT od.ProductID) AS DifferentProductsOrdered
FROM 
    Customers c
INNER JOIN 
    Orders o 
    ON c.CustomerID = o.CustomerID
INNER JOIN 
    [Order Details] od 
    ON o.OrderID = od.OrderID
GROUP BY 
    c.City
HAVING 
    COUNT(DISTINCT od.ProductID) >= 2
ORDER BY 
    DifferentProductsOrdered DESC;

------- 7.      List all Customers who have ordered products, but have the ‘ship city’ on the order different from their own customer cities. --------
SELECT 
    DISTINCT c.CustomerID,
    c.CompanyName,
    c.City AS CustomerCity,
    o.ShipCity
FROM 
    Customers c
INNER JOIN 
    Orders o 
    ON c.CustomerID = o.CustomerID
WHERE 
    c.City <> o.ShipCity
ORDER BY 
    c.CompanyName;

------- 8.      List 5 most popular products, their average price, and the customer city that ordered most quantity of it. --------
WITH ProductTotals AS (
    SELECT 
        od.ProductID,
        SUM(od.Quantity) AS TotalQty,
        AVG(od.UnitPrice) AS AvgPrice
    FROM [Order Details] od
    GROUP BY od.ProductID
),
TopProducts AS (
    SELECT 
        pt.ProductID,
        pt.TotalQty,
        pt.AvgPrice,
        p.ProductName,
        DENSE_RANK() OVER (ORDER BY pt.TotalQty DESC) AS rk
    FROM ProductTotals pt
    JOIN Products p ON p.ProductID = pt.ProductID
),
CityTotals AS (
    SELECT
        od.ProductID,
        c.City,
        SUM(od.Quantity) AS CityQty,
        ROW_NUMBER() OVER (
            PARTITION BY od.ProductID
            ORDER BY SUM(od.Quantity) DESC, c.City
        ) AS rn
    FROM [Order Details] od
    JOIN Orders o     ON o.OrderID = od.OrderID
    JOIN Customers c  ON c.CustomerID = o.CustomerID
    GROUP BY od.ProductID, c.City
)
SELECT
    tp.ProductName,
    tp.AvgPrice,
    cq.City       AS TopCity,
    cq.CityQty    AS QtyFromTopCity,
    tp.TotalQty   AS TotalQtyAllCities
FROM TopProducts tp
JOIN CityTotals cq
  ON cq.ProductID = tp.ProductID AND cq.rn = 1
WHERE tp.rk <= 5
ORDER BY tp.TotalQty DESC;

------- 9.      List all cities that have never ordered something but we have employees there. a.      Use sub-query b.      Do not use sub-query --------
SELECT DISTINCT e.City
FROM Employees e
WHERE e.City NOT IN (
    SELECT DISTINCT c.City
    FROM Customers c
    INNER JOIN Orders o 
        ON c.CustomerID = o.CustomerID
);
SELECT DISTINCT e.City
FROM Employees e
LEFT JOIN Customers c 
    ON e.City = c.City
LEFT JOIN Orders o 
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

------- 10.  List one city, if exists, that is the city from where the employee sold most orders (not the product quantity) is, and also the city of most total quantity of products ordered from. (tip: join  sub-query) --------
WITH EmpCityTop AS (
    SELECT TOP 1 WITH TIES
        e.City,
        COUNT(*) AS OrderCount
    FROM Employees e
    JOIN Orders o ON o.EmployeeID = e.EmployeeID
    GROUP BY e.City
    ORDER BY COUNT(*) DESC, e.City
),
CustCityTop AS (
    SELECT TOP 1 WITH TIES
        c.City,
        SUM(od.Quantity) AS TotalQty
    FROM Customers c
    JOIN Orders o       ON o.CustomerID = c.CustomerID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    GROUP BY c.City
    ORDER BY SUM(od.Quantity) DESC, c.City
)
SELECT TOP 1 t.City
FROM EmpCityTop t
JOIN CustCityTop u ON u.City = t.City
ORDER BY t.City;


---- 11. How do you remove the duplicates record of a table? ----
/* 1. Identify Duplicate Records
first check duplicates using GROUP BY and HAVING:
*/
SELECT column1, column2, COUNT(*) AS DuplicateCount
FROM TableName
GROUP BY column1, column2
HAVING COUNT(*) > 1;



/* Delete Duplicates (Keep One Copy)
Using CTE with ROW_NUMBER()*/

WITH DuplicateCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY column1, column2 ORDER BY (SELECT NULL)) AS rn
    FROM TableName
)
DELETE FROM DuplicateCTE WHERE rn > 1;



----- 3. Alternate Approach (Using Subquery) ----
DELETE FROM TableName
WHERE ID NOT IN (
    SELECT MIN(ID)
    FROM TableName
    GROUP BY column1, column2
);




----- 4. Safer Method (Create New Table and Replace) ----


SELECT DISTINCT * INTO NewTable FROM TableName;

DROP TABLE TableName;

EXEC sp_rename 'NewTable', 'TableName';




