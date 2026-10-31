CREATE DATABASE EnterpriseSales_DW;
GO
USE EnterpriseSales_DW;
GO
CREATE SCHEMA dw; 
CREATE SCHEMA etl;
GO

CREATE TABLE dw.DimDate
(
    DateKey        INT          NOT NULL,
    FullDate       DATE         NOT NULL,
    DayNumber      INT          NOT NULL,
    DayName        VARCHAR(20)  NOT NULL,
    MonthNumber    INT          NOT NULL,
    MonthName      VARCHAR(20)  NOT NULL,
    QuarterNumber  INT          NOT NULL,
    YearNumber     INT          NOT NULL,
    WeekOfYear     INT          NOT NULL,
    IsWeekend      BIT          NOT NULL,

    CONSTRAINT PK_DimDate
        PRIMARY KEY (DateKey)
);

SET DATEFIRST 1;
GO

WITH DateRange AS
(
    SELECT CAST('2025-01-01' AS DATE) AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM DateRange
    WHERE FullDate < '2026-09-23'
)
INSERT INTO dw.DimDate
(
    DateKey,
    FullDate,
    DayNumber,
    DayName,
    MonthNumber,
    MonthName,
    QuarterNumber,
    YearNumber,
    WeekOfYear,
    IsWeekend
)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), FullDate, 112)) AS DateKey,
    FullDate,
    DAY(FullDate),
    DATENAME(WEEKDAY, FullDate),
    MONTH(FullDate),
    DATENAME(MONTH, FullDate),
    DATEPART(QUARTER, FullDate),
    YEAR(FullDate),
    DATEPART(ISO_WEEK, FullDate),
    CASE
        WHEN DATEPART(WEEKDAY, FullDate) IN (6, 7)
            THEN 1
        ELSE 0
    END
FROM DateRange
OPTION (MAXRECURSION 0);
GO

SELECT TOP 10 *
FROM dw.DimDate
ORDER BY FullDate;
-- Required: DimDate, DimCustomer, DimProduct, DimStore, DimEmployee.
-- Required: FactSales, FactReturns, FactSalesTarget.
-- DimCustomer MUST implement SCD Type 2 with surrogate key, business key, start/end dates, IsCurrent and RecordHash.
-- FactSales must reference surrogate dimension keys and document its grain.
-- Add Unknown members (recommended key 0).


CREATE TABLE dw.DimCustomer
(
    CustomerKey          INT IDENTITY(1,1) NOT NULL,
    CustomerID           VARCHAR(50)      NOT NULL,
    CustomerName         VARCHAR(200),
    Gender               VARCHAR(20),
    Age                  INT,
    State                VARCHAR(100),
    Segment              VARCHAR(100),
    AcquisitionChannel   VARCHAR(100),
    SignupDate           DATE,
    Status               VARCHAR(50),
    City                 VARCHAR(100),
    Region               VARCHAR(100),
    LastActivityDate     DATE,

    EffectiveDate        DATE             NOT NULL,
    EndDate              DATE             NULL,
    IsCurrent            BIT              NOT NULL,

    CONSTRAINT PK_DimCustomer
        PRIMARY KEY (CustomerKey)
);

INSERT INTO dw.DimCustomer
(
    CustomerID,
    CustomerName,
    Gender,
    Age,
    State,
    Segment,
    AcquisitionChannel,
    SignupDate,
    Status,
    City,
    Region,
    LastActivityDate,
    EffectiveDate,
    EndDate,
    IsCurrent
)
SELECT
    CustomerID,
    CustomerName,
    Gender,
    Age,
    State,
    Segment,
    AcquisitionChannel,
    SignupDate,
    Status,
    City,
    Region,
    LastActivityDate,
    '2025-01-01' AS EffectiveDate,
    NULL AS EndDate,
    1 AS IsCurrent
FROM EnterpriseSales_Staging.stg.Customer;

select * from dw.DimCustomer

create table dw.DimProduct

