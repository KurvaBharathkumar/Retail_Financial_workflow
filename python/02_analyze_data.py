from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data" / "retail_analysis.csv"
OUT_DIR = ROOT / "outputs" / "reports"
OUT_DIR.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(DATA_PATH, parse_dates=["transaction_date"])
completed = df.loc[df["transaction_status"].eq("Completed")].copy()

completed["month"] = completed["transaction_date"].dt.to_period("M").astype(str)

monthly = (
    completed.groupby("month", as_index=False)
    .agg(
        revenue=("revenue", "sum"),
        cogs=("cogs", "sum"),
        gross_profit=("gross_profit", "sum"),
        transaction_lines=("transaction_id", "count"),
        unique_transactions=("transaction_id", "nunique"),
    )
    .sort_values("month")
)
monthly["gross_profit_margin_pct"] = (
    100 * monthly["gross_profit"] / monthly["revenue"].where(monthly["revenue"] != 0)
)
monthly["previous_month_revenue"] = monthly["revenue"].shift(1)
monthly["mom_revenue_growth_pct"] = (
    100 * (monthly["revenue"] - monthly["previous_month_revenue"])
    / monthly["previous_month_revenue"].where(monthly["previous_month_revenue"] != 0)
)

category = (
    completed.groupby("category", as_index=False)
    .agg(
        revenue=("revenue", "sum"),
        cogs=("cogs", "sum"),
        gross_profit=("gross_profit", "sum"),
        units_sold=("quantity", "sum"),
    )
)
category["gross_profit_margin_pct"] = (
    100 * category["gross_profit"] / category["revenue"].where(category["revenue"] != 0)
)
category = category.sort_values("revenue", ascending=False)

products = (
    completed.groupby(["product_id", "product_name", "category"], as_index=False)
    .agg(
        revenue=("revenue", "sum"),
        gross_profit=("gross_profit", "sum"),
        units_sold=("quantity", "sum"),
    )
    .sort_values("revenue", ascending=False)
)

segments = (
    completed.groupby("customer_segment", as_index=False)
    .agg(
        revenue=("revenue", "sum"),
        gross_profit=("gross_profit", "sum"),
        unique_customers=("customer_id", "nunique"),
        unique_transactions=("transaction_id", "nunique"),
    )
    .sort_values("revenue", ascending=False)
)

monthly.to_csv(OUT_DIR / "monthly_performance.csv", index=False)
category.to_csv(OUT_DIR / "category_performance.csv", index=False)
products.to_csv(OUT_DIR / "product_performance.csv", index=False)
segments.to_csv(OUT_DIR / "customer_segment_performance.csv", index=False)

total_revenue = completed["revenue"].sum()
total_cogs = completed["cogs"].sum()
total_profit = completed["gross_profit"].sum()
overall_margin = 100 * total_profit / total_revenue if total_revenue else float("nan")

summary = pd.DataFrame([{
    "completed_transaction_lines": len(completed),
    "unique_completed_transactions": completed["transaction_id"].nunique(),
    "revenue": round(total_revenue, 2),
    "cogs": round(total_cogs, 2),
    "gross_profit": round(total_profit, 2),
    "gross_profit_margin_pct": round(overall_margin, 2),
}])
summary.to_csv(OUT_DIR / "overall_kpis.csv", index=False)

print("\nOverall KPIs")
print(summary.to_string(index=False))
print("\nCategory performance")
print(category.to_string(index=False))
print("\nTop 10 products")
print(products.head(10).to_string(index=False))
print("\nMonthly performance")
print(monthly.to_string(index=False))
