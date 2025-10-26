
--basic queries: select, where, order by,join, aggregation functions, group by, having
--advanced topics: subquery, CTE, window function, pagination, top
--temp tables
--table variables
--stored procedures
--user defined fucntions

--check constraint: 

SELECT * FROM Employee


INSERT INTO Employee VALUES(7, 'Monstor', 3000)
INSERT INTO Employee VALUES(8, 'Monstor', -3000)

DELETE Employee

ALTER TABLE Employee
ADD CONSTRAINT Chk_Age_Employee CHECK(Age BETWEEN 18 AND 65)

INSERT INTO Employee VALUES(1,  'Sam', 45)


--identity property

CREATE TABLE Product(
    Id INT PRIMARY KEY IDENTITY(1, 1),
    ProductName VARCHAR(20) UNIQUE NOT NULL, 
    UnitPrice MONEY
)

SELECT * FROM Product

INSERT INTO Product VALUES('Green Tea', 2)
INSERT INTO Product VALUES('Latte', 3)
INSERT INTO Product VALUES('Cold Brew', 4)


--truncate vs. delete

--1. Delete is a DML statement so it will not reset the property value. Truncate is a DDL statement that will reset the property value. 

DELETE Product

TRUNCATE TABLE Product

--2. Delete can be used with WHERE clause but TRUNCATE cannot be. 


DELETE Product
WHERE Id = 3


--DROP: is a DDL statement that will delete the whole table


--referential integrity: is implemented by foreign key

--Department and employee table

CREATE TABLE Department(
    Id INT PRIMARY KEY,
    DepartmentName VARCHAR(20),
    Location VARCHAR(20)
)
DROP TABLE Employee

CREATE TABLE Employee(
    Id INT PRIMARY KEY, 
    EmployeeName VARCHAR(20),
    Age INT CHECK (Age BETWEEN 18 AND 65),
    DepartmentId INT FOREIGN KEY REFERENCES Department(Id)
)

SELECT * FROM Department

SELECT * FROM Employee


INSERT INTO Department VALUES(1, 'IT', 'Chicago'), (2, 'HR', 'Sterling'), (3, 'QA', 'NY')


INSERT INTO Department VALUES(1, 'IT', 'Chicago')
INSERT INTO Department VALUES(3, 'Sales', 'TX')


INSERT INTO Employee VALUES(1, 'Laura', 34, 1)

INSERT INTO Employee VALUES(2, 'Fred', 24, 2)

INSERT INTO Employee VALUES(3, 'Fiona', 33, 4)


DELETE Department
WHERE Id =1

DELETE Department
WHERE Id =2


DELETE Employee
WHERE ID = 2


CREATE TABLE Employee(
    Id INT PRIMARY KEY, 
    EmployeeName VARCHAR(20),
    Age INT CHECK (Age BETWEEN 18 AND 65),
    DepartmentId INT FOREIGN KEY REFERENCES Department(Id) ON DELETE SET NULL
)

CREATE TABLE Employee(
    Id INT PRIMARY KEY, 
    EmployeeName VARCHAR(20),
    Age INT CHECK (Age BETWEEN 18 AND 65),
    DepartmentId INT FOREIGN KEY REFERENCES Department(Id) ON DELETE CASCADE
)


DROP TABLE Employee

SELECT * FROM Department

SELECT * FROM Employee


DELETE Department
WHERE Id = 1


--Composite primary key
--student table
--class table
--enrollment table 

CREATE TABLE Student(
    Id INT PRIMARY KEY,
    StudentName VARCHAR(20)
)

CREATE TABLE Class(
    Id INT PRIMARY KEY,
    ClassName VARCHAR(20)
)

CREATE TABLE Enrollment(
    StudentId INT NOT NULL, 
    ClassId INT NOT NULL, 
    CONSTRAINT Pk_Enrollment PRIMARY KEY (StudentId, ClassId),
    CONSTRAINT FK_Enrollment_Student FOREIGN KEY(StudentId) REFERENCES Student(Id),
    CONSTRAINT FK_Enrollment_Class FOREIGN KEY(ClassId) REFERENCES Class(Id)

)


--transaction: group of logically related DML statements that will either succeed together or fail together. 
--3 modes:

--Autocommit transaction: default mode
--Implicit transaction: 
--Explicit transaction: 


DROP TABLE Product