CREATE TABLE dw.DimProduct
(
    ProductKey      INT IDENTITY(1,1) NOT NULL,
    ProductID       VARCHAR(50)       NOT NULL,
    ProductName     VARCHAR(200),
    Brand           VARCHAR(100),
    Category        VARCHAR(100),
    SubCategory     VARCHAR(100),
    UnitPrice       DECIMAL(18,2),
    UnitCost        DECIMAL(18,2),
    Status          VARCHAR(50),

    EffectiveDate   DATE              NOT NULL,
    EndDate         DATE              NULL,
    IsCurrent       BIT               NOT NULL,

    CONSTRAINT PK_DimProduct
        PRIMARY KEY (ProductKey)
);

USE EnterpriseSales_DW;
GO

INSERT INTO dw.DimProduct
(
    ProductID,
    ProductName,
    Brand,
    Category,
    SubCategory,
    UnitPrice,
    UnitCost,
    Status,
    EffectiveDate,
    EndDate,
    IsCurrent
)
SELECT
    ProductID,
    ProductName,
    Brand,
    Category,
    SubCategory,
    UnitPrice,
    UnitCost,
    Status,
    '2025-01-01',
    NULL,
    1
FROM EnterpriseSales_Staging.stg.Product;


SELECT COUNT(*) AS ProductCount
FROM dw.DimProduct;

SELECT TOP 10 *
FROM dw.DimProduct
ORDER BY ProductKey;


CREATE TABLE dw.DimStore
(
    StoreKey       INT IDENTITY(1,1) NOT NULL,
    StoreID        VARCHAR(50)       NOT NULL,
    StoreName      VARCHAR(200),
    City           VARCHAR(100),
    State          VARCHAR(100),
    Region         VARCHAR(100),
    StoreType      VARCHAR(100),
    Status         VARCHAR(50),

    EffectiveDate  DATE              NOT NULL,
    EndDate        DATE              NULL,
    IsCurrent      BIT               NOT NULL,

    CONSTRAINT PK_DimStore
        PRIMARY KEY (StoreKey)
);
GO

USE EnterpriseSales_DW;
GO

INSERT INTO dw.DimStore
(
    StoreID,
    StoreName,
    City,
    State,
    Region,
    StoreType,
    Status,
    EffectiveDate,
    EndDate,
    IsCurrent
)
SELECT
    StoreID,
    StoreName,
    City,
    State,
    Region,
    StoreType,
    Status,
    '2025-01-01',
    NULL,
    1
FROM EnterpriseSales_Staging.stg.Store;
GO

USE EnterpriseSales_DW;
GO

CREATE TABLE dw.DimEmployee
(
    EmployeeKey     INT IDENTITY(1,1) NOT NULL,
    EmployeeID      VARCHAR(50)       NOT NULL,
    EmployeeName    VARCHAR(200),
    Role            VARCHAR(100),
    Department      VARCHAR(100),
    StoreID         VARCHAR(50),
    HireDate        DATE,
    Status          VARCHAR(50),

    EffectiveDate   DATE              NOT NULL,
    EndDate         DATE              NULL,
    IsCurrent       BIT               NOT NULL,

    CONSTRAINT PK_DimEmployee
        PRIMARY KEY (EmployeeKey)
);
GO

USE EnterpriseSales_DW;
GO

INSERT INTO dw.DimEmployee
(
    EmployeeID,
    EmployeeName,
    Role,
    Department,
    StoreID,
    HireDate,
    Status,
    EffectiveDate,
    EndDate,
    IsCurrent
)
SELECT
    EmployeeID,
    EmployeeName,
    Role,
    Department,
    StoreID,
    HireDate,
    Status,
    '2025-01-01',
    NULL,
    1
FROM EnterpriseSales_Staging.stg.Employee;
GO

SELECT COUNT(*) AS EmployeeCount
FROM dw.DimEmployee;

USE EnterpriseSales_DW;
GO

