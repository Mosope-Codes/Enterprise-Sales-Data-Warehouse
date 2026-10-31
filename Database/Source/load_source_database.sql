CREATE DATABASE EnterpriseSales_Source;
GO
USE EnterpriseSales_Source;
GO
CREATE SCHEMA src;
GO
-- Create source tables for Customer, Product, Store, Employee, SalesTransaction, ReturnTransaction and ProductPriceHistory.
-- Load the supplied CSV files with BULK INSERT or SSIS.
-- Keep SalesTransaction.NetAmount as VARCHAR initially to force safe conversion/reject handling.

SELECT COUNT(*) FROM src.Customer;  
SELECT COUNT(*) FROM src.Product;
SELECT COUNT(*) FROM src.Store;
SELECT COUNT(*) FROM src.Employee;
SELECT * FROM src.SalesTransaction;
SELECT COUNT(*) FROM src.ReturnTransaction;
SELECT COUNT(*) FROM src.ProductPriceHistory;

SELECT COUNT(*) AS MissingCustomerID FROM src.SalesTransaction WHERE NULLIF(CustomerID,'') IS NULL;
SELECT COUNT(*) AS InvalidNetAmount FROM src.SalesTransaction WHERE TRY_CONVERT(DECIMAL(18,2),NetAmount) IS NULL;
SELECT OrderID, COUNT(*) AS DuplicateCount FROM src.SalesTransaction GROUP BY OrderID HAVING COUNT(*)>1;

SELECT
    SourceRecordID,
    COUNT(*) AS [RowCount]
FROM src.SalesTransaction
GROUP BY SourceRecordID
HAVING COUNT(*) > 1;

SELECT
    OrderID,
    COUNT(*) AS [RowCount]
FROM src.SalesTransaction
GROUP BY OrderID
HAVING COUNT(*) > 1;

SELECT *
FROM src.SalesTransaction
WHERE OrderID = 'SO00257752'
  AND SourceRecordId = 'NG0000257752';

  
ALTER TABLE src.Customer
ADD LastModifiedDate DATETIME2(0) NULL;
GO

ALTER TABLE src.Product
ADD LastModifiedDate DATETIME2(0) NULL;
GO

ALTER TABLE src.Store
ADD LastModifiedDate DATETIME2(0) NULL;
GO

ALTER TABLE src.Employee
ADD LastModifiedDate DATETIME2(0) NULL;

UPDATE src.Customer
SET LastModifiedDate = '2025-01-01 00:00:00'
WHERE LastModifiedDate IS NULL;
GO

UPDATE src.Product
SET LastModifiedDate = '2025-01-01 00:00:00'
WHERE LastModifiedDate IS NULL;
GO

UPDATE src.Store
SET LastModifiedDate = '2025-01-01 00:00:00'
WHERE LastModifiedDate IS NULL;
GO

UPDATE src.Employee
SET LastModifiedDate = '2025-01-01 00:00:00'
WHERE LastModifiedDate IS NULL;
GO

SELECT
    'Customer' AS TableName,
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN LastModifiedDate IS NULL THEN 1 ELSE 0 END) AS MissingTimestamps,
    MIN(LastModifiedDate) AS EarliestTimestamp,
    MAX(LastModifiedDate) AS LatestTimestamp
FROM src.Customer

UNION ALL

SELECT
    'Product',
    COUNT(*),
    SUM(CASE WHEN LastModifiedDate IS NULL THEN 1 ELSE 0 END),
    MIN(LastModifiedDate),
    MAX(LastModifiedDate)
FROM src.Product

UNION ALL

SELECT
    'Store',
    COUNT(*),
    SUM(CASE WHEN LastModifiedDate IS NULL THEN 1 ELSE 0 END),
    MIN(LastModifiedDate),
    MAX(LastModifiedDate)
FROM src.Store

UNION ALL

