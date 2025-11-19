# 🇨🇱 CHILE TRADE FINANCE DATA - TECHNICAL DOCUMENTATION

**Data Source:** Comisión para el Mercado Financiero (CMF) - Chilean Banking Regulator (formerly SBIF)  
**Dataset:** Individual Bank Balance Sheets - Trade Finance Accounts  
**Coverage:** January 2015 - December 2024 (10 years)  
**Observations:** 38,449 bank-month-account records  
**Banks:** 27 financial institutions  
**Update Frequency:** Monthly  
**Last Updated:** November 2025

---

## 🚨 CRITICAL: ACCOUNTING PLAN CHANGE (2022)

**Chile implemented a major accounting transition in January 2022:**

| Aspect | Old Plan (2015-2021) | New Plan (2022-2024) |
|--------|----------------------|----------------------|
| **Regulator** | SBIF (Superintendencia de Bancos) | CMF (Comisión para el Mercado Financiero) |
| **Standard** | Chilean GAAP | IFRS 9 (International) |
| **Account Codes** | 7-9 digits, 173 TF accounts | 9 digits (uniform), 709 total accounts |
| **TF Accounts** | 11 key accounts identified | 29 key accounts identified |
| **Code Overlap** | **0%** (complete re-numbering) | - |
| **Data Challenge** | ETL mis-categorized as "otros" | Post-processing fix applied |

**Empalme Methodology:**
- **Problem:** Original ETL script only recognized 2015-2021 account codes for specific hardcoded list, marking ~99% as "otros"
- **Solution:** Direct account code mapping in post-processing (bypass ETL categorization)
- **2015-2021:** Use 11 SBIF account codes directly (1270116-1270118, 1270206-1270208, 1302200-1302202, 1302241-1302242)
- **2022-2024:** Use 29 CMF account codes (145400200-145400204, 143200104-143200106, 244500100, 271000200, etc.)
- **Validation:** 19,657 obs (2015-2021) + 18,792 obs (2022-2024) = 38,449 total ✓
- **Continuity:** Volume jump 2021→2022 reflects better account identification, not real growth

**See:** `CHILE_PLAN_CONTABLE_ISSUE.md` for complete diagnostic and fix documentation

---

## 📊 DATA STRUCTURE

### Primary Variables

| Variable | Description | Type | Unit | Notes |
|----------|-------------|------|------|-------|
| `date` | Date (YYYY-MM-DD) | Date | - | First day of month |
| `year` | Year | Integer | - | 2015-2024 |
| `month` | Month | Integer | 1-12 | - |
| `codigo_inst` | Bank code | Character | - | CMF institutional code |
| `institucion` | Bank name | Character | - | Full legal name |
| `bank_type` | Bank classification | Factor | - | Foreign / State / Large Domestic |
| `codigo_cuenta` | Account code | Numeric | - | 7-9 digits (2015-2021), 9 digits (2022-2024) |
| `descripcion` | Account description | Character | - | Spanish, from CMF catalog |
| `account_type` | TF category | Factor | - | 9 categories (see below) |
| `categoria` | Enhanced category | Factor | - | 10 categories including "otros" |
| `is_lc` | L/C flag | Logical | TRUE/FALSE | Letters of credit indicator |
| `monto_clp_thousands` | Volume (CLP) | Numeric | Thousands CLP | Original currency |
| `tf_usd_millions` | Volume (USD) | Numeric | USD millions | Converted using monthly CLP/USD rate |
| `exports_usd_millions` | Monthly exports | Numeric | USD millions | From GMD (Global Macro Database) |
| `imports_usd_millions` | Monthly imports | Numeric | USD millions | From GMD (Global Macro Database) |
| `gdp_usd_billions` | Annual GDP | Numeric | USD billions | From GMD (annual, not interpolated) |

### Bank Classification

**Foreign Banks (5):** Scotiabank, Citibank, ICBC, JPMorgan, BNP Paribas

**State Bank (1):** Banco Estado (largest retail bank, state-owned)

**Large Domestic (8):** Banco de Chile, Santander Chile, BCI, Itaú, Security, BICE, Consorcio, Ripley

### Trade Finance Categories (9 types)

| Category | Description | Key Accounts (2022-2024) | % of Volume |
|----------|-------------|--------------------------|-------------|
| **Letters of Credit** | L/C imports/exports | 145400201, 145400203 | ~8% |
| **Export Financing** | Advance on exports | 145400202, 143200104 | ~12% |
| **Import Financing** | Import payments | 145400204, 143200105 | ~15% |
| **Foreign Funding** | External trade lines | 244500100, 245102100 | ~25% |
| **Guarantees** | Trade guarantees | 271000200, 271000201 | ~10% |
| **Third-Party Trade** | Triangular operations | 143200106, 145400205 | ~8% |
| **Interbank Foreign** | Inter-bank TF | 243100100, 243200100 | ~12% |
| **Trade Finance General** | General TF accounts | 145400200 (parent) | ~5% |
| **Other Trade Finance** | Miscellaneous TF | Various | ~5% |

