# Chile Trade Finance - Data Tables

This folder contains data tables extracted from the Chile Trade Finance dataset (762,687 observations, 2015-2024).

## Files

### 01_bank_concentration_data.csv
Top 10 banks by foreign currency trade finance portfolio.

**Columns:**
- `NombreInstitucion`: Bank name
- `amount_fx`: Foreign currency TF in CLP trillions
- `market_share`: % of top 10 total
- `cumulative_share`: Cumulative market share

**Key Finding:** BCI leads with 20.1% market share (2.7x larger than #2 player).

---

### 02_currency_composition_data.csv
Distribution of TF by currency type.

**Columns:**
- `currency_type`: Currency category (Chilean Peso, Foreign Currency, IPC-indexed)
- `amount`: Total amount in thousands of CLP trillions
- `pct`: % of total

**Key Finding:** 78.3% in Chilean Peso, only 21.7% in foreign currency.

---

### 03_annual_summary_data.csv
Annual summary of TF volumes by currency (2015-2024).

**Columns:**
- `Anho`: Year
- `amount_total`: Total TF in CLP trillions
- `amount_fx`: Foreign currency TF in CLP trillions
- `amount_clp`: Chilean Peso TF in CLP trillions

**Trend:** 2.9% annual growth (CAGR 2015-2024), slower than Brazil/Peru.

---

### 04_top_accounts_data.csv
Top 15 CMF accounting codes by foreign currency volume.

**Columns:**
- `DescripcionCuenta`: Account description (CMF standard)
- `amount_fx`: Foreign currency amount in CLP trillions
- `pct`: % of top 15 total

**Key Finding:** "Créditos de comercio exterior" (code 145400200) dominates.

---

## Data Source
- **Original file:** `data/chile_full.csv`
- **ETL script:** `Scripts/chile_etl.R`
- **Regulatory source:** Comisión para el Mercado Financiero (CMF) - FECU System
- **Profile:** [CHILE_COUNTRY_PROFILE.md](../CHILE_COUNTRY_PROFILE.md)

## Usage Notes
- All monetary values in **CLP** (Chilean Pesos)
- Amounts are in **trillions** (1e12) or **thousands of trillions** (1e15)
- Foreign currency = primarily USD, converted to CLP
- CMF account codes: 14xxxx = Assets, 24xxxx = Liabilities, 8xxxxx = Contingent
- Time series: 1998-2024 available (profile uses 2015-2024 for consistency)

## Known Limitations
- No firm size data (cannot analyze SME vs Large)
- No geographic breakdown (national level only)
- No direct sectoral data (only by operation type)
- Very low TF/Trade ratio (0.88%) indicates under-reporting

## Next Steps
To generate visualizations from these CSVs:
1. Import CSVs into Excel/Google Sheets/Tableau/PowerBI
2. Create bar charts for bank concentration
3. Pie chart for currency composition
4. Line chart for annual trends
5. Reference the country profile for context

---

**Last Updated:** 2025-11-11
**Contact:** Trade Finance Research Team
