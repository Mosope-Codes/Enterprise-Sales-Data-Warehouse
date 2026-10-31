USE EnterpriseSales_DW;
GO

CREATE OR ALTER PROCEDURE dw.usp_ProcessProductDimension
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcessDate DATE = CAST(GETDATE() AS DATE);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Expire current versions where product attributes have changed.
        UPDATE d
        SET
            d.EndDate = DATEADD(DAY, -1, @ProcessDate),
            d.IsCurrent = 0
        FROM dw.DimProduct d
        INNER JOIN EnterpriseSales_Staging.stg.Product s
            ON s.ProductID = d.ProductID
        WHERE d.IsCurrent = 1
          AND (
                ISNULL(d.ProductName, '') <> ISNULL(s.ProductName, '')
             OR ISNULL(d.Brand, '') <> ISNULL(s.Brand, '')
             OR ISNULL(d.Category, '') <> ISNULL(s.Category, '')
             OR ISNULL(d.SubCategory, '') <> ISNULL(s.SubCategory, '')
             OR ISNULL(d.UnitPrice, 0) <> ISNULL(s.UnitPrice, 0)
             OR ISNULL(d.UnitCost, 0) <> ISNULL(s.UnitCost, 0)
             OR ISNULL(d.Status, '') <> ISNULL(s.Status, '')
          );

        -- Insert new products and new versions of changed products.
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
            s.ProductID,
            s.ProductName,
            s.Brand,
            s.Category,
            s.SubCategory,
            s.UnitPrice,
            s.UnitCost,
            s.Status,
            @ProcessDate,
            NULL,
            1
        FROM EnterpriseSales_Staging.stg.Product s
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dw.DimProduct d
            WHERE d.ProductID = s.ProductID
              AND d.IsCurrent = 1
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

USE EnterpriseSales_DW;
GO

CREATE OR ALTER PROCEDURE dw.usp_ProcessStoreDimension
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcessDate DATE = CAST(GETDATE() AS DATE);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Expire changed current store records.
        UPDATE d
        SET
            d.EndDate = DATEADD(DAY, -1, @ProcessDate),
            d.IsCurrent = 0
        FROM dw.DimStore d
        INNER JOIN EnterpriseSales_Staging.stg.Store s
            ON s.StoreID = d.StoreID
        WHERE d.IsCurrent = 1
          AND (
                ISNULL(d.StoreName, '') <> ISNULL(s.StoreName, '')
             OR ISNULL(d.City, '') <> ISNULL(s.City, '')
             OR ISNULL(d.State, '') <> ISNULL(s.State, '')
             OR ISNULL(d.Region, '') <> ISNULL(s.Region, '')
             OR ISNULL(d.StoreType, '') <> ISNULL(s.StoreType, '')
             OR ISNULL(d.Status, '') <> ISNULL(s.Status, '')
          );

        -- Insert new stores and new versions of changed stores.
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
            s.StoreID,
            s.StoreName,
            s.City,
            s.State,
            s.Region,
            s.StoreType,
            s.Status,
            @ProcessDate,
            NULL,
            1
        FROM EnterpriseSales_Staging.stg.Store s
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dw.DimStore d
            WHERE d.StoreID = s.StoreID
              AND d.IsCurrent = 1
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

USE EnterpriseSales_DW;
GO

CREATE OR ALTER PROCEDURE dw.usp_ProcessEmployeeDimension
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcessDate DATE = CAST(GETDATE() AS DATE);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Expire changed current employee records.
        UPDATE d
        SET
            d.EndDate = DATEADD(DAY, -1, @ProcessDate),
            d.IsCurrent = 0
        FROM dw.DimEmployee d
        INNER JOIN EnterpriseSales_Staging.stg.Employee s
            ON s.EmployeeID = d.EmployeeID
        WHERE d.IsCurrent = 1
          AND (
                ISNULL(d.EmployeeName, '') <> ISNULL(s.EmployeeName, '')
             OR ISNULL(d.Role, '') <> ISNULL(s.Role, '')
             OR ISNULL(d.Department, '') <> ISNULL(s.Department, '')
             OR ISNULL(d.StoreID, '') <> ISNULL(s.StoreID, '')
             OR ISNULL(d.HireDate, '19000101') <> ISNULL(s.HireDate, '19000101')
             OR ISNULL(d.Status, '') <> ISNULL(s.Status, '')
          );

        -- Insert new employees and new versions of changed employees.
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
            s.EmployeeID,
            s.EmployeeName,
            s.Role,
            s.Department,
            s.StoreID,
            s.HireDate,
            s.Status,
            @ProcessDate,
            NULL,
            1
        FROM EnterpriseSales_Staging.stg.Employee s
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dw.DimEmployee d
            WHERE d.EmployeeID = s.EmployeeID
              AND d.IsCurrent = 1
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

