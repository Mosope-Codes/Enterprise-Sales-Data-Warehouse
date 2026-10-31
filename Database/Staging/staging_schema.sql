SELECT COUNT(*) AS StagingCount
FROM stg.SalesTransaction;

SELECT COUNT(*) AS ErrorCount
FROM stg.RejectedSales;

SELECT
    ErrorCode,
    ErrorColumn,
    ErrorDescription,
    COUNT(*) AS ErrorCount
FROM stg.RejectedSales
GROUP BY
    ErrorCode,
    ErrorColumn,
    ErrorDescription
ORDER BY ErrorCount DESC;

SELECT
    stg.RejectedSales.OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    StoreID,
    EmployeeID,
    Quantity,
    UnitPrice,
    GrossAmount,
    DiscountAmount,
    NetAmount,
    CostAmount,
    ProfitAmount,
    stg.RejectedSales.SourceRecordID,
    ErrorCode,
    ErrorColumn
FROM stg.RejectedSales;

select * from stg.SalesTransaction
select * from stg.RejectedSales
select * from stg.Customer;
select * from stg.RejectedCustomer
select * from stg.Product
select * from stg.RejectedProduct
select * from stg.Store
select * from stg.Employee
select * from stg.RejectedEmployee
select * from stg.ReturnTransaction
select * from stg.RejectedReturnTransaction
select * from stg.SalesTarget
select * from stg.RejectedSalesTarget
select * from stg.ProductPriceHistory
select * from stg.RejectedProductPriceHistory


CREATE DATABASE EnterpriseSales_Staging;
GO
CREATE SCHEMA stg;
GO
-- Build staging tables with clean warehouse-ready data types.
create table stg.SalesTransaction(
OrderID varchar(50),
OrderDate Date,
CustomerID varchar(50),
ProductID varchar(50),
StoreID varchar(50),
EmployeeID varchar(50),
Channel varchar(50),
PaymentMethod varchar(50),
OrderStatus varchar(50),
Quantity INT,
UnitPrice Decimal(18,2),
GrossAmount Decimal(18,2),
DiscountAmount Decimal(18,2),
NetAmount Decimal(18,2),
CostAmount Decimal(18,2),
ProfitAmount Decimal(18,2),
SourceRecordID varchar(50),
LoadDateTime DateTime2,
BatchID varchar(50)
)


CREATE TABLE stg.Customer
(
    CustomerID          VARCHAR(50),
    CustomerName        VARCHAR(200),
    Gender              VARCHAR(20),
    Age                 INT,
    State               VARCHAR(100),
    Segment             VARCHAR(100),
    AcquisitionChannel  VARCHAR(100),
    SignupDate          DATE,
    Status               VARCHAR(50),
    City                 VARCHAR(100),
    Region               VARCHAR(100),
    Email               VARCHAR(255),
    Phone               VARCHAR(50),
    LastActivityDate     DATE,
    LoadDateTime         DATETIME2,
    BatchID              VARCHAR(50)
);

Alter table stg.Customer
alter column Gender VARCHAR(50);

CREATE TABLE stg.RejectedCustomer
(
    CustomerID          VARCHAR(50),
    CustomerName        VARCHAR(200),
    Gender              VARCHAR(50),
    Age                 VARCHAR(50),
    State               VARCHAR(100),
    Segment             VARCHAR(100),
    AcquisitionChannel  VARCHAR(100),
    SignupDate          VARCHAR(50),
    Status              VARCHAR(50),
    City                VARCHAR(100),
    Region              VARCHAR(100),
    Email               VARCHAR(255),
    Phone               VARCHAR(50),
    LastActivityDate    VARCHAR(50),

    ErrorCode           VARCHAR(50),
    ErrorColumn         VARCHAR(100),
    ErrorDescription    VARCHAR(500),

    LoadDateTime        DATETIME2,
    BatchID             VARCHAR(50)
);

CREATE TABLE stg.Product
(
    ProductID       VARCHAR(50),
    ProductName     VARCHAR(200),
    Brand           VARCHAR(100),
    Category        VARCHAR(100),
    SubCategory     VARCHAR(100),
    UnitPrice       DECIMAL(18,2),
    UnitCost        DECIMAL(18,2),
    Status          VARCHAR(50),
    LoadDateTime    DATETIME2,
    BatchID         VARCHAR(50)
);

CREATE TABLE stg.RejectedProduct
(
    ProductID        VARCHAR(50),
    ProductName      VARCHAR(200),
    Brand            VARCHAR(100),
    Category         VARCHAR(100),
    SubCategory      VARCHAR(100),
    UnitPrice        VARCHAR(50),
    UnitCost         VARCHAR(50),
    Status           VARCHAR(50),

    ErrorCode        VARCHAR(50),
    ErrorColumn      VARCHAR(100),
    ErrorDescription VARCHAR(500),

    LoadDateTime     DATETIME2,
    BatchID          VARCHAR(50)
);

