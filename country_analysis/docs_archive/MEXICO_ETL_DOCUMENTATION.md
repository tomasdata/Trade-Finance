# Mexico Enhanced ETL - Documentation

**Date:** November 19, 2025  
**Script:** `/pre-data/Mexico/mexico_enhanced_etl.R`  
**Output:** `/country_analysis/data/mexico_full.csv`

---

## ✅ What Was Done

### Original Situation
- Had only Letters of Credit (L/C) amounts in MXN
- Could NOT calculate L/C as % of total (missing denominator)
- Limited analysis capabilities

### Enhancement
Discovered that `/pre-data/Mexico/040_R12A_1219_133.csv` contains the **FULL R12A balance sheet** from CNBV (2.95M rows), not just L/C data!

### New Data Extracted

| Concept Code | Description | Usage |
|--------------|-------------|-------|
| **202401504003** | Letters of Credit (Contingent liabilities) | Numerator for % calculation |
| **200000000000** | **Total Liabilities** | **Denominator for % calculation** |
| Exchange rates | SAT daily fix rates (mxnusd.csv) | MXN → USD conversion |

---

## 📊 Output Dataset Structure

### Dimensions
- **2,204 observations** (53 banks × 44 months)
- **15 columns**
- **Period:** January 2022 - August 2025

### Columns

| Column | Type | Description |
|--------|------|-------------|
| `year` | int | Year (2022-2025) |
| `month` | int | Month (1-12) |
| `year_month` | chr | YYYY-MM format |
| `cod_inst` | chr | CNBV institution code (e.g., "040002") |
| `institucion` | chr | Bank name (e.g., "BANAMEX") |
| `amount_mxn` | num | L/C amount in Mexican Pesos |
| `tipo_cambio` | num | Exchange rate MXN/USD (SAT fix) |
| `amount_usd` | num | L/C amount in USD |
| `amount_usd_thousands` | num | L/C amount in USD thousands |
| **`total_liab_mxn`** | num | **Total liabilities in MXN** ← NEW! |
| **`total_liab_usd_millions`** | num | **Total liabilities in USD millions** ← NEW! |
| **`lc_pct_liabilities`** | num | **L/C as % of total liabilities** ← KEY METRIC! |
| `X_exports` | num | Exports (placeholder, NA) |
| `M_imports` | num | Imports (placeholder, NA) |
| `trade` | num | Total trade (placeholder, NA) |

---

## 🎯 Key Metrics Now Available

### 1. L/C Intensity by Bank
**Formula:** `lc_pct_liabilities = (amount_mxn / total_liab_mxn) * 100`

**Top 5 Banks by L/C Intensity (2024 average):**

| Bank | L/C (USD millions) | L/C % of Liabilities |
|------|-------------------|---------------------|
| **ICBC** | 12.4 | **2.90%** ← Highest intensity! |
| **BMONEX** | 42.5 | **0.31%** |
| **SANTANDER** | 119.5 | **0.13%** |
| **HSBC** | 53.9 | **0.13%** |
| **CIBANCO** | 7.7 | **0.12%** |

**Interpretation:** ICBC (Chinese bank) has by far the highest L/C intensity, suggesting strong trade finance specialization despite moderate absolute volumes.

### 2. Time Trends

| Year | Total L/C (USD millions) | Avg L/C % | # Banks |
|------|-------------------------|-----------|---------|
| 2022 | 5,462 | 0.037% | 50 |
| 2023 | 5,924 | 0.040% | 50 |
| 2024 | 5,840 | **0.079%** ← Doubled! | 51 |
| 2025 | 3,635 (8 months) | 0.074% | 52 |

**Key Finding:** L/C intensity **doubled from 2023 to 2024** (0.04% → 0.08%), possibly reflecting nearshoring effects and increased trade finance activity.

### 3. Market Concentration

**Top 5 Banks (2024):**
1. BBVA MEXICO: USD 1,787M (30.6%)
2. SANTANDER: USD 1,434M (24.6%)
3. HSBC: USD 647M (11.1%)
4. BANORTE: USD 514M (8.8%)
5. BMONEX: USD 510M (8.7%)

**CR5 = 83.8%** (highly concentrated market)

---

## 🔧 Technical Notes

### Concept Codes Verified

All concept codes were **manually verified** in the R12A file to ensure they exist and are correctly interpreted:

