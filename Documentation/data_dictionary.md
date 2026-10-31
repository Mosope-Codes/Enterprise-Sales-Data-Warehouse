# Data Dictionary

## Dimensions
- **dw.DimDate** — calendar attributes used for year/month/quarter/day analysis. Business key: FullDate; surrogate key: DateKey.
- **dw.DimCustomer** — customer descriptive attributes. Business key: CustomerID; surrogate key: CustomerKey. Type 2 history is represented through versioning fields such as effective/start/end dates and current-row indicators where defined in the SQL schema.
- **dw.DimProduct** — product, brand, category, subcategory and pricing/cost descriptors. Business key: ProductID; surrogate key: ProductKey.
- **dw.DimStore** — store location and classification attributes. Business key: StoreID; surrogate key: StoreKey.
- **dw.DimEmployee** — employee, role, department and store attributes. Business key: EmployeeID; surrogate key: EmployeeKey.

## Fact tables and grain
- **dw.FactSales** — intended grain: one row per source sales line, identified by OrderID + SourceRecordID. Measures include Quantity, GrossAmount, DiscountAmount, NetAmount, CostAmount and ProfitAmount.
- **dw.FactReturns** — intended grain: one row per return record (ReturnID), with return date, product/customer/date keys and quantity returned.
- **dw.FactSalesTarget** — intended grain: one row per TargetDate + StoreID + Category. Measures include SalesTarget and TransactionTarget.

## Source business keys used by the profiler
CustomerID; ProductID; StoreID; EmployeeID; OrderID + SourceRecordID; ReturnID; TargetDate + StoreID + Category; ProductID + EffectiveDate.

## Important modelling note
OrderID alone is not necessarily unique at the sales-line grain. Duplicate checks should use the documented grain/business key rather than assuming each order has only one row.