CREATE TABLE stg.Store
(
    StoreID       VARCHAR(50),
    StoreName     VARCHAR(200),
    City          VARCHAR(100),
    State         VARCHAR(100),
    Region        VARCHAR(100),
    StoreType     VARCHAR(100),
    Status        VARCHAR(50),
    LoadDateTime  DATETIME2,
    BatchID       VARCHAR(50)
);

CREATE TABLE stg.Employee
(
    EmployeeID     VARCHAR(50),
    EmployeeName   VARCHAR(200),
    Role           VARCHAR(100),
    Department     VARCHAR(100),
    StoreID        VARCHAR(50),
    HireDate       DATE,
    Status         VARCHAR(50),
    LoadDateTime   DATETIME2,
    BatchID        VARCHAR(50)
);

CREATE TABLE stg.RejectedEmployee
(
    EmployeeID       VARCHAR(50),
    EmployeeName     VARCHAR(200),
    Role              VARCHAR(100),
    Department       VARCHAR(100),
    StoreID          VARCHAR(50),
    HireDate         VARCHAR(50),
    Status            VARCHAR(50),

    ErrorCode         VARCHAR(50),
    ErrorColumn       VARCHAR(100),
    ErrorDescription  VARCHAR(500),

    LoadDateTime      DATETIME2,
    BatchID           VARCHAR(50)
);

CREATE TABLE stg.ReturnTransaction
(
    ReturnID          VARCHAR(50),
    OrderID           VARCHAR(50),
    ReturnDate        DATE,
    CustomerID        VARCHAR(50),
    ProductID         VARCHAR(50),
    QuantityReturned  INT,
    ReturnReason      VARCHAR(200),
    Resolution        VARCHAR(100),
    LoadDateTime      DATETIME2,
    BatchID            VARCHAR(50)
);

CREATE TABLE stg.RejectedReturnTransaction
(
    ReturnID          VARCHAR(50),
    OrderID           VARCHAR(50),
    ReturnDate        VARCHAR(50),
    CustomerID        VARCHAR(50),
    ProductID         VARCHAR(50),
    QuantityReturned  VARCHAR(50),
    ReturnReason      VARCHAR(200),
    Resolution        VARCHAR(100),

    ErrorCode         VARCHAR(50),
    ErrorColumn       VARCHAR(100),
    ErrorDescription  VARCHAR(500),

    LoadDateTime      DATETIME2,
    BatchID           VARCHAR(50)
);

CREATE TABLE stg.SalesTarget
(
    TargetDate         DATE,
    StoreID             VARCHAR(50),
    Category            VARCHAR(100),
    SalesTarget         DECIMAL(18,2),
    TransactionTarget   INT,
    LoadDateTime        DATETIME2,
    BatchID             VARCHAR(50)
);

CREATE TABLE stg.RejectedSalesTarget
(
    TargetDate         VARCHAR(50),
    StoreID             VARCHAR(50),
    Category            VARCHAR(100),
    SalesTarget         VARCHAR(50),
    TransactionTarget   VARCHAR(50),

    ErrorCode           VARCHAR(50),
    ErrorColumn         VARCHAR(100),
    ErrorDescription    VARCHAR(500),

    LoadDateTime        DATETIME2,
    BatchID             VARCHAR(50)
);

CREATE TABLE stg.ProductPriceHistory
(
    ProductID      VARCHAR(50),
    EffectiveDate  DATE,
    UnitPrice      DECIMAL(18,2),
    SourceSystem   VARCHAR(100),
    LoadDateTime   DATETIME2,
    BatchID        VARCHAR(50)
);

CREATE TABLE stg.RejectedProductPriceHistory
(
    ProductID        VARCHAR(50),
    EffectiveDate    VARCHAR(50),
    UnitPrice        VARCHAR(50),
    SourceSystem     VARCHAR(100),

    ErrorCode        VARCHAR(50),
    ErrorColumn      VARCHAR(100),
    ErrorDescription VARCHAR(500),

    LoadDateTime      DATETIME2,
    BatchID           VARCHAR(50)
);

create table stg.RejectedSales
alter column Quantity varchar(50)
alter table stg.RejectedSales
alter column UnitPrice varchar(50)
alter table stg.RejectedSales
alter column GrossAmount varchar(50)
alter table stg.RejectedSales
alter column DiscountAmount varchar(50)
alter table stg.RejectedSales
alter column NetAmount varchar(50)
alter table stg.RejectedSales
alter column CostAmount varchar(50)
alter table stg.RejectedSales
alter column ProfitAmount varchar(50)


