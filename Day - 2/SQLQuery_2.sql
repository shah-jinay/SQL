--JINAY SHAH---

--SELECT: RETRIEVE
--WHERE: filter
--ORDER BY: sort
--JOIN: work on multiple tables in one query

--Aggregation functions: returns a single aggregateed result
--1. COUNT(): returns the number of rows

SELECT COUNT(OrderID) AS TotalNumOfRows
FROM Orders

SELECT COUNT(*) AS TotalNumOfRows
FROM Orders

--COUNT(*) vs. COUNT(colName): 

SELECT FirstName, Region
FROM Employees

SELECT COUNT(Region), COUNT(*)
FROM Employees


-- GROUP BY: group rows that have same values into summary rows

--find total number of orders placed by each customers


SELECT c.CustomerID, c.ContactName, c.City, c.Country, COUNT(o.OrderID) AS TotalNumOfOrders
FROM Orders O JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.ContactName, c.City, c.Country
ORDER BY TotalNumOfOrders DESC


--a more complex template: 
--only retreive total order numbers where customers located in USA or Canada, and order number should be greater than or equal to 10

SELECT c.CustomerID, c.ContactName, c.City, c.Country, COUNT(o.OrderID) AS TotalNumOfOrders
FROM Orders O JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.Country IN ('USA', 'Canada')
GROUP BY c.CustomerID, c.ContactName, c.City, c.Country
HAVING COUNT(o.OrderID) >= 10
ORDER BY TotalNumOfOrders DESC


--WHERE vs. HAVING

--1. Both are used as filtters, having will only apply to group as a whole but where is applied to an individual row
--2. Where goes before aggregation but having goes after aggregation

--SQL Execution Order

--SELECT fields, aggregation(fields)
--FROM table JOIN table2 ON..
--WHERE Criteria --optional
--GROUP BY fields -- use when have both aggregated and non-aggregated fields
--HAVING criteia --Optional
--ORDER BY fields DESC --optional


--FROM/JOIN  -----> WHERE ----> GROUP BY ----> HAVING ----> SELECT---> DISTINCT ---> ORDER BY 

SELECT c.CustomerID, c.ContactName AS CustomerName, c.City, c.Country, COUNT(o.OrderID) AS TotalNumOfOrders
FROM Orders AS O JOIN Customers AS c ON o.CustomerID = c.CustomerID
WHERE c.Country IN ('USA', 'Canada')
GROUP BY c.CustomerID, c.ContactName, c.City, c.Country
HAVING COUNT(o.OrderID) >= 10
ORDER BY TotalNumOfOrders DESC

--3. Where can be used with select, update or delete but having can only be used in the select statements. 

SELECT * FROM Products

UPDATE Products
SET UnitPrice = 20
WHERE ProductID = 1



--DISTINCT: 
--COUNT DISTINCT: 

SELECT City 
FROM Customers

SELECT COUNT(City), COUNT(DISTINCT City)
FROM Customers



--2. AVG(): get the average value of the numeric column
--list average revenue for each customer

SELECT c.CustomerID, c.ContactName, AVG(od.UnitPrice * od.Quantity) AS AvgRevenue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od On o.OrderID = od.OrderID
GROUP BY  c.CustomerID, c.ContactName


--3. SUM(): get the sum value of the numeric column
--list sum of revenue for each customer


SELECT c.CustomerID, c.ContactName, SUM(od.UnitPrice * od.Quantity) AS SumRevenue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od On o.OrderID = od.OrderID
GROUP BY  c.CustomerID, c.ContactName


--4. MAX(): get a maximum value for a column
--list maxinum revenue from each customer

SELECT c.CustomerID, c.ContactName, MAX(od.UnitPrice * od.Quantity) AS MaxRevue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od On o.OrderID = od.OrderID
GROUP BY  c.CustomerID, c.ContactName



--5.MIN(): get a minimum value for a column
--list the cheapeast product bought by each customer

SELECT  c.CustomerID, c.ContactName, MIN(od.UnitPrice) AS CheapestProduct
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od On o.OrderID = od.OrderID
GROUP BY  c.CustomerID, c.ContactName