SELECT
    'Employee',
    COUNT(*),
    SUM(CASE WHEN LastModifiedDate IS NULL THEN 1 ELSE 0 END),
    MIN(LastModifiedDate),
    MAX(LastModifiedDate)
FROM src.Employee;

USE EnterpriseSales_Staging;
GO

ALTER TABLE src.Customer
ADD CONSTRAINT DF_Customer_LastModifiedDate
DEFAULT SYSDATETIME() FOR LastModifiedDate;
GO

ALTER TABLE src.Product
ADD CONSTRAINT DF_Product_LastModifiedDate
DEFAULT SYSDATETIME() FOR LastModifiedDate;
GO

ALTER TABLE src.Store
ADD CONSTRAINT DF_Store_LastModifiedDate
DEFAULT SYSDATETIME() FOR LastModifiedDate;
GO

ALTER TABLE src.Employee
ADD CONSTRAINT DF_Employee_LastModifiedDate
DEFAULT SYSDATETIME() FOR LastModifiedDate;
GO

CREATE OR ALTER TRIGGER src.trg_Customer_LastModifiedDate
ON src.Customer
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Avoid recursively updating the timestamp.
    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    UPDATE c
    SET LastModifiedDate = SYSDATETIME()
    FROM src.Customer AS c
    INNER JOIN inserted AS i
        ON i.CustomerID = c.CustomerID;
END;
GO

CREATE OR ALTER TRIGGER src.trg_Product_LastModifiedDate
ON src.Product
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    UPDATE p
    SET LastModifiedDate = SYSDATETIME()
    FROM src.Product AS p
    INNER JOIN inserted AS i
        ON i.ProductID = p.ProductID;
END;
GO

CREATE OR ALTER TRIGGER src.trg_Store_LastModifiedDate
ON src.Store
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    UPDATE s
    SET LastModifiedDate = SYSDATETIME()
    FROM src.Store AS s
    INNER JOIN inserted AS i
        ON i.StoreID = s.StoreID;
END;
GO

CREATE OR ALTER TRIGGER src.trg_Employee_LastModifiedDate
ON src.Employee
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    UPDATE e
    SET LastModifiedDate = SYSDATETIME()
    FROM src.Employee AS e
    INNER JOIN inserted AS i
        ON i.EmployeeID = e.EmployeeID;
END;
GO

USE EnterpriseSales_Staging;
GO

BEGIN TRANSACTION;

DECLARE @OriginalSegment VARCHAR(100);

SELECT @OriginalSegment = Segment
FROM src.Customer
WHERE CustomerID = 'C000001';

-- Check the original timestamp.
SELECT
    CustomerID,
    CustomerName,
    Segment,
    LastModifiedDate AS OriginalLastModifiedDate
FROM src.Customer
WHERE CustomerID = 'C000001';

-- Simulate an update.
UPDATE src.Customer
SET Segment = CASE
    WHEN Segment = 'Premium' THEN 'Mass Market'
    ELSE 'Premium'
END
WHERE CustomerID = 'C000001';

-- Verify that the timestamp changed.
SELECT
    CustomerID,
    CustomerName,
    Segment,
    LastModifiedDate AS UpdatedLastModifiedDate
FROM src.Customer
WHERE CustomerID = 'C000001';

ROLLBACK TRANSACTION;
GO

SELECT
    CustomerID,
    CustomerName,
    Segment,
    LastModifiedDate
FROM src.Customer
WHERE CustomerID = 'C000001';

USE EnterpriseSales_Source;
GO

IF COL_LENGTH('src.SalesTransaction', 'LastModifiedDate') IS NULL
BEGIN
    ALTER TABLE src.SalesTransaction
    ADD LastModifiedDate DATETIME2(0) NULL;
END;
GO

UPDATE src.SalesTransaction
SET LastModifiedDate = '2025-01-01 00:00:00'
WHERE LastModifiedDate IS NULL;
GO

