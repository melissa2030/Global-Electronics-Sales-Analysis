USE ElectronicsSalesDB;
GO

SELECT 'Customers' AS [RowCount], COUNT(*) AS Total FROM Customers
UNION ALL
SELECT 'Products',  COUNT(*) FROM Products
UNION ALL
SELECT 'Regions',   COUNT(*) FROM Regions
UNION ALL
SELECT 'Sales',     COUNT(*) FROM Sales;

select * from Regions

select * from products

select * from customers 

USE ElectronicsSalesDB;
GO

-- 3.1 Preview all tables
SELECT TOP 5 * FROM Customers;
SELECT TOP 5 * FROM Products;
SELECT TOP 5 * FROM Regions;
SELECT TOP 5 * FROM Sales;

-- 3.3 Check for NULL values in Sales
SELECT
    SUM(CASE WHEN SaleDate    IS NULL THEN 1 ELSE 0 END) AS Null_SaleDate,
    SUM(CASE WHEN CustomerID  IS NULL THEN 1 ELSE 0 END) AS Null_CustomerID,
    SUM(CASE WHEN ProductID   IS NULL THEN 1 ELSE 0 END) AS Null_ProductID,
    SUM(CASE WHEN Quantity    IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN Discount    IS NULL THEN 1 ELSE 0 END) AS Null_Discount
FROM Sales;

-- 3.4 Check date range of sales

SELECT
    MIN(SaleDate) AS EarliestSale,
    MAX(SaleDate) AS LatestSale,
    DATEDIFF(DAY, MIN(SaleDate), MAX(SaleDate)) AS SpanInDays
FROM Sales;

-- 3.5 Validate: any negative quantities or prices?
SELECT COUNT(*) AS InvalidQuantities FROM Sales    WHERE Quantity   <= 0;
SELECT COUNT(*) AS InvalidPrices     FROM Products WHERE UnitPrice  <= 0 OR UnitCost <= 0;

-- 3.6 Duplicate check in Sales
SELECT SaleID, COUNT(*) AS DupeCount
FROM Sales
GROUP BY SaleID
HAVING COUNT(*) > 1;

-- 3.7 Add a computed Revenue column as a calculated view helper


SELECT
    s.SaleID,
    s.SaleDate,
    p.ProductName,
    s.Quantity,
    p.UnitPrice,
    s.Discount,
    ROUND(s.Quantity * p.UnitPrice * (1 - s.Discount), 2)                          AS Revenue,
    ROUND(s.Quantity * p.UnitPrice * (1 - s.Discount)
          - s.Quantity * p.UnitCost - s.ShippingCost, 2)                           AS Profit
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
ORDER BY s.SaleDate;

---STEP 4 — Sales Analysis Queries

USE ElectronicsSalesDB;
GO

-- ─────────────────────────────────────────────────────────────
-- 4.1 Total Revenue, Profit & Orders Overall

SELECT
    COUNT(s.SaleID)                                                               AS TotalOrders,
    SUM(s.Quantity)                                                               AS UnitsSold,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)                   AS TotalRevenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
              - s.Quantity * p.UnitCost - s.ShippingCost), 2)                    AS TotalProfit,
    ROUND(
        SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
            - s.Quantity * p.UnitCost - s.ShippingCost)
        / NULLIF(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 0) * 100
    , 2)                                                                          AS ProfitMarginPct
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID;

-- ─────────────────────────────────────────────────────────────
-- 4.2 Revenue by Year and Month (Time Trend)
SELECT
    YEAR(s.SaleDate)                                                    AS SaleYear,
    MONTH(s.SaleDate)                                                   AS SaleMonth,
    DATENAME(MONTH, s.SaleDate)                                         AS MonthName,
    COUNT(s.SaleID)                                                     AS Orders,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS Revenue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate), DATENAME(MONTH, s.SaleDate)
ORDER BY SaleYear, SaleMonth;

-- ─────────────────────────────────────────────────────────────
-- 4.3 Revenue by Quarter

SELECT
    YEAR(s.SaleDate)                                                    AS SaleYear,
    DATEPART(QUARTER, s.SaleDate)                                       AS Quarter,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS Revenue,
    COUNT(s.SaleID)                                                     AS Orders
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY YEAR(s.SaleDate), DATEPART(QUARTER, s.SaleDate)
ORDER BY SaleYear, Quarter;

-- ─────────────────────────────────────────────────────────────
-- 4.4 Revenue by Region

