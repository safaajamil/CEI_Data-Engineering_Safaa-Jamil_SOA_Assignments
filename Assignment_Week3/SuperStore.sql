DROP TABLE IF EXISTS dbo.orders;
DROP TABLE IF EXISTS dbo.products;
DROP TABLE IF EXISTS dbo.customers;
GO
USE SalesDB;
GO
-- Check Imported Data
SELECT TOP 10 *
FROM dbo.SuperStore;
-- Create Customers Table
CREATE TABLE dbo.customers
(
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name NVARCHAR(100),
    Segment NVARCHAR(50),
    Country NVARCHAR(50),
    City NVARCHAR(100),
    State NVARCHAR(100),
    Postal_Code INT,
    Region NVARCHAR(50)
);
INSERT INTO dbo.customers
SELECT
    Customer_ID,
    MAX(Customer_Name),
    MAX(Segment),
    MAX(Country),
    MAX(City),
    MAX(State),
    MAX(Postal_Code),
    MAX(Region)
FROM dbo.SuperStore
GROUP BY Customer_ID;
-- Create Products Table
CREATE TABLE dbo.products
(
    Product_ID VARCHAR(30) PRIMARY KEY,
    Category NVARCHAR(50),
    Sub_Category NVARCHAR(50),
    Product_Name NVARCHAR(255)
);
INSERT INTO dbo.products
SELECT
    Product_ID,
    MAX(Category),
    MAX(Sub_Category),
    MAX(Product_Name)
FROM dbo.SuperStore
GROUP BY Product_ID;
 
-- Create Orders Table
CREATE TABLE dbo.orders
(
    Row_ID INT PRIMARY KEY,
    Order_ID VARCHAR(30),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode NVARCHAR(50),
    Customer_ID VARCHAR(20),
    Product_ID VARCHAR(30),
    Sales FLOAT,
    Quantity INT,
    Discount FLOAT,
    Profit FLOAT
);

INSERT INTO dbo.orders
SELECT
    Row_ID,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Sales,
    Quantity,
    Discount,
    Profit
FROM dbo.SuperStore;

-- Verify Data
SELECT COUNT(*) AS Customers
FROM dbo.customers;
SELECT COUNT(*) AS Products
FROM dbo.products;
SELECT COUNT(*) AS Orders
FROM dbo.orders;

-- Subquery
-- Orders Above Average Sales
SELECT *
FROM dbo.orders
WHERE Sales >
(
    SELECT AVG(Sales)
    FROM dbo.orders
);
-- Highest Order Per Customer
SELECT *
FROM dbo.orders o
WHERE Sales =
(
    SELECT MAX(Sales)
    FROM dbo.orders
    WHERE Customer_ID = o.Customer_ID
);

-- CTE
-- Total Sales Per Customer
WITH CustomerSales AS
(
    SELECT
        Customer_ID,
        SUM(Sales) AS TotalSales
    FROM dbo.orders
    GROUP BY Customer_ID
)
SELECT *
FROM CustomerSales
ORDER BY TotalSales DESC;

-- Window Function
-- ROW_NUMBER()
SELECT
    Customer_ID,
    Sales,
    ROW_NUMBER() OVER
    (
        ORDER BY Sales DESC
    ) AS Row_Number
FROM dbo.orders;
-- RANK()
SELECT
    Customer_ID,
    Sales,
    RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS Sales_Rank
FROM dbo.orders;
-- JOIN + CTE + WINDOW FUNCTION
WITH CustomerSales AS
(
    SELECT
        Customer_ID,
        SUM(Sales) AS TotalSales
    FROM dbo.orders
    GROUP BY Customer_ID
)

SELECT
    c.Customer_Name,
    cs.TotalSales,
    RANK() OVER
    (
        ORDER BY cs.TotalSales DESC
    ) AS CustomerRank
FROM CustomerSales cs
INNER JOIN dbo.customers c
ON cs.Customer_ID = c.Customer_ID
ORDER BY CustomerRank;

-- Top 10 Customers
SELECT TOP 10
    c.Customer_Name,
    SUM(o.Sales) AS TotalSales
FROM dbo.customers c
INNER JOIN dbo.orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_Name
ORDER BY TotalSales DESC;
-- Lowest 10 Customers
SELECT TOP 10
    c.Customer_Name,
    SUM(o.Sales) AS TotalSales
FROM dbo.customers c
INNER JOIN dbo.orders o
ON c.Customer_ID=o.Customer_ID
GROUP BY c.Customer_Name
ORDER BY TotalSales ASC;

-- Single Order Customers
SELECT
    Customer_ID,
    COUNT(*) AS Orders
FROM dbo.orders
GROUP BY Customer_ID
HAVING COUNT(*) = 1;

-- Customers Above Average Sales
SELECT
    Customer_ID,
    SUM(Sales) AS TotalSales
FROM dbo.orders
GROUP BY Customer_ID
HAVING SUM(Sales) >
(
    SELECT AVG(Sales)
    FROM dbo.orders
);

--  Validation
SELECT COUNT(*) AS TotalRows
FROM dbo.SuperStore;
SELECT COUNT(*) AS MissingSales
FROM dbo.SuperStore
WHERE Sales IS NULL;
SELECT COUNT(*) AS MissingProfit
FROM dbo.SuperStore
WHERE Profit IS NULL;
SELECT Customer_ID,
COUNT(*) AS DuplicateCustomers
FROM dbo.customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1;
SELECT Product_ID,
COUNT(*) AS DuplicateProducts
FROM dbo.products
GROUP BY Product_ID
HAVING COUNT(*) > 1;