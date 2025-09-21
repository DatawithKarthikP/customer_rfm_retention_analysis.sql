-- ===============================================
-- 📊 Customer RFM & Retention Analysis in SQL Server
-- ===============================================

-- Assumes: Orders and Customers tables as defined above
-- Goal: Analyze customer value & retention using SQL Server

-- STEP 1: Set analysis reference date
DECLARE @AnalysisDate DATE = '2025-09-01';

-- ===============================================
-- 📌 1. Calculate RFM metrics for each customer
-- ===============================================
WITH RFM_CTE AS (
    SELECT
        c.CustomerID,
        c.CustomerName,
        MAX(o.OrderDate) AS LastOrderDate,
        COUNT(o.OrderID) AS Frequency,
        SUM(o.TotalAmount) AS Monetary,
        DATEDIFF(DAY, MAX(o.OrderDate), @AnalysisDate) AS Recency
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    GROUP BY c.CustomerID, c.CustomerName
)
SELECT * FROM RFM_CTE;

-- ===============================================
-- 📌 2. Rank customers into RFM segments (1 to 5 scale)
-- ===============================================
WITH RFM_Scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS RecencyScore,
        NTILE(5) OVER (ORDER BY Frequency) AS FrequencyScore,
        NTILE(5) OVER (ORDER BY Monetary) AS MonetaryScore
    FROM (
        SELECT
            c.CustomerID,
            c.CustomerName,
            MAX(o.OrderDate) AS LastOrderDate,
            COUNT(o.OrderID) AS Frequency,
            SUM(o.TotalAmount) AS Monetary,
            DATEDIFF(DAY, MAX(o.OrderDate), @AnalysisDate) AS Recency
        FROM Customers c
        LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
        GROUP BY c.CustomerID, c.CustomerName
    ) AS RFM
)
SELECT 
    CustomerID,
    CustomerName,
    Recency, Frequency, Monetary,
    RecencyScore, FrequencyScore, MonetaryScore,
    CAST(RecencyScore AS VARCHAR) + CAST(FrequencyScore AS VARCHAR) + CAST(MonetaryScore AS VARCHAR) AS RFM_Segment
FROM RFM_Scored;

-- ===============================================
-- 📌 3. Identify Top 10 High-Value Customers
-- ===============================================
WITH RFM_Rank AS (
    SELECT *,
        (RecencyScore + FrequencyScore + MonetaryScore) AS RFM_TotalScore
    FROM (
        -- Reuse previous RFM_Scored logic
        SELECT *,
            NTILE(5) OVER (ORDER BY Recency DESC) AS RecencyScore,
            NTILE(5) OVER (ORDER BY Frequency) AS FrequencyScore,
            NTILE(5) OVER (ORDER BY Monetary) AS MonetaryScore
        FROM (
            SELECT
                c.CustomerID,
                c.CustomerName,
                MAX(o.OrderDate) AS LastOrderDate,
                COUNT(o.OrderID) AS Frequency,
                SUM(o.TotalAmount) AS Monetary,
                DATEDIFF(DAY, MAX(o.OrderDate), @AnalysisDate) AS Recency
            FROM Customers c
            LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
            GROUP BY c.CustomerID, c.CustomerName
        ) AS RFM
    ) AS Scored
)
SELECT TOP 10 CustomerID, CustomerName, RFM_TotalScore, Recency, Frequency, Monetary
FROM RFM_Rank
ORDER BY RFM_TotalScore DESC;

-- ===============================================
-- 📌 4. Calculate Monthly Retention Rate
-- ===============================================
WITH Monthly_Orders AS (
    SELECT 
        CustomerID,
        FORMAT(OrderDate, 'yyyy-MM') AS OrderMonth,
        MIN(OrderDate) OVER (PARTITION BY CustomerID) AS FirstPurchaseDate
    FROM Orders
),
Month_Retention AS (
    SELECT 
        OrderMonth,
        COUNT(DISTINCT CustomerID) AS ActiveCustomers
    FROM Monthly_Orders
    GROUP BY OrderMonth
)
SELECT * FROM Month_Retention
ORDER BY OrderMonth;

-- ===============================================
-- 📌 5. Identify Churned Customers (No purchase in last 90 days)
-- ===============================================
SELECT 
    c.CustomerID,
    c.CustomerName,
    MAX(o.OrderDate) AS LastOrderDate,
    DATEDIFF(DAY, MAX(o.OrderDate), @AnalysisDate) AS DaysSinceLastPurchase
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName
HAVING DATEDIFF(DAY, MAX(o.OrderDate), @AnalysisDate) > 90;

-- ===============================================
-- 📌 6. Cohort Analysis: Group customers by first purchase month
-- ===============================================
WITH FirstOrder AS (
    SELECT 
        CustomerID,
        MIN(OrderDate) AS FirstOrderDate
    FROM Orders
    GROUP BY CustomerID
),
Cohorts AS (
    SELECT 
        c.CustomerID,
        FORMAT(f.FirstOrderDate, 'yyyy-MM') AS CohortMonth,
        FORMAT(o.OrderDate, 'yyyy-MM') AS OrderMonth
    FROM Orders o
    JOIN FirstOrder f ON o.CustomerID = f.CustomerID
    JOIN Customers c ON o.CustomerID = c.CustomerID
)
SELECT 
    CohortMonth,
    OrderMonth,
    COUNT(DISTINCT CustomerID) AS RetainedCustomers
FROM Cohorts
GROUP BY CohortMonth, OrderMonth
ORDER BY CohortMonth, OrderMonth;