SELECT
    r.RegionName,
    r.Country,
    COUNT(s.SaleID)                                                     AS Orders,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS Revenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
              - s.Quantity * p.UnitCost - s.ShippingCost), 2)          AS Profit
FROM Sales s
JOIN Products  p ON s.ProductID = p.ProductID
JOIN Regions   r ON s.RegionID  = r.RegionID
GROUP BY r.RegionName, r.Country
ORDER BY Revenue DESC;

-- ─────────────────────────────────────────────────────────────
-- 4.5 Top 10 Best-Selling Products by Revenue

SELECT TOP 10
    p.ProductName,
    p.Category,
    p.SubCategory,
    SUM(s.Quantity)                                                     AS UnitsSold,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS Revenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
              - s.Quantity * p.UnitCost - s.ShippingCost), 2)          AS Profit
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductName, p.Category, p.SubCategory
ORDER BY Revenue DESC;

-- ─────────────────────────────────────────────────────────────
-- 4.6 Revenue & Profit by Product Category

SELECT
    p.Category,
    COUNT(DISTINCT p.ProductID)                                         AS ProductCount,
    SUM(s.Quantity)                                                     AS UnitsSold,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS Revenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
              - s.Quantity * p.UnitCost - s.ShippingCost), 2)          AS Profit,
    ROUND(
        SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
            - s.Quantity * p.UnitCost - s.ShippingCost)
        / NULLIF(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 0) * 100
    , 2)                                                                AS MarginPct
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY Revenue DESC;

-- ─────────────────────────────────────────────────────────────
-- 4.7 Top 10 Customers by Revenue

SELECT TOP 10
    c.CustomerID,
    c.FirstName + ' ' + c.LastName                                      AS CustomerName,
    c.Country,
    c.AgeGroup,
    COUNT(s.SaleID)                                                     AS Orders,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS TotalSpend
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Products  p ON s.ProductID  = p.ProductID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Country, c.AgeGroup
ORDER BY TotalSpend DESC;

-- ─────────────────────────────────────────────────────────────
-- 4.8 Revenue by Customer Age Group

SELECT
    c.AgeGroup,
    COUNT(DISTINCT c.CustomerID)                                        AS Customers,
    COUNT(s.SaleID)                                                     AS Orders,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS Revenue
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Products  p ON s.ProductID  = p.ProductID
GROUP BY c.AgeGroup
ORDER BY Revenue DESC;

-- ─────────────────────────────────────────────────────────────
-- 4.9 Average Order Value (AOV) by Region
-- ─────────────────────────────────────────────────────────────
SELECT
    r.RegionName,
    COUNT(s.SaleID)                                                     AS Orders,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS Revenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount))
          / COUNT(s.SaleID), 2)                                         AS AvgOrderValue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
JOIN Regions  r ON s.RegionID  = r.RegionID
GROUP BY r.RegionName
ORDER BY AvgOrderValue DESC;


-- 4.10 Discount Impact Analysis

SELECT
    CASE
        WHEN s.Discount = 0          THEN 'No Discount'
        WHEN s.Discount <= 0.05      THEN 'Low (1-5%)'
        WHEN s.Discount <= 0.10      THEN 'Medium (6-10%)'
        ELSE 'High (>10%)'
    END                                                                 AS DiscountTier,
    COUNT(s.SaleID)                                                     AS Orders,
    ROUND(AVG(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS AvgOrderValue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)         AS TotalRevenue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY
    CASE
        WHEN s.Discount = 0          THEN 'No Discount'
        WHEN s.Discount <= 0.05      THEN 'Low (1-5%)'
        WHEN s.Discount <= 0.10      THEN 'Medium (6-10%)'
        ELSE 'High (>10%)'
    END
ORDER BY TotalRevenue DESC;

-- STEP 5: ADVANCED ANALYTICS


USE ElectronicsSalesDB;
GO


-- 5.1 Running Total Revenue Over Time (Window Function)

WITH MonthlySales AS (
    SELECT
        YEAR(s.SaleDate)                                                AS SaleYear,
        MONTH(s.SaleDate)                                               AS SaleMonth,
        DATENAME(MONTH, s.SaleDate)                                     AS MonthName,
        ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)     AS MonthlyRevenue
    FROM Sales s
    JOIN Products p ON s.ProductID = p.ProductID
    GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate), DATENAME(MONTH, s.SaleDate)
)
SELECT
    SaleYear,
    SaleMonth,
    MonthName,
    MonthlyRevenue,
    ROUND(SUM(MonthlyRevenue) OVER (
        PARTITION BY SaleYear
        ORDER BY SaleMonth
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2)                                                               AS RunningTotalRevenue
FROM MonthlySales
ORDER BY SaleYear, SaleMonth;

-- 5.2 Month-over-Month Revenue Growth %

WITH MonthlySales AS (
    SELECT
        YEAR(s.SaleDate)                                                AS SaleYear,
        MONTH(s.SaleDate)                                               AS SaleMonth,
        ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)     AS Revenue
    FROM Sales s
    JOIN Products p ON s.ProductID = p.ProductID
    GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate)
),
WithLag AS (
    SELECT
        SaleYear,
        SaleMonth,
        Revenue,
        LAG(Revenue) OVER (ORDER BY SaleYear, SaleMonth)               AS PrevMonthRevenue
    FROM MonthlySales
)
SELECT
    SaleYear,
    SaleMonth,
    Revenue,
    PrevMonthRevenue,
    CASE
        WHEN PrevMonthRevenue IS NULL OR PrevMonthRevenue = 0 THEN NULL
        ELSE ROUND((Revenue - PrevMonthRevenue) / PrevMonthRevenue * 100, 2)
    END                                                                 AS MoM_GrowthPct
