# 📑 DATA DOCUMENTATION INDEX

Quick navigation guide for country_analysis data documentation.

---

## 🎯 START HERE

**New to the project?** Read in this order:
1. 📊 [**COUNTRY_DATA_OVERVIEW.md**](COUNTRY_DATA_OVERVIEW.md) - Executive summary (all 4 countries)
2. 🗺️ [**MASTER_ANALYSIS_PLAN.md**](MASTER_ANALYSIS_PLAN.md) - 42 plots specification
3. 🌍 [**GMD_INTEGRATION_FINDINGS.md**](GMD_INTEGRATION_FINDINGS.md) - Trade data methodology

Then dive into individual country docs as needed.

---

## 📚 COUNTRY-SPECIFIC DOCUMENTATION

### 🇲🇽 Mexico
- **File:** [README_MEXICO_DATA.md](README_MEXICO_DATA.md)
- **Size:** 8.4 KB (235 lines, 28 sections)
- **Coverage:** 2022-2025 (3.7 years), 53 banks
- **Focus:** Bank-level L/C analysis, nearshoring effect
- **Unique:** L/C intensity metric (% of total liabilities)

**Key Sections:**
- Data structure (12 variables)
- Bank classification (Foreign/Large/Other - 10/9/34)
- CNBV R12A account details (202401504003)
- BACI (2022-2023) + GMD (2024-2025) trade data
- Nearshoring findings (100% growth 2023→2024)
- Limitations (short series, single L/C type)

---

### 🇵🇪 Peru
- **File:** [README_PERU_DATA.md](README_PERU_DATA.md)
- **Size:** 11 KB (287 lines, 34 sections)
- **Coverage:** 2010-2024 (14.25 years), 19 banks
- **Focus:** Size distribution, longest time series
- **Unique:** 5 borrower size categories (Corporate to Micro)

**Key Sections:**
- Size classification (SBS standard with UIT thresholds)
- Bank types (Foreign/State/Large/Consumer - 5/0/2/3)
- SBS Credit Registry methodology
- BACI (2010-2023) + GMD (2024) trade data
- Crisis impacts (China slowdown, COVID, political)
- Size distribution analysis (Corporate 45%, Micro 2%)

---

### 🇨🇱 Chile
- **File:** [README_CHILE_DATA.md](README_CHILE_DATA.md)
- **Size:** 15 KB (389 lines, 37 sections)
- **Coverage:** 2015-2024 (10 years), 27 banks
- **Focus:** Product-level detail, accounting transition
- **Unique:** 40 TF account codes (9 categories)

**Key Sections:**
- ⚠️ **CRITICAL:** Accounting plan change 2022 (SBIF → CMF/IFRS 9)
- Empalme methodology (11 old codes + 29 new codes)
- 9 TF categories (L/C, Export/Import financing, Guarantees, etc.)
- CMF balance sheet account details
- BACI (2015-2023) + GMD (2024) trade data
- Fix documentation (direct account code mapping)

**Related:** [CHILE_PLAN_CONTABLE_ISSUE.md](CHILE_PLAN_CONTABLE_ISSUE.md) - Full diagnostic (6.2 KB)

---

### 🇧🇷 Brazil
- **File:** [README_BRAZIL_DATA.md](README_BRAZIL_DATA.md)
- **Size:** 16 KB (396 lines, 40 sections)
- **Coverage:** 2012-2024 (13 years), 27 states
- **Focus:** Regional & sectoral analysis (no banks)
- **Unique:** 27 states, 8 sectors, 4 TF modalities

**Key Sections:**
- Geographic regions (5: Southeast, South, Center-West, Northeast, North)
- Economic sectors (Manufacturing 55%, Wholesale 30%, Agriculture 5%)
- Size distribution (Medium 53.5%, Large 26.4%)
- TF modalities (ACC 42%, ACE 28%, FINIMP 25%, NCE 5%)
- BCB SCR system methodology
- BACI (2012-2023) + GMD (2024) trade data
- Regional inequality analysis

---

## 🔬 TECHNICAL DOCUMENTATION

### Trade Data Integration
- **File:** [GMD_INTEGRATION_FINDINGS.md](GMD_INTEGRATION_FINDINGS.md)
- **Size:** 14.8 KB
- **Content:**
  - BACI vs GMD methodology comparison
  - Coverage: BACI through 2023, GMD for 2024+
  - Differences: GMD exports ~6% higher, imports ~28% higher (BOP vs customs)
  - All 4 countries validation (2020-2024)
  - Empalme strategy documentation