CREATE TABLE dw.FactSales
(
    SalesKey        BIGINT IDENTITY(1,1) NOT NULL,

    DateKey         INT          NOT NULL,
    CustomerKey     INT          NOT NULL,
    ProductKey      INT          NOT NULL,
    StoreKey        INT          NOT NULL,
    EmployeeKey     INT          NOT NULL,

    OrderID         VARCHAR(50)  NOT NULL,
    SourceRecordID  VARCHAR(50)  NOT NULL,

    Channel         VARCHAR(50),
    PaymentMethod   VARCHAR(50),
    OrderStatus     VARCHAR(50),

    Quantity        INT,
    UnitPrice       DECIMAL(18,2),
    GrossAmount     DECIMAL(18,2),
    DiscountAmount  DECIMAL(18,2),
    NetAmount       DECIMAL(18,2),
    CostAmount      DECIMAL(18,2),
    ProfitAmount    DECIMAL(18,2),

    CONSTRAINT PK_FactSales
        PRIMARY KEY (SalesKey)
);
GO

SELECT
    COUNT(*) AS SalesRows,
    COUNT(DISTINCT OrderID + '|' + SourceRecordID) AS UniqueSalesKeys
FROM EnterpriseSales_Staging.stg.SalesTransaction;

USE EnterpriseSales_DW;
GO

SELECT
    COUNT(*) AS TotalSalesRows,

    SUM(CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END) AS MissingDate,
    SUM(CASE WHEN c.CustomerKey IS NULL THEN 1 ELSE 0 END) AS MissingCustomer,
    SUM(CASE WHEN p.ProductKey IS NULL THEN 1 ELSE 0 END) AS MissingProduct,
    SUM(CASE WHEN s.StoreKey IS NULL THEN 1 ELSE 0 END) AS MissingStore,
    SUM(CASE WHEN e.EmployeeKey IS NULL THEN 1 ELSE 0 END) AS MissingEmployee

FROM
(
    SELECT DISTINCT
        OrderID,
        SourceRecordID,
        OrderDate,
        CustomerID,
        ProductID,
        StoreID,
        EmployeeID
    FROM EnterpriseSales_Staging.stg.SalesTransaction
) x

LEFT JOIN dw.DimDate d
    ON d.FullDate = x.OrderDate

LEFT JOIN dw.DimCustomer c
    ON c.CustomerID = x.CustomerID
    AND c.IsCurrent = 1

LEFT JOIN dw.DimProduct p
    ON p.ProductID = x.ProductID
    AND p.IsCurrent = 1

LEFT JOIN dw.DimStore s
    ON s.StoreID = x.StoreID
    AND s.IsCurrent = 1

LEFT JOIN dw.DimEmployee e
    ON e.EmployeeID = x.EmployeeID
    AND e.IsCurrent = 1;
GO

SELECT
    s.CustomerID,
    COUNT(*) AS SalesRows
FROM EnterpriseSales_Staging.stg.SalesTransaction s
LEFT JOIN EnterpriseSales_DW.dw.DimCustomer c
    ON s.CustomerID = c.CustomerID
    AND c.IsCurrent = 1
WHERE c.CustomerKey IS NULL
GROUP BY s.CustomerID
ORDER BY SalesRows DESC;

SELECT
    '[' + ISNULL(s.CustomerID, 'NULL') + ']' AS CustomerID,
    LEN(s.CustomerID) AS CustomerIDLength,
    DATALENGTH(s.CustomerID) AS DataLength,
    COUNT(*) AS SalesRows
FROM EnterpriseSales_Staging.stg.SalesTransaction s
LEFT JOIN EnterpriseSales_DW.dw.DimCustomer c
    ON s.CustomerID = c.CustomerID
    AND c.IsCurrent = 1
WHERE c.CustomerKey IS NULL
GROUP BY
    s.CustomerID,
    LEN(s.CustomerID),
    DATALENGTH(s.CustomerID);

SELECT count(*)
FROM EnterpriseSales_Staging.stg.SalesTransaction;

USE EnterpriseSales_DW;
GO

SET IDENTITY_INSERT dw.DimCustomer ON;
GO

INSERT INTO dw.DimCustomer
(
    CustomerKey,
    CustomerID,
    CustomerName,
    Gender,
    Age,
    State,
    Segment,
    AcquisitionChannel,
    SignupDate,
    Status,
    City,
    Region,
    LastActivityDate,
    EffectiveDate,
    EndDate,
    IsCurrent
)
VALUES
(
    -1,
    'UNKNOWN',
    'Unknown Customer',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'UNKNOWN',
    NULL,
    NULL,
    NULL,
    '1900-01-01',
    NULL,
    1
);
GO

