# ⚠️ METHODOLOGICAL UPDATE - TRADE DATA INTEGRATION

**Date:** November 19, 2025  
**Impact:** All 4 countries (Mexico, Peru, Chile, Brazil)  
**Status:** ✅ Documentation updated, scripts pending update

---

## 🎯 PROBLEM IDENTIFIED

### Original Approach (INCORRECT ❌)
```
BACI Database (through 2023) → GMD Database (2024+)
├─ Trade data: BACI historical + GMD recent
├─ GDP: GMD interpolated monthly ❌
└─ Result: Discontinuities + artificial data
```

**Issues:**
1. **❌ Mixing sources creates discontinuities:**
   - BACI (customs-based) vs GMD (BOP-based)
   - GMD exports ~6% higher, imports ~28% higher
   - Structural break in time series at 2023→2024

2. **❌ GDP interpolation creates artificial data:**
   - GDP is inherently annual (national accounts)
   - Monthly interpolation = invented data points
   - Misleading precision for monthly TF/GDP ratios

---

## ✅ CORRECTED APPROACH

### New Methodology (CORRECT ✅)
```
GMD Database ONLY (full period available)
├─ Trade data: GMD monthly exports/imports (BOP)
├─ GDP: GMD annual (NO interpolation)
└─ Result: Consistent methodology, real data
```

**Advantages:**
1. **✅ Single source = no discontinuities**
   - Consistent BOP methodology across all years
   - No structural breaks in time series
   - Clean comparative analysis

2. **✅ Annual GDP = real data**
   - Respects annual nature of GDP measurement
   - No invented monthly values
   - Annual TF/GDP ratios = meaningful metrics

3. **✅ Official statistics**
   - GMD sources from national central banks
   - Balance of Payments = official national accounts
   - Validated by IMF/World Bank

---

## 📊 IMPLEMENTATION BY COUNTRY

### 🇲🇽 Mexico
| Aspect | Old | New |
|--------|-----|-----|
| **Trade data** | BACI 2022-2023 + GMD 2024-2025 | GMD 2022-2024 only |
| **GDP** | GMD quarterly interpolated monthly | GMD annual (2022-2024) |
| **Coverage** | 44 months banking, mixed trade | 44 months banking, consistent trade |
| **Variables** | `exports_usd_millions`, `imports_usd_millions` (mixed) | `exports_usd_millions`, `imports_usd_millions`, `gdp_usd_billions` (GMD) |

**GMD Availability:** 2020-2024 (5 years)  
**Banking Data:** 2022-2025 (44 months)  
**Overlap:** 2022-2024 (perfect match)

---

### 🇵🇪 Peru
| Aspect | Old | New |
|--------|-----|-----|
| **Trade data** | BACI 2010-2023 + GMD 2024 | GMD 2010-2024 only |
| **GDP** | GMD quarterly interpolated monthly | GMD annual (2010-2024) |
| **Coverage** | 171 months banking, mixed trade | 171 months banking, consistent trade |
| **Variables** | `exports_usd_millions`, `imports_usd_millions`, `ngdp_usd_millions` (mixed) | `exports_usd_millions`, `imports_usd_millions`, `gdp_usd_billions` (GMD) |

**GMD Availability:** 2010-2024 (15 years)  
**Banking Data:** Oct 2010 - Dec 2024 (171 months)  
**Overlap:** 2010-2024 (perfect match)

---

### 🇨🇱 Chile
| Aspect | Old | New |
|--------|-----|-----|
| **Trade data** | BACI 2015-2023 + GMD 2024 | GMD 2015-2024 only |
| **GDP** | GMD quarterly interpolated monthly | GMD annual (2015-2024) |
| **Coverage** | 120 months banking, mixed trade | 120 months banking, consistent trade |
| **Variables** | Not present in original | `exports_usd_millions`, `imports_usd_millions`, `gdp_usd_billions` (GMD) |
| **Note** | SBIF→CMF transition Jan 2022 (banking only) | Trade data unaffected by accounting change |

