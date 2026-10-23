from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data" / "retail_analysis.csv"
CHART_DIR = ROOT / "outputs" / "charts"
CHART_DIR.mkdir(parents=True, exist_ok=True)

df = pd.read_csv(DATA_PATH, parse_dates=["transaction_date"])
df = df.loc[df["transaction_status"].eq("Completed")].copy()
df["month"] = df["transaction_date"].dt.to_period("M").astype(str)

# 1. Monthly revenue and gross profit
monthly = (
    df.groupby("month")[["revenue", "gross_profit"]]
    .sum()
    .sort_index()
)
ax = monthly.plot(kind="line", marker="o", figsize=(10, 5))
ax.set_title("Monthly Revenue and Gross Profit")
ax.set_xlabel("Month")
ax.set_ylabel("Amount")
ax.grid(True, alpha=0.25)
plt.tight_layout()
plt.savefig(CHART_DIR / "monthly_revenue_profit.png", dpi=200, bbox_inches="tight")
plt.close()

# 2. Revenue by category
category_revenue = df.groupby("category")["revenue"].sum().sort_values(ascending=False)
ax = category_revenue.plot(kind="bar", figsize=(9, 5))
ax.set_title("Revenue by Product Category")
ax.set_xlabel("Category")
ax.set_ylabel("Revenue")
ax.tick_params(axis="x", rotation=30)
plt.tight_layout()
plt.savefig(CHART_DIR / "revenue_by_category.png", dpi=200, bbox_inches="tight")
plt.close()

# 3. Gross profit margin by category
category = df.groupby("category")[["revenue", "gross_profit"]].sum()
category["margin_pct"] = 100 * category["gross_profit"] / category["revenue"].where(category["revenue"] != 0)
category = category["margin_pct"].sort_values(ascending=False)
ax = category.plot(kind="bar", figsize=(9, 5))
ax.set_title("Gross Profit Margin by Category")
ax.set_xlabel("Category")
ax.set_ylabel("Gross profit margin (%)")
ax.tick_params(axis="x", rotation=30)
plt.tight_layout()
plt.savefig(CHART_DIR / "gross_profit_margin_by_category.png", dpi=200, bbox_inches="tight")
plt.close()

# 4. Top 10 products by revenue
top_products = (
    df.groupby("product_name")["revenue"]
    .sum()
    .nlargest(10)
    .sort_values()
)
ax = top_products.plot(kind="barh", figsize=(9, 6))
ax.set_title("Top 10 Products by Revenue")
ax.set_xlabel("Revenue")
ax.set_ylabel("Product")
plt.tight_layout()
plt.savefig(CHART_DIR / "top_10_products.png", dpi=200, bbox_inches="tight")
plt.close()

# 5. Transaction status distribution (all rows, not only completed)
all_status = pd.read_csv(DATA_PATH)
status_counts = all_status["transaction_status"].value_counts()
ax = status_counts.plot(kind="bar", figsize=(8, 5))
ax.set_title("Transaction-Line Count by Status")
ax.set_xlabel("Status")
ax.set_ylabel("Transaction lines")
ax.tick_params(axis="x", rotation=20)
plt.tight_layout()
plt.savefig(CHART_DIR / "transaction_status_distribution.png", dpi=200, bbox_inches="tight")
plt.close()

print(f"Charts saved to: {CHART_DIR}")
