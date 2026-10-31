import pandas as pd
sales=pd.read_csv("../01_Source_Data/sales_transactions.csv")
sales["NetAmount"]=pd.to_numeric(sales["NetAmount"],errors="coerce")
rejects=sales[sales.NetAmount.isna()].copy(); rejects["RejectReason"]="Invalid NetAmount"
clean=sales[sales.NetAmount.notna()].copy()
clean["GrossAmount_Calc"]=clean.Quantity*clean.UnitPrice
clean["ProfitAmount_Calc"]=clean.NetAmount-clean.CostAmount
print(sales.shape,clean.shape,rejects.shape)
clean.to_csv("../01_Source_Data/processed_sales.csv",index=False); rejects.to_csv("../01_Source_Data/rejected_sales.csv",index=False)
# Extend: duplicate detection, profiling report, charts and Excel output.
