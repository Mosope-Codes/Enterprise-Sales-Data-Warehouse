-- Minimum quality suite
SELECT COUNT(*) FROM dw.FactSales WHERE CustomerKey IS NULL;
SELECT CustomerID FROM dw.DimCustomer GROUP BY CustomerID HAVING SUM(CASE WHEN IsCurrent=1 THEN 1 ELSE 0 END)<>1;
SELECT COUNT(*) FROM dw.FactSales f LEFT JOIN dw.DimCustomer d ON f.CustomerKey=d.CustomerKey WHERE d.CustomerKey IS NULL;
SELECT COUNT(*) FROM dw.FactSales WHERE ABS(ProfitAmount-(NetAmount-CostAmount))>.01;
SELECT OrderID,COUNT(*) FROM dw.FactSales GROUP BY OrderID HAVING COUNT(*)>1;
-- Add freshness, source/target counts, financial reconciliation, valid-date and required-field checks.