**GMD Availability:** 2015-2024 (10 years)  
**Banking Data:** Jan 2015 - Dec 2024 (120 months)  
**Overlap:** 2015-2024 (perfect match)  
**Key:** Trade data consistency spans SBIF→CMF accounting transition

---

### 🇧🇷 Brazil
| Aspect | Old | New |
|--------|-----|-----|
| **Trade data** | BACI 2012-2023 + GMD 2024 | GMD 2012-2024 only |
| **GDP** | GMD quarterly interpolated monthly | GMD annual (2012-2024) |
| **Coverage** | 156 months banking, mixed trade | 156 months banking, consistent trade |
| **Variables** | `exports_usd_millions`, `imports_usd_millions`, `ngdp_usd_millions` (mixed) | `exports_usd_millions`, `imports_usd_millions`, `gdp_usd_billions` (GMD) |

**GMD Availability:** 2012-2024 (13 years)  
**Banking Data:** Jan 2012 - Dec 2024 (156 months)  
**Overlap:** 2012-2024 (perfect match)  
**Note:** State-level GDP from IBGE (separate integration)

---

## 📝 VARIABLE NAMING CONVENTION

### Updated Variables (All Countries)

| Variable | Type | Unit | Source | Notes |
|----------|------|------|--------|-------|
| `exports_usd_millions` | Numeric | USD millions | GMD | Monthly, BOP methodology |
| `imports_usd_millions` | Numeric | USD millions | GMD | Monthly, BOP methodology |
| `gdp_usd_billions` | Numeric | USD billions | GMD | **Annual only** (no interpolation) |

**Key Changes:**
- ✅ `gdp_usd_billions` (annual) replaces `ngdp_usd_millions` (monthly interpolated)
- ✅ Unit change: billions (GDP) vs millions (trade) for scale clarity
- ✅ All from GMD (no BACI mix)

---

## 🔧 REQUIRED UPDATES

### 1. Documentation ✅ COMPLETE
- [x] README_MEXICO_DATA.md - Updated trade data section
- [x] README_PERU_DATA.md - Updated trade data section
- [x] README_CHILE_DATA.md - Updated trade data section
- [x] README_BRAZIL_DATA.md - Updated trade data section
- [x] All change logs updated with methodological fix note

### 2. Scripts ⏳ PENDING
- [ ] `00_integrate_gmd.R` - Create from scratch with corrected approach:
  ```r
  # Load GMD (single source)
  gmd <- read_csv("data/GMD.csv")
  
  # Extract monthly trade (BOP)
  trade_monthly <- gmd %>%
    filter(country %in% c("Mexico", "Peru", "Chile", "Brazil")) %>%
    select(country, year, month, exports_usd_millions, imports_usd_millions)
  
  # Extract ANNUAL GDP (no interpolation)
  gdp_annual <- gmd %>%
    filter(country %in% c("Mexico", "Peru", "Chile", "Brazil")) %>%
    distinct(country, year, gdp_usd_billions)
  
  # Merge with banking data
  # - Trade: monthly (matches banking frequency)
  # - GDP: annual (one value per year, replicated for all months)
  ```

- [ ] Update processed RDS files:
  - `mexico_processed.rds` - Add GMD trade + annual GDP
  - `peru_processed.rds` - Replace BACI with GMD, annual GDP
  - `chile_processed.rds` - Add GMD trade + annual GDP
  - `brasil_processed.rds` - Replace BACI with GMD, annual GDP

### 3. Analysis Scripts ⏳ PENDING
- [ ] `02_mexico_analysis.R` - Update to use `gdp_usd_billions` (annual)
- [ ] `03_peru_analysis.R` - Update to use `gdp_usd_billions` (annual)
- [ ] `04_chile_analysis.R` - Update to use `gdp_usd_billions` (annual)
- [ ] `05_brazil_analysis.R` - Update to use `gdp_usd_billions` (annual)
- [ ] `06_comparison.R` - Update TF vs Trade plots with GMD only