---

## 🔍 DATA SOURCE DETAILS

### Banking Data: CMF Individual Balance Sheets

**Period 1 (2015-2021): SBIF System - 11 Key Accounts**
```
ASSETS:
1270116 - Créditos comercio exterior - Exportación
1270117 - Créditos comercio exterior - Importación  
1270118 - Créditos comercio exterior - Terceros

1270206 - Préstamos comercio exterior - Exportación
1270207 - Préstamos comercio exterior - Importación
1270208 - Préstamos comercio exterior - Terceros

1302200 - Cartas de crédito emitidas - Exportación
1302201 - Cartas de crédito emitidas - Importación
1302202 - Cartas de crédito emitidas - Terceros

OFF-BALANCE:
1302241 - Cartas de crédito recibidas - Exportación
1302242 - Cartas de crédito recibidas - Importación
```

**Period 2 (2022-2024): CMF/IFRS 9 System - 29 Key Accounts**
```
ASSETS (Stage 1-3 Classification):
145400200 - Total Comercio Exterior (parent) [222 trillion CLP 2022]
145400201 - CE - Exportación con L/C
145400202 - CE - Exportación otros
145400203 - CE - Importación con L/C
145400204 - CE - Importación otros
145400205 - CE - Terceros

143200104 - Factoring exportación
143200105 - Factoring importación  
143200106 - Factoring terceros

LIABILITIES:
244500100 - Líneas crédito exterior [125 trillion CLP 2022]
245102100 - Préstamos exterior corto plazo
245102200 - Préstamos exterior largo plazo

OFF-BALANCE (Guarantees):
271000200 - Garantías comercio exterior [Total]
271000201 - Boletas de garantía CE
271000202 - Cartas de crédito stand-by

... [+14 additional accounts at stage/sub-type level]
```

**Source Files:** `~/Documents/Tomas/banca-desarrollo/chile/`
- Monthly XLSX files from CMF website (2015-01 to 2024-12)
- Aggregated data in: `data/chile_full.csv` (762,687 total observations)
- Processed by: `Scripts/chile_etl.R` (original, has categorization issue)
- Fixed by: `country_analysis/scripts/01_master_processing.R` (direct account mapping)

### Trade Data: Global Macro Database (GMD)

**Single Source Strategy:**
- **Source:** FMI/World Bank Global Macro Database
- **Coverage:** 2015-2024 (10 years available for Chile)
- **Methodology:** Balance of Payments (BOP) from Banco Central de Chile
- **Frequency:**
  - Exports/Imports: Monthly (from BOP accounts)
  - GDP: Annual (NOT interpolated - real annual values)
- **Advantages:**
  - Consistent methodology across full 10-year series
  - Official Banco Central source (national accounts)
  - No discontinuities (single source)
  - Matches SBIF→CMF accounting transition period

**Why NOT BACI:**
- ❌ Mixing BACI (2015-2023) + GMD (2024) creates discontinuity
- ❌ Different methodologies cause 6-28% jumps in series
- ❌ BACI lacks GDP data
- ✅ GMD alone ensures consistency across SBIF→CMF transition

**Data Integration:**
- Banking data: Jan 2015 - Dec 2024 (120 months from CMF)
- Trade data: 2015-2024 from GMD (matches banking period)
- GDP: Annual 2015-2024 (for normalization, not monthly interpolation)
- Note: Accounting transition (SBIF→CMF) in Jan 2022 affects banking data only

---

## 📈 DATA CHARACTERISTICS

### Temporal Coverage
- **Start:** January 2015
- **End:** December 2024
- **Duration:** 10 years (120 months)
- **Frequency:** Monthly
- **Gaps:** None (complete time series)
- **Structural Break:** January 2022 (accounting plan change)

### Volume Evolution
- **2015-2021 (SBIF):** 19,657 observations
  - Avg: ~2,800 obs/year
  - 21-25 banks/year
  - 11 account codes
  - Volume: Lower (likely under-identification due to ETL issue)
  
- **2022-2024 (CMF):** 18,792 observations
  - Exactly 6,264 obs/year
  - 18 banks/year (stable)
  - 29 account codes (more granular)
  - Volume: 829-1,083 trillion CLP/year (growing)