--TOP predicate: select a specific number or certain percentage of records
--retrieve top 5 most expensive products

SELECT TOP 5 ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC


--retrieve top 10 percent most expensive products

SELECT TOP 10 PERCENT ProductName, UnitPrice
FROM Products
ORDER BY UnitPrice DESC


--list top 5 customers who created the most total revenue


SELECT TOP 5 c.CustomerID, c.ContactName, SUM(od.UnitPrice * od.Quantity) AS SumRevenue
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID JOIN [Order Details] od On o.OrderID = od.OrderID
GROUP BY  c.CustomerID, c.ContactName
ORDER BY SumRevenue DESC



--Subquery: A select statement that is embedded inside another select statement

--find the customers from the same city where Alejandra Camino lives 

SELECT ContactName, City
FROM Customers
WHERE City IN (
    SELECT City
    FROM Customers
    WHERE ContactName = 'Alejandra Camino'
)

--sometimes subquery and join can be used interchangeably

--find customers who made orders in the past

--JOIN

SELECT DISTINCT c.CustomerID, c.ContactName, c.City, c.Country
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID


--subquery

SELECT CustomerId, ContactName, City, Country
FROM Customers 
WHERE CustomerID IN(
    SELECT DISTINCT CustomerID
    FROM Orders
)


--subquery vs. join
--1. Join can only be used in the FROM clause but subquery can be used in SELECT, FROM, WHERE, HAVING, ORDER BY


--get the order information like which employees deal with which order but limit the employees location to London:

--join

SELECT  e.FirstName, e.LastName, o.OrderDate
FROM Employees e join Orders o On e.EmployeeID = o.EmployeeID
WHERE e.City = 'London'
ORDER BY e.FirstName, e.LastName, o.OrderDate

--Subquery

SELECT  (SELECT e1.FirstName FROM Employees e1 WHERE e1.EmployeeID = o.EmployeeID) AS FirstName, (SELECT e2.LastName FROM Employees e2 WHERE e2.EmployeeID = o.EmployeeID) AS LastName, o.OrderDate
FROM Orders o
WHERE (
    SELECT e3.City
    FROM Employees e3
    WHERE e3.EmployeeID = o.EmployeeID
) IN ('London')
ORDER BY  (SELECT e1.FirstName FROM Employees e1 WHERE e1.EmployeeID = o.EmployeeID), (SELECT e2.LastName FROM Employees e2 WHERE e2.EmployeeID = o.EmployeeID), o.OrderDate


--2. Subquery is easy to understand and maintain


--Let's find the customers who never placed any order

--JOIN

SELECT C.CustomerID, c.ContactName, c.City, C.Country
FROM Customers c LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL


--Subquery

SELECT c.CustomerID, c.ContactName, c.City, c.Country
FROM Customers c
WHERE C.CustomerID NOT IN (
    SELECT DISTINCT CustomerID
    FROM Orders
)

--3. Usually JOIN has better performance than subquery. 
--JOIN: INNER, OUTER(LET, RIGHT, FULL)
--physical joins: hash join, merge join, neested loop join 


--Correlated Subquery: when an inner query is dependent on the outer query, then that is a correlated subquery


--Customer name and total number of orders by customer

--JOIN


SELECT C.ContactName, COUNT(o.OrderID) As TotalNumOfOrders
FROM Customers c LEFT JOIN Orders o On c.CustomerID = o.CustomerID
GROUP BY C.ContactName
ORDER BY TotalNumOfOrders DESC


--Subquery

SELECT c.ContactName, (SELECT COUNT(o.OrderID) FROM Orders o WHERE o.CustomerID = C.CustomerID) AS TotalNumOfOrders 
FROM Customers c 
ORDER BY TotalNumOfOrders DESC


--derived table: is the subquery in the FROM clause

SELECT dt.CompanyName, dt.City
FROM (SELECT *
FROM Customers) dt

--get customers information and the number of orders made by each customer

--JOIN

SELECT C.ContactName, c.City, C.Country, COUNT(o.OrderID) As TotalNumOfOrders
FROM Customers c LEFT JOIN Orders o On c.CustomerID = o.CustomerID
GROUP BY C.ContactName, c.City, C.Country
ORDER BY TotalNumOfOrders DESC


