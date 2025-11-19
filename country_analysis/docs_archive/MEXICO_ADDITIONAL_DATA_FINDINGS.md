# 🇲🇽 MEXICO - Additional Data Discovery

**Date:** November 19, 2025  
**Status:** ✅ MAJOR UPGRADE - Full balance sheet available!

---

## 🎯 KEY FINDING: We Can Calculate L/C as % of Total Liabilities!

### What We Discovered in `/pre-data/Mexico/`

The folder contains the **complete R12A balance sheet** (regulatory financial statements) from CNBV, not just L/C data!

| File | Description | Value |
|------|-------------|-------|
| **040_R12A_1219_133.csv** | Full monthly balance sheet for all banks | ✅ **2.95M observations** |
| **mxnusd.csv** | Daily SAT exchange rates | ✅ **3,964 days** (2015-2024) |

---

## 📊 R12A Balance Sheet - Complete Structure

### Dataset Dimensions
- **Observations:** 2,947,694 rows
- **Period:** January 2022 - August 2025 (44 months)
- **Banks:** 54 institutions (53 banks + 1 aggregate code "5")
- **Account codes:** 1,321 unique concepts (full balance sheet!)

### Key Account Codes Identified

| Code | Description | Type | Notes |
|------|-------------|------|-------|
| **100000000000** | Total Assets | Asset | Main aggregate |
| **200000000000** | **Total Liabilities** | **Liability** | ✅ **THIS IS WHAT WE NEEDED!** |
| **202401504003** | Letters of Credit (contingent liabilities) | Contingent | Trade finance metric |
| **300000000000** | Total Capital | Equity | Balance check |

### Account Code Structure (CNBV Format)
- **First digit:** Class (1=Assets, 2=Liabilities, 3=Capital)
- **Positions 1-4:** Major category
- **Positions 5-8:** Subcategory
- **Positions 9-12:** Detail level
- **Many zeros:** Aggregate/total concept

---

## 💰 Data Verification - January 2022

### Example: BANAMEX (Institution 40002)

| Concept | Code | Amount (MXN) | Amount (USD bn) @ 20 MXN/USD |
|---------|------|--------------|------------------------------|
| **Total Assets** | 100000000000 | 1,424,266,326,556 | **71.2** |
| **Total Liabilities** | 200000000000 | 1,239,291,000,000 | **62.0** |
| **Letters of Credit** | 202401504003 | 390,963,886 | **0.02** |

### L/C as % of Total Liabilities
- **BANAMEX:** 390M / 1,239B = **0.032%** ← We can now calculate this!
- **System-wide (Jan 2022):** 11.3B MXN in L/C

---

## 🔄 What This Changes for Our Analysis

### ❌ BEFORE (what we thought we had):
- ✅ Outstanding L/C amounts (USD millions)
- ✅ By bank, by month
- ❌ **NO total liabilities** → Could NOT calculate %
- Limited to absolute amounts and market shares

### ✅ NOW (what we actually have):
- ✅ Outstanding L/C amounts
- ✅ **TOTAL LIABILITIES by bank, by month** ← **NEW!**
- ✅ **Can calculate L/C as % of total liabilities** ← **KEY METRIC!**
- ✅ Can analyze L/C intensity by bank type
- ✅ Can track how L/C % evolves over time
- ✅ Full balance sheet available for context

---

## 📈 New Analyses Now Possible

### Enhanced Mexico Analysis (02_mexico_analysis.R)

#### 1. **L/C as % of Total Liabilities - Time Series**
```r
# Calculate monthly for each bank
mexico$lc_pct_liabilities <- (mexico$lc_amount / mexico$total_liabilities) * 100

# System-wide average
# By bank type (Foreign vs Domestic)
# Identify banks with high L/C intensity
```

#### 2. **Bank Type Comparison**
- Foreign banks vs Domestic banks L/C intensity
- Large banks vs Small banks
- Hypothesis: Foreign banks may have higher L/C % due to trade focus

#### 3. **L/C Intensity Leaders**
- Top 10 banks by L/C as % of liabilities
- Which banks specialize in trade finance?
- Correlation with trade volumes

#### 4. **Time Evolution**
- How has L/C intensity changed 2022-2025?
- COVID recovery effects?
- Nearshoring impact on Mexican trade finance?

#### 5. **Balance Sheet Context**
- L/C relative to other contingent liabilities
- Compare with Peru/Chile where we have similar metrics

---

## 🔧 Updated Data Processing Required

### Modify `01_master_processing.R` - Mexico Section

**Add to Mexico processing:**