SET IDENTITY_INSERT dw.DimCustomer OFF;
GO

USE EnterpriseSales_DW;
GO

SELECT
    COUNT(*) AS TotalSalesRows,

    SUM(CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END) AS MissingDate,
    SUM(CASE WHEN c.CustomerKey IS NULL THEN 1 ELSE 0 END) AS MissingCustomer,
    SUM(CASE WHEN p.ProductKey IS NULL THEN 1 ELSE 0 END) AS MissingProduct,
    SUM(CASE WHEN s.StoreKey IS NULL THEN 1 ELSE 0 END) AS MissingStore,
    SUM(CASE WHEN e.EmployeeKey IS NULL THEN 1 ELSE 0 END) AS MissingEmployee

FROM
(
    SELECT DISTINCT
        OrderID,
        SourceRecordID,
        OrderDate,
        CustomerID,
        ProductID,
        StoreID,
        EmployeeID
    FROM EnterpriseSales_Staging.stg.SalesTransaction
) x

LEFT JOIN dw.DimDate d
    ON d.FullDate = x.OrderDate

LEFT JOIN dw.DimCustomer c
    ON c.CustomerID =
        CASE
            WHEN x.CustomerID = '' THEN 'UNKNOWN'
            ELSE x.CustomerID
        END
    AND c.IsCurrent = 1

LEFT JOIN dw.DimProduct p
    ON p.ProductID = x.ProductID
    AND p.IsCurrent = 1

LEFT JOIN dw.DimStore s
    ON s.StoreID = x.StoreID
    AND s.IsCurrent = 1

LEFT JOIN dw.DimEmployee e
    ON e.EmployeeID = x.EmployeeID
    AND e.IsCurrent = 1;
GO

USE EnterpriseSales_DW;
GO

WITH DeduplicatedSales AS
(
    SELECT
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

        ROW_NUMBER() OVER
        (
            PARTITION BY OrderID, SourceRecordID
            ORDER BY LoadDateTime
        ) AS RowNum

    FROM EnterpriseSales_Staging.stg.SalesTransaction
)

INSERT INTO dw.FactSales
(
    DateKey,
    CustomerKey,
    ProductKey,
    StoreKey,
    EmployeeKey,
    OrderID,
    SourceRecordID,
    Channel,
    PaymentMethod,
    OrderStatus,
    Quantity,
    UnitPrice,
    GrossAmount,
    DiscountAmount,
    NetAmount,
    CostAmount,
    ProfitAmount
)
SELECT
    d.DateKey,
    CASE
        WHEN s.CustomerID = '' THEN -1
        ELSE c.CustomerKey
    END AS CustomerKey,
    p.ProductKey,
    st.StoreKey,
    e.EmployeeKey,

    s.OrderID,
    s.SourceRecordID,
    s.Channel,
    s.PaymentMethod,
    s.OrderStatus,
    s.Quantity,
    s.UnitPrice,
    s.GrossAmount,
    s.DiscountAmount,
    s.NetAmount,
    s.CostAmount,
    s.ProfitAmount

FROM DeduplicatedSales s

INNER JOIN dw.DimDate d
    ON d.FullDate = s.OrderDate

LEFT JOIN dw.DimCustomer c
    ON c.CustomerID = s.CustomerID
    AND c.IsCurrent = 1

INNER JOIN dw.DimProduct p
    ON p.ProductID = s.ProductID
    AND p.IsCurrent = 1

INNER JOIN dw.DimStore st
    ON st.StoreID = s.StoreID
    AND st.IsCurrent = 1

INNER JOIN dw.DimEmployee e
    ON e.EmployeeID = s.EmployeeID
    AND e.IsCurrent = 1

WHERE s.RowNum = 1;
GO

SELECT COUNT(*) AS FactSalesRows
FROM dw.FactSales;

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT OrderID + '|' + SourceRecordID) AS UniqueBusinessKeys,
    SUM(CASE WHEN CustomerKey = -1 THEN 1 ELSE 0 END) AS UnknownCustomerRows