SELECT c.ContactName, c.City, C.Country, dt.TotalNumberOfOrders
FROM Customers c LEFT JOIN (
    SELECT o.CustomerID, COUNT(OrderID) AS TotalNumberOfOrders
    FROM Orders o
    GROUP BY o.CustomerID
) dt ON c.CustomerID = dt.CustomerID
ORDER BY dt.TotalNumberOfOrders DESC



--Union vs. Union ALL: 

--common features:
--1. Both Union and Union All are used to combine result sets vertically. 

SELECT City, Country
FROM Customers 
UNION
SELECT City, Country
FROM Employees  

SELECT City, Country
FROM Customers 
UNION ALL
SELECT City, Country
FROM Employees  


--2. Both of them follow the same criteria:

    --i. the number of the columns must be the same
        
    --ii: The data type of each column must be identical

--differences
--1. Union will remove duplicates but union all will not. 
--2. Union will sort the fist column ascendigly by defualt but union all will not. 
--3. Union can't be used in recursive cte but union all can be used. 



--Window Function: operate on set of rows and return a single aggregated value for each row by adding an extra column. 

--RANK(): give a rank based on certain order. 

SELECT ProductID, ProductName, UnitPrice, RANK() OVER(ORDER BY UnitPrice DESC) RNK 
FROM Products


--product with the 2nd highest price 

SELECT dt.ProductID, dt.ProductName, dt.UnitPrice, dt.RNK
FROM (SELECT ProductID, ProductName, UnitPrice, RANK() OVER(ORDER BY UnitPrice DESC) RNK 
FROM Products) dt
WHERE dt.RNK = 2

--if there is a tie, there will be a value gap with rank funciton. If you don't want a value gap, go with dense rank. 


--DENSE_RANK(): 

SELECT ProductID, ProductName, UnitPrice,RANK() OVER(ORDER BY UnitPrice DESC) RNK , DENSE_RANK() OVER(ORDER BY UnitPrice DESC) DENSE_RNK 
FROM Products


--ROW_NUMBER():  it will provide the ranking of the sorted record starting from 1. 


SELECT ProductID, ProductName, UnitPrice,RANK() OVER(ORDER BY UnitPrice DESC) RNK , DENSE_RANK() OVER(ORDER BY UnitPrice DESC) DENSE_RNK,
ROW_NUMBER() OVER(ORDER BY UnitPrice DESC) ROW_NUM
FROM Products


--partition by: divides the result set into partitions and allows us to perform calculation on each subset. It is used in conjunction with windows function

--list customers from every country with the ranking for number of orders

SELECT c.ContactName, c.Country, COUNT(o.OrderID) AS NumOfOrders, RANK() OVER( PARTITION BY c.Country ORDER BY COUNT(o.OrderID) DESC) RNK
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName, c.Country


--- find top 3 customers from every country with maximum orders

SELECT dt.ContactName, dt.Country, dt.NumOfOrders, dt.RNK
FROM (SELECT c.ContactName, c.Country, COUNT(o.OrderID) AS NumOfOrders, RANK() OVER( PARTITION BY c.Country ORDER BY COUNT(o.OrderID) DESC) RNK
FROM Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.ContactName, c.Country) dt
WHERE dt.RNK <=3


--cte: common table expression: a temprorary name result set to make our query more readable


SELECT c.ContactName, c.City, C.Country, dt.TotalNumberOfOrders
FROM Customers c LEFT JOIN (
    SELECT o.CustomerID, COUNT(OrderID) AS TotalNumberOfOrders
    FROM Orders o
    GROUP BY o.CustomerID
) dt ON c.CustomerID = dt.CustomerID
ORDER BY dt.TotalNumberOfOrders DESC


WITH OrderCntCTE
AS
(
    SELECT o.CustomerID, COUNT(OrderID) AS TotalNumberOfOrders
    FROM Orders o
    GROUP BY o.CustomerID
)
SELECT c.ContactName, c.City, C.Country, cte.TotalNumberOfOrders
FROM Customers c LEFT JOIN OrderCntCTE cte ON c.CustomerID = cte.CustomerID
ORDER BY cte.TotalNumberOfOrders DESC


