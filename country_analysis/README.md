# 🌎 LATAM Trade Finance Comparative Analysis

**Multi-Country Study:** Mexico 🇲🇽 | Peru 🇵🇪 | Chile 🇨🇱 | Brazil 🇧🇷  
**Project Lead:** Tomás Fernández  
**Last Updated:** November 2025  
**Status:** Data ready, analysis phase starting

---

## 📋 PROJECT OVERVIEW

Comprehensive analysis of trade finance patterns across 4 Latin American countries using regulatory banking data (2010-2025) and official trade statistics. This project examines bank-level lending, borrower size distributions, regional patterns, and product types to understand trade finance access and dynamics in the region.

**Total Dataset:** 892,604 observations
- Mexico: 2,204 obs (bank-month, 2022-2025)
- Peru: 13,785 obs (bank-month-size, 2010-2024)
- Chile: 38,449 obs (bank-month-account, 2015-2024)
- Brazil: 838,166 obs (state-sector-size-month, 2012-2024)

---

## 🎯 QUICK START

### Read Documentation in This Order:

1. **📄 This README** - Project overview, methodology, quick reference
2. **🇲🇽 README_MEXICO_DATA.md** - Mexico data & methods (8.6 KB)
3. **🇵🇪 README_PERU_DATA.md** - Peru data & methods (11 KB)
4. **🇨🇱 README_CHILE_DATA.md** - Chile data & methods (16 KB)
5. **🇧🇷 README_BRAZIL_DATA.md** - Brazil data & methods (16 KB)

### Run Analysis:

```bash
# Update CSVs with GMD data (if needed)
Rscript scripts/update_csvs_with_gmd.R

# Process all countries
Rscript scripts/01_master_processing.R

# Run country-specific analysis
Rscript scripts/02_mexico_analysis.R
Rscript scripts/03_peru_analysis.R
Rscript scripts/04_chile_analysis.R
Rscript scripts/05_brazil_analysis.R

# Generate report
Rscript scripts/07_integrated_report.R
```

---

## 📊 DATA SOURCES

### Banking Data (Regulatory - Official)

| Country | Regulator | Dataset | Coverage | Key Feature |
|---------|-----------|---------|----------|-------------|
| **Mexico** | CNBV | R12A Balance Sheets | 2022-2025 (44m) | Import L/C ≤180 days |
| **Peru** | SBS | Credit Registry | 2010-2024 (171m) | 5 borrower sizes |
| **Chile** | CMF | Balance Sheets | 2015-2024 (120m) | 40 TF accounts |
| **Brazil** | BCB | SCR System | 2012-2024 (156m) | 27 states, 8 sectors |

### Trade & Macro Data (GMD - Single Source)

**Source:** Global Macro Database (FMI/World Bank)
- **Coverage:** 2020-2024 for all 4 countries
- **Methodology:** Balance of Payments (BOP) official statistics
- **Variables:** 
  - Exports & Imports (monthly, from BOP accounts)
  - GDP (annual, NOT interpolated)
- **Advantages:**
  - ✅ Consistent methodology (no discontinuities)
  - ✅ Official sources (national central banks)
  - ✅ Includes GDP for normalization
  - ✅ Covers all banking data periods

**Why GMD Only (Not BACI):**
- ❌ **Avoided:** Mixing BACI + GMD creates ~6% export, ~28% import discontinuities
- ❌ **Different methodologies:** Customs (BACI) vs BOP (GMD)
- ✅ **Single source ensures:** No artificial breaks in time series

---

## 📈 COUNTRY COMPARISON

| Aspect | Mexico | Peru | Chile | Brazil |
|--------|--------|------|-------|--------|
| **Observations** | 2,204 | 13,785 | 38,449 | 838,166 |
| **Time Span** | 3.7 years | 14.2 years | 10 years | 13 years |
| **Banks** | 53 | 19 | 27 | ❌ None |
| **Bank Types** | 3 types | 4 types | 3 types | ❌ N/A |
| **Size Detail** | ❌ No | ✅ 5 sizes | ❌ No | ✅ 5 sizes |
| **Geography** | ❌ No | ❌ No | ❌ No | ✅ 27 states |
| **Sectors** | ❌ No | ❌ No | ❌ No | ✅ 8 sectors |
| **Products** | 1 (L/C) | 1 (TF credit) | ✅ 9 types | ✅ 4 modalities |
| **Unique Strength** | Recent + Nearshoring | Longest + Size | 40 accounts | Regional + Sector |
| **Key Limitation** | Short series | No products | 2022 break | No banks |

---

## 🔬 METHODOLOGY HIGHLIGHTS