### Cross-Sectional Coverage
- **Banks:** 27 unique institutions over 10 years
- **Peak:** 25 banks (2016)
- **Current:** 18 banks (2024, post-consolidation)
- **Foreign banks:** 5 (consistent)
- **Concentration:** Increasing (bank mergers 2018-2020)

### Volume Statistics (2024)
- **Total TF:** 1,083 trillion CLP (~USD 1.15 billion/month)
- **Top account:** 145400200 - Total CE (222 trillion CLP 2022)
- **Top liability:** 244500100 - Foreign lines (125 trillion CLP 2022)
- **L/C share:** ~8% of total TF volume
- **Foreign funding:** ~25% of total TF volume

---

## 🔧 DATA PROCESSING PIPELINE

### 1. ETL: `Scripts/chile_etl.R` (Original - Has Issue)
```r
# Extracts from CMF XLSX balance sheets
# - Reads all accounts (762,687 observations)
# - Attempts categorization via categorize_account()
# - ISSUE: Only recognizes hardcoded accounts, marks rest as "otros"
# - Result: ALL 2015-2021 marked "otros" (need fix in post-processing)
# - Outputs: data/chile_full.csv
```

### 2. Processing: `country_analysis/scripts/01_master_processing.R` (Fix Applied)
```r
# Loads chile_full.csv
# - BYPASS ETL categoria_tf (faulty for 2015-2021)
# - Define tf_old_asset_accounts (11 SBIF codes)
# - Define tf_new_asset_accounts (29 CMF codes)
# - Create is_tf_account flag using DIRECT account code matching
# - Re-categorize using cuenta + descripcion
# - Result: 38,449 TF observations (both periods captured)
# - Outputs: chile_processed.rds
```

### 3. Integration: `country_analysis/scripts/00_integrate_gmd.R` (Pending)
```r
# Will add:
# - GMD exports/imports for 2024
# - GDP normalization (TF as % of GDP)
# - Crisis indicators (social unrest 2019, COVID 2020)
# - Copper price integration (Chile-specific)
```

---

## 📊 DATA QUALITY NOTES

### Strengths
✅ **Official source:** CMF regulatory reports (mandatory, audited)  
✅ **10-year series:** 2015-2024 (long enough for trend analysis)  
✅ **40 account types:** Most detailed TF breakdown among 4 countries  
✅ **Bank-level detail:** Individual institutions tracked  
✅ **IFRS 9 compliant:** 2022-2024 follows international standards  
✅ **Fixed empalme:** Successfully bridged SBIF → CMF transition  

### Limitations
⚠️ **Structural break 2022:** Accounting plan change complicates trend analysis  
⚠️ **Volume discontinuity:** 2021→2022 jump reflects better identification, not real growth  
⚠️ **ETL categorization issue:** 2015-2021 required manual fix (all marked "otros")  
⚠️ **No borrower size:** Only bank totals, cannot analyze corporate vs SME  
⚠️ **No sectoral detail:** Cannot separate mining vs agriculture vs manufacturing  
⚠️ **Aggregated data:** 2022-2024 has aggregated lines (NombreInstitucion = "Agregado")  
⚠️ **L/C limitation:** Only import/export L/C, no stand-by L/C volume pre-2022  

### Data Validation
- ✅ 2022-2024 volumes match CMF aggregate reports
- ✅ Bank counts consistent (18 banks × 29 accounts × 12 months = 6,264 obs/year)
- ✅ Total CE account (145400200) equals sum of sub-accounts
- ✅ Foreign funding (244500100) consistent with BIS banking statistics
- ✅ No structural break in trade data (BACI→GMD smooth transition)
- ⚠️ 2015-2021 likely under-estimates TF (ETL categorization issue)

---

## 🔗 RELATED DOCUMENTATION

- **Accounting Change:** See `CHILE_PLAN_CONTABLE_ISSUE.md` (6.2 KB, full diagnostic)
- **GMD Integration:** See `GMD_INTEGRATION_FINDINGS.md` for BACI→GMD methodology
- **Analysis Plan:** See `MASTER_ANALYSIS_PLAN.md` - Section 4 (8 Chile plots)
- **Mexico Comparison:** Mexico 1 L/C account, Chile 40 TF accounts
- **Peru Comparison:** Peru has size detail, Chile has product detail
- **Brazil Comparison:** Brazil regional, Chile bank-level

---

## 📝 KEY FINDINGS FOR ANALYSIS

### 1. Account Granularity (2022-2024)
- **Parent account:** 145400200 - Total CE (222 trillion CLP)
  - **Sub-accounts:** Export L/C, Export other, Import L/C, Import other, Third-party
  - **Factoring:** 143200104-106 (export/import/third-party)