CREATE TABLE stg.RejectedStore
(
    StoreID          VARCHAR(50),
    StoreName        VARCHAR(200),
    City             VARCHAR(100),
    State            VARCHAR(100),
    Region           VARCHAR(100),
    StoreType        VARCHAR(100),
    Status           VARCHAR(50),

    ErrorCode        VARCHAR(50),
    ErrorColumn      VARCHAR(100),
    ErrorDescription VARCHAR(500),

    LoadDateTime     DATETIME2,
    BatchID          VARCHAR(50)
);

CREATE TABLE stg.RejectedSales
(
    OrderID          VARCHAR(50),
    OrderDate        VARCHAR(50),
    CustomerID       VARCHAR(50),
    ProductID        VARCHAR(50),
    StoreID          VARCHAR(50),
    EmployeeID       VARCHAR(50),
    Channel          VARCHAR(50),
    PaymentMethod    VARCHAR(50),
    OrderStatus      VARCHAR(50),

    Quantity         VARCHAR(50),
    UnitPrice        VARCHAR(50),
    GrossAmount      VARCHAR(50),
    DiscountAmount   VARCHAR(50),
    NetAmount        VARCHAR(50),
    CostAmount       VARCHAR(50),
    ProfitAmount     VARCHAR(50),

    SourceRecordID   VARCHAR(50),

    ErrorCode        VARCHAR(50),
    ErrorColumn      VARCHAR(100),
    ErrorDescription VARCHAR(500),

    LoadDateTime     DATETIME2,
    BatchID          VARCHAR(50)
);

CREATE TABLE stg.RejectedReturnTransaction
(
    ReturnID          VARCHAR(50),
    OrderID           VARCHAR(50),
    ReturnDate        VARCHAR(50),
    CustomerID        VARCHAR(50),
    ProductID         VARCHAR(50),
    QuantityReturned  VARCHAR(50),
    ReturnReason      VARCHAR(200),
    Resolution        VARCHAR(100),

    ErrorCode         VARCHAR(50),
    ErrorColumn       VARCHAR(100),
    ErrorDescription  VARCHAR(500),

    LoadDateTime      DATETIME2,
    BatchID           VARCHAR(50)
);

SELECT 'Customer' AS TableName, COUNT(*) AS [RowCount]
FROM stg.Customer

UNION ALL

SELECT 'Product', COUNT(*)
FROM stg.Product

UNION ALL

SELECT 'Store', COUNT(*)
FROM stg.Store

UNION ALL

SELECT 'Employee', COUNT(*)
FROM stg.Employee

UNION ALL

SELECT 'SalesTransaction', COUNT(*)
FROM stg.SalesTransaction

UNION ALL

SELECT 'ReturnTransaction', COUNT(*)
FROM stg.ReturnTransaction

UNION ALL

SELECT 'SalesTarget', COUNT(*)
FROM stg.SalesTarget

UNION ALL

SELECT 'ProductPriceHistory', COUNT(*)
FROM stg.ProductPriceHistory;

select count(*) from stg.Store;
truncate table stg.Store

WITH CTE_Duplicates AS (
    SELECT
        StoreID,
        StoreName,
        City,
        State,
        Region,
        StoreType,
        Status,
        ROW_NUMBER() OVER (
            PARTITION BY StoreID,StoreName,City,State,Region,StoreType,Status
            ORDER BY StoreID ASC              
        ) AS row_num
    FROM src.Store
)

DELETE FROM CTE_Duplicates 
WHERE row_num > 1;

SELECT
    MIN(OrderDate) AS MinDate,
    MAX(OrderDate) AS MaxDate
FROM stg.SalesTransaction

SELECT
    MIN(ReturnDate) AS MinDate,
    MAX(ReturnDate) AS MaxDate
FROM stg.ReturnTransaction

SELECT
    MIN(TargetDate) AS MinDate,
    MAX(TargetDate) AS MaxDate
FROM stg.SalesTarget

SELECT
    MIN(EffectiveDate) AS MinDate,
    MAX(EffectiveDate) AS MaxDate
FROM stg.ProductPriceHistory;

SELECT
    OrderID,
    SourceRecordID,
    COUNT(*) AS Occurrences
FROM EnterpriseSales_Staging.stg.SalesTransaction
GROUP BY
    OrderID,
    SourceRecordID
HAVING COUNT(*) > 1
ORDER BY Occurrences DESC;

SELECT DISTINCT
    s.CustomerID