```r
# Verified in R12A for BANAMEX (Jan 2022):
100000000000 → Total Assets = MXN 1.424 trillion
200000000000 → Total Liabilities = MXN 1.239 trillion  ✓ CONFIRMED
202401504003 → Letters of Credit = MXN 391 million     ✓ CONFIRMED
```

### Exchange Rate Processing

- **Source:** SAT (Servicio de Administración Tributaria) official daily rates
- **Method:** Last non-NA value of each month
- **Range:** 14.84 - 24.39 MXN/USD (2022-2025)
- **Format:** Semicolon-separated, comma as decimal (converted to point)

### Bank Name Mapping

53 banks mapped from CNBV codes to names:
- **Commercial banks:** 040xxx codes (e.g., 040002 = BANAMEX)
- **Development banks:** 037xxx codes (e.g., 037006 = BANCOMEXT)
- Includes major foreign banks: HSBC, SCOTIABANK, ICBC, MUFG, JP MORGAN, etc.

### Data Quality

✅ **Complete:**
- All L/C observations have corresponding total liabilities
- Exchange rates available for all months 2022-2025
- No missing bank names (all mapped or coded)

⚠️ **Placeholders:**
- Trade data (X_exports, M_imports, trade) set to NA
- Can be filled later from BACI or INEGI sources if needed

---

## 📈 Implications for Analysis

### NOW Possible:

1. **✅ L/C as % of total liabilities** - Key intensity metric
2. **✅ Compare bank types** - Foreign vs Domestic vs Development
3. **✅ Identify specialists** - Banks with high L/C intensity
4. **✅ Time evolution** - Track changes 2022-2025
5. **✅ Cross-country comparison** - Compare with Peru/Chile on % basis

### Enhanced Analyses:

#### Mexico-Specific (02_mexico_analysis.R):
- L/C intensity time series
- Bank type comparison (Foreign vs Domestic)
- Top 10 banks by intensity (not just volume)
- Nearshoring impact (2024 spike)
- Correlation with trade volumes (when available)

#### Cross-Country (06_comparison.R):
- Trade finance intensity: Mexico (L/C %), Peru (TF credit %), Chile (TF loans %)
- Bank type patterns across countries
- Concentration metrics (HHI, CR5)

---

## 🔄 Integration with Processing Pipeline

### Updated Workflow:

**OLD:**
```
pre-data/Mexico/mexico_full.csv (simple L/C data)
  ↓
country_analysis/data/mexico_full.csv (copy)
  ↓
01_master_processing.R (minimal processing)
```

**NEW:**
```
pre-data/Mexico/040_R12A_1219_133.csv (full balance sheet)
  ↓
pre-data/Mexico/mexico_enhanced_etl.R (extract L/C + liabilities)
  ↓
country_analysis/data/mexico_full.csv (enhanced with %)
  ↓
01_master_processing.R (use enhanced data)
```

### Next Steps:

1. ✅ **DONE:** Enhanced mexico_full.csv generated
2. ⏳ **TODO:** Update `01_master_processing.R` to use new columns
3. ⏳ **TODO:** Create enhanced `02_mexico_analysis.R` with % metrics
4. ⏳ **TODO:** Add Mexico to cross-country comparisons

---

## 📝 Script Location

**ETL Script:** `/Users/tomasfernandez/Documents/Tomas/Trade-Finance/pre-data/Mexico/mexico_enhanced_etl.R`

**To re-run:**
```bash
cd /Users/tomasfernandez/Documents/Tomas/Trade-Finance/pre-data/Mexico
Rscript mexico_enhanced_etl.R
```

**Output:** Automatically replaces `country_analysis/data/mexico_full.csv`

---

## ✅ Verification

**File generated:** `/Users/tomasfernandez/Documents/Tomas/Trade-Finance/country_analysis/data/mexico_full.csv`

**Size:** 205 KB  
**Rows:** 2,204  
**Columns:** 15  

**Quick check:**
```r
library(dplyr)
mexico <- read.csv('data/mexico_full.csv')
summary(mexico$lc_pct_liabilities)  # Should show 0.0% - 2.9% range
```

---

**Status:** ✅ COMPLETE - Enhanced Mexico dataset ready for analysis  
**Impact:** MAJOR - Unlocked % calculations and cross-country comparability  
**Last Updated:** November 19, 2025
