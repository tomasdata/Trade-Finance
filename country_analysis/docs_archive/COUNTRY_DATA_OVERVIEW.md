# 📊 COUNTRY DATA OVERVIEW - EXECUTIVE SUMMARY

**Project:** LATAM Trade Finance Comparative Analysis  
**Countries:** Mexico 🇲🇽 | Peru 🇵🇪 | Chile 🇨🇱 | Brazil 🇧🇷  
**Date:** November 2025  
**Status:** Data processing complete, ready for analysis

---

## 🎯 QUICK REFERENCE

| Country | Observations | Time Period | Banks | Granularity | Key Strength |
|---------|--------------|-------------|-------|-------------|--------------|
| **Mexico** | 2,204 | 2022-2025 (3.7y) | 53 | Bank-Month | Recent + L/C intensity |
| **Peru** | 13,785 | 2010-2024 (14.2y) | 19 | Bank-Month-Size | Longest + Size detail |
| **Chile** | 38,449 | 2015-2024 (10y) | 27 | Bank-Month-Account | 40 TF accounts |
| **Brazil** | 838,166 | 2012-2024 (13y) | ❌ | State-Sector-Size | Geographic + Sectoral |

**Total Dataset:** 892,604 observations across 4 countries

---

## 🔍 DATA SOURCES

### Banking Data (Regulatory)

| Country | Regulator | Source System | Report Type |
|---------|-----------|---------------|-------------|
| **Mexico** | CNBV | R12A Balance Sheets | Account 202401504003 (Import L/C ≤180 days) |
| **Peru** | SBS | Credit Registry | "Créditos por Liquidar por Comercio Exterior" |
| **Chile** | CMF (ex-SBIF) | Individual Balance Sheets | 40 accounts (11 SBIF + 29 CMF codes) |
| **Brazil** | BCB | SCR System | ACC, ACE, FINIMP, NCE modalities |

### Trade Data (Dual Sources)

**BACI Database (CEPII)**
- Coverage: Through 2023 for all countries
- Methodology: Harmonized HS6 from UN COMTRADE
- Used for: Long historical series (2010/2012-2023)

**Global Macro Database (GMD) - FMI/World Bank**
- Coverage: 2024 onwards for all countries
- Methodology: Balance of Payments (BOP) statistics
- Used for: Recent data + GDP normalization
- Note: GMD exports ~6% higher, imports ~28% higher vs BACI (BOP vs customs)

**Empalme Strategy:**
- ✅ BACI through 2023 (detailed, product-level)
- ✅ GMD for 2024-2025 (fills gap, includes GDP)
- ✅ Both validated against national statistics

---

## 🇲🇽 MEXICO: Bank-Level L/C Analysis

### Data Characteristics
- **Period:** Jan 2022 - Aug 2025 (44 months)
- **Coverage:** 53 banks, complete monthly series
- **Variable:** Import Letters of Credit (≤180 days commercial)
- **Volume:** USD 20.86 billion cumulative (44 months)
- **Enhancement:** L/C as % of total liabilities (intensity metric)

### Bank Classification
- **Foreign (10):** BBVA, Santander, Citi, HSBC, JP Morgan, etc.
- **Large Domestic (9):** Banorte, Inbursa, Afirme, etc.
- **Other Domestic (34):** Regional and specialized banks

### Key Features
- ✅ Recent data through Aug 2025
- ✅ Enhanced with total liabilities (L/C intensity)
- ✅ BACI trade 2022-2023, GMD 2024-2025
- ✅ Nearshoring effect visible (100% growth 2023→2024)
- ⚠️ Short time series (only 3.67 years)
- ⚠️ Single L/C type (import ≤180 days only)

### Recommended Analysis
- L/C intensity by bank type (Foreign vs Domestic)
- Nearshoring impact quantification (2023→2024 jump)
- Concentration analysis (HHI, CR5)
- Trade-TF correlation (with GMD data)

**See:** `README_MEXICO_DATA.md` for full technical documentation

---

## 🇵🇪 PERU: Size Distribution Pioneer