IF OBJECT_ID(
    'src.DF_SalesTransaction_LastModifiedDate',
    'D'
) IS NULL
BEGIN
    ALTER TABLE src.SalesTransaction
    ADD CONSTRAINT DF_SalesTransaction_LastModifiedDate
    DEFAULT SYSDATETIME() FOR LastModifiedDate;
END;
GO

CREATE OR ALTER TRIGGER src.trg_SalesTransaction_LastModifiedDate
ON src.SalesTransaction
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF TRIGGER_NESTLEVEL() > 1
        RETURN;

    UPDATE s
    SET LastModifiedDate = SYSDATETIME()
    FROM src.SalesTransaction AS s
    INNER JOIN inserted AS i
        ON s.OrderID = i.OrderID
       AND s.SourceRecordID = i.SourceRecordID;
END;
GO

SELECT
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
FROM dbo.ETLWatermark
WHERE SourceTable IN
(
    'Customer',
    'Product',
    'Store',
    'Employee',
    'SalesTransaction'
)
ORDER BY SourceTable;

SELECT
    COUNT(*) AS TotalRows,
    MIN(ReturnDate) AS EarliestReturnDate,
    MAX(ReturnDate) AS LatestReturnDate
FROM src.ReturnTransaction;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'src'
  AND TABLE_NAME = 'ReturnTransaction'
ORDER BY ORDINAL_POSITION;

SELECT
    ReturnID,
    COUNT(*) AS Occurrences
FROM src.ReturnTransaction
GROUP BY ReturnID
HAVING COUNT(*) > 1;

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'src'
  AND TABLE_NAME = 'SalesTarget'
ORDER BY ORDINAL_POSITION;


SELECT
    TargetDate,
    StoreID,
    Category,
    COUNT(*) AS Occurrences,
    MIN(SalesTarget) AS MinimumSalesTarget,
    MAX(SalesTarget) AS MaximumSalesTarget,
    MIN(TransactionTarget) AS MinimumTransactionTarget,
    MAX(TransactionTarget) AS MaximumTransactionTarget
FROM src.SalesTarget
GROUP BY
    TargetDate,
    StoreID,
    Category
HAVING COUNT(*) > 1
ORDER BY
    TargetDate,
    StoreID,
    Category;

   SELECT
    ProductID,
    COUNT(*) AS PriceRecordCount,
    MIN(EffectiveDate) AS FirstEffectiveDate,
    MAX(EffectiveDate) AS LastEffectiveDate
FROM src.ProductPriceHistory
GROUP BY ProductID
HAVING COUNT(*) > 1
ORDER BY PriceRecordCount DESC;

USE EnterpriseSales_Source;

SELECT TOP 10
    CustomerID,
    CustomerName,
    Segment,
    State,
    Status,
    LastModifiedDate
FROM src.Customer
ORDER BY CustomerID;

USE EnterpriseSales_DW;

SELECT
    CustomerKey,
    CustomerID,
    CustomerName,
    Segment,
    State,
    EffectiveDate,
    EndDate,
    IsCurrent
FROM dw.DimCustomer
WHERE CustomerID = 'C000001'
ORDER BY EffectiveDate;


USE EnterpriseSales_Source;

UPDATE src.Customer
SET Segment = 'Gold'
WHERE CustomerID = 'C000001';

SELECT
    CustomerID,
    CustomerName,
    Segment,
    LastModifiedDate
FROM src.Customer
WHERE CustomerID = 'C000001';

USE EnterpriseSales_DW;

SELECT
    CustomerKey,
    CustomerID,
    CustomerName,
    Segment,
    State,
    EffectiveDate,
    EndDate,
    IsCurrent
FROM dw.DimCustomer
WHERE CustomerID = 'C000001'
ORDER BY EffectiveDate, CustomerKey;








SELECT DISTINCT Segment
FROM src.Customer
ORDER BY Segment;