FROM dw.FactSales;

USE EnterpriseSales_DW;
GO

CREATE TABLE dw.FactReturns
(
    ReturnKey          BIGINT IDENTITY(1,1) NOT NULL,

    DateKey            INT          NOT NULL,
    CustomerKey        INT          NOT NULL,
    ProductKey         INT          NOT NULL,

    ReturnID           VARCHAR(50)  NOT NULL,
    OrderID            VARCHAR(50),

    QuantityReturned   INT,
    ReturnReason       VARCHAR(200),
    Resolution         VARCHAR(100),

    CONSTRAINT PK_FactReturns
        PRIMARY KEY (ReturnKey)
);
GO

SELECT
    COUNT(*) AS TotalReturnRows,

    SUM(CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END) AS MissingDate,
    SUM(CASE WHEN c.CustomerKey IS NULL THEN 1 ELSE 0 END) AS MissingCustomer,
    SUM(CASE WHEN p.ProductKey IS NULL THEN 1 ELSE 0 END) AS MissingProduct

FROM EnterpriseSales_Staging.stg.ReturnTransaction r

LEFT JOIN dw.DimDate d
    ON d.FullDate = r.ReturnDate

LEFT JOIN dw.DimCustomer c
    ON c.CustomerID =
        CASE
            WHEN r.CustomerID = '' THEN 'UNKNOWN'
            ELSE r.CustomerID
        END
    AND c.IsCurrent = 1

LEFT JOIN dw.DimProduct p
    ON p.ProductID = r.ProductID
    AND p.IsCurrent = 1;
GO

USE EnterpriseSales_DW;
GO

SELECT
    COUNT(*) AS TotalReturnRows,
    SUM(CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END) AS MissingDate,
    SUM(CASE WHEN c.CustomerKey IS NULL THEN 1 ELSE 0 END) AS MissingCustomer,
    SUM(CASE WHEN p.ProductKey IS NULL THEN 1 ELSE 0 END) AS MissingProduct
FROM EnterpriseSales_Staging.stg.ReturnTransaction r
LEFT JOIN dw.DimDate d
    ON d.FullDate = r.ReturnDate
LEFT JOIN dw.DimCustomer c
    ON c.CustomerID =
        CASE
            WHEN r.CustomerID = '' THEN 'UNKNOWN'
            ELSE r.CustomerID
        END
    AND c.IsCurrent = 1
LEFT JOIN dw.DimProduct p
    ON p.ProductID = r.ProductID
    AND p.IsCurrent = 1;
GO

USE EnterpriseSales_DW;
GO

INSERT INTO dw.FactReturns
(
    DateKey,
    CustomerKey,
    ProductKey,
    ReturnID,
    OrderID,
    QuantityReturned,
    ReturnReason,
    Resolution
)
SELECT
    d.DateKey,
    CASE 
        WHEN r.CustomerID = '' THEN -1
        ELSE c.CustomerKey
    END AS CustomerKey,
    p.ProductKey,
    r.ReturnID,
    r.OrderID,
    r.QuantityReturned,
    r.ReturnReason,
    r.Resolution
FROM EnterpriseSales_Staging.stg.ReturnTransaction r
INNER JOIN dw.DimDate d
    ON d.FullDate = r.ReturnDate
LEFT JOIN dw.DimCustomer c
    ON c.CustomerID = r.CustomerID
    AND c.IsCurrent = 1
INNER JOIN dw.DimProduct p
    ON p.ProductID = r.ProductID
    AND p.IsCurrent = 1;
GO

SELECT COUNT(*) AS FactReturnsRows
FROM dw.FactReturns;

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT ReturnID) AS UniqueReturnIDs
FROM dw.FactReturns;

USE EnterpriseSales_DW;
GO

CREATE TABLE dw.FactSalesTarget
(
    SalesTargetKey      BIGINT IDENTITY(1,1) NOT NULL,
    DateKey             INT NOT NULL,
    StoreKey            INT NOT NULL,
    Category            VARCHAR(100) NOT NULL,
    SalesTarget         DECIMAL(18,2),
    TransactionTarget   INT,

    CONSTRAINT PK_FactSalesTarget
        PRIMARY KEY (SalesTargetKey)
);
GO