--lifecycle: cte has to be used right away in the very next select statement and also has to be delcared and used in the same batch


--recursive CTE:  

--1. Initalization
--2. Recursive Rule 

SELECT EmployeeID, FirstName, ReportsTo
FROM Employees


--level 1: Andrew
--level 2: Nancy, Janet, Margaret, Steven, Laura
--level 3: Michael, Robert, Anne

WITH EmpHierarchyCTE
AS(
    SELECT EmployeeID, FirstName, ReportsTo, 1 lvl
    FROM Employees 
    WHERE ReportsTo IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.FirstName, e.ReportsTo, cte.lvl + 1
    FROM Employees e JOIN  EmpHierarchyCTE cte ON e.ReportsTo = cte.EmployeeID
)
SELECT *  FROM EmpHierarchyCTE



------- 1. How many products can you find in the Production.Product table? --------
SELECT COUNT(*) AS ProductCount
FROM Production.Product;

------- 2. Write a query that retrieves the number of products in the Production.Product table that are included in a subcategory. The rows that have NULL in column ProductSubcategoryID are considered to not be a part of any subcategory. --------
SELECT COUNT(*) AS ProductsWithSubcategory
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL;

------- 3. How many Products reside in each SubCategory? Write a query to display the results with the following titles. ProductSubcategoryID CountedProducts --------
SELECT 
    ProductSubcategoryID,
    COUNT(*) AS CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID
ORDER BY ProductSubcategoryID;

------- 4. How many products that do not have a product subcategory. --------

SELECT COUNT(*) AS ProductsWithoutSubcategory
FROM Production.Product
WHERE ProductSubcategoryID IS NULL;

------- 5. Write a query to list the sum of products quantity in the Production.ProductInventory table. --------

SELECT SUM(Quantity) AS TotalProductQuantity
FROM Production.ProductInventory;

------- 6. Write a query to list the sum of products in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100. ProductID TheSum. --------
SELECT 
    ProductID, 
    SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY ProductID
HAVING SUM(Quantity) < 100
ORDER BY ProductID;

------- 7.    Write a query to list the sum of products with the shelf information in the Production.ProductInventory table and LocationID set to 40 and limit the result to include just summarized quantities less than 100 Shelf      ProductID    TheSum --------
SELECT 
    Shelf,
    ProductID,
    SUM(Quantity) AS TheSum
FROM Production.ProductInventory
WHERE LocationID = 40
GROUP BY Shelf, ProductID
HAVING SUM(Quantity) < 100
ORDER BY Shelf, ProductID;

------- 8. Write the query to list the average quantity for products where column LocationID has the value of 10 from the table Production.ProductInventory table. --------
SELECT 
    ProductID,
    AVG(Quantity) AS AverageQuantity
FROM Production.ProductInventory
WHERE LocationID = 10
GROUP BY ProductID
ORDER BY ProductID;


------- 9.    Write query  to see the average quantity  of  products by shelf  from the table Production.ProductInventory ProductID   Shelf      TheAvg --------
SELECT 
    ProductID,
    Shelf,
    AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
GROUP BY ProductID, Shelf
ORDER BY Shelf, ProductID;

------- 10.  Write query  to see the average quantity  of  products by shelf excluding rows that has the value of N/A in the column Shelf from the table Production.ProductInventory ProductID   Shelf      TheAvg --------
SELECT 
    ProductID,
    Shelf,
    AVG(Quantity) AS TheAvg
FROM Production.ProductInventory
WHERE Shelf <> 'N/A'
GROUP BY ProductID, Shelf
ORDER BY Shelf, ProductID;


------- 11.  List the members (rows) and average list price in the Production.Product table. This should be grouped independently over the Color and the Class column. Exclude the rows where Color or Class are null. Color   Class  TheCount AvgPrice --------
SELECT 
    Color,
    Class,
    COUNT(*) AS TheCount,
    AVG(ListPrice) AS AvgPrice
FROM Production.Product
WHERE Color IS NOT NULL 
  AND Class IS NOT NULL