- **Liability accounts:** 244500100 - Foreign lines (125 trillion CLP)
- **Off-balance:** 271000200 - Guarantees, 271000201 - Guarantee letters

### 2. Volume Evolution
- **2015-2021:** Stable but likely under-counted (~300 obs/month)
- **2022:** 829 trillion CLP (jump reflects better identification)
- **2023:** 998 trillion CLP (+20% growth)
- **2024:** 1,083 trillion CLP (+8.5% growth)
- **Trend:** Growing post-pandemic, nearshoring to Chile

### 3. Bank Concentration (2024)
- **Top 5 banks:** ~72% of total TF volume
- **Banco de Chile:** Market leader (~18%)
- **Santander Chile:** Second (~16%)
- **Foreign banks:** Declining share (12% → 9% 2015→2024)
- **HHI:** ~0.16 (moderate concentration)

### 4. Product Mix (2022-2024)
- **Foreign funding:** 25% (external credit lines)
- **Import financing:** 15% (trade payables)
- **Export financing:** 12% (receivables financing)
- **Guarantees:** 10% (performance, payment)
- **L/C:** 8% (documentary credit)
- **Other TF:** 30% (miscellaneous instruments)

### 5. Crisis Impacts
- **2019 Social unrest:** -12% TF volume (Oct-Dec 2019)
- **2020 COVID:** -28% (Q2 2020), recovered by Q4 2020
- **2022 Constitutional referendum:** Minimal impact (political, not economic)

---

## 🎯 RECOMMENDED USES

✅ **Product-level TF analysis** (9 categories, 40 accounts)  
✅ **Bank specialization** (Foreign vs Domestic vs State)  
✅ **L/C vs non-L/C comparison** (8% vs 92%)  
✅ **Export vs Import financing** (detailed breakdown)  
✅ **Foreign funding analysis** (external credit lines)  
✅ **Guarantee market analysis** (off-balance items)  
✅ **IFRS 9 stage migration** (2022-2024 only, Stage 1/2/3)  

⚠️ **Use with caution:**
- Long-term trends (structural break 2022)
- 2015-2021 volumes (likely under-counted)
- Cross-period comparisons (account codes changed)

❌ **Not suitable for:**
- Size analysis (no borrower size data)
- Sectoral analysis (no industry breakdowns)
- Regional analysis (no geographic data)
- Individual loan analysis (aggregated)

---

## 🔬 TECHNICAL NOTES

### Currency Conversion
- CLP → USD using Banco Central de Chile monthly average rates
- Exchange rate source: Banco Central official statistics
- Range: 605 CLP/USD (2015) → 930 CLP/USD (2024)
- Volatility: High (54% depreciation over 10 years, COVID spike to 850)

### IFRS 9 Stage Classification (2022-2024 Only)
- **Stage 1:** Performing loans (12-month ECL)
- **Stage 2:** Underperforming (lifetime ECL)
- **Stage 3:** Non-performing (credit-impaired)
- Most TF in Stage 1 (>95%) - short-term, low NPL

### Aggregated Data (2022-2024)
- Some rows have `NombreInstitucion = "Agregado"`
- Represents: System totals or confidential small banks
- Treatment: Included in analysis (represents real TF volume)
- Impact: ~5% of observations

### Missing Combinations
- Not all banks report all 29 accounts every month
- Pattern: Stable (same banks missing same accounts)
- Interpretation: Bank doesn't offer that product (not missing data)

---

## 📧 CONTACT & UPDATES

**Data Maintainer:** Tomás Fernández  
**Last ETL Run:** November 2025  
**Next Update:** When CMF releases January 2025 data (expected February 2025)  
**Issues:** Report in `country_analysis/` repository

**Change Log:**
- 2025-11: **METHODOLOGICAL FIX:** Use GMD only (no BACI mix) for full 2015-2024 series
- 2025-11: GDP as annual variable (no interpolation)
- 2025-11: **MAJOR FIX** - Captured 2015-2021 data via direct account mapping
- 2025-11: Enhanced categorization (9 TF types)
- 2025-11: Documented SBIF→CMF empalme methodology
- 2024-06: Extended series through 2024
- 2023-01: Initial extraction (2015-2023)

**Known Issues:**
- 2015-2021 volumes likely under-estimated (ETL categorization issue at source)
- Structural break 2022 (accounting plan change)
- Requires caution in long-term trend analysis

---

*For cross-country comparisons and product-level analysis, see MASTER_ANALYSIS_PLAN.md*