### Chile Accounting Fix
- **File:** [CHILE_PLAN_CONTABLE_ISSUE.md](CHILE_PLAN_CONTABLE_ISSUE.md)
- **Size:** 6.2 KB
- **Content:**
  - Problem: SBIF → CMF transition Jan 2022 (0% code overlap)
  - Diagnostic: ETL mis-categorized 2015-2021 as "otros"
  - Solution: Direct account code mapping (bypass ETL)
  - Result: 38,449 obs captured (19,657 old + 18,792 new)
  - 11 SBIF codes + 29 CMF codes documented

### Analysis Master Plan
- **File:** [MASTER_ANALYSIS_PLAN.md](MASTER_ANALYSIS_PLAN.md)
- **Size:** 50 KB
- **Content:**
  - 42 plots specification (10 MEX + 8 PER + 8 CHL + 8 BRA + 6 comparison + 2 extras)
  - Each plot: Rationale, data, specifications, interpretation
  - Priority tiers (TIER 1-3)
  - Execution order and dependencies

---

## 📊 QUICK COMPARISON TABLE

| Aspect | Mexico | Peru | Chile | Brazil |
|--------|--------|------|-------|--------|
| **Documentation** | 8.4 KB | 11 KB | 15 KB | 16 KB |
| **Sections** | 28 | 34 | 37 | 40 |
| **Observations** | 2,204 | 13,785 | 38,449 | 838,166 |
| **Time Period** | 2022-2025 | 2010-2024 | 2015-2024 | 2012-2024 |
| **Duration** | 3.7 years | 14.2 years | 10 years | 13 years |
| **Banks** | 53 | 19 | 27 | ❌ None |
| **Bank Types** | 3 | 4 | 3 | ❌ N/A |
| **Size Detail** | ❌ No | ✅ 5 sizes | ❌ No | ✅ 5 sizes |
| **Geography** | ❌ No | ❌ No | ❌ No | ✅ 27 states |
| **Sectors** | ❌ No | ❌ No | ❌ No | ✅ 8 sectors |
| **Products** | 1 L/C | 1 TF credit | ✅ 9 types | ✅ 4 modalities |
| **Trade Data** | BACI+GMD | BACI+GMD | BACI+GMD | BACI+GMD |
| **Key Strength** | Recent + Intensity | Longest + Size | 40 accounts | Geographic + Sector |

---

## 🎯 USE CASES

### Bank-Level Analysis
→ Read: Mexico + Peru + Chile (all have bank detail)
- Concentration (HHI, CR5)
- Foreign vs Domestic strategies
- Market shares

### Size Distribution
→ Read: Peru + Brazil (both have 5 size categories)
- Corporate dominance vs SME access
- Size mobility
- Medium enterprises as backbone (~50% in both)

### Product Analysis
→ Read: Chile (most detailed - 40 accounts, 9 categories)
- L/C vs non-L/C
- Export vs Import financing
- Guarantees and off-balance items

### Regional Analysis
→ Read: Brazil (only country with geographic detail)
- State-level TF intensity
- Regional inequality (Gini)
- North vs South development gap
- Sector specialization by region

### Time Series & Trends
→ Read: Peru (longest - 14.25 years) + Brazil (13 years)
- Long-term trends
- Multiple crisis periods
- Structural changes

### Recent Phenomena
→ Read: Mexico (most recent - through Aug 2025)
- Nearshoring effect (2023→2024)
- Post-pandemic recovery
- Current state of TF

---

## 🔗 NAVIGATION TIPS

### By Research Question
- **"How concentrated is TF?"** → Mexico/Peru/Chile READMEs (have bank-level)
- **"Do SMEs access TF?"** → Peru/Brazil READMEs (have size detail)
- **"What TF products are used?"** → Chile README (40 accounts) + Brazil README (4 modalities)
- **"Regional patterns?"** → Brazil README (27 states, 5 regions)
- **"Crisis impacts?"** → Peru README (3 crises) + Brazil README (6 crises)
- **"Nearshoring effect?"** → Mexico README (2023→2024 analysis)

### By Data Source
- **CNBV (Mexico):** → README_MEXICO_DATA.md § Data Source Details
- **SBS (Peru):** → README_PERU_DATA.md § Banking Data
- **CMF (Chile):** → README_CHILE_DATA.md § Data Source Details + CHILE_PLAN_CONTABLE_ISSUE.md
- **BCB (Brazil):** → README_BRAZIL_DATA.md § Banking Data: SCR System

### By Trade Data
- **BACI methodology:** → GMD_INTEGRATION_FINDINGS.md § BACI Database
- **GMD methodology:** → GMD_INTEGRATION_FINDINGS.md § Global Macro Database
- **Empalme (transition):** → All country READMEs § Trade Data: Dual Sources

---

## 📁 FILE STRUCTURE

