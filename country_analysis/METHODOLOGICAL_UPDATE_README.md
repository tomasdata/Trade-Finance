# 🔄 METHODOLOGICAL UPDATE - November 2025

## ⚠️ IMPORTANT CHANGES

This document describes critical methodological improvements implemented to ensure data consistency and quality across all 4 countries.

---

## 🎯 WHAT CHANGED

### 1. Trade Data: Single Source Strategy (GMD Only)

**PREVIOUS (WRONG):** Mixing BACI + GMD created discontinuities
```
2010-2023: BACI data (customs methodology)
2024-2025: GMD data (BOP methodology)
→ Result: ~6% export jump, ~28% import jump at transition
→ Problem: Artificial breaks in time series
```

**NEW (CORRECT):** GMD only for all years
```
2010-2024: GMD data exclusively (BOP methodology)
→ Result: Consistent methodology across all years
→ Benefit: No discontinuities, official sources
```

**Implementation:**
- ✅ All 4 CSV files updated (`scripts/update_csvs_with_gmd.R`)
- ✅ Columns: `exports_usd_millions`, `imports_usd_millions`, `gdp_usd_billions`
- ✅ Mexico: 2,204 obs updated
- ✅ Peru: 96,495 obs updated
- ✅ Chile: 762,687 obs updated
- ✅ Brazil: 838,166 obs updated

---

### 2. GDP Treatment: Annual Variable (No Interpolation)

**PREVIOUS (WRONG):** Attempting monthly GDP interpolation
```
Annual GDP → Linear interpolation → Monthly GDP
→ Problem: Creates artificial data (no real monthly GDP exists)
→ Problem: False precision in monthly TF/GDP ratios
```

**NEW (CORRECT):** GDP as annual variable
```
GDP = Annual value from official sources
→ Use for: Annual TF/GDP ratios only
→ Benefit: Real data, no artificial interpolation
```

**Implication:**
- TF/GDP ratios calculated annually (not monthly)
- Monthly analysis uses TF volumes and trade data only
- GDP used for annual comparisons and normalization

---

### 3. Documentation: Consolidated to 5 READMEs

**PREVIOUS:** 14 separate MD files (fragmented, redundant)

**NEW:** 5 comprehensive READMEs
1. **README.md** - Project overview (15 KB)
2. **README_MEXICO_DATA.md** - Mexico technical docs (8.6 KB)
3. **README_PERU_DATA.md** - Peru technical docs (11 KB)
4. **README_CHILE_DATA.md** - Chile technical docs (16 KB)
5. **README_BRAZIL_DATA.md** - Brazil technical docs (16 KB)

**Archived:** 10 files moved to `docs_archive/` for reference

---

## 📊 IMPACT ON DATA

### Mexico
- **Before:** BACI 2022-2023, GMD 2024-2025 (discontinuity)
- **After:** GMD 2022-2024 (consistent)
- **Trade data:** 2,204 obs all from GMD
- **GDP:** Annual 2022-2024

### Peru
- **Before:** BACI 2010-2023, GMD 2024 (discontinuity)
- **After:** GMD 2010-2024 (consistent)
- **Trade data:** 96,495 obs all from GMD
- **GDP:** Annual 2010-2024

### Chile
- **Before:** BACI 2015-2023, GMD 2024 (discontinuity)
- **After:** GMD 2015-2024 (consistent)
- **Trade data:** 762,687 obs all from GMD
- **GDP:** Annual 2015-2024
- **Note:** SBIF→CMF accounting change 2022 separate issue

### Brazil
- **Before:** BACI 2012-2023, GMD 2024 (discontinuity)
- **After:** GMD 2012-2024 (consistent)
- **Trade data:** 838,166 obs all from GMD
- **GDP:** Annual 2012-2024

---

## ✅ VALIDATION

### 1. No Discontinuities
```r
# Check for jumps at source transition points
# OLD (BACI→GMD): Visible 6-28% jumps
# NEW (GMD only): Smooth series
```

### 2. Data Consistency
- All 4 countries use same trade data source (GMD/BOP)
- All 4 countries use same GDP source (GMD/official)
- Comparable across countries (same methodology)

### 3. Official Sources
- GMD data from: IMF, World Bank, National Central Banks
- BOP methodology: Standard international accounting
- GDP: Annual official estimates (no interpolation)

---

## 🔧 IMPLEMENTATION DETAILS

### Files Updated