GROUP BY Color, Class
ORDER BY Color, Class;


------- 12.   Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables. Join them and produce a result set similar to the following. Country Province --------
SELECT 
    c.Name AS Country,
    s.Name AS Province
FROM Person.CountryRegion AS c
JOIN Person.StateProvince AS s
    ON c.CountryRegionCode = s.CountryRegionCode
ORDER BY c.Name, s.Name;


-------13.  Write a query that lists the country and province names from person. CountryRegion and person. StateProvince tables and list the countries filter them by Germany and Canada. Join them and produce a result set similar to the following. Country Province --------
SELECT 
    c.Name AS Country,
    s.Name AS Province
FROM Person.CountryRegion AS c
JOIN Person.StateProvince AS s
    ON c.CountryRegionCode = s.CountryRegionCode
WHERE c.Name IN ('Germany', 'Canada')
ORDER BY c.Name, s.Name;



------- 14.  List all Products that has been sold at least once in last 27 years. --------
SELECT DISTINCT 
    p.ProductID,
    p.Name AS ProductName
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod
    ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader AS soh
    ON sod.SalesOrderID = soh.SalesOrderID
WHERE soh.OrderDate >= DATEADD(YEAR, -27, GETDATE())
ORDER BY p.Name;


------- 15.  List top 5 locations (Zip Code) where the products sold most. --------
SELECT TOP 5
    a.PostalCode AS ZipCode,
    SUM(sod.OrderQty) AS TotalProductsSold
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
JOIN Person.Address AS a
    ON soh.BillToAddressID = a.AddressID
GROUP BY a.PostalCode
ORDER BY TotalProductsSold DESC;

------- 16.  List top 5 locations (Zip Code) where the products sold most in last 27 years. --------
SELECT TOP 5
    a.PostalCode AS ZipCode,
    SUM(sod.OrderQty) AS TotalProductsSold
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
JOIN Person.Address AS a
    ON soh.ShipToAddressID = a.AddressID
WHERE soh.OrderDate >= DATEADD(YEAR, -27, GETDATE())
  AND a.PostalCode IS NOT NULL
GROUP BY a.PostalCode
ORDER BY TotalProductsSold DESC;


------- 17.   List all city names and number of customers in that city. --------
SELECT 
    a.City,
    COUNT(DISTINCT c.CustomerID) AS NumberOfCustomers
FROM Sales.Customer AS c
JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
JOIN Person.Address AS a
    ON soh.BillToAddressID = a.AddressID
GROUP BY a.City
ORDER BY NumberOfCustomers DESC, a.City;

------- 18.  List city names which have more than 2 customers, and number of customers in that city --------
SELECT 
    a.City,
    COUNT(DISTINCT c.CustomerID) AS NumberOfCustomers
FROM Sales.Customer AS c
JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
JOIN Person.Address AS a
    ON soh.BillToAddressID = a.AddressID
GROUP BY a.City
HAVING COUNT(DISTINCT c.CustomerID) > 2
ORDER BY NumberOfCustomers DESC, a.City;


------- 19.  List the names of customers who placed orders after 1/1/98 with order date. --------
SELECT 
    p.FirstName + ' ' + p.LastName AS CustomerName,
    soh.OrderDate
FROM Sales.Customer AS c
JOIN Person.Person AS p
    ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
WHERE soh.OrderDate > '1998-01-01'
ORDER BY soh.OrderDate;



------- 21.  Display the names of all customers  along with the  count of products they bought --------
SELECT 
    p.FirstName + ' ' + p.LastName AS CustomerName,
    COUNT(sod.ProductID) AS ProductCount
FROM Sales.Customer AS c
JOIN Person.Person AS p
    ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY p.FirstName, p.LastName
ORDER BY ProductCount DESC, CustomerName;


------- 22.  Display the customer ids who bought more than 100 Products with count of products. --------
SELECT 
    c.CustomerID,
    SUM(sod.OrderQty) AS TotalProductsBought
FROM Sales.Customer AS c
JOIN Sales.SalesOrderHeader AS soh
    ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY c.CustomerID