### Banking Data Processing

Each country has specific ETL scripts in `banca-desarrollo/{country}/`:
- **Mexico:** `mexico_enhanced_etl.R` - Extracts L/C (202401504003) + Total Liabilities
- **Peru:** `peru_etl.R` - Filters foreign-trade credit by size
- **Chile:** `chile_etl.R` - Handles SBIF→CMF transition (2022)
- **Brazil:** `brasil_etl.R` - Aggregates by state/sector/size

Master processing: `scripts/01_master_processing.R`
- Standardizes column names across countries
- Classifies banks (Foreign/Domestic/State)
- Adds GMD trade data
- Saves country-specific RDS files

### Trade Data Integration (GMD Only)

**Decision:** Use GMD exclusively (not BACI mix)
- **BACI issue:** Would create discontinuities when transitioning to GMD
- **GMD advantage:** Consistent BOP methodology across all years
- **Coverage:** 2020-2024 for all countries (covers all banking periods)
- **GDP:** Annual values (no monthly interpolation - no artificial data)

Integration script (pending): `scripts/00_integrate_gmd.R`
- Merges GMD with processed banking data
- Adds: exports_usd_millions, imports_usd_millions, gdp_usd_billions
- Calculates: TF as % of annual GDP (normalized metric)
- Adds crisis indicators

### Chile Special Case: Accounting Plan Change (2022)

**Challenge:** Chile changed accounting standards January 2022
- **Old system (2015-2021):** SBIF, 7-9 digit codes, 11 TF accounts identified
- **New system (2022-2024):** CMF/IFRS 9, 9-digit codes, 29 TF accounts identified
- **Code overlap:** 0% (complete re-numbering)

**Solution:** Direct account code mapping
- 2015-2021: Use 11 SBIF codes directly
- 2022-2024: Use 29 CMF codes directly
- Result: Complete 10-year series (38,449 observations)
- Note: Volume jump 2021→2022 reflects better identification, not real growth

**See:** `README_CHILE_DATA.md` for full methodology

---

## 📊 KEY FINDINGS

### 1. Nearshoring Effect (Mexico)
- **2023 avg:** USD 355M/month
- **2024 avg:** USD 710M/month
- **Growth:** +100% year-over-year
- **Peak:** June 2024 (USD 729M)

### 2. Size Distribution (Peru & Brazil)
- **Corporate dominance:** 45% (Peru), 26% (Brazil)
- **Medium enterprises:** Backbone of TF (18% Peru, 54% Brazil)
- **Micro access:** Limited (2% Peru, 4% Brazil)
- **Pattern:** Stable over time, inequality persistent

### 3. Product Composition (Chile)
- **Foreign funding:** 25% (external credit lines)
- **Import financing:** 15%
- **Export financing:** 12%
- **Guarantees:** 10%
- **L/C:** 8% (small share)

### 4. Regional Inequality (Brazil)
- **Southeast + South:** 81% of total TF
- **North region:** Only 2.2%
- **Top 5 states:** 72% of total TF
- **Gini coefficient:** ~0.58 (high concentration)

### 5. Bank Concentration (3 countries)
- **Mexico:** CR5 = 65%, foreign banks dominate
- **Peru:** CR5 = 80%, BCP + Scotiabank lead
- **Chile:** CR5 = 72%, Banco de Chile + Santander

---

## 📁 PROJECT STRUCTURE