FROM EnterpriseSales_Staging.stg.SalesTransaction s
LEFT JOIN EnterpriseSales_Staging.stg.Customer c
    ON s.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT
    OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    StoreID,
    EmployeeID,
    SourceRecordID,
    COUNT(*) AS Occurrences
FROM EnterpriseSales_Staging.stg.SalesTransaction
GROUP BY
    OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    StoreID,
    EmployeeID,
    SourceRecordID
HAVING COUNT(*) > 1;

SELECT
    OrderStatus,
    COUNT(*) AS NegativeProfitRows,
    MIN(ProfitAmount) AS MinimumProfit
FROM EnterpriseSales_Staging.stg.SalesTransaction
WHERE ProfitAmount < 0
GROUP BY OrderStatus
ORDER BY NegativeProfitRows DESC;

SELECT TOP 20
    OrderID,
    SourceRecordID,
    COUNT(*) AS Occurrences
FROM EnterpriseSales_Staging.stg.SalesTransaction
GROUP BY
    OrderID,
    SourceRecordID
HAVING COUNT(*) > 1
ORDER BY Occurrences DESC;

SELECT * FROM EnterpriseSales_Staging.stg.SalesTransaction
WHERE OrderID = 'SO00200263'
  AND SourceRecordID = 'NG0000200263';

SELECT *
FROM EnterpriseSales_Staging.stg.SalesTarget
WHERE
    (TargetDate = '2025-03-12' AND StoreID = 'S0188' AND Category = 'Networking')
    OR
    (TargetDate = '2026-05-31' AND StoreID = 'S0039' AND Category = 'Office Equipment');

USE EnterpriseSales_Staging;
GO

CREATE TABLE dbo.ETLWatermark
(
    WatermarkID INT IDENTITY(1,1) PRIMARY KEY,
    SourceTable VARCHAR(100) NOT NULL UNIQUE,
    LastSuccessfulWatermark DATETIME2(0) NOT NULL,
    LastSuccessfulLoadDate DATETIME2(0) NULL
);
GO

INSERT INTO dbo.ETLWatermark
(
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
)
VALUES
(
    'Customer',
    '2025-01-01 00:00:00',
    GETDATE()
),
(
    'Product',
    '2025-01-01 00:00:00',
    GETDATE()
),
(
    'Store',
    '2025-01-01 00:00:00',
    GETDATE()
),
(
    'Employee',
    '2025-01-01 00:00:00',
    GETDATE()
);
GO

SELECT
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
FROM dbo.ETLWatermark
ORDER BY SourceTable;

USE EnterpriseSales_Source;
GO

SELECT
    COUNT(*) AS TotalCustomers,
    COUNT(DISTINCT CustomerID) AS UniqueCustomers,
    SUM(
        CASE
            WHEN LastModifiedDate IS NULL THEN 1
            ELSE 0
        END
    ) AS MissingTimestamps,
    MIN(LastModifiedDate) AS EarliestTimestamp,
    MAX(LastModifiedDate) AS LatestTimestamp,
    SUM(
        CASE
            WHEN LastModifiedDate > '2025-01-01 00:00:00'
            THEN 1
            ELSE 0
        END
    ) AS CustomersNewerThanBaseline
FROM src.Customer;
GO

USE EnterpriseSales_Staging;
GO

ALTER TABLE stg.Customer
ADD SourceLastModifiedDate DATETIME2(0) NULL;
GO

ALTER TABLE stg.Product
ADD SourceLastModifiedDate DATETIME2(0) NULL;
GO

ALTER TABLE stg.Store
ADD SourceLastModifiedDate DATETIME2(0) NULL;
GO

ALTER TABLE stg.Employee
ADD SourceLastModifiedDate DATETIME2(0) NULL;
GO

USE EnterpriseSales_Staging;
GO

UPDATE t
SET t.SourceLastModifiedDate = s.LastModifiedDate
FROM stg.Customer AS t
INNER JOIN EnterpriseSales_Source.src.Customer AS s
    ON s.CustomerID = t.CustomerID
WHERE t.SourceLastModifiedDate IS NULL;
GO

UPDATE t
SET t.SourceLastModifiedDate = s.LastModifiedDate
FROM stg.Product AS t
INNER JOIN EnterpriseSales_Source.src.Product AS s
    ON s.ProductID = t.ProductID
WHERE t.SourceLastModifiedDate IS NULL;
GO

UPDATE t
SET t.SourceLastModifiedDate = s.LastModifiedDate
FROM stg.Store AS t
INNER JOIN EnterpriseSales_Source.src.Store AS s
    ON s.StoreID = t.StoreID
WHERE t.SourceLastModifiedDate IS NULL;
GO

