# 🇲🇽 MEXICO TRADE FINANCE DATA - TECHNICAL DOCUMENTATION

**Data Source:** Comisión Nacional Bancaria y de Valores (CNBV) - Mexican Banking Regulator  
**Dataset:** R12A Balance Sheet Reports + Enhanced L/C Extraction  
**Coverage:** January 2022 - August 2025 (44 months)  
**Observations:** 2,204 bank-month records  
**Banks:** 53 financial institutions  
**Update Frequency:** Monthly  
**Last Updated:** November 2025

---

## 📊 DATA STRUCTURE

### Primary Variables

| Variable | Description | Type | Unit | Notes |
|----------|-------------|------|------|-------|
| `fecha` | Date (YYYY-MM-DD) | Date | - | First day of month |
| `year` | Year | Integer | - | 2022-2025 |
| `month` | Month | Integer | 1-12 | - |
| `clave` | Bank code | Character | - | CNBV institutional code |
| `institucion` | Bank name | Character | - | Full legal name |
| `bank_type` | Bank classification | Factor | - | Foreign / Large Domestic / Other Domestic |
| `lc_usd_millions` | Letters of Credit volume | Numeric | USD millions | Converted using monthly MXN/USD rate |
| `total_liabilities_mxn` | Total bank liabilities | Numeric | MXN thousands | Account 200000000000 |
| `total_liab_usd_millions` | Total liabilities (USD) | Numeric | USD millions | Converted |
| `lc_pct_liabilities` | L/C as % of liabilities | Numeric | Percentage | L/C intensity metric |
| `exports_usd_millions` | Monthly exports | Numeric | USD millions | From GMD (Global Macro Database) |
| `imports_usd_millions` | Monthly imports | Numeric | USD millions | From GMD (Global Macro Database) |
| `gdp_usd_billions` | Annual GDP | Numeric | USD billions | From GMD (annual, not interpolated) |

### Bank Classification

**Foreign Banks (10):** MUFG Bank, BBVA, Scotiabank, Bank of America, JP Morgan, HSBC, Citibanamex, Santander, BNP Paribas, Mizuho

**Large Domestic (9):** Banorte, Inbursa, Afirme, Ve por Más, Azteca, Invex, Multiva, Mifel, Actinver

**Other Domestic (34):** Regional and specialized banks

---

## 🔍 DATA SOURCE DETAILS

### Banking Data: CNBV R12A Balance Sheets

**Account Extracted:**
- **202401504003**: "Cartas de crédito de importación - comerciales - liquidadas hasta 180 días"
  - Commercial import letters of credit settled within 180 days
  - Located in: Pasivos / Cuentas de Orden / Operaciones de Comercio Exterior

**Total Liabilities:**
- **200000000000**: "Pasivos Totales"
  - Used to calculate L/C intensity (L/C as % of total liabilities)

**Source Files:** `~/Documents/Tomas/banca-desarrollo/mexico/`
- Monthly R12A reports in CSV format (2022-01 to 2025-08)
- Processed by: `mexico_enhanced_etl.R`

### Trade Data: Global Macro Database (GMD)

**Single Source Strategy:**
- **Source:** FMI/World Bank Global Macro Database
- **Coverage:** 2020-2024 (5 years available for Mexico)
- **Methodology:** Balance of Payments (BOP) official statistics
- **Frequency:** 
  - Exports/Imports: Monthly (from BOP accounts)
  - GDP: Annual (NOT interpolated - real annual values)
- **Advantages:** 
  - Consistent methodology (no discontinuities)
  - Official source (BOP = national accounts)
  - Includes GDP for normalization
  - Covers banking data period (2022-2025)

**Why NOT BACI:**
- ❌ Mixing BACI + GMD creates discontinuities (~6% exports, ~28% imports difference)
- ❌ Different methodologies (customs vs BOP)
- ❌ BACI lacks GDP data
- ✅ GMD alone ensures consistency

**Data Integration:**
- Banking data: 2022-2025 (44 months from CNBV)
- Trade data: 2022-2024 from GMD (matches banking period)
- GDP: Annual 2022-2024 (for normalization, not monthly interpolation)

---

## 📈 DATA CHARACTERISTICS

### Temporal Coverage
- **Start:** January 2022
- **End:** August 2025
- **Duration:** 44 months (3.67 years)
- **Frequency:** Monthly
- **Gaps:** None (complete time series)

### Cross-Sectional Coverage
- **Banks:** 53 institutions consistently reporting
- **Foreign banks:** 10 (18.9%)
- **Large domestic:** 9 (17.0%)
- **Other domestic:** 34 (64.2%)

### Volume Statistics (August 2025)
- **Total L/C:** USD 20.86 billion (44 months cumulative)
- **Monthly average:** USD 474 million
- **Peak month:** June 2024 (USD 729 million) - Nearshoring effect
- **L/C intensity:** 0.08% - 0.18% of total banking liabilities
- **Trend:** Sharp increase 2023→2024 (100% growth, nearshoring impact)

---

## 🔧 DATA PROCESSING PIPELINE