FROM WithLag
ORDER BY SaleYear, SaleMonth;


-- 5.3 Year-over-Year Revenue Comparison

WITH YearlySales AS (
    SELECT
        YEAR(s.SaleDate)                                                AS SaleYear,
        ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)     AS Revenue
    FROM Sales s
    JOIN Products p ON s.ProductID = p.ProductID
    GROUP BY YEAR(s.SaleDate)
)
SELECT
    SaleYear,
    Revenue,
    LAG(Revenue) OVER (ORDER BY SaleYear)                              AS PrevYearRevenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY SaleYear))
        / NULLIF(LAG(Revenue) OVER (ORDER BY SaleYear), 0) * 100
    , 2)                                                               AS YoY_GrowthPct
FROM YearlySales;


-- 5.4 Product Ranking by Revenue Within Each Category

WITH ProductRevenue AS (
    SELECT
        p.Category,
        p.ProductName,
        ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)     AS Revenue
    FROM Sales s
    JOIN Products p ON s.ProductID = p.ProductID
    GROUP BY p.Category, p.ProductName
)
SELECT
    Category,
    ProductName,
    Revenue,
    RANK() OVER (PARTITION BY Category ORDER BY Revenue DESC)          AS RankInCategory
FROM ProductRevenue
ORDER BY Category, RankInCategory;


-- 5.5 Customer Lifetime Value (LTV) & Segmentation

WITH CustomerStats AS (
    SELECT
        c.CustomerID,
        c.FirstName + ' ' + c.LastName                                  AS CustomerName,
        c.Country,
        COUNT(s.SaleID)                                                  AS TotalOrders,
        ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)      AS LifetimeValue,
        MIN(s.SaleDate)                                                   AS FirstPurchase,
        MAX(s.SaleDate)                                                   AS LastPurchase
    FROM Sales s
    JOIN Customers c ON s.CustomerID = c.CustomerID
    JOIN Products  p ON s.ProductID  = p.ProductID
    GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Country
)
SELECT
    CustomerID,
    CustomerName,
    Country,
    TotalOrders,
    LifetimeValue,
    FirstPurchase,
    LastPurchase,
    DATEDIFF(DAY, FirstPurchase, LastPurchase)                          AS DaysBetweenPurchases,
    CASE
        WHEN LifetimeValue >= 3000 THEN 'VIP'
        WHEN LifetimeValue >= 1500 THEN 'Regular'
        ELSE 'Occasional'
    END                                                                 AS CustomerSegment
FROM CustomerStats
ORDER BY LifetimeValue DESC;


-- 5.6 Revenue Contribution % per Region (Percent of Total)

WITH RegionRevenue AS (
    SELECT
        r.RegionName,
        ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)     AS Revenue
    FROM Sales s
    JOIN Products p ON s.ProductID = p.ProductID
    JOIN Regions  r ON s.RegionID  = r.RegionID
    GROUP BY r.RegionName
)
SELECT
    RegionName,
    Revenue,
    ROUND(Revenue / SUM(Revenue) OVER () * 100, 2)                     AS RevenueSharePct
FROM RegionRevenue
ORDER BY Revenue DESC;