USE EnterpriseSales_DW;
GO

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dw'
  AND TABLE_NAME IN (
      'FactSales',
      'FactReturns',
      'FactSalesTarget'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dw'
  AND TABLE_NAME IN (
      'DimDate',
      'DimCustomer',
      'DimProduct',
      'DimStore',
      'DimEmployee'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

    USE EnterpriseSales_Staging;
GO

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
  AND TABLE_NAME IN (
      'SalesTransaction',
      'ReturnTransaction',
      'SalesTarget'
  )
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;

USE EnterpriseSales_DW;
GO

CREATE OR ALTER PROCEDURE dw.usp_ProcessSalesFact
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        ;WITH SalesSource AS
        (
            SELECT
                s.OrderID,
                s.SourceRecordID,
                s.OrderDate,
                s.CustomerID,
                s.ProductID,
                s.StoreID,
                s.EmployeeID,
                s.Channel,
                s.PaymentMethod,
                s.OrderStatus,
                s.Quantity,
                s.UnitPrice,
                s.GrossAmount,
                s.DiscountAmount,
                s.NetAmount,
                s.CostAmount,
                s.ProfitAmount,
                ROW_NUMBER() OVER
                (
                    PARTITION BY s.OrderID, s.SourceRecordID
                    ORDER BY s.LoadDateTime DESC
                ) AS RowNum
            FROM EnterpriseSales_Staging.stg.SalesTransaction s
            WHERE s.OrderID IS NOT NULL
              AND s.SourceRecordID IS NOT NULL
              AND s.OrderDate IS NOT NULL
              AND TRY_CONVERT(DECIMAL(18,2), s.NetAmount) IS NOT NULL
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
            dt.DateKey,
            COALESCE(dc.CustomerKey, -1),
            dp.ProductKey,
            ds.StoreKey,
            de.EmployeeKey,
            s.OrderID,
            s.SourceRecordID,
            s.Channel,
            s.PaymentMethod,
            s.OrderStatus,
            s.Quantity,
            s.UnitPrice,
            s.GrossAmount,
            s.DiscountAmount,
            TRY_CONVERT(DECIMAL(18,2), s.NetAmount),
            s.CostAmount,
            s.ProfitAmount
        FROM SalesSource s
        INNER JOIN dw.DimDate dt
            ON dt.FullDate = s.OrderDate
        LEFT JOIN dw.DimCustomer dc
            ON dc.CustomerID = s.CustomerID
           AND dc.IsCurrent = 1
        INNER JOIN dw.DimProduct dp
            ON dp.ProductID = s.ProductID
           AND dp.IsCurrent = 1
        INNER JOIN dw.DimStore ds
            ON ds.StoreID = s.StoreID
           AND ds.IsCurrent = 1
        INNER JOIN dw.DimEmployee de
            ON de.EmployeeID = s.EmployeeID
           AND de.IsCurrent = 1
        WHERE s.RowNum = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM dw.FactSales f
              WHERE f.OrderID = s.OrderID
                AND f.SourceRecordID = s.SourceRecordID
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

EXEC dw.usp_ProcessSalesFact;

SELECT
    COUNT(*) AS TotalSalesRows,
    COUNT(DISTINCT CONCAT(OrderID, '|', SourceRecordID))
        AS DistinctBusinessKeys
FROM dw.FactSales;

USE EnterpriseSales_DW;
GO

CREATE OR ALTER PROCEDURE dw.usp_ProcessReturnsFact
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        ;WITH ReturnSource AS
        (
            SELECT
                r.ReturnID,
                r.OrderID,
                r.ReturnDate,
                r.CustomerID,
                r.ProductID,
                r.QuantityReturned,
                r.ReturnReason,
                r.Resolution,
                ROW_NUMBER() OVER
                (
                    PARTITION BY r.ReturnID
                    ORDER BY r.LoadDateTime DESC
                ) AS RowNum
            FROM EnterpriseSales_Staging.stg.ReturnTransaction r
        )
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
            dt.DateKey,
            COALESCE(dc.CustomerKey, -1),
            COALESCE(dp.ProductKey, -1),
            r.ReturnID,
            r.OrderID,
            r.QuantityReturned,
            r.ReturnReason,
            r.Resolution
        FROM ReturnSource r
        INNER JOIN EnterpriseSales_DW.dw.DimDate dt
            ON dt.FullDate = r.ReturnDate
        LEFT JOIN EnterpriseSales_DW.dw.DimCustomer dc
            ON dc.CustomerID = r.CustomerID
           AND dc.IsCurrent = 1
        LEFT JOIN EnterpriseSales_DW.dw.DimProduct dp
            ON dp.ProductID = r.ProductID
           AND dp.IsCurrent = 1
        WHERE r.RowNum = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM dw.FactReturns f
              WHERE f.ReturnID = r.ReturnID
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

USE EnterpriseSales_DW;
GO

CREATE OR ALTER PROCEDURE dw.usp_ProcessSalesTargetFact
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        ;WITH TargetSource AS
        (
            SELECT
                s.TargetDate,
                s.StoreID,
                s.Category,
                s.SalesTarget,
                s.TransactionTarget,
                ROW_NUMBER() OVER
                (
                    PARTITION BY
                        s.TargetDate,
                        s.StoreID,
                        s.Category
                    ORDER BY s.LoadDateTime DESC
                ) AS RowNum
            FROM EnterpriseSales_Staging.stg.SalesTarget s
        )
        INSERT INTO dw.FactSalesTarget
        (
            DateKey,
            StoreKey,
            Category,
            SalesTarget,
            TransactionTarget
        )
        SELECT
            dt.DateKey,
            ds.StoreKey,
            s.Category,
            s.SalesTarget,
            s.TransactionTarget
        FROM TargetSource s
        INNER JOIN EnterpriseSales_DW.dw.DimDate dt
            ON dt.FullDate = s.TargetDate
        INNER JOIN EnterpriseSales_DW.dw.DimStore ds
            ON ds.StoreID = s.StoreID
           AND ds.IsCurrent = 1
        WHERE s.RowNum = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM dw.FactSalesTarget f
              WHERE f.DateKey = dt.DateKey
                AND f.StoreKey = ds.StoreKey
                AND f.Category = s.Category
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

CREATE OR ALTER PROCEDURE dbo.usp_UpdateETLWatermark
    @SourceTable VARCHAR(100),
    @NewWatermark DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    UPDATE dbo.ETLWatermark
    SET
        LastSuccessfulWatermark = @NewWatermark,
        LastSuccessfulLoadDate = SYSDATETIME()
    WHERE SourceTable = @SourceTable;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50001, 'Watermark record was not found.', 1;
    END;
END;
GO

USE EnterpriseSales_DW;
GO

SELECT 'DimDate' AS TableName, COUNT_BIG(*) AS TotalRows
FROM dw.DimDate

UNION ALL

SELECT 'DimCustomer', COUNT_BIG(*)
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
GO

SELECT
    'FactSales - Date' AS CheckName,
    COUNT_BIG(*) AS InvalidRows
FROM dw.FactSales f
LEFT JOIN dw.DimDate d
    ON f.DateKey = d.DateKey
WHERE d.DateKey IS NULL

UNION ALL

SELECT
    'FactSales - Customer',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimCustomer d
    ON f.CustomerKey = d.CustomerKey
WHERE d.CustomerKey IS NULL

UNION ALL

SELECT
    'FactSales - Product',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimProduct d
    ON f.ProductKey = d.ProductKey
WHERE d.ProductKey IS NULL

UNION ALL

SELECT
    'FactSales - Store',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimStore d
    ON f.StoreKey = d.StoreKey
WHERE d.StoreKey IS NULL

UNION ALL

SELECT
    'FactSales - Employee',
    COUNT_BIG(*)
FROM dw.FactSales f
LEFT JOIN dw.DimEmployee d
    ON f.EmployeeKey = d.EmployeeKey
WHERE d.EmployeeKey IS NULL;

USE EnterpriseSales_DW;
GO

-- Validate FactReturns
SELECT
    'FactReturns - Date' AS CheckName,
    COUNT_BIG(*) AS InvalidRows
FROM dw.FactReturns f
LEFT JOIN dw.DimDate d
    ON f.DateKey = d.DateKey
WHERE d.DateKey IS NULL

UNION ALL

SELECT
    'FactReturns - Customer',
    COUNT_BIG(*)
FROM dw.FactReturns f
LEFT JOIN dw.DimCustomer d
    ON f.CustomerKey = d.CustomerKey
WHERE d.CustomerKey IS NULL

UNION ALL

SELECT
    'FactReturns - Product',
    COUNT_BIG(*)
FROM dw.FactReturns f
LEFT JOIN dw.DimProduct d
    ON f.ProductKey = d.ProductKey
WHERE d.ProductKey IS NULL

UNION ALL

-- Validate FactSalesTarget
SELECT
    'FactSalesTarget - Date',
    COUNT_BIG(*)
FROM dw.FactSalesTarget f
LEFT JOIN dw.DimDate d
    ON f.DateKey = d.DateKey
WHERE d.DateKey IS NULL

UNION ALL

SELECT
    'FactSalesTarget - Store',
    COUNT_BIG(*)
FROM dw.FactSalesTarget f
LEFT JOIN dw.DimStore d
    ON f.StoreKey = d.StoreKey
WHERE d.StoreKey IS NULL;

USE EnterpriseSales_DW;
GO

-- FactSales: one row per OrderId + SourceRecordId
SELECT
    'FactSales' AS TableName,
    OrderID,
    SourceRecordID,
    COUNT_BIG(*) AS DuplicateCount
FROM dw.FactSales
GROUP BY OrderID, SourceRecordID
HAVING COUNT_BIG(*) > 1;

-- FactReturns: check ReturnID uniqueness
SELECT
    'FactReturns' AS TableName,
    ReturnID,
    COUNT_BIG(*) AS DuplicateCount
FROM dw.FactReturns
GROUP BY ReturnID
HAVING COUNT_BIG(*) > 1;

-- FactSalesTarget: check its business-key grain
SELECT
    'FactSalesTarget' AS TableName,
    DateKey,
    StoreKey,
    Category,
    COUNT_BIG(*) AS DuplicateCount
FROM dw.FactSalesTarget
GROUP BY DateKey, StoreKey, Category
HAVING COUNT_BIG(*) > 1;

USE EnterpriseSales_DW;
GO

SELECT
    SalesTargetKey,
    DateKey,
    StoreKey,
    Category,
    SalesTarget,
    TransactionTarget
FROM dw.FactSalesTarget
WHERE
    (DateKey = 20250312 AND StoreKey = 188
     AND Category = 'Networking')
    OR
    (DateKey = 20260531 AND StoreKey = 39
     AND Category = 'Office Equipment')
ORDER BY
    DateKey,
    StoreKey,
    Category;

    USE EnterpriseSales_Staging;
GO

SELECT
    TargetDate,
    StoreID,
    Category,
    SalesTarget,
    TransactionTarget,
    BatchID,
    LoadDateTime
FROM stg.SalesTarget
WHERE
    (TargetDate = '2025-03-12'
     AND StoreID = (
         SELECT StoreID
         FROM EnterpriseSales_Source.src.Store
         WHERE StoreID IS NOT NULL
         ORDER BY StoreID
         OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY
     )
     AND Category = 'Networking')
    OR
    (TargetDate = '2026-05-31'
     AND Category = 'Office Equipment')
ORDER BY
    TargetDate,
    StoreID,
    Category;

USE EnterpriseSales_DW;
GO

SELECT
    f.DateKey,
    d.FullDate,
    f.StoreKey,
    s.StoreID,
    f.Category,
    f.SalesTargetKey,
    f.SalesTarget,
    f.TransactionTarget
FROM dw.FactSalesTarget f
JOIN dw.DimDate d
    ON f.DateKey = d.DateKey
JOIN dw.DimStore s
    ON f.StoreKey = s.StoreKey
WHERE
    (f.DateKey = 20250312 AND f.StoreKey = 188
     AND f.Category = 'Networking')
    OR
    (f.DateKey = 20260531 AND f.StoreKey = 39
     AND f.Category = 'Office Equipment')
ORDER BY
    f.DateKey,
    f.StoreKey,
    f.Category,
    f.SalesTargetKey;

USE EnterpriseSales_Staging;
GO

SELECT
    SourceTable,
    LastSuccessfulWatermark,
    LastSuccessfulLoadDate
FROM dbo.ETLWatermark
ORDER BY SourceTable;

USE EnterpriseSales_DW;
GO

SELECT
    OrderID,
    SourceRecordID,
    COUNT_BIG(*) AS DuplicateCount
FROM dw.FactSales
GROUP BY
    OrderID,
    SourceRecordID
HAVING COUNT_BIG(*) > 1;

USE EnterpriseSales_Staging;
GO

SELECT
    TargetDate,
    StoreID,
    Category,
    SalesTarget,
    TransactionTarget,
    BatchID,
    LoadDateTime
FROM stg.SalesTarget
WHERE
    (TargetDate = '2025-03-12'
     AND StoreID = 'S0188'
     AND Category = 'Networking')
    OR
    (TargetDate = '2026-05-31'
     AND StoreID = 'S0039'
     AND Category = 'Office Equipment')
ORDER BY
    TargetDate,
    StoreID,
    Category,
    LoadDateTime;
USE EnterpriseSales_Source;
GO

SELECT *
FROM src.SalesTarget
WHERE
    (
        TargetDate = '2025-03-12'
        AND StoreID = 'S0188'
        AND Category = 'Networking'
    )
    OR
    (
        TargetDate = '2026-05-31'
        AND StoreID = 'S0039'
        AND Category = 'Office Equipment'
    );