### Data Characteristics
- **Period:** Oct 2010 - Dec 2024 (171 months, 14.25 years)
- **Coverage:** 19 banks × 5 size categories × monthly
- **Variable:** Foreign-trade credit (all TF instruments)
- **Volume:** USD 859 billion cumulative (14.25 years)
- **Unique:** Borrower size detail (Corporate/Large/Medium/Small/Micro)

### Size Categories (SBS Standard)
- **Corporate (45%):** > USD 37M annual sales
- **Large (25%):** USD 7.5M - 37M
- **Medium (18%):** USD 2.5M - 7.5M
- **Small (10%):** USD 450K - 2.5M
- **Micro (2%):** USD 30K - 450K

### Bank Classification
- **Foreign (5):** Scotiabank, Citibank, ICBC, Santander, BanBif
- **Large Domestic (2):** BCP, BBVA Continental
- **Consumer/Retail (3):** Interbank, Pichincha, Mibanco

### Key Features
- ✅ Longest time series (14.25 years)
- ✅ Size detail (unique among 4 countries)
- ✅ 3 crisis periods captured (China slowdown, COVID, political)
- ✅ BACI trade 2010-2023, GMD 2024
- ⚠️ No product breakdown (cannot separate L/C vs other TF)
- ⚠️ Size based on total credit, not TF-specific

### Recommended Analysis
- Size distribution over time (corporate dominance vs SME access)
- Bank specialization (Foreign trade-focused, Consumer minimal TF)
- Crisis impact quantification (2015-16, 2020, 2022)
- Size mobility and concentration dynamics

**See:** `README_PERU_DATA.md` for full technical documentation

---

## 🇨🇱 CHILE: Product-Level Detail Champion

### Data Characteristics
- **Period:** Jan 2015 - Dec 2024 (120 months, 10 years)
- **Coverage:** 27 banks, 40 TF account codes
- **Variable:** 9 TF categories (L/C, Export/Import financing, Guarantees, etc.)
- **Volume:** 38,449 bank-month-account observations
- **Challenge:** Accounting plan change 2022 (SBIF → CMF/IFRS 9)

### ⚠️ CRITICAL: Accounting Transition (Jan 2022)
| Aspect | Period 1 (2015-2021) | Period 2 (2022-2024) |
|--------|----------------------|----------------------|
| System | SBIF (7-9 digit codes) | CMF/IFRS 9 (9 digits) |
| Accounts | 11 identified | 29 identified |
| Observations | 19,657 (7 years) | 18,792 (3 years) |
| Code Overlap | **0%** (complete re-numbering) | - |

**Empalme Solution:**
- Direct account code mapping (bypass ETL categorization issue)
- 2015-2021: 11 SBIF codes (1270116-1270118, 1302200-1302242, etc.)
- 2022-2024: 29 CMF codes (145400200-145400205, 143200104-106, etc.)
- Result: Complete 10-year series, both periods captured

### TF Categories (9 types)
1. **Letters of Credit** (8%): Import/export L/C
2. **Export Financing** (12%): Advance on exports
3. **Import Financing** (15%): Import payments
4. **Foreign Funding** (25%): External trade credit lines
5. **Guarantees** (10%): Trade guarantees, stand-by L/C
6. **Third-Party Trade** (8%): Triangular operations
7. **Interbank Foreign** (12%): Inter-bank TF
8. **Trade Finance General** (5%): Parent accounts
9. **Other TF** (5%): Miscellaneous

### Bank Classification
- **Foreign (5):** Scotiabank, Citibank, ICBC, JPMorgan, BNP Paribas
- **State (1):** Banco Estado (largest retail bank)
- **Large Domestic (8):** Banco de Chile, Santander Chile, BCI, etc.

### Key Features
- ✅ 40 TF accounts (most detailed among 4 countries)
- ✅ Product breakdown (L/C, factoring, guarantees, funding)
- ✅ 10-year series with successful SBIF→CMF empalme
- ✅ BACI trade 2015-2023, GMD 2024
- ⚠️ Structural break 2022 (accounting change)
- ⚠️ No borrower size or sector detail