SELECT
    COUNT(*) AS TotalTargetRows,
    SUM(CASE WHEN d.DateKey IS NULL THEN 1 ELSE 0 END) AS MissingDate,
    SUM(CASE WHEN s.StoreKey IS NULL THEN 1 ELSE 0 END) AS MissingStore
FROM EnterpriseSales_Staging.stg.SalesTarget t
LEFT JOIN dw.DimDate d
    ON d.FullDate = t.TargetDate
LEFT JOIN dw.DimStore s
    ON s.StoreID = t.StoreID
    AND s.IsCurrent = 1;

USE EnterpriseSales_DW;
GO

INSERT INTO dw.FactSalesTarget
(
    DateKey,
    StoreKey,
    Category,
    SalesTarget,
    TransactionTarget
)
SELECT
    d.DateKey,
    s.StoreKey,
    t.Category,
    t.SalesTarget,
    t.TransactionTarget
FROM EnterpriseSales_Staging.stg.SalesTarget t
INNER JOIN dw.DimDate d
    ON d.FullDate = t.TargetDate
INNER JOIN dw.DimStore s
    ON s.StoreID = t.StoreID
    AND s.IsCurrent = 1;
GO

SELECT COUNT(*) AS FactSalesTargetRows
FROM dw.FactSalesTarget;

SELECT
    d.FullDate AS TargetDate,
    s.StoreID,
    f.Category,
    COUNT(*) AS RecordCount
FROM dw.FactSalesTarget f
INNER JOIN dw.DimDate d
    ON d.DateKey = f.DateKey
INNER JOIN dw.DimStore s
    ON s.StoreKey = f.StoreKey
GROUP BY
    d.FullDate,
    s.StoreID,
    f.Category
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT SalesTargetKey) AS UniqueFactKeys
FROM dw.FactSalesTarget;

USE EnterpriseSales_DW;
GO

SELECT
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN IsCurrent = 1 THEN 1 ELSE 0 END) AS CurrentCustomers,
    SUM(CASE WHEN IsCurrent = 0 THEN 1 ELSE 0 END) AS HistoricalCustomers
FROM dw.DimCustomer;

SELECT
    s.CustomerID,
    s.CustomerName AS StagingName,
    d.CustomerName AS WarehouseName,
    s.Segment AS StagingSegment,
    d.Segment AS WarehouseSegment
FROM EnterpriseSales_Staging.stg.Customer s
INNER JOIN dw.DimCustomer d
    ON s.CustomerID = d.CustomerID
WHERE d.IsCurrent = 1
  AND
  (
        ISNULL(s.CustomerName, '') <> ISNULL(d.CustomerName, '')
     OR ISNULL(s.Gender, '') <> ISNULL(d.Gender, '')
     OR ISNULL(s.Age, -1) <> ISNULL(d.Age, -1)
     OR ISNULL(s.State, '') <> ISNULL(d.State, '')
     OR ISNULL(s.Segment, '') <> ISNULL(d.Segment, '')
     OR ISNULL(s.AcquisitionChannel, '') <> ISNULL(d.AcquisitionChannel, '')
     OR ISNULL(s.SignupDate, '1900-01-01') <> ISNULL(d.SignupDate, '1900-01-01')
     OR ISNULL(s.Status, '') <> ISNULL(d.Status, '')
     OR ISNULL(s.City, '') <> ISNULL(d.City, '')
     OR ISNULL(s.Region, '') <> ISNULL(d.Region, '')
     OR ISNULL(s.LastActivityDate, '1900-01-01') <> ISNULL(d.LastActivityDate, '1900-01-01')
  );

  USE EnterpriseSales_Staging;
GO

SELECT *
INTO #Customer_SCD_Test
FROM stg.Customer;
GO

SELECT TOP 1
    CustomerID,
    CustomerName,
    Segment
FROM #Customer_SCD_Test
ORDER BY CustomerID;