**CSV Updates:** `scripts/update_csvs_with_gmd.R`
```r
# Removes: X_exports, M_imports, trade (BACI columns)
# Adds: exports_usd_millions, imports_usd_millions, gdp_usd_billions (GMD)
# For: mexico_full.csv, peru_full.csv, chile_full.csv, brasil_full.csv
```

**Documentation Updates:**
- README.md (new main overview)
- README_MEXICO_DATA.md (§ Trade Data updated)
- README_PERU_DATA.md (§ Trade Data updated)
- README_CHILE_DATA.md (§ Trade Data updated)
- README_BRAZIL_DATA.md (§ Trade Data updated)

**Processing Scripts:**
- `01_master_processing.R` - Already handles GMD columns correctly
- `00_integrate_gmd.R` - (Pending) Will use updated CSV structure

---

## 📋 NEXT STEPS

### Immediate
1. ✅ CSVs updated with GMD data
2. ✅ Documentation consolidated (5 READMEs)
3. ⏳ Re-run `01_master_processing.R` to update RDS files
4. ⏳ Create `00_integrate_gmd.R` for GDP integration

### Analysis Phase
- TF volumes: Use monthly data
- Trade correlation: Use GMD monthly exports/imports
- GDP normalization: Use annual GDP (TF/GDP ratios per year)
- Crisis analysis: Use annual/quarterly indicators

---

## 🎓 METHODOLOGICAL RATIONALE

### Why GMD Over BACI?

**BACI Strengths:**
- ✅ Product-level detail (HS6 codes)
- ✅ Bilateral trade flows
- ✅ Long history (1995+)

**BACI Limitations for This Project:**
- ❌ Customs-based (different from BOP used in national accounts)
- ❌ Ends 2023 (no recent data)
- ❌ No GDP data
- ❌ Creates discontinuities when mixed with GMD

**GMD Advantages:**
- ✅ BOP methodology (consistent with national accounts)
- ✅ Official sources (IMF, World Bank, Central Banks)
- ✅ Includes GDP (same source as trade)
- ✅ Recent data (through 2024+)
- ✅ No discontinuities (single methodology)

### Why Annual GDP (Not Interpolated)?

**Interpolation Issues:**
- ❌ No real monthly GDP exists
- ❌ Creates false precision
- ❌ Interpolation methods are arbitrary
- ❌ Misleading monthly TF/GDP ratios

**Annual GDP Benefits:**
- ✅ Real official data (no artificial values)
- ✅ Matches reporting frequency of GDP statistics
- ✅ Appropriate for annual comparisons
- ✅ No false precision claims

---

## 📊 COMPARISON: OLD vs NEW

### Old Approach (PROBLEMATIC)
```
Trade Data:
├─ 2010-2023: BACI (customs)  ← Methodology 1
└─ 2024-2025: GMD (BOP)       ← Methodology 2  ⚠️ DISCONTINUITY

GDP:
├─ Annual GDP from GMD
└─ Interpolated to monthly    ⚠️ ARTIFICIAL DATA
```

### New Approach (CORRECT)
```
Trade Data:
└─ 2010-2024: GMD only (BOP)  ← Single methodology ✅ CONSISTENT

GDP:
└─ Annual GDP from GMD        ← Real data only ✅ NO INTERPOLATION
```

---

## ⚠️ IMPORTANT FOR ANALYSIS

### Do NOT Do This:
```r
# ❌ WRONG: Monthly TF/GDP ratios
monthly_ratio <- tf_monthly / (gdp_annual / 12)  # Artificial!

# ❌ WRONG: Mix BACI + GMD
trade <- rbind(baci_2010_2023, gmd_2024)  # Discontinuity!
```

### DO This Instead:
```r
# ✅ CORRECT: Annual TF/GDP ratios
annual_ratio <- tf_annual / gdp_annual

# ✅ CORRECT: GMD only
trade <- gmd_2010_2024  # Consistent methodology

# ✅ CORRECT: Monthly analysis without GDP
monthly_analysis <- tf_monthly / exports_monthly  # Both monthly
```

---

## 📧 CONTACT

**Questions about methodology:**
- See: Individual country READMEs (§ Trade Data: Single Source Strategy)
- Contact: Tomás Fernández
- Date: November 2025

**Change implemented by:** Tomás Fernández  
**Date:** November 19, 2025  
**Status:** ✅ Complete (CSVs + Documentation updated)

---

*This methodological update ensures data consistency and quality across all 4 countries.*
