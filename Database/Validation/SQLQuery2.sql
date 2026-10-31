SELECT
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
FROM dbo.ETLWatermark
ORDER BY SourceTable;

SELECT 'Customer' AS TableName, COUNT_BIG(*) AS TotalRows FROM stg.Customer
UNION ALL SELECT 'Product', COUNT_BIG(*) FROM stg.Product
UNION ALL SELECT 'Store', COUNT_BIG(*) FROM stg.Store
UNION ALL SELECT 'Employee', COUNT_BIG(*) FROM stg.Employee
UNION ALL SELECT 'SalesTransaction', COUNT_BIG(*) FROM stg.SalesTransaction
UNION ALL SELECT 'ReturnTransaction', COUNT_BIG(*) FROM stg.ReturnTransaction
UNION ALL SELECT 'ProductPriceHistory', COUNT_BIG(*) FROM stg.ProductPriceHistory
UNION ALL SELECT 'SalesTarget', COUNT_BIG(*) FROM stg.SalesTarget;

SELECT 'DimDate' AS TableName, COUNT_BIG(*) AS TotalRows FROM dw.DimDate
UNION ALL SELECT 'DimCustomer', COUNT_BIG(*) FROM dw.DimCustomer
UNION ALL SELECT 'DimProduct', COUNT_BIG(*) FROM dw.DimProduct
UNION ALL SELECT 'DimStore', COUNT_BIG(*) FROM dw.DimStore
UNION ALL SELECT 'DimEmployee', COUNT_BIG(*) FROM dw.DimEmployee
UNION ALL SELECT 'FactSales', COUNT_BIG(*) FROM dw.FactSales
UNION ALL SELECT 'FactReturns', COUNT_BIG(*) FROM dw.FactReturns
UNION ALL SELECT 'FactSalesTarget', COUNT_BIG(*) FROM dw.FactSalesTarget;

USE EnterpriseSales_DW;

-- Sales fact integrity
SELECT
    'FactSales - Invalid DateKey' AS CheckName,
    COUNT_BIG(*) AS IssueCount
FROM dw.FactSales f
LEFT JOIN dw.DimDate d ON f.DateKey = d.DateKey
WHERE d.DateKey IS NULL

UNION ALL

SELECT
    'FactSales - Invalid CustomerKey',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimCustomer d ON f.CustomerKey = d.CustomerKey
WHERE d.CustomerKey IS NULL

UNION ALL

SELECT
    'FactSales - Invalid ProductKey',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimProduct d ON f.ProductKey = d.ProductKey
WHERE d.ProductKey IS NULL

UNION ALL

SELECT
    'FactSales - Invalid StoreKey',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimStore d ON f.StoreKey = d.StoreKey
WHERE d.StoreKey IS NULL

UNION ALL

SELECT
    'FactSales - Invalid EmployeeKey',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimEmployee d ON f.EmployeeKey = d.EmployeeKey
WHERE d.EmployeeKey IS NULL;