UPDATE #Customer_SCD_Test
SET Segment = 'Corporate'
WHERE CustomerID = 'C000001';

SELECT
    CustomerID,
    CustomerName,
    Segment
FROM #Customer_SCD_Test
WHERE CustomerID = 'C000001';

USE EnterpriseSales_DW;
GO

SELECT
    s.CustomerID,
    d.CustomerKey AS ExistingCustomerKey,
    d.Segment AS OldSegment,
    s.Segment AS NewSegment
FROM EnterpriseSales_Staging.dbo.#Customer_SCD_Test s
INNER JOIN dw.DimCustomer d
    ON s.CustomerID = d.CustomerID
WHERE d.IsCurrent = 1
  AND ISNULL(s.Segment, '') <> ISNULL(d.Segment, '');

USE EnterpriseSales_DW;
GO

SELECT
    s.CustomerID,
    d.CustomerKey,
    d.Segment AS CurrentSegment,
    s.Segment AS StagingSegment
FROM EnterpriseSales_Staging.stg.Customer s
INNER JOIN dw.DimCustomer d
    ON d.CustomerID = s.CustomerID
    AND d.IsCurrent = 1
WHERE s.CustomerID <> 'UNKNOWN'
  AND
  (
        ISNULL(s.CustomerName, '') <> ISNULL(d.CustomerName, '')
     OR ISNULL(s.Gender, '') <> ISNULL(d.Gender, '')
     OR ISNULL(s.Age, -1) <> ISNULL(d.Age, -1)
     OR ISNULL(s.State, '') <> ISNULL(d.State, '')
     OR ISNULL(s.Segment, '') <> ISNULL(d.Segment, '')
     OR ISNULL(s.AcquisitionChannel, '') <> ISNULL(d.AcquisitionChannel, '')
     OR ISNULL(s.SignupDate, '1900-01-01') <> ISNULL(d.SignupDate, '1900-01-01')
     OR ISNULL(s.Status, '') <> ISNULL(d.Status, '')
     OR ISNULL(s.City, '') <> ISNULL(d.City, '')
     OR ISNULL(s.Region, '') <> ISNULL(d.Region, '')
     OR ISNULL(s.LastActivityDate, '1900-01-01') <> ISNULL(d.LastActivityDate, '1900-01-01')
  );
GO

USE EnterpriseSales_DW;
GO

SELECT TOP 1
    CustomerID,
    CustomerName,
    Segment,
    EffectiveDate,
    EndDate,
    IsCurrent
FROM dw.DimCustomer
WHERE IsCurrent = 1
  AND CustomerID <> 'UNKNOWN'
ORDER BY CustomerID;

USE EnterpriseSales_DW;
GO

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dw'
  AND TABLE_NAME = 'DimCustomer'
ORDER BY ORDINAL_POSITION;

SELECT TOP (5) *
FROM dw.DimCustomer
ORDER BY CustomerKey;

