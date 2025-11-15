# Peru Trade Finance - Data Tables

This folder contains data tables extracted from the Peru Trade Finance dataset (96,496 observations, 2010-2024).

## Files

### 01_tf_by_firm_size_data.csv
Trade Finance ("Comercio exterior") by firm size.

**Columns:**
- `size`: Firm size (Corporate, Large, Medium, Small, Micro)
- `amount_pen`: TF amount in PEN millions
- `amount_usd`: TF amount in USD millions
- `pct`: % of total TF portfolio

**Key Finding:** Corporate + Large = 88.7% of TF, Small + Micro = only 2.0% (extreme exclusion).

---

### 02_credit_type_distribution_data.csv
**CONTEXT TABLE**: Commercial credit portfolio by type (ALL credit types, not just TF).

**Columns:**
- `Concepto`: Credit type (Préstamos, Comercio exterior, Factoring, etc.)
- `amount_pen`: Amount in PEN millions
- `pct`: % of total commercial credit
- `is_trade_finance`: Yes/No flag to identify TF row

**Purpose:** Shows TF within the broader commercial credit landscape.

**Key Finding:** TF (10.4%) is second only to general loans (65.1%).

**Note:** This is the ONLY Peru file that includes non-TF data. All other files filter for "Comercio exterior" only. This table provides important context about TF's share of total commercial credit.

---

### 03_bank_concentration_data.csv
Top 10 banks in trade finance market.

**Columns:**
- `institucion_std`: Standardized bank name
- `amount_pen`: TF amount in PEN millions
- `market_share`: % of top 10 total
- `cumulative`: Cumulative market share

**Key Finding:** BBVA Perú leads (28.7%), CR5 = 88.6% (oligopoly).

---

### 04_annual_growth_data.csv
Annual trade finance volumes and growth rates (2010-2024).

**Columns:**
- `anio`: Year
- `amount_usd`: TF portfolio in USD millions
- `yoy_growth`: Year-over-year growth %

**Trend:** 2.3% CAGR, but +27.8% recovery in 2021-2022 post-COVID (strongest in region).

---

### 05_tf_penetration_data.csv
Trade Finance penetration rate by firm size.

**Columns:**
- `size`: Firm size
- `total_credit`: Total credit portfolio in PEN millions
- `tf_amount`: TF amount in PEN millions
- `tf_penetration`: TF as % of total credit

**Key Finding:** Large firms: 4.15% TF penetration vs. Small/Micro: 0.5-0.6% (systematic barriers).

---

## Data Source
- **Original file:** `data/peru_full.csv`
- **ETL script:** `Scripts/peru_etl.R`
- **Regulatory source:** Superintendencia de Banca, Seguros y AFP (SBS) - SIC System
- **Profile:** [PERU_COUNTRY_PROFILE.md](../PERU_COUNTRY_PROFILE.md)

## Usage Notes
- All monetary values in **PEN** (Peruvian Soles) millions or **USD** millions
- TF = "Comercio exterior" credit type only
- Firm size classification: SBS-mandated by annual revenue
- Dollarization: 78-82% of TF is USD-denominated (highest after Mexico)
- Time series: 2010-2024 (171 months)

## Key Insights
- **Highest concentration:** CR5 = 88.6% (most oligopolistic market)
- **Worst SME access:** Only 2.0% of TF goes to Small + Micro firms
- **Mining dominance:** ~58% of TF tied to copper/gold exports (estimated)
- **Data gap:** TF/Trade ratio = 0.64% (very low, indicates under-reporting)

## Next Steps
To generate visualizations from these CSVs:
1. Import into Excel/Google Sheets/Tableau/PowerBI
2. Create bar charts for firm size distribution
3. Pie chart for credit type mix
4. Waterfall chart for bank concentration
5. Line chart for annual growth with annotations (COVID, commodity cycles)
6. Reference the country profile for policy recommendations

---

**Last Updated:** 2025-11-11
**Contact:** Trade Finance Research Team