HAVING SUM(sod.OrderQty) > 100
ORDER BY TotalProductsBought DESC;

------- 23.  List all of the possible ways that suppliers can ship their products. Display the results as below Supplier Company Name Shipping Company Name --------
SELECT 
    v.Name AS [Supplier Company Name],
    s.Name AS [Shipping Company Name]
FROM Purchasing.Vendor AS v
CROSS JOIN Purchasing.ShipMethod AS s
ORDER BY v.Name, s.Name;


------- 24.  Display the products order each day. Show Order date and Product Name. --------
SELECT 
    soh.OrderDate,
    p.Name AS ProductName
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
ORDER BY soh.OrderDate, p.Name;

------- 25.  Displays pairs of employees who have the same job title. --------
SELECT 
    e1.BusinessEntityID AS EmployeeID_1,
    p1.FirstName + ' ' + p1.LastName AS EmployeeName_1,
    e2.BusinessEntityID AS EmployeeID_2,
    p2.FirstName + ' ' + p2.LastName AS EmployeeName_2,
    e1.JobTitle
FROM HumanResources.Employee AS e1
JOIN HumanResources.Employee AS e2
    ON e1.JobTitle = e2.JobTitle
   AND e1.BusinessEntityID < e2.BusinessEntityID
JOIN Person.Person AS p1
    ON e1.BusinessEntityID = p1.BusinessEntityID
JOIN Person.Person AS p2
    ON e2.BusinessEntityID = p2.BusinessEntityID
ORDER BY e1.JobTitle, EmployeeName_1, EmployeeName_2;


------- 26.  Display all the Managers who have more than 2 employees reporting to them. --------
SELECT 
    m.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(e.BusinessEntityID) AS NumberOfEmployees
FROM HumanResources.Employee AS e
JOIN HumanResources.Employee AS m
    ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person.Person AS p
    ON m.BusinessEntityID = p.BusinessEntityID
GROUP BY m.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(e.BusinessEntityID) > 2
ORDER BY NumberOfEmployees DESC, ManagerName;


------- 27.  Display the customers and suppliers by city. The results should have the following columns City Name Contact Name, Type (Customer or Supplier)--------
-- Combine Customers and Suppliers by City
-- Customers (Individuals)
SELECT DISTINCT
    a.City,
    p.FirstName + ' ' + p.LastName AS [Name],
    p.FirstName + ' ' + p.LastName AS [Contact Name],
    'Customer' AS [Type]
FROM Sales.Customer AS c
JOIN Person.Person AS p
  ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea
  ON bea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address AS a
  ON a.AddressID = bea.AddressID

UNION ALL

-- Customers (Stores)
SELECT DISTINCT
    a.City,
    st.Name AS [Name],
    COALESCE(cp.FirstName + ' ' + cp.LastName, st.Name) AS [Contact Name],
    'Customer' AS [Type]
FROM Sales.Customer AS c
JOIN Sales.Store AS st
  ON c.StoreID = st.BusinessEntityID
LEFT JOIN Person.BusinessEntityContact AS bec
  ON st.BusinessEntityID = bec.BusinessEntityID
LEFT JOIN Person.Person AS cp
  ON bec.PersonID = cp.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea
  ON bea.BusinessEntityID = st.BusinessEntityID
JOIN Person.Address AS a
  ON a.AddressID = bea.AddressID

UNION ALL

-- Suppliers (Vendors)
SELECT DISTINCT
    a.City,
    v.Name AS [Name],
    COALESCE(vp.FirstName + ' ' + vp.LastName, v.Name) AS [Contact Name],
    'Supplier' AS [Type]
FROM Purchasing.Vendor AS v
LEFT JOIN Person.BusinessEntityContact AS vbec
  ON v.BusinessEntityID = vbec.BusinessEntityID
LEFT JOIN Person.Person AS vp
  ON vbec.PersonID = vp.BusinessEntityID
JOIN Person.BusinessEntityAddress AS vbea
  ON vbea.BusinessEntityID = v.BusinessEntityID
JOIN Person.Address AS a
  ON a.AddressID = vbea.AddressID
ORDER BY City, [Type], [Name];