CREATE TABLE Product(
    Id INT PRIMARY KEY IDENTITY(1, 1),
    ProductName VARCHAR(20) UNIQUE NOT NULL, 
    UnitPrice MONEY,
    Quantity INT
)


SELECT * FROM Product


INSERT INTO Product VALUES('Green Tea', 2, 100)
INSERT INTO Product VALUES('Latte', 3, 100)
INSERT INTO Product VALUES('Cold Brew', 4, 100)


--Properties
--ACID

--1. Atomicity: work must be atomic
--2. Consistency:: whatever happens in the middle of the transaction, this property will never leave our db in half completed state
--3. Isolation: two transaactions will be isolated from each other by locking the resource. 
--4. Durability: once the transaction is completed, the changes made to the db will be permanent. 


--concurrency problem: when two or more users are trying to access the same data.

--1. Dirty Read: if t1 allows t2 to read the uncommitted data and then the t1 rolls back, dirty read happens; happens when the isolation level is read uncommitted and is 
                --solved by isolation level read committed. 
--2. Lost Update: when t1 and t2 are trying read and update the same data but t2 finishes its work first even though t1 started the transaction fitst. So the update from the t2 will be missing. 
                --happens when isolation level is read committed and is solved by isolation level repeatable read and serializable
--3. Non Repeatable Read: T1 reads the same data twice while t2 is updating the data; happens when isolation level is read committed and is solved by updating the isolation
                        --level to repeatable read
--4. Phantom Read: T1 reads the same data twice while t2 is inserting the new data; happens when isolation level is non repeatable read and is solved by updating the isolation
                        --level to serializable




--index: on disk structure and db object that increases the data retrieval speed from a table -- SELECT 

--Clustered Index: sort the record, pk automatically generates clustered index, there can only be one clustered index in one table since data can only be sorted in one way
--Non clustered Index: not sort the data, can be generated by unique key, one table can have multiple non clustered index


CREATE TABLE Customer(
    Id INT PRIMARY KEY,
    FullName VARCHAR(20),
    City VARCHAR(20),
    Country VARCHAR(20)
)

SELECT * 
FROM Customer

CREATE CLUSTERED INDEX Cluster_IX_Customer_ID ON Customer(Id)

INSERT INTO Customer VALUES(2, 'David', 'Chicago', 'USA')
INSERT INTO Customer VALUES(1, 'Fred', 'NY', 'USA')


DROP TABLE Customer


CREATE INDEX NonCluster_IX_Customer_City ON Customer(City)


--disadvantages:
--it will cost extra space , slow DML statements like update/insert/delete


--PERFORMANCE TUNING 
--look at the execution plan/ sql profiler 
--create index wisely
-- Avoid unnecessary joins
-- Avoid using SELECT * 
--Use a derived table to avoid grouping of lots of non aggregated fields
--use join to replace subquery