```
country_analysis/
│
├── 📄 README.md                     ← YOU ARE HERE (project overview)
│
├── 🇲🇽 README_MEXICO_DATA.md        ← Mexico: 53 banks, L/C intensity
├── 🇵🇪 README_PERU_DATA.md          ← Peru: 5 sizes, 14.25 years
├── 🇨🇱 README_CHILE_DATA.md         ← Chile: 40 accounts, SBIF→CMF empalme
├── 🇧🇷 README_BRAZIL_DATA.md        ← Brazil: 27 states, 8 sectors
│
├── data/
│   ├── GMD.csv                      ← Global Macro Database (trade/GDP)
│   ├── mexico_full.csv              ← Mexico source (2,204 obs) - GMD updated
│   ├── peru_full.csv                ← Peru source (96,495 obs) - GMD updated
│   ├── chile_full.csv               ← Chile source (762,687 obs) - GMD updated
│   ├── brasil_full.csv              ← Brazil source (838,166 obs) - GMD updated
│   └── processed/
│       ├── mexico_processed.rds     ← Ready for analysis
│       ├── peru_processed.rds       ← Ready for analysis
│       ├── chile_processed.rds      ← Ready for analysis
│       └── brasil_processed.rds     ← Ready for analysis
│
├── scripts/
│   ├── update_csvs_with_gmd.R       ← Update CSVs with GMD data ✅
│   ├── 01_master_processing.R       ← Data loading + standardization ✅
│   ├── 00_integrate_gmd.R           ← GMD integration (pending)
│   ├── 02_mexico_analysis.R         ← 10 Mexico plots (pending)
│   ├── 03_peru_analysis.R           ← 8 Peru plots (pending)
│   ├── 04_chile_analysis.R          ← 8 Chile plots (pending)
│   ├── 05_brazil_analysis.R         ← 8 Brazil plots (pending)
│   ├── 06_comparison.R              ← 6 comparison plots (pending)
│   └── 07_integrated_report.R       ← HTML report generation (pending)
│
├── plots/                           ← Generated plots (42 total planned)
├── tables/                          ← LaTeX tables for publication
├── reports/                         ← HTML reports
│
└── docs_archive/                    ← Old documentation (archived)
    ├── CHILE_PLAN_CONTABLE_ISSUE.md
    ├── COUNTRY_DATA_OVERVIEW.md
    ├── DATA_EXPLORATION_FINDINGS.md
    ├── DOCUMENTATION_INDEX.md
    ├── GMD_INTEGRATION_FINDINGS.md
    ├── MASTER_ANALYSIS_PLAN.md
    ├── METHODOLOGICAL_UPDATE.md
    ├── MEXICO_ADDITIONAL_DATA_FINDINGS.md
    ├── MEXICO_ETL_DOCUMENTATION.md
    └── README_DATA.md
```

---

## 🎯 RESEARCH QUESTIONS

### Bank-Level Analysis (Mexico, Peru, Chile)
- How concentrated is trade finance lending?
- Do foreign banks specialize in trade finance?
- What drives L/C intensity differences across banks?
- How did nearshoring affect bank strategies (Mexico)?

### Size Distribution (Peru, Brazil)
- Do SMEs access trade finance?
- Has size distribution changed over time?
- Why do medium enterprises dominate TF?
- Is there size mobility in TF access?

### Product Analysis (Chile)
- What share is L/C vs other instruments?
- Export vs import financing patterns?
- How important are guarantees and foreign funding?
- Did product mix change with IFRS 9 (2022)?

### Regional Patterns (Brazil)
- Which states dominate trade finance?
- Is TF concentration increasing or decreasing?
- How does sectoral composition vary by region?
- What explains North-South TF gap?

### Crisis Impacts (All Countries)
- How did COVID-19 affect TF volumes?
- Did China slowdown impact Peru/Brazil (2015-16)?
- Political instability effects (Peru 2022, Chile 2019)?
- Nearshoring boost quantification (Mexico 2023-24)?

### Macro Integration (All Countries)
- TF as % of GDP trends?
- Correlation with export/import volumes?
- Crisis recovery patterns?
- Trade openness and TF access?

---

## 📊 PLANNED ANALYSIS (42 Plots)

### Mexico (10 plots)
1. L/C evolution (dual-axis: USD + % of liabilities)
2. L/C by bank type (box plots)
3. Top 10 banks by L/C intensity (bar chart)
4. Concentration metrics (HHI + CR5 time series)
5. Nearshoring effect (2023 vs 2024 comparison)
6. L/C vs Trade scatter (with trend line)
7. Market share evolution (stacked area)
8. Bank type composition (pie chart)
9. Seasonality patterns (heatmap)
10. Triple-axis: L/C vs GDP vs Trade

### Peru (8 plots)
1. TF % of total credit (time series + crisis overlays)
2. TF by borrower size (stacked area)
3. TF by bank type (box plots)
4. Concentration dynamics (HHI + CR5)
5. Size distribution (5-panel facets: Corp/Large/Med/Small/Micro)
6. TF vs GDP growth (scatter with correlation)
7. Crisis periods detailed (indexed 2019=100)
8. Bank specialization (heatmap: bank × size)

### Chile (8 plots)
1. TF % of total loans (2015-2024 with 2022 break)
2. Export vs Import financing (dual-line)
3. L/C evolution (stacked bars: export/import/third-party)
4. Foreign funding (line + % of TF)
5. Concentration metrics (HHI + CR5)
6. 40-account breakdown (small multiples)
7. Third-party trade (time series)
8. Guarantees evolution (stacked area)