### Recommended Analysis
- Product composition (L/C vs non-L/C, export vs import)
- Foreign funding evolution (external credit lines)
- Guarantee market analysis (off-balance items)
- Accounting transition impact (2021→2022 volume jump)

**See:** `README_CHILE_DATA.md` + `CHILE_PLAN_CONTABLE_ISSUE.md` for full documentation

---

## 🇧🇷 BRAZIL: Regional & Sectoral Analysis Giant

### Data Characteristics
- **Period:** Jan 2012 - Dec 2024 (156 months, 13 years)
- **Coverage:** 27 states × 8 sectors × 5 sizes × 4 modalities
- **Variable:** TF credit (ACC, ACE, FINIMP, NCE)
- **Volume:** USD 6.94 trillion cumulative (13 years)
- **Unique:** Geographic + Sectoral detail (no individual banks)

### Geographic Regions
| Region | States | % of TF | Key Profile |
|--------|--------|---------|-------------|
| **Southeast** | SP, RJ, MG, ES | 43.7% | Industrial hub, ports |
| **South** | PR, SC, RS | 37.6% | Agriculture, manufacturing |
| **Center-West** | GO, MT, MS, DF | 6.3% | Agribusiness |
| **Northeast** | BA, PE, CE, etc. | 10.2% | Agriculture, textiles |
| **North** | PA, AM, etc. | 2.2% | Commodities, Amazon |

### Economic Sectors
1. **Manufacturing** (55%): Automotive, machinery, chemicals
2. **Wholesale/Retail** (30%): Trade distribution
3. **Agriculture** (5%): Soy, corn, livestock
4. **Transport/Logistics** (3%): Ports, shipping
5. **Mining, Construction, IT, Other** (7%): Various

### Size Categories (BCB Standard)
- **Medium (53.5%):** BRL 4.8M-300M revenue (~$940K-$58M USD)
- **Large (26.4%):** > BRL 300M (~$58M USD)
- **Small (15.6%):** BRL 360K-4.8M (~$70K-$940K)
- **Micro (4.0%):** < BRL 360K (~$70K)
- **Unknown (0.5%):** Not classified

### TF Modalities (BCB Instruments)
- **ACC (42%):** Pre-shipment export financing
- **ACE (28%):** Post-shipment export financing
- **FINIMP (25%):** Import financing
- **NCE (5%):** Export credit note

### Key Features
- ✅ 838,166 observations (largest dataset)
- ✅ 27 states (regional inequality analysis)
- ✅ 8 sectors (manufacturing vs agriculture)
- ✅ 4 TF modalities (unique to Brazil)
- ✅ 13-year series, 6 crisis periods
- ✅ BACI trade 2012-2023, GMD 2024
- ❌ No bank-level data (cannot analyze individual institutions)
- ❌ No concentration metrics (HHI, CR5 not calculable)

### Recommended Analysis
- Regional distribution (27 states, inequality metrics)
- Sectoral composition (manufacturing dominates 55%)
- Size distribution (compare with Peru)
- Modality evolution (ACC vs ACE trend)
- North vs South development gap
- Manufacturing vs Agriculture financing patterns

**See:** `README_BRAZIL_DATA.md` for full technical documentation

---

## 📊 COMPARATIVE MATRIX

### Data Granularity
| Feature | Mexico | Peru | Chile | Brazil |
|---------|--------|------|-------|--------|
| **Individual Banks** | ✅ 53 | ✅ 19 | ✅ 27 | ❌ None |
| **Bank Types** | ✅ 3 types | ✅ 4 types | ✅ 3 types | ❌ N/A |
| **Borrower Size** | ❌ No | ✅ 5 sizes | ❌ No | ✅ 5 sizes |
| **Geographic Detail** | ❌ No | ❌ No | ❌ No | ✅ 27 states |
| **Sectoral Detail** | ❌ No | ❌ No | ❌ No | ✅ 8 sectors |
| **Product Types** | 1 (L/C) | 1 (TF credit) | ✅ 9 types | ✅ 4 modalities |

