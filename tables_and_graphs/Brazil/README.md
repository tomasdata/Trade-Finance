# Brazil Trade Finance - Data Tables

This folder contains data tables extracted from the Brazil Trade Finance dataset (838,167 observations, 2012-2024).

## Files

### 01_tf_by_firm_size_data.csv
Trade Finance portfolio by firm size classification.

**Columns:**
- `porte`: Firm size (Micro, Small, Medium, Large, Not Available)
- `records`: Number of observations
- `carteira_ativa_total`: Total active portfolio in BRL billions
- `pct_records`: % of total records
- `pct_carteira`: % of total portfolio

**Key Finding:** Large companies hold 78.1% of TF portfolio with only 26.4% of operations.

---

### 02_tf_by_sector_data.csv
Trade Finance portfolio by CNAE economic sector (Top 10).

**Columns:**
- `cnae_secao`: CNAE sector name
- `records`: Number of observations
- `carteira_ativa_total`: Total active portfolio in BRL billions

**Key Finding:** Manufacturing industries dominate with 54.8% of operations.

---

### 03_tf_by_state_data.csv
Trade Finance portfolio by Brazilian state (Top 10).

**Columns:**
- `uf`: State code (SP, RS, SC, etc.)
- `records`: Number of observations
- `carteira_ativa_total`: Total active portfolio in BRL billions

**Key Finding:** São Paulo accounts for 38.7% of all TF operations.

---

### 04_maturity_structure_data.csv
Distribution of TF portfolio by maturity buckets.

**Columns:**
- `maturity_bucket`: Time range (0-90 days, 91-360 days, etc.)
- `amount`: Portfolio amount in BRL trillions
- `pct`: % of total portfolio

**Key Finding:** 91-360 days is the dominant bucket (39.5% of portfolio).

---

### 05_temporal_evolution_data.csv
Monthly evolution of TF portfolio (2012-2024).

**Columns:**
- `data_base`: Date (YYYY-MM-DD format)
- `carteira_ativa`: Total active portfolio in BRL trillions

**Trend:** 4.3% annual growth (CAGR 2012-2024), resilient during COVID-19.

---

### 06_npl_analysis_data.csv
Non-Performing Loan indicators.

**Columns:**
- `indicator`: NPL type (npl_ratio_15d, npl_ratio_inadim, problem_ratio)
- `ratio`: NPL as % of active portfolio

**Key Finding:** NPL ratio >15 days = 0.75% (excellent credit quality).

---

### 07_indexer_distribution_data.csv
Distribution of TF by interest rate indexer type.

**Columns:**
- `indexador`: Indexer type (Pre-fixed, Post-fixed, Floating, etc.)
- `count`: Number of records
- `pct`: % of total records

**Key Finding:** 52.6% of TF uses pre-fixed rates (certainty for exporters/importers).

---

## Data Source
- **Original file:** `data/brasil_full.csv`
- **ETL script:** `Scripts/brasil_etl.R`
- **Regulatory source:** Banco Central do Brasil (BCB) - SCR System
- **Profile:** [BRAZIL_COUNTRY_PROFILE.md](../BRAZIL_COUNTRY_PROFILE.md)

## Usage Notes
- All monetary values in **BRL** (Brazilian Reais)
- Active portfolio = `carteira_ativa` field
- Firm size classification follows BCB standards
- CNAE = Brazilian standard industrial classification
- State codes = ISO 3166-2:BR (AC, AL, SP, etc.)

## Next Steps
To generate visualizations from these CSVs:
1. Import CSVs into Excel/Google Sheets/Tableau/PowerBI
2. Create bar charts, time series, pie charts as needed
3. Reference the country profile for context and interpretation

---

**Last Updated:** 2025-11-11
**Contact:** Trade Finance Research Team