UPDATE t
SET t.SourceLastModifiedDate = s.LastModifiedDate
FROM stg.Employee AS t
INNER JOIN EnterpriseSales_Source.src.Employee AS s
    ON s.EmployeeID = t.EmployeeID
WHERE t.SourceLastModifiedDate IS NULL;
GO

CREATE TABLE stg.CustomerDelta
(
    CustomerID VARCHAR(50) NOT NULL,
    CustomerName VARCHAR(255) NULL,
    Gender VARCHAR(50) NULL,
    Age INT NULL,
    State VARCHAR(100) NULL,
    Segment VARCHAR(100) NULL,
    AcquisitionChannel VARCHAR(100) NULL,
    SignupDate DATE NULL,
    Status VARCHAR(50) NULL,
    City VARCHAR(100) NULL,
    Region VARCHAR(100) NULL,
    LastActivityDate DATE NULL,
    Email VARCHAR(255) NULL,
    Phone VARCHAR(50) NULL,
    SourceLastModifiedDate DATETIME2(0) NULL,
    LoadDateTime DATETIME2(0) NULL,
    BatchID VARCHAR(100) NULL
);

USE EnterpriseSales_Staging;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
  AND TABLE_NAME = 'Customer'
ORDER BY ORDINAL_POSITION;

USE EnterpriseSales_Staging;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
  AND TABLE_NAME = 'CustomerDelta'
ORDER BY ORDINAL_POSITION;

ALTER TABLE stg.CustomerDelta
ALTER COLUMN CustomerName VARCHAR(200) NULL;
GO

ALTER TABLE stg.CustomerDelta
ALTER COLUMN BatchID VARCHAR(50) NULL;
GO

USE EnterpriseSales_Staging;
GO

SELECT
    'Customer' AS TableName,
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CustomerID) AS DistinctCustomerIDs
FROM stg.Customer

UNION ALL

SELECT
    'CustomerDelta',
    COUNT(*),
    COUNT(DISTINCT CustomerID)
FROM stg.CustomerDelta;

USE EnterpriseSales_Staging;
GO

SELECT
    'Customer' AS TableName,
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CustomerID) AS DistinctCustomerIDs
FROM stg.Customer

UNION ALL

SELECT
    'CustomerDelta',
    COUNT(*),
    COUNT(DISTINCT CustomerID)
FROM stg.CustomerDelta;

SELECT
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
FROM dbo.ETLWatermark
WHERE SourceTable = 'Customer';

USE EnterpriseSales_Staging;
GO

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%Product%Delta%';

USE EnterpriseSales_Staging;
GO

IF OBJECT_ID('stg.ProductDelta', 'U') IS NULL
BEGIN
    SELECT TOP (0) *
    INTO stg.ProductDelta
    FROM stg.Product;
END;
GO

USE EnterpriseSales_Staging;
GO

SELECT 'Product' AS TableName, COUNT_BIG(*) AS TotalRows
FROM stg.Product

UNION ALL

SELECT 'ProductDelta', COUNT_BIG(*)
FROM stg.ProductDelta;

SELECT
    ProductID,
    COUNT_BIG(*) AS DuplicateCount
FROM stg.Product
GROUP BY ProductID
HAVING COUNT_BIG(*) > 1;

SELECT
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
FROM dbo.ETLWatermark
WHERE SourceTable = 'Product';

USE EnterpriseSales_Staging;
GO

IF OBJECT_ID('stg.StoreDelta', 'U') IS NULL
BEGIN
    SELECT TOP (0) *
    INTO stg.StoreDelta
    FROM stg.Store;
END;
GO

USE EnterpriseSales_Staging;
GO

IF OBJECT_ID('stg.EmployeeDelta', 'U') IS NULL
BEGIN
    SELECT TOP (0) *
    INTO stg.EmployeeDelta
    FROM stg.Employee;
END;
GO

USE EnterpriseSales_Staging;
GO

SELECT
    'Customer' AS TableName,
    COUNT_BIG(*) AS TotalRows
FROM stg.Customer

UNION ALL

SELECT 'Product', COUNT_BIG(*)
FROM stg.Product

UNION ALL

SELECT 'Store', COUNT_BIG(*)
FROM stg.Store

UNION ALL

SELECT 'Employee', COUNT_BIG(*)
FROM stg.Employee;

USE EnterpriseSales_Staging;
GO

IF COL_LENGTH('stg.SalesTransaction', 'SourceLastModifiedDate') IS NULL
BEGIN
    ALTER TABLE stg.SalesTransaction
    ADD SourceLastModifiedDate DATETIME2(0) NULL;
END;
GO

