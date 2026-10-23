from pathlib import Path
import pandas as pd

ROOT = Path(financial_performance.csv).resolve().parents[1]
DATA_PATH = ROOT / "data" / "retail_analysis.csv"
OUT_DIR = ROOT / "outputs" / "validation"
OUT_DIR.mkdir(parents=True, exist_ok=True)

if not DATA_PATH.exists():
    raise FileNotFoundError(
        f"Missing {DATA_PATH}. Export the result of sql/05_export_analysis_dataset.sql "
        "from MySQL Workbench to this location."
    )

df = pd.read_csv("financial_performance.csv")
required = {
    "transaction_id", "transaction_date", "customer_id", "customer_segment",
    "city", "product_id", "product_name", "category", "quantity",
    "unit_price", "unit_cost", "discount_pct", "payment_method",
    "transaction_status", "revenue", "cogs", "gross_profit"
}
missing_columns = required - set(df.columns)
if missing_columns:
    raise ValueError(f"CSV is missing required columns: {sorted(missing_columns)}")

df["transaction_date"] = pd.to_datetime(df["transaction_date"], errors="coerce")
numeric = [
    "quantity", "unit_price", "unit_cost", "discount_pct",
    "revenue", "cogs", "gross_profit"
]
for col in numeric:
    df[col] = pd.to_numeric(df[col], errors="coerce")

checks = {
    "row_count_is_550": len(df) == 550,
    "transaction_id_unique": not df["transaction_id"].duplicated().any(),
    "no_missing_transaction_id": df["transaction_id"].notna().all(),
    "valid_dates": df["transaction_date"].notna().all(),
    "positive_quantity": (df["quantity"] > 0).all(),
    "discount_between_0_and_100": df["discount_pct"].between(0, 100).all(),
    "valid_statuses": df["transaction_status"].isin(
        ["Completed", "Cancelled", "Returned", "Pending"]
    ).all(),
    "revenue_reconciles": (
        (df["revenue"] - (
            df["quantity"] * df["unit_price"] * (1 - df["discount_pct"] / 100)
        )).abs() <= 0.02
    ).all(),
    "cogs_reconciles": (
        (df["cogs"] - df["quantity"] * df["unit_cost"]).abs() <= 0.02
    ).all(),
    "profit_reconciles": (
        (df["gross_profit"] - (df["revenue"] - df["cogs"])).abs() <= 0.02
    ).all(),
}

results = pd.DataFrame(
    [{"check": name, "passed": bool(passed)} for name, passed in checks.items()]
)
results.to_csv(OUT_DIR / "python_validation_results.csv", index=False)

print(f"Rows: {len(df)}")
print(f"Columns: {len(df.columns)}")
print("\nMissing values by column:")
print(df.isna().sum().to_string())
print("\nValidation results:")
print(results.to_string(index=False))

if not results["passed"].all():
    raise SystemExit("One or more validation checks failed. Review the CSV and SQL export.")
print("\nAll validation checks passed.")