**Key:** All TF/GDP calculations must be **annual** (e.g., annual TF sum / annual GDP)

---

## 📊 IMPACT ON ANALYSIS

### Plots Affected

#### Monthly plots ✅ No change
- TF evolution over time
- Seasonality patterns
- Bank concentration
- Size distribution

#### Normalized plots ⚠️ Changed methodology
- **TF as % of GDP:** Now annual calculation only
  - Old: Monthly TF / Interpolated monthly GDP ❌
  - New: Annual TF sum / Annual GDP ✅
  - Impact: One point per year instead of 12 points

- **TF vs Trade correlation:**
  - Old: Monthly TF vs mixed BACI/GMD ❌
  - New: Monthly TF vs GMD only ✅
  - Impact: Consistent methodology, no 2023→2024 jump

#### Cross-country comparisons ✅ Improved
- Now all 4 countries use same source (GMD)
- No methodological differences
- Clean comparisons

---

## 🎯 KEY BENEFITS

### 1. Methodological Rigor
✅ Single source = one methodology  
✅ No artificial interpolation  
✅ Annual GDP respects measurement frequency  

### 2. Data Quality
✅ Official BOP statistics from national banks  
✅ No discontinuities in time series  
✅ Validated by IMF/World Bank  

### 3. Analysis Clarity
✅ TF/GDP ratios meaningful (annual aggregates)  
✅ Trade correlations clean (consistent source)  
✅ Cross-country comparisons valid (same methodology)  

---

## 📋 CHECKLIST FOR IMPLEMENTATION

### Before Analysis
- [ ] Update `00_integrate_gmd.R` with single-source approach
- [ ] Re-run data processing (regenerate all 4 RDS files)
- [ ] Verify variables: `exports_usd_millions`, `imports_usd_millions`, `gdp_usd_billions`
- [ ] Check GDP is annual (not monthly interpolated)

### During Analysis
- [ ] Use annual aggregation for TF/GDP calculations
- [ ] Document: "TF as % of GDP calculated annually"
- [ ] Trade correlations: Note "GMD BOP methodology"
- [ ] Cross-country: Emphasize "consistent methodology across countries"

### Quality Checks
- [ ] No jumps in trade series (2023→2024 should be smooth)
- [ ] GDP values constant within year (12 months same value)
- [ ] TF/GDP ratios sensible (0.1-2% typical range)
- [ ] Trade-TF correlation strong (r² > 0.6 expected)

---

## 📚 DOCUMENTATION UPDATED

| File | Status | Lines Changed | Key Updates |
|------|--------|---------------|-------------|
| README_MEXICO_DATA.md | ✅ Complete | ~30 lines | Trade data section, variables table, change log |
| README_PERU_DATA.md | ✅ Complete | ~30 lines | Trade data section, variables table, change log |
| README_CHILE_DATA.md | ✅ Complete | ~35 lines | Trade data section, variables table, change log |
| README_BRAZIL_DATA.md | ✅ Complete | ~30 lines | Trade data section, variables table, change log |
| METHODOLOGICAL_UPDATE.md | ✅ Created | 350 lines | This comprehensive guide |

**Total documentation:** 505 lines updated/created

---

## 🚀 NEXT STEPS

1. **Create `00_integrate_gmd.R`** with corrected methodology
2. **Re-run data processing** to regenerate all RDS files
3. **Update TODO list** to reflect methodological change
4. **Proceed with analysis** using clean, consistent data

**Priority:** HIGH (blocking all analysis scripts)  
**Estimated time:** 1-2 hours to implement + validate  
**Impact:** Foundation for all 42 plots

---

## 📧 CONTACT

**Methodological Lead:** Tomás Fernández  
**Date of Fix:** November 19, 2025  
**Issue:** Identified mixing BACI+GMD + interpolating GDP  
**Solution:** GMD only + annual GDP  
**Status:** Documentation complete, implementation pending

---

*This methodological update ensures rigorous, consistent analysis across all 4 countries.*
