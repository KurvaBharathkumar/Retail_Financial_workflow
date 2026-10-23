# Financial & Retail Business Performance Analysis

## Project objective
Build a reproducible end-to-end analytics workflow using MySQL Workbench and Python in VS Code. The project uses synthetic retail transaction data to calculate revenue, cost of goods sold (COGS), gross profit, gross profit margin, monthly trends, product performance, and customer-segment performance.

## Data disclaimer
All data are synthetic and generated for demonstration. They do not represent a real company or actual financial results.

## Metric definitions
- Revenue = quantity × unit price × (1 − discount percentage / 100)
- COGS = quantity × unit cost
- Gross profit = revenue − COGS
- Gross profit margin = gross profit / revenue × 100
- Only `Completed` transactions are included in sales and gross-profit KPIs.
- Cancelled, Returned, and Pending lines are excluded from those KPIs. This sample does not model refund amounts, taxes, shipping, operating expenses, or EBITDA.

## Requirements
- MySQL Server 8.0+
- MySQL Workbench
- Python 3.10+
- VS Code with the Python extension

## Workflow
1. Open `sql/01_create_database_and_tables.sql` in MySQL Workbench and execute it.
2. Execute `sql/02_generate_synthetic_data.sql`. It generates 50 customers, 20 products, and 550 transaction-line records.
3. Execute `sql/03_data_quality_checks.sql` and review all results.
4. Execute `sql/04_financial_analysis.sql` and inspect the KPI, monthly, category, product, and segment results.
5. Execute `sql/05_export_analysis_dataset.sql`.
6. In the Result Grid, export the result set as CSV to `data/retail_analysis.csv`.
7. In VS Code, create and activate a virtual environment:
   - macOS/Linux: `python3 -m venv .venv && source .venv/bin/activate`
   - Windows PowerShell: `py -m venv .venv` then `.\.venv\Scripts\Activate.ps1`
8. Install dependencies: `python -m pip install -r requirements.txt`
9. Run `python python/01_validate_data.py`.
10. Run `python python/02_analyze_data.py`.
11. Run `python python/03_visualize_data.py`.
12. Review the CSV outputs under `outputs/reports/`, validation results under `outputs/validation/`, and charts under `outputs/charts/`.

## Validation
The Python validation script checks the expected row count, unique transaction IDs, valid dates, positive quantities, discount bounds, status values, and reconciliation of revenue, COGS, and gross profit.

## Limitations
The generated transaction pattern is deterministic and designed for demonstrating a workflow. It should not be treated as a representative sample of real retail demand. Because the synthetic data spans dates in 2025, it is suitable for practicing historical trend analysis but not for inferring current market behavior.

## Final reporting
Use actual results from your executed queries and scripts. Do not claim business findings before reviewing the outputs. Explain the limitations of synthetic data and avoid describing gross profit as EBITDA or net profit.
