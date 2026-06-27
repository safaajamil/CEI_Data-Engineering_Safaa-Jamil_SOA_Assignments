USE SalesDB;
GO

EXEC sp_help sales_data;
--.Explore table (schema, sample data).
SELECT TOP 10 *
FROM sales_data;
--Apply WHERE filters (region, category, date, sales).
SELECT *
FROM sales_data
WHERE Region = 'West';
SELECT *
FROM sales_data
WHERE Category = 'Furniture';
SELECT *
FROM sales_data
WHERE Sales > 500;
SELECT *
FROM sales_data
WHERE YEAR(Order_Date) = 2017;
--Use GROUP BY for aggregations (sales, quantity, averages)
SELECT Region,
SUM(Sales) AS TotalSales
FROM sales_data
GROUP BY Region;
SELECT Category,
AVG(Sales) AS AverageSales
FROM sales_data
GROUP BY Category;
SELECT Category,
SUM(Quantity) AS TotalQuantity
FROM sales_data
GROUP BY Category;
--Sort and limit results (top products, top categories).
SELECT TOP 10 Product_Name,
Sales
FROM sales_data
ORDER BY Sales DESC;
SELECT TOP 5 Category,
SUM(Sales) AS TotalSales
FROM sales_data
GROUP BY Category
ORDER BY TotalSales DESC;
--Solve use cases (monthly trends, top customers, duplicates)
SELECT
MONTH(Order_Date) AS Month,
SUM(Sales) AS TotalSales
FROM sales_data
GROUP BY MONTH(Order_Date)
ORDER BY Month;
SELECT TOP 10
Customer_Name,
SUM(Sales) AS TotalSales
FROM sales_data
GROUP BY Customer_Name
ORDER BY TotalSales DESC;
SELECT
Order_ID,
COUNT(*) AS CountOfOrders
FROM sales_data
GROUP BY Order_ID
HAVING COUNT(*) > 1;
--Validate results (row counts, data quality)
SELECT COUNT(*) AS TotalRows
FROM sales_data;
SELECT COUNT(*) AS MissingSales
FROM sales_data
WHERE Sales IS NULL;
SELECT COUNT(*) AS MissingProfit
FROM sales_data
WHERE Profit IS NULL;