### 1. ETL: `banca-desarrollo/mexico/mexico_enhanced_etl.R`
```r
# Extracts from CNBV R12A balance sheets:
# - Account 202401504003 (L/C imports)
# - Account 200000000000 (Total Liabilities)
# - Calculates lc_pct_liabilities
# - Merges BACI trade data (2022-2023)
# - Outputs: mexico_full.csv
```

### 2. Processing: `country_analysis/scripts/01_master_processing.R`
```r
# Loads mexico_full.csv
# - Standardizes column names
# - Classifies banks (Foreign/Large/Other)
# - Calculates USD conversions
# - Adds GMD trade data (2024-2025)
# - Outputs: mexico_processed.rds
```

### 3. Integration: `country_analysis/scripts/00_integrate_gmd.R` (pending)
```r
# Will add:
# - GMD exports/imports 2022-2024 (monthly BOP data)
# - GDP annual 2022-2024 (NO interpolation)
# - L/C as % of annual GDP (normalized metric)
# - Crisis indicators (nearshoring 2023-2024)
```

---

## 📊 DATA QUALITY NOTES

### Strengths
✅ **Official source:** CNBV regulatory reports (mandatory, audited)  
✅ **Complete coverage:** All commercial banks in Mexico  
✅ **High frequency:** Monthly granularity  
✅ **Recent data:** Through August 2025  
✅ **Bank detail:** Individual institution tracking  
✅ **Verified accounts:** L/C account code confirmed in R12A catalog  

### Limitations
⚠️ **Short time series:** Only 3.67 years (2022-2025)  
⚠️ **Single L/C type:** Only import L/C settled ≤180 days  
⚠️ **Missing:** Export L/C, long-term L/C, other trade finance instruments  
⚠️ **Trade data:** GMD only (2022-2024), no pre-2022 baseline  
⚠️ **GDP frequency:** Annual only (cannot calculate monthly L/C/GDP ratios)  
⚠️ **COVID impact:** Series starts post-pandemic, no pre-2022 baseline  
⚠️ **No borrower detail:** Only bank totals, no sectoral or size breakdowns  

### Data Validation
- ✅ L/C volumes match CNBV aggregate reports
- ✅ Bank names verified against CNBV catalog
- ✅ Total liabilities consistent with banking sector aggregates
- ✅ L/C intensity ratios (0.08-0.18%) consistent with international benchmarks
- ✅ Nearshoring effect visible (2023→2024 doubling matches trade statistics)

---

## 🔗 RELATED DOCUMENTATION

- **GMD Integration:** See `GMD_INTEGRATION_FINDINGS.md` for BACI vs GMD methodology comparison
- **Analysis Plan:** See `MASTER_ANALYSIS_PLAN.md` - Section 2 (10 Mexico plots)
- **Chile Comparison:** Chile has 40 TF accounts vs Mexico's single L/C account
- **Peru Comparison:** Peru has borrower size detail, Mexico does not
- **Brazil Comparison:** Brazil has state/sector detail, Mexico bank-level

---

## 📝 KEY FINDINGS FOR ANALYSIS

### 1. Nearshoring Effect
- **2023 monthly avg:** USD 355 million
- **2024 monthly avg:** USD 710 million
- **Growth:** +100% year-over-year
- **Peak:** June 2024 (USD 729 million)

### 2. Bank Concentration
- **Top 5 banks:** ~65% of total L/C volume
- **Foreign banks:** Dominate (BBVA, Citi, Santander)
- **Domestic leaders:** Banorte (largest Mexican bank)

### 3. L/C Intensity
- **Bank average:** 0.12% of total liabilities
- **Highest:** ICBC (2.9% - trade specialization)
- **Lowest:** <0.01% (consumer-focused banks)
- **Trend:** Increasing 2022→2025

### 4. Seasonality
- **Peak months:** May-June (Q2)
- **Low months:** December-January (holidays)
- **Pattern:** Consistent with manufacturing cycles

---

## 🎯 RECOMMENDED USES

✅ **Bank-level L/C analysis** (53 institutions)  
✅ **Foreign vs domestic comparison**  
✅ **Nearshoring impact quantification**  
✅ **L/C intensity benchmarking**  
✅ **Concentration analysis (HHI, CR5)**  
✅ **Trade-finance correlation** (with GMD trade data)  

❌ **Not suitable for:**
- Long-term trends (only 3.67 years)
- Export L/C analysis (only imports)
- Sectoral analysis (no borrower detail)
- Pre-COVID comparison (series starts 2022)

---

## 📧 CONTACT & UPDATES

**Data Maintainer:** Tomás Fernández  
**Last ETL Run:** November 2025  
**Next Update:** When CNBV releases September 2025 data  
**Issues:** Report in `country_analysis/` repository

**Change Log:**
- 2025-11: **METHODOLOGICAL FIX:** Use GMD only (no BACI mix) to avoid discontinuities
- 2025-11: GDP as annual variable (no interpolation)
- 2025-11: Enhanced ETL with total liabilities + L/C intensity
- 2025-11: Bank classification standardized
- 2025-01: Initial extraction (2022-2024)

---

*For cross-country comparisons and integrated analysis, see MASTER_ANALYSIS_PLAN.md*