CREATE OR ALTER PROCEDURE dw.usp_ProcessCustomerDimension
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /*
          Step 1: Get the Customer records extracted into the delta table.
          Ignore blank IDs and the unknown member.
        */
        ;WITH SourceCustomers AS
        (
            SELECT
                CustomerID,
                CustomerName,
                Gender,
                Age,
                State,
                Segment,
                AcquisitionChannel,
                SignupDate,
                Status,
                City,
                Region,
                LastActivityDate,
                SourceLastModifiedDate,
                ROW_NUMBER() OVER
                (
                    PARTITION BY CustomerID
                    ORDER BY SourceLastModifiedDate DESC
                ) AS rn
            FROM EnterpriseSales_Staging.stg.CustomerDelta
            WHERE NULLIF(LTRIM(RTRIM(CustomerID)), '') IS NOT NULL
              AND CustomerID <> 'UNKNOWN'
        )
        SELECT
            CustomerID,
            CustomerName,
            Gender,
            Age,
            State,
            Segment,
            AcquisitionChannel,
            SignupDate,
            Status,
            City,
            Region,
            LastActivityDate,
            SourceLastModifiedDate
        INTO #SourceCustomers
        FROM SourceCustomers
        WHERE rn = 1;

        /*
          Step 2: Expire existing versions where tracked attributes changed.
        */
        UPDATE d
        SET
            d.EndDate = DATEADD
            (
                DAY,
                -1,
                CAST(s.SourceLastModifiedDate AS DATE)
            ),
            d.IsCurrent = 0
        FROM dw.DimCustomer AS d
        INNER JOIN #SourceCustomers AS s
            ON s.CustomerID = d.CustomerID
        WHERE d.IsCurrent = 1
          AND
          (
                 ISNULL(d.CustomerName, '') <> ISNULL(s.CustomerName, '')
              OR ISNULL(d.Gender, '') <> ISNULL(s.Gender, '')
              OR ISNULL(d.Age, -1) <> ISNULL(s.Age, -1)
              OR ISNULL(d.State, '') <> ISNULL(s.State, '')
              OR ISNULL(d.Segment, '') <> ISNULL(s.Segment, '')
              OR ISNULL(d.AcquisitionChannel, '') <>
                 ISNULL(s.AcquisitionChannel, '')
              OR ISNULL(d.SignupDate, '19000101') <>
                 ISNULL(s.SignupDate, '19000101')
              OR ISNULL(d.Status, '') <> ISNULL(s.Status, '')
              OR ISNULL(d.City, '') <> ISNULL(s.City, '')
              OR ISNULL(d.Region, '') <> ISNULL(s.Region, '')
              OR ISNULL(d.LastActivityDate, '19000101') <>
                 ISNULL(s.LastActivityDate, '19000101')
          );

        /*
          Step 3: Insert new customers and new versions of changed customers.
        */
        INSERT INTO dw.DimCustomer
        (
            CustomerID,
            CustomerName,
            Gender,
            Age,
            State,
            Segment,
            AcquisitionChannel,
            SignupDate,
            Status,
            City,
            Region,
            LastActivityDate,
            EffectiveDate,
            EndDate,
            IsCurrent
        )
        SELECT
            s.CustomerID,
            s.CustomerName,
            s.Gender,
            s.Age,
            s.State,
            s.Segment,
            s.AcquisitionChannel,
            s.SignupDate,
            s.Status,
            s.City,
            s.Region,
            s.LastActivityDate,
            CAST(s.SourceLastModifiedDate AS DATE),
            NULL,
            1
        FROM #SourceCustomers AS s
        LEFT JOIN dw.DimCustomer AS d
            ON d.CustomerID = s.CustomerID
           AND d.IsCurrent = 1
        WHERE d.CustomerKey IS NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO

USE EnterpriseSales_DW;
GO

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dw'
  AND TABLE_NAME IN
  (
      'DimProduct',
      'DimStore',
      'DimEmployee'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

USE EnterpriseSales_DW;

SELECT
    'FactSales' AS TableName,
    SUM(NetAmount) AS TotalNetSales
FROM dw.FactSales

UNION ALL

SELECT
    'FactSalesTarget',
    SUM(SalesTarget)
FROM dw.FactSalesTarget;

USE EnterpriseSales_DW;

SELECT 'DimCustomer' AS TableName, COUNT_BIG(*) AS TotalRows
FROM dw.DimCustomer

UNION ALL

SELECT 'DimProduct', COUNT_BIG(*)
FROM dw.DimProduct

UNION ALL

SELECT 'DimStore', COUNT_BIG(*)
FROM dw.DimStore

UNION ALL

SELECT 'DimEmployee', COUNT_BIG(*)
FROM dw.DimEmployee

UNION ALL

SELECT 'FactSales', COUNT_BIG(*)
FROM dw.FactSales

UNION ALL

SELECT 'FactReturns', COUNT_BIG(*)
FROM dw.FactReturns

UNION ALL

SELECT 'FactSalesTarget', COUNT_BIG(*)
FROM dw.FactSalesTarget;

USE EnterpriseSales_DW;

SELECT
    CustomerID,
    COUNT(*) AS VersionCount,
    SUM(CASE WHEN IsCurrent = 1 THEN 1 ELSE 0 END) AS CurrentVersions
FROM dw.DimCustomer
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY VersionCount DESC;