UPDATE stg.SalesTransaction
SET SourceLastModifiedDate = '2025-01-01 00:00:00'
WHERE SourceLastModifiedDate IS NULL;
GO

USE EnterpriseSales_Staging;
GO

IF OBJECT_ID('stg.SalesTransactionDelta', 'U') IS NULL
BEGIN
    SELECT TOP (0) *
    INTO stg.SalesTransactionDelta
    FROM stg.SalesTransaction;
END;
GO

SELECT
    'SalesTransaction' AS TableName,
    COUNT_BIG(*) AS TotalRows
FROM stg.SalesTransaction

UNION ALL

SELECT
    'SalesTransactionDelta',
    COUNT_BIG(*)
FROM stg.SalesTransactionDelta;

USE EnterpriseSales_Source;
GO

SELECT
    OrderID,
    SourceRecordID,
    COUNT_BIG(*) AS DuplicateCount
FROM src.SalesTransaction
GROUP BY
    OrderID,
    SourceRecordID
HAVING COUNT_BIG(*) > 1
ORDER BY DuplicateCount DESC;

USE EnterpriseSales_Staging;
GO

IF NOT EXISTS (
    SELECT 1
    FROM dbo.ETLWatermark
    WHERE SourceTable = 'SalesTransaction'
)
BEGIN
    INSERT INTO dbo.ETLWatermark
    (
        SourceTable,
        LastSuccessfulWatermark,
        LastSuccessfulLoadDate
    )
    VALUES
    (
        'SalesTransaction',
        '2025-01-01 00:00:00',
        NULL
    );
END;
GO

USE EnterpriseSales_Staging;
GO

CREATE OR ALTER PROCEDURE stg.usp_MergeSalesTransactionDelta
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        ;WITH RankedDelta AS
        (
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY OrderID, SourceRecordID
                    ORDER BY
                        SourceLastModifiedDate DESC,
                        LoadDateTime DESC
                ) AS RowNum
            FROM stg.SalesTransactionDelta
            WHERE TRY_CONVERT(DECIMAL(18,2), NetAmount) IS NOT NULL
        )
        UPDATE target
        SET
            target.OrderDate = source.OrderDate,
            target.CustomerID = source.CustomerID,
            target.ProductID = source.ProductID,
            target.StoreID = source.StoreID,
            target.EmployeeID = source.EmployeeID,
            target.Channel = source.Channel,
            target.PaymentMethod = source.PaymentMethod,
            target.OrderStatus = source.OrderStatus,
            target.Quantity = source.Quantity,
            target.UnitPrice = source.UnitPrice,
            target.GrossAmount = source.GrossAmount,
            target.DiscountAmount = source.DiscountAmount,
            target.NetAmount = source.NetAmount,
            target.CostAmount = source.CostAmount,
            target.ProfitAmount = source.ProfitAmount,
            target.SourceLastModifiedDate =
                source.SourceLastModifiedDate,
            target.LoadDateTime = SYSDATETIME(),
            target.BatchID = source.BatchID
        FROM stg.SalesTransaction AS target
        INNER JOIN RankedDelta AS source
            ON target.OrderID = source.OrderID
           AND target.SourceRecordID = source.SourceRecordID
        WHERE source.RowNum = 1;

        ;WITH RankedDelta AS
        (
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY OrderID, SourceRecordID
                    ORDER BY
                        SourceLastModifiedDate DESC,
                        LoadDateTime DESC
                ) AS RowNum
            FROM stg.SalesTransactionDelta
            WHERE TRY_CONVERT(DECIMAL(18,2), NetAmount) IS NOT NULL
        )
        INSERT INTO stg.SalesTransaction
        (
            OrderID,
            OrderDate,
            CustomerID,
            ProductID,
            StoreID,
            EmployeeID,
            Channel,
            PaymentMethod,
            OrderStatus,
            Quantity,
            UnitPrice,
            GrossAmount,
            DiscountAmount,
            NetAmount,
            CostAmount,
            ProfitAmount,
            SourceRecordID,
            LoadDateTime,
            BatchID,
            SourceLastModifiedDate
        )
        SELECT
            source.OrderID,
            source.OrderDate,
            source.CustomerID,
            source.ProductID,
            source.StoreID,
            source.EmployeeID,
            source.Channel,
            source.PaymentMethod,
            source.OrderStatus,
            source.Quantity,
            source.UnitPrice,
            source.GrossAmount,
            source.DiscountAmount,
            source.NetAmount,
            source.CostAmount,
            source.ProfitAmount,
            source.SourceRecordID,
            SYSDATETIME(),
            source.BatchID,
            source.SourceLastModifiedDate
        FROM RankedDelta AS source
        WHERE source.RowNum = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM stg.SalesTransaction AS target
              WHERE target.OrderID = source.OrderID
                AND target.SourceRecordID = source.SourceRecordID
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
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
    'SalesTransaction',
    'ReturnTransaction'
)
ORDER BY SourceTable;