```r
# Load full R12A balance sheet
r12a_raw <- read_csv("../pre-data/Mexico/040_R12A_1219_133.csv")

# Extract TOTAL LIABILITIES (concepto 200000000000)
total_liabilities <- r12a_raw %>%
  filter(concepto == "200000000000", institucion != 5) %>%  # Exclude aggregate
  mutate(
    year = as.integer(substr(periodo, 1, 4)),
    month = as.integer(substr(periodo, 5, 6)),
    cod_inst = institucion,
    total_liab_mxn = importe_pesos
  ) %>%
  select(year, month, cod_inst, total_liab_mxn)

# Extract L/C (concepto 202401504003)
lc_data <- r12a_raw %>%
  filter(concepto == "202401504003", institucion != 5) %>%
  mutate(
    year = as.integer(substr(periodo, 1, 4)),
    month = as.integer(substr(periodo, 5, 6)),
    cod_inst = institucion,
    lc_mxn = importe_pesos
  ) %>%
  select(year, month, cod_inst, lc_mxn)

# Merge with exchange rates
fx <- read_delim("../pre-data/Mexico/mxnusd.csv", delim = ";") %>%
  # Parse date and extract month
  # Convert "para solventar obligaciones" to numeric
  # Get last FX of each month

# Final Mexico dataset
mexico <- lc_data %>%
  left_join(total_liabilities, by = c("year", "month", "cod_inst")) %>%
  left_join(fx, by = c("year", "month")) %>%
  mutate(
    # Convert to USD
    lc_usd_millions = lc_mxn / (fx_rate * 1e6),
    total_liab_usd_millions = total_liab_mxn / (fx_rate * 1e6),
    
    # Calculate percentage
    lc_pct_liabilities = (lc_mxn / total_liab_mxn) * 100
  )
```

---

## 📊 Comparable with Other Countries Now!

### Cross-Country Metric: "Trade Finance as % of Total"

| Country | Metric | Numerator | Denominator | Status |
|---------|--------|-----------|-------------|--------|
| **Mexico** | L/C % of liabilities | L/C amount | **Total liabilities** | ✅ **NOW AVAILABLE!** |
| **Peru** | TF credit % of total | Foreign-trade credit | Total credit | ✅ Available |
| **Chile** | TF loans % of total | Trade finance accounts | Total loans | ✅ Can calculate |
| **Brazil** | TF credit % (by state/sector) | Trade finance | Total credit | ✅ Available |

**Key insight:** We can now create a **true cross-country comparison** of trade finance intensity!

---

## 🎯 Updated Analysis Priorities

### Priority 1: Update `01_master_processing.R`
- Load full R12A balance sheet
- Extract total liabilities (200000000000)
- Extract L/C (202401504003)
- Process exchange rates (mxnusd.csv)
- Calculate L/C as % of total liabilities

### Priority 2: Enhanced `02_mexico_analysis.R`
- **NEW Plot 1:** L/C as % of total liabilities over time (system-wide)
- **NEW Plot 2:** L/C % by bank type (Foreign vs Domestic)
- **NEW Plot 3:** Top 10 banks by L/C intensity (%)
- **Existing Plot 4:** L/C absolute amounts by bank type
- **NEW Plot 5:** L/C % correlation with trade volumes
- **NEW Plot 6:** Distribution of L/C intensity across banks

### Priority 3: Cross-Country Comparison
- Add Mexico to `06_comparison.R`
- Compare "Trade finance as % of total" across 4 countries
- Analyze bank type patterns (foreign vs domestic)

---

## 📝 Exchange Rate Processing Note

File `mxnusd.csv` has:
- **Format:** Semicolon-separated (`;`)
- **Decimal separator:** Comma (`,`) - needs conversion to point (`.`)
- **Date format:** DD/MM/YYYY
- **Column:** "para solventar obligaciones" (to settle obligations)
- **Frequency:** Daily → Need to aggregate to monthly (last business day)

**Processing steps:**
1. Read with `read_delim(delim = ";")`
2. Convert date format
3. Replace comma with point in numeric column
4. Convert to numeric
5. Aggregate to monthly (last value of each month)
6. Match to R12A data by year-month

---

## ✅ Summary

### What We Gained:
1. ✅ **Total liabilities by bank, by month** (2.95M obs)
2. ✅ **Can calculate L/C as % of total liabilities**
3. ✅ **Full balance sheet context** (1,321 account codes)
4. ✅ **Daily exchange rates** for precise MXN→USD conversion
5. ✅ **Comparability with Peru/Chile** on intensity metrics

### What We Need to Do:
1. ⏳ **Update 01_master_processing.R** to use full R12A data
2. ⏳ **Process mxnusd.csv** to monthly exchange rates
3. ⏳ **Recalculate Mexico dataset** with % metrics
4. ⏳ **Enhance 02_mexico_analysis.R** with new plots
5. ⏳ **Add Mexico to cross-country comparisons**

### Impact:
**MAJOR UPGRADE** - Mexico analysis goes from "limited" to "comprehensive" with the discovery of full balance sheet data. We now have one of the most complete datasets for Mexico banking trade finance!

---

**Status:** Ready to update processing script  
**Next Action:** Modify `01_master_processing.R` to incorporate R12A balance sheet and exchange rates