### Time Coverage
| Country | Start | End | Duration | Crisis Periods Captured |
|---------|-------|-----|----------|-------------------------|
| **Peru** | Oct 2010 | Dec 2024 | **14.25 years** | China slowdown, COVID, Political (3) |
| **Brazil** | Jan 2012 | Dec 2024 | 13 years | Recession, Lava Jato, COVID, China boom (6) |
| **Chile** | Jan 2015 | Dec 2024 | 10 years | Social unrest, COVID (2) |
| **Mexico** | Jan 2022 | Aug 2025 | 3.67 years | Nearshoring (post-pandemic only) |

### Trade Data Integration
| Country | BACI Period | GMD Period | Transition |
|---------|-------------|------------|------------|
| **Mexico** | 2022-2023 | 2024-2025 | Smooth |
| **Peru** | 2010-2023 | 2024 | Smooth |
| **Chile** | 2015-2023 | 2024 | Smooth |
| **Brazil** | 2012-2023 | 2024 | Smooth |

---

## 🎯 ANALYTICAL OPPORTUNITIES

### Cross-Country Comparisons

**Bank-Level Analysis (Mexico, Peru, Chile):**
- Concentration dynamics (HHI, CR5)
- Foreign vs Domestic strategies
- Bank specialization patterns

**Size Distribution (Peru, Brazil):**
- Corporate dominance vs SME access
- Size mobility over time
- Medium enterprises as TF backbone (both ~50%)

**Product Mix (Chile only):**
- L/C vs non-L/C instruments
- Export vs Import financing
- Guarantee market evolution

**Regional Patterns (Brazil only):**
- Geographic inequality (Gini coefficient)
- State-level TF intensity
- North vs South development gap
- Sector specialization by region

**Crisis Impact (All countries):**
- COVID response (2020-2021)
- China demand effect (Peru, Brazil commodities)
- Nearshoring (Mexico 2023-2024)
- Political instability (Peru 2022, Chile 2019)

### Macro Integration (with GMD)
- TF as % of GDP (all countries)
- TF vs Trade correlation (exports + imports)
- Crisis periods overlay
- Trade openness indicators

---

## 🚨 DATA QUALITY & LIMITATIONS

### Strengths by Country
- 🇲🇽 **Mexico:** Most recent data (through Aug 2025), L/C intensity metric
- 🇵🇪 **Peru:** Longest series (14.25 years), size detail, crisis coverage
- 🇨🇱 **Chile:** Most product detail (40 accounts, 9 categories)
- 🇧🇷 **Brazil:** Geographic + sectoral detail, largest dataset (838K obs)

### Limitations by Country
- 🇲🇽 **Mexico:** Short series (3.67 years), single L/C type, no pre-COVID baseline
- 🇵🇪 **Peru:** No product breakdown, size from total credit not TF-specific
- 🇨🇱 **Chile:** Structural break 2022 (accounting change), no size/sector
- 🇧🇷 **Brazil:** No bank-level data, cannot analyze concentration or bank strategies

### Common Limitations
- ⚠️ Trade data transition: BACI (through 2023) → GMD (2024+), methodology differs (~6-28%)
- ⚠️ No standardized TF definition across countries
- ⚠️ Currency conversion volatility (BRL, CLP high depreciation)
- ⚠️ No common time period for all 4 countries (max overlap: 2015-2021)

---

## 📁 DOCUMENTATION STRUCTURE