/*
1. What is an index? Types, pros and cons
Answer:
    An index is a database structure that speeds up data retrieval by providing quick access paths to rows.
    Types: Clustered, Non-clustered, Unique, Composite, Full-text, Spatial.
    Pros: Faster SELECT queries, better sorting and filtering.
    Cons: Slower INSERT/UPDATE/DELETE (due to index maintenance), extra storage.

2. Difference between Primary Key and Unique Constraint
Answer:
    Primary Key: Enforces uniqueness + non-null constraint; only one per table.
    Unique Constraint: Ensures uniqueness but allows one NULL; multiple can exist per table.

3. What is a Check Constraint
Answer:
    A check constraint enforces a condition on column values.
    Example:
    CHECK (salary > 0)
    Ensures only positive salary values are allowed.

4. Difference between Temp Table and Table Variable
Answer:
    Temp Table: Stored in tempdb, supports indexes, statistics, and transactions; used for large datasets.
    Table Variable: Stored in memory, limited optimization; better for small datasets or quick operations.

5. Difference between WHERE and HAVING
Answer:
    WHERE: Filters rows before grouping (used with non-aggregates).
    HAVING: Filters after grouping (used with aggregates).
    Example:
        WHERE salary > 50000  
        HAVING COUNT(*) > 5

6. RANK() vs DENSE_RANK()
Answer:
    RANK(): Skips ranks after ties (gaps).
    DENSE_RANK(): No gaps.
    Example:
        Scores: 100, 90, 90, 80 →
        RANK: 1, 2, 2, 4
        DENSE_RANK: 1, 2, 2, 3

7. COUNT(*) vs COUNT(column)
Answer:
    COUNT(*): Counts all rows (includes NULLs).
    COUNT(column): Counts only non-NULL values.

8. Left Join vs Inner Join; JOIN vs Subquery performance
Answer:
    Inner Join: Returns matching rows in both tables.
    Left Join: Returns all left rows, even without matches.
    Performance: Joins are generally faster because the optimizer can better optimize join plans; subqueries often re-evaluate per row (especially correlated ones).

9. What is a Correlated Subquery
Answer:
    A correlated subquery references columns from the outer query. Runs once per outer row.
    Example:
    SELECT e.Name
    FROM Employees e
    WHERE e.Salary > (SELECT AVG(Salary)
                    FROM Employees
                    WHERE Department = e.Department);

10. What is a CTE, why use it
Answer:
    CTE (Common Table Expression) defines a temporary result set using WITH.
    Improves readability.
    Helps recursive queries.
    Avoids repeating subqueries.
    Example:
    WITH TopEmployees AS (
    SELECT * FROM Employees WHERE Salary > 80000
    )
    SELECT * FROM TopEmployees;

11. What does SQL Profiler do
Answer:
    SQL Profiler monitors database activity: queries executed, duration, CPU usage, reads/writes.
    Used for performance tuning and debugging.

12. What is SQL Injection, how to prevent it
Answer:
    SQL Injection: Attacker injects malicious SQL via inputs.
    Prevention: Use parameterized queries, stored procedures, ORM frameworks, and input validation.

13. SP vs User Defined Function
Answer:
    Stored Procedure: Can modify data, call functions, use transactions.
    Function: Must return a value, cannot modify data.
    Use SP for business logic; Function for computations.

14. UNION vs UNION ALL

Answer:
    UNION: Removes duplicates.
    UNION ALL: Keeps duplicates, faster since no sort/distinct needed.
    Criteria: Columns count and data types must match.

15. Steps to Improve SQL Queries
Answer:
    Use proper indexing.
    Avoid SELECT *.
    Use joins instead of subqueries.
    Analyze execution plans.
    Filter early (WHERE).
    Use appropriate data types.
    Avoid functions on indexed columns.

16. Concurrency Problems in Transactions
Answer:
    Dirty Read: Uncommitted data read.
    Non-Repeatable Read: Data changes between reads.
    Phantom Read: New rows appear between reads.
    Controlled by isolation levels.

17. What is Deadlock, how to prevent
Answer:
    Deadlock: Two transactions wait for each other’s locks indefinitely.
    Prevention:
    Access objects in same order.
    Keep transactions short.
    Use lower isolation level if possible.
    Implement retry logic.

18. What is Normalization, 1NF, benefits
Answer:
    Normalization: Organizing data to reduce redundancy and improve integrity.
    1NF: Each cell holds atomic (single) value.
    Benefits: Less redundancy, better data integrity, efficient updates.

19. System Defined Databases
Answer:
    master – DB system info.
    model – Template for new DBs.
    msdb – SQL Agent jobs, backups.
    tempdb – Temporary objects and operations.

20. Composite Key
Answer:
    A composite key combines two or more columns to uniquely identify a record.
    Example: (OrderID, ProductID)

21. Candidate Key
Answer:
    All possible columns (or combinations) that can uniquely identify a record.
    One candidate key becomes the primary key.

22. DDL vs DML
Answer:
    DDL (Data Definition Language): CREATE, ALTER, DROP, TRUNCATE.
    DML (Data Manipulation Language): SELECT, INSERT, UPDATE, DELETE.

23. ACID Properties
Answer:
    Atomicity: All or nothing.
    Consistency: Maintains valid state.
    Isolation: Independent transactions.
    Durability: Changes persist after commit.

24. Table Scan vs Index Scan
Answer:
    Table Scan: Reads entire table.
    Index Scan: Reads only indexed portion.
    Index scans are faster for selective queries.

25. Union vs Join
Answer:
    Union: Combines rows vertically (same columns).
    Join: Combines columns horizontally (related tables).
    Example:
        UNION adds rows; JOIN adds columns.

26. Relationship Examples
Answer:
    One-to-One: Employee → Passport
    → Use a foreign key with UNIQUE constraint.
    One-to-Many: Department → Employees
    → Foreign key in Employees referencing DepartmentID.
    Many-to-Many: Students ↔ Courses
    → Use a junction table (StudentCourses).
*/