### Brazil (8 plots)
1. Top 10 states (faceted time series)
2. 8 sectors (stacked area)
3. 5 sizes (stacked area, compare with Peru)
4. State × Sector heatmap (2024 snapshot)
5. Regional Gini inequality (time series)
6. North vs South comparison (dual-panel)
7. Manufacturing vs Services (dual-line)
8. Modality evolution (ACC/ACE/FINIMP/NCE)

### Cross-Country (6 plots)
1. TF intensity 3-country comparison (MEX/PER/CHL)
2. Concentration comparison (HHI + CR5 all 3)
3. Size distribution Peru vs Brazil
4. TF vs Trade scatter (all 4 countries)
5. Crisis impact indexed (2019=100, all countries)
6. Nearshoring proxy (Mexico vs others)

---

## 🚀 EXECUTION PLAN

### Phase 1: Data Preparation ✅ COMPLETE
- [x] Create folder structure
- [x] Extract and document all 4 countries
- [x] Update CSVs with GMD data (no BACI mix)
- [x] Master processing script (01_master_processing.R)
- [x] Documentation (5 READMEs)

### Phase 2: GMD Integration (Current)
- [ ] Create 00_integrate_gmd.R
- [ ] Merge GMD with processed RDS files
- [ ] Add: exports, imports, GDP (annual)
- [ ] Calculate: TF/GDP ratios
- [ ] Add crisis indicators

### Phase 3: Country Analysis
- [ ] Mexico analysis (02_mexico_analysis.R) - 10 plots
- [ ] Peru analysis (03_peru_analysis.R) - 8 plots
- [ ] Chile analysis (04_chile_analysis.R) - 8 plots
- [ ] Brazil analysis (05_brazil_analysis.R) - 8 plots

### Phase 4: Comparison & Report
- [ ] Cross-country comparison (06_comparison.R) - 6 plots
- [ ] Integrated report (07_integrated_report.R) - HTML
- [ ] LaTeX tables for publication (7 tables)
- [ ] Master run_all.R script

---

## 📊 DATA QUALITY

### Strengths
✅ **Official sources:** All data from regulatory agencies (mandatory reporting)  
✅ **Large N:** 892K observations across 4 countries  
✅ **Long series:** Peru 14.2 years, Brazil 13 years  
✅ **Bank detail:** 99 unique banks (MEX 53, PER 19, CHL 27)  
✅ **Size detail:** Peru & Brazil (5 categories each)  
✅ **Product detail:** Chile (40 accounts), Brazil (4 modalities)  
✅ **Geographic detail:** Brazil (27 states, 5 regions)  
✅ **Recent data:** Mexico through August 2025  
✅ **Consistent trade data:** GMD only (no BACI discontinuities)  

### Limitations
⚠️ **Mexico short series:** Only 3.67 years (2022-2025)  
⚠️ **Brazil no banks:** State/sector/size only, no individual institutions  
⚠️ **Chile structural break:** Accounting change 2022 (SBIF→CMF)  
⚠️ **GDP frequency:** Annual only (no monthly interpolation)  
⚠️ **Different TF definitions:** Not standardized across countries  
⚠️ **Currency volatility:** BRL, CLP high depreciation (2010-2024)  
⚠️ **Limited overlap:** Common period 2022-2023 only (2 years)  

---

## 📚 CITATION

If you use this data or analysis, please cite:

```
Fernández, T. (2025). LATAM Trade Finance Comparative Analysis: 
Mexico, Peru, Chile, and Brazil (2010-2025). 
Data sources: CNBV, SBS, CMF, BCB, Global Macro Database.
```

---

## 📧 CONTACT & UPDATES

**Project Lead:** Tomás Fernández  
**Repository:** `Trade-Finance/country_analysis/`  
**Last Updated:** November 2025  
**Status:** Data processing complete, analysis starting

**For questions:**
- Data methodology: See country-specific READMEs
- Chile accounting issue: See `README_CHILE_DATA.md` § Accounting Transition
- Trade data: GMD methodology documented in all READMEs
- Analysis plans: See `docs_archive/MASTER_ANALYSIS_PLAN.md`

---

## 🔄 CHANGE LOG

**November 2025:**
- ✅ Updated all CSVs with GMD data only (removed BACI mix)
- ✅ Fixed Chile 2015-2021 data capture (SBIF→CMF empalme)
- ✅ Consolidated documentation to 5 READMEs
- ✅ GDP as annual variable (no interpolation)
- ✅ Created update_csvs_with_gmd.R script
- ✅ All 4 countries processed and ready

**Next:**
- Create 00_integrate_gmd.R (merge GMD with RDS files)
- Start country-specific analysis scripts
- Generate plots and reports

---

*For detailed country-specific information, see README_{COUNTRY}_DATA.md files.*