```
country_analysis/
├── README_MEXICO_DATA.md      # 🇲🇽 Mexico technical docs (8.5 KB)
├── README_PERU_DATA.md        # 🇵🇪 Peru technical docs (10.2 KB)
├── README_CHILE_DATA.md       # 🇨🇱 Chile technical docs (12.8 KB)
├── README_BRAZIL_DATA.md      # 🇧🇷 Brazil technical docs (14.5 KB)
├── COUNTRY_DATA_OVERVIEW.md   # 📊 This executive summary
│
├── GMD_INTEGRATION_FINDINGS.md     # GMD vs BACI methodology (14.8 KB)
├── MASTER_ANALYSIS_PLAN.md         # 42 plots specification (50 KB)
├── CHILE_PLAN_CONTABLE_ISSUE.md    # Chile accounting fix (6.2 KB)
│
├── data/
│   ├── brasil_full.csv        # 838,166 obs (source)
│   ├── chile_full.csv         # 762,687 obs (source)
│   ├── mexico_full.csv        # 2,204 obs (source)
│   ├── peru_full.csv          # 96,495 obs (source)
│   └── processed/
│       ├── brasil_processed.rds    # 838,166 TF obs (ready)
│       ├── chile_processed.rds     # 38,449 TF obs (ready)
│       ├── mexico_processed.rds    # 2,204 L/C obs (ready)
│       └── peru_processed.rds      # 13,785 TF obs (ready)
│
└── scripts/
    ├── 01_master_processing.R      # Data loading + standardization ✅
    ├── 00_integrate_gmd.R          # GMD integration (pending)
    ├── 02_mexico_analysis.R        # 10 plots (pending)
    ├── 03_peru_analysis.R          # 8 plots (pending)
    ├── 04_chile_analysis.R         # 8 plots (pending)
    ├── 05_brazil_analysis.R        # 8 plots (pending)
    ├── 06_comparison.R             # 6 comparison plots (pending)
    └── 07_integrated_report.R      # HTML report generation (pending)
```

---

## 📈 DATASET STATISTICS

### Observation Counts
```
Mexico:     2,204 obs  (  0.2% of total)
Peru:      13,785 obs  (  1.5% of total)
Chile:     38,449 obs  (  4.3% of total)
Brazil:   838,166 obs  ( 93.9% of total)
────────────────────────────────────────
TOTAL:    892,604 obs  (100.0%)
```

### Time Coverage
```
Longest series:  Peru      (14.25 years, 171 months)
Second longest:  Brazil    (13 years, 156 months)
Medium length:   Chile     (10 years, 120 months)
Shortest:        Mexico    (3.67 years, 44 months)

Common overlap:  2015-2021 (7 years, 3 countries: Peru, Chile, Brazil)
Full overlap:    2022-2023 (2 years, all 4 countries)
```

### Bank Coverage
```
Total unique banks:  99 (Mexico 53 + Peru 19 + Chile 27 + Brazil 0)
Foreign banks:       20 unique across 3 countries
State banks:         2 (Peru 0, Chile 1, Brazil state-aggregated)
Large domestic:      19 unique
```

---

## 🎬 NEXT STEPS

### Immediate Priorities
1. ✅ **COMPLETED:** Data processing (all 4 countries, 892K obs ready)
2. ✅ **COMPLETED:** Documentation (4 READMEs + technical guides)
3. 🔄 **NEXT:** Create `00_integrate_gmd.R` (GMD data integration, GDP normalization)
4. 🔄 **NEXT:** Start analysis scripts (Mexico first, 10 plots)

### Analysis Sequence
1. **Mexico** (2,204 obs, newest data, nearshoring focus)
2. **Peru** (13,785 obs, size distribution, longest series)
3. **Chile** (38,449 obs, product detail, accounting transition)
4. **Brazil** (838K obs, regional/sectoral, largest dataset)
5. **Comparison** (6 plots across countries)
6. **Report** (40-50 pages, all countries integrated)

### Deliverables
- 🎨 **42 plots** total (10 MEX + 8 PER + 8 CHL + 8 BRA + 6 comparison + 2 extras)
- 📊 **7 LaTeX tables** for publication (summary stats, concentration, correlations, etc.)
- 📄 **HTML report** (~40-50 pages with all plots and tables)
- 📋 **Data appendices** (bank classifications, account mappings, GMD methodology)

---

## 📧 CONTACT

**Project Lead:** Tomás Fernández  
**Date:** November 2025  
**Repository:** `Trade-Finance/country_analysis/`  
**Status:** Data ready, analysis phase starting

**For detailed technical documentation, see individual country READMEs.**

---

*Last Updated: November 2025*