USE EnterpriseSales_Staging;
GO

IF OBJECT_ID('stg.ReturnTransactionDelta', 'U') IS NULL
BEGIN
    SELECT TOP (0) *
    INTO stg.ReturnTransactionDelta
    FROM stg.ReturnTransaction;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.ETLWatermark
    WHERE SourceTable = 'ReturnTransaction'
)
BEGIN
    INSERT INTO dbo.ETLWatermark
    (
        SourceTable,
        LastSuccessfulWatermark,
        LastSuccessfulLoadDate
    )
    VALUES
    (
        'ReturnTransaction',
        '2025-01-01 00:00:00',
        NULL
    );
END;
GO

USE EnterpriseSales_Staging;
GO

CREATE OR ALTER PROCEDURE stg.usp_MergeReturnTransactionDelta
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update existing return records
        ;WITH RankedDelta AS
        (
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY ReturnID
                    ORDER BY LoadDateTime DESC
                ) AS RowNum
            FROM stg.ReturnTransactionDelta
        )
        UPDATE target
        SET
            target.OrderID = source.OrderID,
            target.ReturnDate = source.ReturnDate,
            target.CustomerID = source.CustomerID,
            target.ProductID = source.ProductID,
            target.QuantityReturned = source.QuantityReturned,
            target.ReturnReason = source.ReturnReason,
            target.Resolution = source.Resolution,
            target.LoadDateTime = SYSDATETIME(),
            target.BatchID = source.BatchID
        FROM stg.ReturnTransaction AS target
        INNER JOIN RankedDelta AS source
            ON target.ReturnID = source.ReturnID
        WHERE source.RowNum = 1;

        -- Insert new return records
        ;WITH RankedDelta AS
        (
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY ReturnID
                    ORDER BY LoadDateTime DESC
                ) AS RowNum
            FROM stg.ReturnTransactionDelta
        )
        INSERT INTO stg.ReturnTransaction
        (
            ReturnID,
            OrderID,
            ReturnDate,
            CustomerID,
            ProductID,
            QuantityReturned,
            ReturnReason,
            Resolution,
            LoadDateTime,
            BatchID
        )
        SELECT
            source.ReturnID,
            source.OrderID,
            source.ReturnDate,
            source.CustomerID,
            source.ProductID,
            source.QuantityReturned,
            source.ReturnReason,
            source.Resolution,
            SYSDATETIME(),
            source.BatchID
        FROM RankedDelta AS source
        WHERE source.RowNum = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM stg.ReturnTransaction AS target
              WHERE target.ReturnID = source.ReturnID
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

USE EnterpriseSales_Staging;
GO

IF OBJECT_ID('stg.ProductPriceHistoryDelta', 'U') IS NULL
BEGIN
    SELECT TOP (0) *
    INTO stg.ProductPriceHistoryDelta
    FROM stg.ProductPriceHistory;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.ETLWatermark
    WHERE SourceTable = 'ProductPriceHistory'
)
BEGIN
    INSERT INTO dbo.ETLWatermark
    (
        SourceTable,
        LastSuccessfulWatermark,
        LastSuccessfulLoadDate
    )
    VALUES
    (
        'ProductPriceHistory',
        '2025-01-01 00:00:00',
        NULL
    );
END;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'src'
  AND TABLE_NAME = 'ProductPriceHistory'
ORDER BY ORDINAL_POSITION;

SELECT
    ProductID,
    EffectiveDate,
    COUNT(*) AS Occurrences
FROM src.ProductPriceHistory
GROUP BY
    ProductID,
    EffectiveDate
HAVING COUNT(*) > 1;

USE EnterpriseSales_Staging;
GO