```
country_analysis/
│
├── 📑 DOCUMENTATION_INDEX.md          ← YOU ARE HERE
├── 📊 COUNTRY_DATA_OVERVIEW.md        ← Start here (executive summary)
│
├── 🇲🇽 README_MEXICO_DATA.md          ← Mexico technical docs
├── 🇵🇪 README_PERU_DATA.md            ← Peru technical docs
├── 🇨🇱 README_CHILE_DATA.md           ← Chile technical docs
├── 🇧🇷 README_BRAZIL_DATA.md          ← Brazil technical docs
│
├── 🌍 GMD_INTEGRATION_FINDINGS.md     ← Trade data methodology (BACI vs GMD)
├── 🗺️ MASTER_ANALYSIS_PLAN.md        ← 42 plots specification
├── 🔧 CHILE_PLAN_CONTABLE_ISSUE.md   ← Chile accounting fix
│
├── data/                              ← Source CSV files
│   ├── brasil_full.csv
│   ├── chile_full.csv
│   ├── mexico_full.csv
│   ├── peru_full.csv
│   └── processed/                     ← Processed RDS files (ready)
│       ├── brasil_processed.rds
│       ├── chile_processed.rds
│       ├── mexico_processed.rds
│       └── peru_processed.rds
│
└── scripts/                           ← Analysis scripts
    ├── 01_master_processing.R         ✅ Complete
    ├── 00_integrate_gmd.R             ⏳ Pending
    ├── 02_mexico_analysis.R           ⏳ Pending
    ├── 03_peru_analysis.R             ⏳ Pending
    ├── 04_chile_analysis.R            ⏳ Pending
    ├── 05_brazil_analysis.R           ⏳ Pending
    ├── 06_comparison.R                ⏳ Pending
    └── 07_integrated_report.R         ⏳ Pending
```

---

## 📊 DOCUMENTATION METRICS

**Total documentation:** 60.4 KB across 5 main files

| File | Lines | Sections | Size | Focus |
|------|-------|----------|------|-------|
| COUNTRY_DATA_OVERVIEW | 439 | 51 | 17 KB | Executive summary, all 4 countries |
| README_BRAZIL_DATA | 396 | 40 | 16 KB | Regional/sectoral, 27 states, 8 sectors |
| README_CHILE_DATA | 389 | 37 | 15 KB | Product detail, 40 accounts, accounting fix |
| README_PERU_DATA | 287 | 34 | 11 KB | Size distribution, 14.25 years, crisis analysis |
| README_MEXICO_DATA | 235 | 28 | 8.4 KB | Recent data, nearshoring, L/C intensity |

**Supporting documentation:** 71.0 KB
- MASTER_ANALYSIS_PLAN.md: 50 KB (42 plots)
- GMD_INTEGRATION_FINDINGS.md: 14.8 KB (trade data)
- CHILE_PLAN_CONTABLE_ISSUE.md: 6.2 KB (accounting fix)

**Total project documentation:** 131.4 KB

---

## ✅ COMPLETION STATUS

### Documentation ✅ Complete
- [x] Mexico README (8.4 KB, 28 sections)
- [x] Peru README (11 KB, 34 sections)
- [x] Chile README (15 KB, 37 sections)
- [x] Brazil README (16 KB, 40 sections)
- [x] Executive overview (17 KB, 51 sections)
- [x] GMD integration guide (14.8 KB)
- [x] Chile accounting fix (6.2 KB)
- [x] Master analysis plan (50 KB, 42 plots)
- [x] Documentation index (this file)

### Data Processing ✅ Complete
- [x] 01_master_processing.R (all 4 countries)
- [x] Mexico: 2,204 obs ready
- [x] Peru: 13,785 obs ready
- [x] Chile: 38,449 obs ready (SBIF+CMF empalme)
- [x] Brazil: 838,166 obs ready

### Next Phase ⏳ Pending
- [ ] 00_integrate_gmd.R (GMD data integration)
- [ ] Analysis scripts (02-06)
- [ ] Report generation (07)

---

## 📧 QUESTIONS?

**Can't find something?** Check:
1. This index (search by keyword)
2. COUNTRY_DATA_OVERVIEW.md (executive summary)
3. Individual country READMEs (detailed technical docs)

**Need help with:**
- **Trade data methodology:** → GMD_INTEGRATION_FINDINGS.md
- **Chile accounting issue:** → CHILE_PLAN_CONTABLE_ISSUE.md
- **Analysis plan:** → MASTER_ANALYSIS_PLAN.md
- **Specific country:** → README_{COUNTRY}_DATA.md

**Contact:** Tomás Fernández | November 2025

---

*Last Updated: November 2025 | All documentation complete and up-to-date*
