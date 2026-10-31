# Architecture and processing flow

```text
CSV / Excel source files + SQL source tables
                  |
                  v
      SQL Server source database (src)
                  |
                  v
          SSIS staging load
                  |
                  v
     SQL Server staging database (stg)
                  |
                  v
      Python/Pandas data profiling
                  |
                  v
     SSIS / SQL warehouse processing
                  |
                  v
 SQL Server warehouse (dw dimensions + facts)
                  |
                  v
       Power BI semantic model/report
```

## Main components
1. **Source layer** stores operational extracts and reference data.
2. **Staging layer** separates ingestion from warehouse modelling and includes staging/reject structures plus incremental merge/watermark definitions in the SQL scripts.
3. **Python profiler** reads the eight approved staging tables and reports row/column counts, data types, missing values, exact duplicate rows, business-key duplicates, distinct values, categorical distributions, numeric summaries and date ranges. Customer checks also examine age range and date-order anomalies. Profiling reports issues; it does not automatically clean every issue.
4. **Warehouse layer** contains DimDate, DimCustomer, DimProduct, DimStore, DimEmployee, FactSales, FactReturns and FactSalesTarget. Customer Type 2 processing is defined in the warehouse SQL.
5. **Power BI** presents sales/profit KPIs, monthly trend, regional sales, channel mix, product sales and actual-versus-target analysis.

## Automation status
The project owner reported a successful SQL Server Agent run of the deployed `Master ETL.dtsx` package in SSISDB. Power BI was published to the Power BI Service; the latest supplied screenshot showed scheduled refresh disabled because at least one data source credential was missing. Complete gateway/credential mapping and test a refresh before claiming end-to-end cloud refresh is active.