CREATE OR ALTER PROCEDURE stg.usp_MergeProductPriceHistoryDelta
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update existing price-history records
        ;WITH RankedDelta AS
        (
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY ProductID, EffectiveDate
                    ORDER BY LoadDateTime DESC
                ) AS RowNum
            FROM stg.ProductPriceHistoryDelta
        )
        UPDATE target
        SET
            target.UnitPrice = source.UnitPrice,
            target.SourceSystem = source.SourceSystem,
            target.LoadDateTime = SYSDATETIME(),
            target.BatchID = source.BatchID
        FROM stg.ProductPriceHistory AS target
        INNER JOIN RankedDelta AS source
            ON target.ProductID = source.ProductID
           AND target.EffectiveDate = source.EffectiveDate
        WHERE source.RowNum = 1;

        -- Insert new price-history records
        ;WITH RankedDelta AS
        (
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY ProductID, EffectiveDate
                    ORDER BY LoadDateTime DESC
                ) AS RowNum
            FROM stg.ProductPriceHistoryDelta
        )
        INSERT INTO stg.ProductPriceHistory
        (
            ProductID,
            EffectiveDate,
            UnitPrice,
            SourceSystem,
            LoadDateTime,
            BatchID
        )
        SELECT
            source.ProductID,
            source.EffectiveDate,
            source.UnitPrice,
            source.SourceSystem,
            SYSDATETIME(),
            source.BatchID
        FROM RankedDelta AS source
        WHERE source.RowNum = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM stg.ProductPriceHistory AS target
              WHERE target.ProductID = source.ProductID
                AND target.EffectiveDate = source.EffectiveDate
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

USE EnterpriseSales_Staging;
GO

IF OBJECT_ID('stg.SalesTargetDelta', 'U') IS NULL
BEGIN
    SELECT TOP (0) *
    INTO stg.SalesTargetDelta
    FROM stg.SalesTarget;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.ETLWatermark
    WHERE SourceTable = 'SalesTarget'
)
BEGIN
    INSERT INTO dbo.ETLWatermark
    (
        SourceTable,
        LastSuccessfulWatermark,
        LastSuccessfulLoadDate
    )
    VALUES
    (
        'SalesTarget',
        '2025-01-01 00:00:00',
        NULL
    );
END;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'src'
  AND TABLE_NAME = 'SalesTarget'
ORDER BY ORDINAL_POSITION;

SELECT
    COUNT(*) AS TotalRows,
    SUM(
        CASE
            WHEN TRY_CONVERT(DATE, TargetDate) IS NULL
                THEN 1
            ELSE 0
        END
    ) AS InvalidTargetDates,
    MIN(TRY_CONVERT(DATE, TargetDate)) AS EarliestTargetDate,
    MAX(TRY_CONVERT(DATE, TargetDate)) AS LatestTargetDate
FROM src.SalesTarget;

```sql
USE EnterpriseSales_Staging;
GO

CREATE OR ALTER PROCEDURE stg.usp_MergeSalesTargetDelta
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update matching records if their measures change.
        UPDATE target
        SET
            target.SalesTarget = source.SalesTarget,
            target.TransactionTarget = source.TransactionTarget,
            target.LoadDateTime = SYSDATETIME(),
            target.BatchID = source.BatchID
        FROM stg.SalesTarget AS target
        INNER JOIN stg.SalesTargetDelta AS source
            ON target.TargetDate = source.TargetDate
           AND target.StoreID = source.StoreID
           AND target.Category = source.Category
           AND target.SalesTarget = source.SalesTarget
           AND target.TransactionTarget = source.TransactionTarget;

        -- Insert records that do not already exist.
        INSERT INTO stg.SalesTarget
        (
            TargetDate,
            StoreID,
            Category,
            SalesTarget,
            TransactionTarget,
            LoadDateTime,
            BatchID
        )
        SELECT DISTINCT
            source.TargetDate,
            source.StoreID,
            source.Category,
            source.SalesTarget,
            source.TransactionTarget,
            SYSDATETIME(),
            source.BatchID
        FROM stg.SalesTargetDelta AS source
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM stg.SalesTarget AS target
            WHERE target.TargetDate = source.TargetDate
              AND target.StoreID = source.StoreID
              AND target.Category = source.Category
              AND target.SalesTarget = source.SalesTarget
              AND target.TransactionTarget = source.TransactionTarget
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
```

-- Compare source, staging, and delta counts.
SELECT 'Source' AS TableName, COUNT(*) AS TotalRows
FROM EnterpriseSales_Source.src.SalesTarget

UNION ALL

SELECT 'Staging', COUNT(*)
FROM stg.SalesTarget

UNION ALL

SELECT 'Delta', COUNT(*)
FROM stg.SalesTargetDelta;

-- Confirm the two known combinations remain represented.
SELECT
    TargetDate,
    StoreID,
    Category,
    SalesTarget,
    TransactionTarget
FROM stg.SalesTarget
WHERE
    (TargetDate = '2025-03-12'
     AND StoreID = 'S0188'
     AND Category = 'Networking')
    OR
    (TargetDate = '2026-05-31'
     AND StoreID = 'S0039'
     AND Category = 'Office Equipment')
ORDER BY TargetDate, StoreID, Category;


SELECT
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
FROM dbo.ETLWatermark
ORDER BY SourceTable;