-- 5.7 3-Month Moving Average Revenue
-- ─────────────────────────────────────────────────────────────
WITH MonthlySales AS (
    SELECT
        YEAR(s.SaleDate)                                                AS SaleYear,
        MONTH(s.SaleDate)                                               AS SaleMonth,
        ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)     AS Revenue
    FROM Sales s
    JOIN Products p ON s.ProductID = p.ProductID
    GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate)
)
SELECT
    SaleYear,
    SaleMonth,
    Revenue,
    ROUND(AVG(Revenue) OVER (
        ORDER BY SaleYear, SaleMonth
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                                                               AS MovingAvg_3M
FROM MonthlySales
ORDER BY SaleYear, SaleMonth;


-- STEP 6: CREATE REPORTING VIEWS (for dashboards / reporting)


USE ElectronicsSalesDB;
GO

-- 6.1 Overall KPI Summary View
CREATE OR ALTER VIEW vw_KPI_Summary AS
SELECT
    COUNT(s.SaleID)                                                             AS TotalOrders,
    COUNT(DISTINCT s.CustomerID)                                                AS UniqueCustomers,
    SUM(s.Quantity)                                                             AS TotalUnitsSold,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)                 AS TotalRevenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
              - s.Quantity * p.UnitCost - s.ShippingCost), 2)                  AS TotalProfit,
    ROUND(
        SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
            - s.Quantity * p.UnitCost - s.ShippingCost)
        / NULLIF(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 0) * 100
    , 2)                                                                        AS OverallMarginPct,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount))
          / NULLIF(COUNT(s.SaleID), 0), 2)                                      AS AvgOrderValue
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID;
GO

-- 6.2 Monthly Sales Dashboard View
CREATE OR ALTER VIEW vw_Monthly_Sales AS
SELECT
    YEAR(s.SaleDate)                                                            AS SaleYear,
    MONTH(s.SaleDate)                                                           AS SaleMonth,
    DATENAME(MONTH, s.SaleDate)                                                 AS MonthName,
    r.RegionName,
    p.Category,
    COUNT(s.SaleID)                                                             AS Orders,
    SUM(s.Quantity)                                                             AS UnitsSold,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)                 AS Revenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
              - s.Quantity * p.UnitCost - s.ShippingCost), 2)                  AS Profit
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
JOIN Regions  r ON s.RegionID  = r.RegionID
GROUP BY
    YEAR(s.SaleDate), MONTH(s.SaleDate), DATENAME(MONTH, s.SaleDate),
    r.RegionName, p.Category;
GO

-- 6.3 Product Performance View
CREATE OR ALTER VIEW vw_Product_Performance AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    p.SubCategory,
    p.UnitCost,
    p.UnitPrice,
    ROUND(p.UnitPrice - p.UnitCost, 2)                                          AS UnitMargin,
    COUNT(s.SaleID)                                                             AS TimesSold,
    SUM(s.Quantity)                                                             AS TotalUnitsSold,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)                 AS TotalRevenue,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)
              - s.Quantity * p.UnitCost - s.ShippingCost), 2)                  AS TotalProfit
FROM Products p
LEFT JOIN Sales s ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category, p.SubCategory, p.UnitCost, p.UnitPrice;
GO

-- 6.4 Customer 360 View
CREATE OR ALTER VIEW vw_Customer_360 AS
SELECT
    c.CustomerID,
    c.FirstName + ' ' + c.LastName                                              AS CustomerName,
    c.Gender,
    c.AgeGroup,
    c.Country,
    c.JoinDate,
    COUNT(s.SaleID)                                                             AS TotalOrders,
    SUM(s.Quantity)                                                             AS TotalUnitsPurchased,
    ROUND(SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)), 2)                 AS LifetimeValue,
    MIN(s.SaleDate)                                                             AS FirstPurchaseDate,
    MAX(s.SaleDate)                                                             AS LastPurchaseDate,
    CASE
        WHEN SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)) >= 3000 THEN 'VIP'
        WHEN SUM(s.Quantity * p.UnitPrice * (1 - s.Discount)) >= 1500 THEN 'Regular'
        ELSE 'Occasional'
    END                                                                         AS Segment
FROM Customers c
LEFT JOIN Sales    s ON c.CustomerID = s.CustomerID
LEFT JOIN Products p ON s.ProductID  = p.ProductID
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Gender, c.AgeGroup, c.Country, c.JoinDate;
GO

-- ── Query your views 
SELECT * FROM vw_KPI_Summary;
SELECT * FROM vw_Monthly_Sales      ORDER BY SaleYear, SaleMonth;
SELECT * FROM vw_Product_Performance ORDER BY TotalRevenue DESC;
SELECT * FROM vw_Customer_360        ORDER BY LifetimeValue DESC;