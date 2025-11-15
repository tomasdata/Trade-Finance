# 🌎 Trade Finance Research Project - Latin America

## 📊 Project Overview

Comprehensive research analyzing **trade finance markets** across Latin America and global banking systems. This project integrates regulatory data, international trade statistics, and banking sector information to understand credit availability, market structure, and cross-country dynamics in trade financing.

**Period Covered**: 2010-2025 (varies by country)  
**Countries Analyzed**: Brazil 🇧🇷, Chile 🇨🇱, Mexico 🇲🇽, Peru 🇵🇪  
**Data Points**: 1.7+ million observations  
**Last Updated**: January 15, 2025  

---

## 📊 Project Status Dashboard

### ✅ **COMPLETED COMPONENTS**

#### 1️⃣ **Core Banking Databases - Harmonized & Processed**

| Country | Records | Period | Files | Analysis Outputs | Status |
|---------|---------|--------|-------|------------------|--------|
| 🇧🇷 **Brazil** | 838,167 | 2012-2024 (13y) | brasil_full.csv (220MB) | 9 CSV tables | ✅ **COMPLETE** |
| 🇨🇱 **Chile** | 762,687 | 2015-2024 (10y, 26y avail) | chile_full.csv (195MB) | 6 CSV tables | ✅ **COMPLETE** |
| 🇵🇪 **Peru** | 96,496 | 2010-2024 (14y) | peru_full.csv (22MB) | 8 CSV tables | ✅ **COMPLETE** |
| 🇲🇽 **Mexico** | ~5,000 | 2015-2019, 2022-2025 | 040_R12A_*.csv (129MB) | 7 CSV tables | ⚠️ **LC ONLY** |

**Processing Pipeline**: 4 ETL scripts (R) → 30 country-level analysis tables → Cross-country comparisons

---

#### 2️⃣ **FFIEC 009 - US Banks' International Exposure** ✅

- **39 quarterly Excel files** (2015Q2-2024Q4) → **78 cleaned datasets**
- **Pipeline**: `1_extract_raw.py` → `2_analyze_structure.py` → `3_clean_and_organize.py` → `4_validate_and_document.py`
- **Output**: 91 countries × 15 CSV tables per quarter
- **Validation**: 100% OCR accuracy verified
- **Documentation**: `FFIEC 009/README_PROCESAMIENTO.md`
- **Status**: ✅ **DATA PROCESSED** | ⏳ **LATAM ANALYSIS PENDING**

---

#### 3️⃣ **FCIB Trade Credit Survey** ✅

- **32 monthly PDFs** processed (Jan 2023 - Oct 2025)
- **125 records** × 14 variables → `fcib_credit_collections_panel.csv`
- **LATAM Countries**: Argentina 🇦🇷, Brazil 🇧🇷, Chile 🇨🇱, Colombia 🇨🇴, Costa Rica 🇨🇷, Ecuador 🇪🇨, Mexico 🇲🇽, Peru 🇵🇪
- **Indicators**: Sales mix, payment terms (5 buckets), avg days beyond terms, payment delays (4 categories)
- **Scripts**: `fcib_pdf_extract.py` + `fcib_pdf_extract_v2.py` (4 fallback strategies)
- **Status**: ✅ **COMPLETE** | ⚠️ Pre-2024 PDFs: partial extraction only

---

### ⏳ **IN PROGRESS**

#### 4️⃣ **US Trade Exposure Justification** (TO-DO Point 3)

**Available Data**:
- ✅ **US EXIM Bank**: `exim auth.csv` - 51,415 authorizations (2007-2025, USD 258B)
  - Top LATAM: Mexico (2,971), Brazil (1,182), Argentina (255), Peru (234), Chile (178)
  - ⚠️ 33,142 "Multiple Countries" entries need filtering
- ✅ **FFIEC 009**: 39 quarters USA→World banking claims (Trade_Finance column isolated)
- ✅ **BACI Trade Data**: `baci_trade_cty.csv` (16MB, bilateral flows 2015-2023)

**Pending Analysis**:
- ⏳ Script to analyze FFIEC 009 → USA→LATAM bilateral TF exposure
- ⏳ EXIM Bank → Filter & aggregate LATAM countries
- ⏳ Integrate BACI trade data with TF penetration ratios
- ⏳ Narrative document justifying USA's regional relevance

**Current Work**: Data ready, analysis scripts in development

---

### 📋 **NOT STARTED** (Being Organized)

#### 5️⃣ **Development Banks & Export Credit Agencies** (TO-DO Point 4)

**🗂️ Structure Defined** (`banca-desarrollo/` directory):
- ✅ **Inventory created**: `banca-desarrollo/README.md` lists 13 institutions across 9 countries + 2 multilaterals
- ✅ **Folder structure planned**: `<país>/<institución>/` organization
- ⏳ **Files being downloaded**: PDFs/reports being collected and organized

**Institutions Documented (Files Being Collected)**:

| Institution | Country | Reports Planned | Status |
|-------------|---------|-----------------|--------|
| **CORFO (COBEX/FOGAIN)** | �� Chile | 21 monthly reports (2023-2024)<br>`Informe GC Diciembre 2024_v2.pdf` | � **Being organized** |
| **NAFIN** | �� Mexico | `nafinsa_informe_anual_2023.pdf` | 📥 Being organized |
| **Bancomext** | 🇲🇽 Mexico | `bancomext_informe_anual_2023.pdf` | � Being organized |
| **Bancóldex** | 🇨🇴 Colombia | `bancoldex_reporte_anual_2023.pdf` | � Being organized |
| **Finagro** | �� Colombia | `finagro_informe_gestion_2023.pdf` | � Being organized |
| **Findeter** | 🇨🇴 Colombia | 2 reports (gestión + sectorial 2023) | 📥 Being organized |
| **BICE** | �� Argentina | `bice_memoria_balance_2023.pdf` | 📥 Being organized |
| **BNDES** | 🇧🇷 Brazil | `bndes_relatorio_anual_2023_en.pdf` | � Being organized |
| **BDP** | 🇧🇴 Bolivia | `bdp_memoria_2023.pdf` | 📥 Being organized |
| **AFD** | 🇵� Paraguay | `afd_memoria_2023.pdf` | 📥 Being organized |
| **BDE** | 🇪🇨 Ecuador | `bde_memoria_2023.pdf` | 📥 Being organized |
| **ANDE** | 🇺🇾 Uruguay | `ande_memoria_2023.pdf` | 📥 Being organized |
| **CAF** | 🌎 Multilateral | `caf_informe_anual_2023_interactivo.pdf` | � Being organized |
| **FONPLATA** | 🌎 Multilateral | `fonplata_memoria_2023.pdf` | 📥 Being organized |

**⚠️ Blocked Sources** (Manual Download Required):
- **COFIDE** (🇵🇪 Peru): Website returns 404, needs manual authentication
- **BCIE/CABEI** (🌎 Multilateral): Next.js/CloudFront site, requires browser execution
- **FNG Colombia**: Incapsula protection, returns empty HTML via scripts

**Next Steps**:
1. **Finish file collection** into `banca-desarrollo/<país>/<institución>/` structure
2. **OCR extraction pipeline** for 13+ development bank PDFs
3. **Extract structured data**: disbursements, portfolio by program, guarantees
4. **Cross-reference with TF data** to measure public vs private TF contribution
5. **Clarify COBEX**: Inventory refers to `chile/cobdx/` folder (CORFO guarantee program)

**📖 Documentation**: See `banca-desarrollo/README.md` for complete inventory and `banca-desarrollo/TODO.md` for progress tracking

---

### 🚧 **CRITICAL GAPS**

#### Data Coverage Issues

| Issue | Impact | Priority |
|-------|--------|----------|
| **Mexico: LC-only (15-25% coverage)** | Missing 75-85% of TF market (USD 19-30B) | 🔴 **HIGH** |
| **Mexico: 2020-2021 data gap** | No COVID-period analysis | 🟡 **MEDIUM** |
| **Argentina & Colombia** | Only FCIB survey data, no banking data | 🟡 **MEDIUM** |
| **Uruguay, Paraguay** | Not included in any dataset | 🟢 **LOW** |
| **Development banks** | 0% processed (6 institutions) | 🟡 **MEDIUM** |
| **FFIEC→LATAM analysis** | Data ready, script pending | 🟡 **MEDIUM** |

---

### 📈 **QUANTITATIVE SUMMARY**

**Processed Data**:
- **Total observations**: 1,702,350 (Brasil 838K + Chile 763K + Peru 96K + Mexico 5K)
- **Analysis tables generated**: 37 CSV files (30 country-specific + 7 cross-country)
- **Scripts completed**: 10 (4 ETL + 2 FFIEC + 2 FCIB + 2 analysis)
- **Documentation files**: 8 comprehensive READMEs
- **Country profiles**: 4 detailed markdown reports (15-24 KB each)

**Unprocessed Data**:
- **Development bank PDFs**: 6 institutions (23 files total)
- **EXIM Bank**: 51,415 operations (needs LATAM filtering)
- **BIS CBS**: 136 MB global banking statistics (needs TF isolation)

---

### 🎯 **IMMEDIATE PRIORITIES** (Next 2 Weeks)

1. ✅ **FCIB Panel Verification** - COMPLETED (125 records validated)
2. ⏳ **FFIEC 009 → USA→LATAM Exposure Analysis** - Script in development
3. ⏳ **EXIM Bank → LATAM Country Filtering** - Data cleaning phase
4. 📊 **CORFO Excel Processing** (julio 2023) - Structured data, quick win
5. 📝 **USA Relevance Narrative Document** - Based on FFIEC + EXIM + BACI

**Long-term (Next Quarter)**:
- Consolidated LATAM panel (4 countries unified CSV)
- Mexico full TF data acquisition (beyond LC)
- Development bank data extraction (6 PDFs)
- Argentina & Colombia banking data search
- COBEX/COBDX reference clarification

---

## 🎯 Research Questions

1. **How concentrated are trade finance markets** in Latin America?
2. **Do SMEs have adequate access** to trade credit instruments?
3. **What drives trade finance evolution** over time (COVID, policy, trade shocks)?
4. **How does TF provision compare** across countries and banking systems?
5. **What is the relationship** between trade finance and actual trade flows?

---

## 📁 Complete Directory Structure & Navigation Guide

### 🗂️ **ROOT LEVEL - START HERE**

```
Trade-Finance/
│
├── README.md                           ← YOU ARE HERE - Project overview
├── RESUMEN_EJECUTIVO_TRADE_FINANCE.md  ← Executive summary (Spanish)
├── README_DATA_PIPELINE.md             ← Data flow documentation
├── README_GLOBAL_SERIES.md             ← Global data series guide
├── REPORTE_SISTEMATICO_BASES_DE_DATOS.md ← Systematic database report
└── .gitattributes                      ← Git LFS configuration
```

**👉 START WITH**: `RESUMEN_EJECUTIVO_TRADE_FINANCE.md` for a quick overview of what data exists and what's missing.

---

### 📊 **1. RAW DATA (`pre-data/` root level)**

**Core Country Data Files** (🔴 = Git LFS Large Files):

```
├── Brasil/
│   ├── brasil_full.csv                 🔴 220 MB - BCB Sistema de Crédito (2012-2024)
│   └── brl_usd_monthly_ptax.csv        - Monthly BRL/USD exchange rates
│
├── Chile/
│   └── chile_full.csv                  🔴 195 MB - CMF regulatory data (2015-2024, 26 years available)
│
├── Mexico/
│   ├── 040_R12A_1219_133.csv          🔴 129 MB - CNBV Letters of Credit (2015-2019) ⚠️
│   ├── mxnusd.csv                      - MXN/USD exchange rates
│   └── README.md                       - Mexico data limitations
│
├── Peru/
│   ├── peru_full.csv                   - SBS trade credit data (2010-2024)
│   └── Mensuales-*.csv                 - BCRP exchange rates (PEN/USD)
│
├── Consolidated banking statistics BIS.csv  🔴 136 MB - BIS global banking (2015-2024)
├── baci_trade_cty.csv                  - CEPII bilateral trade flows
├── exim auth.csv                       - US EXIM Bank authorizations (51,414 ops)
├── WUI_Data.csv                        - World Uncertainty Index
├── country_codes_V202501.csv           - Country classification
├── income levels.xlsx                  - World Bank income groups
└── country_correspondence.csv          - Country code harmonization
```

**⚠️ DATA QUALITY NOTES**:
- **Mexico**: Coverage ends 2019 (5-year gap, major limitation)
- **Chile**: TF/Trade ratio only 0.88% (under-reporting suspected)
- **Brazil**: Most comprehensive dataset (firm size + sector + region)
- **Peru**: High concentration (Top 5 = 88.6% market share)

---

### 🔬 **2. FFIEC 009 - US Banks' International Exposure**

Complete processing pipeline for Federal Reserve data:

```
FFIEC 009/
│
├── *.xls, *.xlsx                       - 39 quarterly raw files (2015Q2-2024Q4)
├── 1_extract_raw.py                    - Extract tables from Excel files
├── 2_analyze_structure.py              - Understand data structure
├── 3_clean_and_organize.py             - Standardize and clean
├── 4_validate_and_document.py          - Quality checks
├── README_PROCESAMIENTO.md             - Complete processing documentation
│
├── extracted_raw/                      - Python-extracted CSVs by quarter
│   ├── 2015Q2_Jun 30 2015 - EE16 (009)/
│   ├── 2015Q3_Sep 28 2015 - EE16 (009)/
│   └── ... (39 folders, one per quarter)
│
├── cleaned_data/                       - Processed & standardized data
│   ├── 2015Q2_complete/               - All tables consolidated
│   ├── 2015Q2_data_only/              - Only data rows (no headers)
│   └── ... (78 folders: complete + data_only per quarter)
│
├── analysis_reports/                   - JSON structure analysis
├── validation_reports/                 - Data quality reports
└── Data-nic/                          🔴 Multiple large CSV files (branch/bank metadata)
```

**📖 HOW TO USE FFIEC DATA**:
1. Read `README_PROCESAMIENTO.md` for full methodology
2. Use `cleaned_data/YYYYQX_complete/` for analysis-ready files
3. Key tables: `All_Banks_Table_1.csv` (summary), `LFI_Table_*.csv` (by bank)

---

### 💻 **3. PROCESSING SCRIPTS (`Scripts/`)**

**Primary Analysis Scripts**:

```
Scripts/
│
├── README.md                           ← SCRIPT DOCUMENTATION - Read this first!
│
│── 🌟 COUNTRY ETL PIPELINES 🌟
├── brasil_etl.R                        - Brazil: BCB → USD conversion + BACI merge
├── chile_etl.R                         - Chile: CMF → USD + operation categorization  
├── mexico_lc_etl.R                     - Mexico: CNBV → USD + LC analysis
├── peru_etl.R                          - Peru: SBS → USD + firm size classification
│
│── 🌟 INTEGRATED ANALYSIS 🌟
├── Trade finance data and analysis.R   - 2,087 lines - MASTER SCRIPT
│   │                                     ├─ BACI trade flows
│   │                                     ├─ EXIM Bank financing
│   │                                     ├─ BIS banking statistics
│   │                                     ├─ FFIEC 009 integration
│   │                                     └─ Cross-source analysis
│
├── latam banks.R                       - 907 lines - Country-specific banking analysis
│   │                                     ├─ Peru: SBS by firm size
│   │                                     ├─ Brazil: CNAE sector classification
│   │                                     ├─ Mexico: CNBV letters of credit
│   │                                     └─ Chile: CMF 24 TF accounts
│
│── 🌟 AUTOMATION & REPORTING 🌟
├── generate_all_country_data.py        - Auto-generate country datasets
├── generate_cross_country_analysis.py  - Cross-country comparisons
├── generate_country_graphs.R           - Publication-ready visualizations
├── country_profiles.R                  - Generate country profile reports
│
│── 🌟 ACADEMIC DATA 🌟
├── Hardy data analysis.R               - Bryan Hardy firm-level data analysis
│
│── 🌟 SPECIALIZED TOOLS 🌟
├── fcib_pdf_extract.py                 - Extract FCIB survey data from PDFs
├── README_FCIB.md                      - FCIB methodology documentation
```

**🚀 QUICK START**:
```r
# Process all country data
source("Scripts/brasil_etl.R")
source("Scripts/chile_etl.R") 
source("Scripts/mexico_lc_etl.R")
source("Scripts/peru_etl.R")

# Run master analysis
source("Scripts/Trade finance data and analysis.R")

# Generate reports
source("Scripts/country_profiles.R")
```

---

### 📈 **4. ANALYSIS OUTPUTS (`tables_and_graphs/`)**

**Generated Data Tables & Reports**:

```
tables_and_graphs/
│
├── README.md                           ← OUTPUT DOCUMENTATION - Start here
├── ANALYSIS_COVERAGE_REPORT.md         - What's analyzed, what's missing
├── DATA_GENERATION_SUMMARY.md          - How tables were created
│
│── 🇧🇷 BRAZIL ANALYSIS
├── Brazil/
│   ├── BRAZIL_COUNTRY_PROFILE.md       - 15 KB comprehensive report
│   ├── README.md                        - Brazil analysis guide
│   ├── 01_tf_by_firm_size_data.csv     - Micro/Small/Medium/Large breakdown
│   ├── 02_tf_by_sector_data.csv        - 21 CNAE sectors
│   ├── 03_tf_by_state_data.csv         - 27 states geographic analysis
│   ├── 04_maturity_structure_data.csv  - 6 maturity buckets
│   ├── 05_temporal_evolution_data.csv  - Monthly time series
│   ├── 06_npl_analysis_data.csv        - Credit quality metrics
│   ├── 07_indexer_distribution_data.csv - Interest rate structure
│   ├── 08_currency_by_maturity_data.csv - BRL vs USD by maturity
│   └── 09_regional_evolution_top5_data.csv - Top states evolution
│
│── 🇨🇱 CHILE ANALYSIS
├── Chile/
│   ├── CHILE_COUNTRY_PROFILE.md        - 18 KB report (26-year series)
│   ├── README.md                        - Chile analysis guide
│   ├── 01_bank_concentration_data.csv  - Top 10 market shares
│   ├── 02_currency_composition_data.csv - CLP/USD/indexed breakdown
│   ├── 03_annual_summary_data.csv      - Yearly aggregates
│   ├── 04_top_accounts_data.csv        - Most important TF accounts
│   ├── 05_export_import_breakdown_data.csv - Operation type split
│   └── 06_annual_growth_rates_data.csv - YoY changes
│
│── 🇲🇽 MEXICO ANALYSIS
├── Mexico/
│   ├── MEXICO_COUNTRY_PROFILE.md       - 24 KB report (⚠️ LC only)
│   ├── README.md                        - Mexico limitations explained
│   ├── 01_bank_concentration_data.csv  - Top banks in LC market
│   ├── 02_annual_lc_volume_data.csv    - Yearly LC issuance
│   ├── 03_lc_seasonality_data.csv      - Monthly patterns
│   ├── 04_monthly_evolution_data.csv   - Time series
│   ├── 05_lc_trade_penetration_data.csv - LC/Trade ratios
│   ├── 06_monthly_lc_trade_ratio_data.csv - Monthly penetration
│   └── 07_bank_market_share_with_trade_data.csv - Bank shares vs trade
│
│── 🇵🇪 PERU ANALYSIS
├── Peru/
│   ├── PERU_COUNTRY_PROFILE.md         - 21 KB report (highest concentration)
│   ├── README.md                        - Peru analysis guide
│   ├── 01_tf_by_firm_size_data.csv     - 5 size categories
│   ├── 02_credit_type_distribution_data.csv - 8 credit types
│   ├── 03_bank_concentration_data.csv  - Top banks (CR5=88.6%)
│   ├── 04_annual_growth_data.csv       - Yearly changes
│   ├── 05_tf_penetration_data.csv      - TF/Trade analysis
│   ├── 06_dollarization_over_time_data.csv - USD share evolution
│   ├── 07_tf_evolution_by_size_data.csv - Firm size trends
│   └── 08_tf_trade_ratio_over_time_data.csv - Penetration trends
│
│── 🌎 CROSS-COUNTRY COMPARISONS
├── Cross_Country_Comparisons/
│   ├── README.md                        - Comparison methodology
│   ├── 01_market_concentration_comparison.csv - HHI, CR5 across countries
│   ├── 02_sme_access_comparison.csv    - Small firm access metrics
│   ├── 03_tf_trade_penetration_comparison.csv - TF/Trade ratios
│   ├── 04_data_quality_assessment.csv  - Coverage & reliability
│   ├── 05_currency_composition_comparison.csv - USD vs local currency
│   ├── 06_growth_volatility_comparison.csv - Market stability
│   └── 07_summary_statistics_comparison.csv - Key metrics table
│
│── 🏦 GLOBAL BANKING (BIS)
├── BIS/
│   ├── bis_concentration_latest.csv    - Latest quarter concentration
│   ├── bis_exposure_by_reporting_country_latest.csv - Country breakdown
│   └── bis_exposure_total_by_quarter.csv - Time series
│
│── 🇺🇸 US EXPORT FINANCE (EXIM)
└── EXIM/
    ├── exim_authorizations_by_country.csv - Country-level approvals
    ├── exim_latam_summary.csv          - LATAM aggregate
    ├── exim_program_mix.csv            - Guarantee/Insurance/Loan split
    ├── exim_removed_borrowers.csv      - Exclusions analysis
    ├── exim_small_business_share.csv   - SME participation
    └── exim_term_distribution.csv      - Maturity structure
```

**📊 PROFILE COMPARISON**:

| Country | Profile Size | Period | Observations | Key Strength |
|---------|-------------|---------|--------------|--------------|
| Brazil 🇧🇷 | 15 KB | 2012-2024 | 838,167 | Geographic + Sector granularity |
| Chile 🇨🇱 | 18 KB | 2015-2024 (26yr avail) | 762,687 | Longest time series |
| Peru 🇵🇪 | 21 KB | 2010-2024 | 96,496 | Firm size detail |
| Mexico 🇲🇽 | 24 KB | 2022-2025 | 2,204 | ⚠️ LC only (15-25% coverage) |

---

### 📚 **5. DOCUMENTATION (`data/` + root)**

**Methodology & Reference Documents**:

```
├── data/
│   └── GUIA_COMPLETA_TRADE_FINANCE.md  - 📖 COMPLETE METHODOLOGY GUIDE
│                                          ├─ Variable definitions
│                                          ├─ Data transformations
│                                          ├─ Harmonization procedures
│                                          └─ Calculation formulas
│
├── RESUMEN_EJECUTIVO_TRADE_FINANCE.md  - 🎯 Executive summary (what works, what doesn't)
├── README_DATA_PIPELINE.md              - 🔄 Data flow diagrams
├── README_GLOBAL_SERIES.md              - 🌐 International data sources
├── REPORTE_SISTEMATICO_BASES_DE_DATOS.md - 📊 Systematic database inventory
├── ANALISIS_OCR_FORTALECIMIENTO.md      - 🔍 OCR analysis for data extraction
└── TODO_MEJORAS_OCR.md                  - 📝 OCR improvement roadmap
```

---

### 📄 **6. ORIGINAL DOCUMENTS (`documents/`)**

**Source Materials**:

```
documents/
└── Monthly FCIB Credit & Collections Surveys (2023-2025)
    ├── 2023-01_FCIB_Credit_Collections_Survey.pdf
    ├── 2023-05_FCIB_Credit_Collections_Survey.pdf
    ├── ... (40+ monthly surveys)
    └── 2025-10_FCIB_Credit_Collections_Survey_Argentina_Costa_Rica_India_Italy1.pdf
```

**📖 USAGE**: Extract trade credit terms, collection periods, and credit manager sentiment by country.

---

### 🎓 **7. ACADEMIC DATA & DEVELOPMENT BANKS**

**Research Datasets**:

```
├── BryanHardy_JMP_FirmData_forMP.dta   - Firm-level data (Chile focus)
├── HardySaffie_CCT_Data.dta            - Conditional cash transfer impact analysis
│
└── banca-desarrollo/                    🏦 DEVELOPMENT BANKS (Files Being Organized)
    ├── README.md                        - Complete inventory: 13 institutions, 9 countries + 2 multilaterals
    └── TODO.md                          - Progress tracking: CORFO ✅, NAFIN/Bancomext 📥, etc.
    │
    └── [Planned structure - files being collected]:
        ├── chile/cobdx/                 - CORFO (COBEX/FOGAIN): 21 monthly reports 2023-2024
        ├── mexico/nafin/                - NAFIN annual report 2023
        ├── mexico/bancomext/            - Bancomext annual report 2023
        ├── colombia/bancoldex/          - Bancóldex annual report 2023
        ├── colombia/finagro/            - Finagro sustainable management 2023
        ├── colombia/findeter/           - Findeter integrated + sectoral reports 2023
        ├── argentina/bice/              - BICE memoria y balance 2023
        ├── brasil/bndes/                - BNDES relatório anual 2023 (English)
        ├── bolivia/bdp/                 - BDP memoria 2023
        ├── paraguay/afd/                - AFD memoria sostenibilidad 2023
        ├── ecuador/bde/                 - BDE memoria 2023
        ├── uruguay/ande/                - ANDE memoria 2023
        ├── multilaterales/caf/          - CAF informe anual 2023
        └── multilaterales/fonplata/     - FONPLATA memoria anual 2023
```

**📖 USAGE**: 
- **Current Status**: Inventory and folder structure defined, files being downloaded/organized
- **Objective**: Extract disbursements, guarantees, and TF-specific programs to measure public vs private TF provision
- **Next Phase**: OCR extraction pipeline for 13+ development bank annual reports

---

### 🎤 **8. PRESENTATIONS**

```
presentations/
└── Trade_Finance.tex                    - LaTeX presentation template
```

---

## �️ HOW TO NAVIGATE THIS PROJECT

### **I'm a researcher wanting to...**

#### ...understand what data exists
1. Start with `RESUMEN_EJECUTIVO_TRADE_FINANCE.md` (Spanish executive summary)
2. Read country profiles in `tables_and_graphs/[Country]/[COUNTRY]_COUNTRY_PROFILE.md`
3. Check `tables_and_graphs/ANALYSIS_COVERAGE_REPORT.md` for gaps

#### ...reproduce the analysis
1. Install R packages: `tidyverse`, `readxl`, `lubridate`, `zoo`, `sf`
2. Install Python: `pandas`, `numpy`, `openpyxl`, `PyPDF2`
3. Run country ETLs: `Scripts/brasil_etl.R`, `chile_etl.R`, `mexico_lc_etl.R`, `peru_etl.R`
4. Run master analysis: `Scripts/Trade finance data and analysis.R`
5. Generate reports: `Scripts/country_profiles.R`

#### ...access processed data
- **Pre-generated tables**: `tables_and_graphs/[Country]/`
- **Cross-country comparisons**: `tables_and_graphs/Cross_Country_Comparisons/`
- **Time series**: Check `*_temporal_evolution_data.csv` or `*_monthly_evolution_data.csv` files

#### ...understand methodology
- **Overall pipeline**: `README_DATA_PIPELINE.md`
- **Variable definitions**: `data/GUIA_COMPLETA_TRADE_FINANCE.md`
- **Script logic**: `Scripts/README.md`

### **I'm a policymaker needing to...**

#### ...benchmark my country's TF market
1. Go to `tables_and_graphs/[YourCountry]/[COUNTRY]_COUNTRY_PROFILE.md`
2. Compare with `tables_and_graphs/Cross_Country_Comparisons/01_market_concentration_comparison.csv`
3. Review SME access: `02_sme_access_comparison.csv`

#### ...identify gaps in TF provision
- **Geographic gaps** (Brazil only): `Brazil/03_tf_by_state_data.csv`
- **Firm size gaps**: `*/01_tf_by_firm_size_data.csv` (Brazil, Peru)
- **Sector gaps** (Brazil only): `Brazil/02_tf_by_sector_data.csv`

#### ...design policy interventions
- Review country profiles' "Key Insights & Recommendations" sections
- Check `exim auth.csv` for government guarantee program examples
- Study concentration metrics (CR5, HHI) in `*_bank_concentration_data.csv`

### **I'm a bank strategist looking to...**

#### ...enter a new market
1. Check market concentration: `tables_and_graphs/[Country]/03_bank_concentration_data.csv`
2. Identify underserved segments: `01_tf_by_firm_size_data.csv`
3. Review competitive landscape: Country profile "Banking Sector Concentration" section

#### ...analyze competitor strategies
- Review top bank shares in country profiles
- Check temporal evolution: `*_temporal_evolution_data.csv` or `*_monthly_evolution_data.csv`
- Compare with BACI trade data to find gaps: `*_tf_trade_penetration_data.csv`

### **I'm a developer wanting to...**

#### ...extract Chile data automatically
1. Read `Scripts/README.md` section on CMF API
2. Use endpoints documented in script annotations
3. Check `Scripts/cmf data.R` for working examples (24 TF account codes identified)

#### ...build a dashboard
- **Data source**: Pre-generated CSVs in `tables_and_graphs/`
- **Key metrics**: Extract from `Cross_Country_Comparisons/07_summary_statistics_comparison.csv`
- **Time series**: Use `*_evolution_data.csv` files for charts
- **Country maps**: Use geographic data from `Brazil/03_tf_by_state_data.csv`

---

## �📊 Data Sources & Coverage

### 🇧🇷 **1. Brazil - Most Comprehensive Dataset**

| Attribute | Details |
|-----------|---------|
| **Source** | Banco Central do Brasil (BCB) - SCR Sistema de Crédito |
| **File** | `Brasil/brasil_full.csv` 🔴 220 MB (Git LFS) |
| **Period** | Jan 2012 - Dec 2024 (156 months, 13 years) |
| **Observations** | 838,167 |
| **Granularity** | Monthly, firm-level (anonymized IDs) |
| **TF Portfolio** | ~USD 492 billion |
| **TF/Trade Ratio** | 67.4% (highest in region) |
| **✅ Strengths** | • 4 firm sizes (Micro/Small/Medium/Large)<br>• 21 CNAE sectors<br>• 27 states (geographic)<br>• 6 maturity buckets<br>• NPL rates<br>• Indexer/interest structure |
| **⚠️ Limitations** | • Firm IDs anonymized<br>• Bank-intermediated only<br>• Excludes non-bank TF<br>• Definition: "PJ - Comércio exterior" (narrow but 99.999% complete) |
| **ETL Script** | `Scripts/brasil_etl.R` |
| **Output Tables** | 9 analysis files in `tables_and_graphs/Brazil/` |

**Key Finding**: São Paulo = 48.4% of market, SMEs only 4.6% of portfolio

---

### 🇨🇱 **2. Chile - Longest Time Series**

| Attribute | Details |
|-----------|---------|
| **Source** | Comisión para el Mercado Financiero (CMF) |
| **File** | `Chile/chile_full.csv` 🔴 195 MB (Git LFS) |
| **Period** | Jan 2015 - Dec 2024 (120 months, **26 years available 1998-2024**) |
| **Observations** | 762,687 |
| **Granularity** | Monthly, bank-level, account-level |
| **TF Portfolio** | ~USD 1.6 billion |
| **TF/Trade Ratio** | 0.88% ⚠️ (suspiciously low, under-reporting likely) |
| **✅ Strengths** | • Longest regional series<br>• Operation type (export/import/third-country)<br>• 24 TF-specific accounts identified<br>• Currency detail (CLP/USD/indexed)<br>• **API available** for auto-updates |
| **⚠️ Limitations** | • No firm-size breakdown<br>• Limited sectoral info<br>• Very low TF/Trade suggests incomplete coverage<br>• Documented credits only |
| **ETL Script** | `Scripts/chile_etl.R` (also `cmf data.R` for API extraction) |
| **Output Tables** | 6 analysis files in `tables_and_graphs/Chile/` |

**Key Finding**: Export financing 27% higher than import, CR5 = 42.7% (lowest concentration)

**🔌 API Discovery**: CMF provides REST API with 1,104 TF-related accounts, 24 core codes identified. See `Scripts/README.md` for endpoints.

---

### 🇲🇽 **3. Mexico - Letters of Credit Only (Incomplete Coverage)**

| Attribute | Details |
|-----------|---------|
| **Source** | Comisión Nacional Bancaria y de Valores (CNBV) |
| **File** | `Mexico/040_R12A_1219_133.csv` 🔴 129 MB (Git LFS) |
| **Period** | Jan 2015 - Dec 2019 (5 years) + ⚠️ Jan 2022 - Aug 2025 (partial, recent data) |
| **Observations** | ~5,000 records (174 KB actual data size) |
| **Granularity** | Monthly, bank-level |
| **TF Portfolio** | ~USD 5.7 billion (**LC only**) |
| **TF/Trade Ratio** | 0.50% (LC only) / **Estimated 2.2-3.0% full TF market** |
| **✅ Strengths** | • Detailed Letters of Credit data<br>• Bank concentration visible<br>• Clear seasonality patterns<br>• MXN/USD conversion included |
| **⚠️ CRITICAL Limitations** | • **LC ONLY = 15-25% of total TF market**<br>• **Estimated full TF market: USD 25-35 billion (not captured)**<br>• **2020-2021 data gap** (COVID period missing)<br>• No firm-size breakdown<br>• No sectoral detail<br>• USMCA dominance (66% trade with US) → open account not tracked |
| **ETL Script** | `Scripts/mexico_lc_etl.R` |
| **Output Tables** | 7 analysis files in `tables_and_graphs/Mexico/` |

**Key Finding**: BBVA + Santander = 50.9% of LC market (duopoly)

**⚠️ MAJOR COVERAGE GAP**: 
- This dataset captures **ONLY Letters of Credit**, which represent 15-25% of Mexico's total trade finance market
- Full TF portfolio estimated at USD 25-35 billion (vs. USD 5.7B LC observed)
- Missing instruments: guarantees, acceptances, forfaiting, confirming, discounting
- **TO-DO**: Obtain comprehensive CNBV TF data beyond LC-only (R12A report series incomplete)

---

### 🇵🇪 **4. Peru - Highest Concentration**

| Attribute | Details |
|-----------|---------|
| **Source** | Superintendencia de Banca, Seguros y AFP (SBS) |
| **File** | `Peru/peru_full.csv` |
| **Period** | Oct 2010 - Dec 2024 (171 months, 14 years) |
| **Observations** | 96,496 |
| **Granularity** | Monthly, firm-size categories (5 levels) |
| **TF Portfolio** | ~USD 0.8 billion |
| **TF/Trade Ratio** | 0.64% |
| **✅ Strengths** | • 5 firm sizes (Corporate/Large/Medium/Small/Micro)<br>• 8 credit type context<br>• Dollarization tracking (78-82% USD)<br>• SME access analysis |
| **⚠️ Limitations** | • No sectoral breakdown<br>• No geographic detail<br>• High concentration (Top 5 = 88.6%) limits competition |
| **ETL Script** | `Scripts/peru_etl.R` |
| **Output Tables** | 8 analysis files in `tables_and_graphs/Peru/` |

**Key Finding**: Extreme oligopoly (CR5=88.6%, Top 3=69.9%), SMEs only 2.0% of portfolio (worst in region), mining-driven

---

### 🏦 **5. FFIEC 009 - US Banks' Global TF Exposure**

| Attribute | Details |
|-----------|---------|
| **Source** | Federal Financial Institutions Examination Council (US Federal Reserve) |
| **Directory** | `FFIEC 009/` (complete pipeline) |
| **Period** | 2015Q2 - 2024Q4 (39 quarters, 9.5 years) |
| **Files** | 39 quarterly Excel reports → 78 cleaned datasets |
| **Granularity** | Quarterly, country-level, bank-type level (LFI = Large Foreign Institutions) |
| **Coverage** | US banks >$30B assets reporting international exposure |
| **✅ Strengths** | • Dedicated "Trade_Finance" column<br>• All countries covered<br>• Multiple claim types<br>• Processing pipeline documented<br>• Validation reports included |
| **⚠️ Limitations** | • US banks only (excludes local banks)<br>• Quarterly (not monthly)<br>• Aggregated by country<br>• Definition may differ from local regulators |
| **Processing** | 4-stage Python pipeline: `1_extract` → `2_analyze` → `3_clean` → `4_validate` |
| **Documentation** | `FFIEC 009/README_PROCESAMIENTO.md` (complete methodology) |

**Output Structure**: 
- `extracted_raw/`: 39 folders (one per quarter)
- `cleaned_data/`: 78 folders (complete + data_only per quarter)
- `analysis_reports/`, `validation_reports/`: Quality checks

---

### 🌐 **6. BIS - Global Banking Statistics**

| Attribute | Details |
|-----------|---------|
| **Source** | Bank for International Settlements |
| **File** | `Consolidated banking statistics BIS.csv` 🔴 136 MB (Git LFS) |
| **Period** | 2015-2024 (quarterly) |
| **Coverage** | International banking claims/liabilities by country-pair |
| **Use in Project** | Calculate TF context, benchmark against global trends |
| **⚠️ Limitation** | Does not isolate trade finance specifically |

---

### 📦 **7. BACI/CEPII - International Trade Flows**

| Attribute | Details |
|-----------|---------|
| **Source** | CEPII (French Research Center) |
| **File** | `baci_trade_cty.csv` |
| **Period** | 2015-2023 (annual) |
| **Coverage** | Bilateral trade flows (exports/imports) for all country pairs |
| **Use in Project** | Calculate TF/Trade penetration ratios, identify coverage gaps |
| **Granularity** | Country-level, HS product codes available |

**Critical for**: Understanding why TF/Trade ratios are low (open account, non-bank financing, etc.)

---

### 🇺🇸 **8. US EXIM Bank - Export Credit Guarantees**

| Attribute | Details |
|-----------|---------|
| **Source** | Export-Import Bank of the United States |
| **File** | `exim auth.csv` |
| **Period** | 2007-2025 (18 years) |
| **Records** | 51,414 authorizations |
| **Total Value** | USD 258 billion approved |
| **Coverage** | Guarantees, Insurance, Direct Loans, Working Capital programs |
| **Use in Project** | Government TF support analysis, SME participation, country comparison |

**LATAM Focus**: Analysis of US export financing to Brazil, Chile, Mexico, Peru in `tables_and_graphs/EXIM/`

---

### 📋 **9. FCIB Surveys - Industry Sentiment**

| Attribute | Details |
|-----------|---------|
| **Source** | Finance, Credit & International Business Association |
| **Directory** | `documents/` (40+ PDFs) |
| **Period** | Jan 2023 - Nov 2025 (monthly) |
| **Coverage** | Credit manager sentiment, collection periods, payment terms by country |
| **Use in Project** | Qualitative validation of quantitative findings |
| **Extraction** | `Scripts/fcib_pdf_extract.py` (automated PDF parsing) |

---

### 🗺️ **10. Supporting Reference Data**

| File | Purpose |
|------|---------|
| `country_codes_V202501.csv` | ISO 3166-1 codes, standardized names |
| `country_correspondence.csv` | Harmonize country names across sources |
| `income levels.xlsx` | World Bank income classification |
| `WUI_Data.csv` | World Uncertainty Index (control variable) |
| `BryanHardy_JMP_FirmData_forMP.dta` | Academic research data (firm-level, Chile) |
| `HardySaffie_CCT_Data.dta` | Conditional cash transfer impact study |

---

## 🔧 Processing Pipeline

### Stage 1: Data Extraction
```
Raw Sources → Scripts/*_etl.R → Cleaned CSVs
```
- Each country has dedicated ETL script
- Standardizes formats, currencies, time periods
- Handles missing values and outliers

### Stage 2: Feature Generation
```
Cleaned Data → generate_all_country_data.py → Analysis Tables
```
- Calculates concentration indices (HHI)
- Computes growth rates and volatility
- Generates penetration ratios

### Stage 3: Cross-Country Analysis
```
Country Tables → generate_cross_country_analysis.py → Comparisons
```
- Harmonizes metrics across countries
- Creates comparable time series
- Quality assessment flags

### Stage 4: Visualization & Reporting
```
Analysis Tables → country_profiles.R → Country Profiles
```
- Generates standardized country reports
- Creates publication-ready tables
- Produces summary statistics

---

## 📈 Key Metrics & Indicators

### Market Structure
- **HHI (Herfindahl-Hirschman Index)**: Bank concentration
- **Top 3/5/10 Share**: Market share of largest banks
- **Bank Count**: Active institutions in trade finance

### Access Indicators
- **SME Share**: % of trade credit to small/medium firms
- **Penetration Ratio**: Trade finance / Total trade volume
- **Geographic Coverage**: Regional dispersion indices

### Temporal Dynamics
- **YoY Growth**: Annual growth rates
- **Volatility**: Standard deviation of growth
- **Trend Components**: Seasonal adjustments

### Credit Quality
- **NPL Ratios**: Non-performing loan rates (Brazil)
- **Maturity Structure**: Short vs medium-term exposure
- **Dollarization**: USD share in total credit

---

## 🚀 Quick Start Guide

### Step 1: Clone Repository (⚠️ Requires Git LFS)

```bash
# Install Git LFS first
brew install git-lfs  # macOS
# or: sudo apt-get install git-lfs  # Linux
# or: download from https://git-lfs.github.com/  # Windows

# Initialize LFS
git lfs install

# Clone repository
git clone https://github.com/tomasdata/Trade-Finance.git
cd Trade-Finance/pre-data

# Verify large files downloaded (should show ~978 MB)
git lfs ls-files -s
```

**⚠️ Important**: Without Git LFS, large CSV files will be pointer files (~150 bytes) instead of actual data.

---

### Step 2: Explore Pre-Generated Analysis (Fastest)

**For most users, start here - all analysis is already done:**

```bash
cd tables_and_graphs/

# View country-specific analysis
cat Brazil/01_tf_evolution_data.csv       # Brazil time series
cat Chile/01_tf_evolution_data.csv        # Chile time series
cat Mexico/01_tf_evolution_data.csv       # Mexico time series
cat Peru/01_tf_evolution_data.csv         # Peru time series

# View cross-country comparisons
cat Cross_Country_Comparisons/01_monthly_evolution_comparison.csv
cat Cross_Country_Comparisons/07_summary_statistics_comparison.csv

# Full list of outputs
ls -lh Brazil/      # 9 analysis files
ls -lh Chile/       # 6 analysis files
ls -lh Mexico/      # 7 analysis files
ls -lh Peru/        # 8 analysis files
ls -lh Cross_Country_Comparisons/  # 9 comparison files
```

---

### Step 3: Read Raw Data (If Needed)

```r
# Open R or RStudio
setwd("pre-data/")

# Load country datasets
brasil <- read.csv("Brasil/brasil_full.csv")    # 838,167 obs
chile <- read.csv("Chile/chile_full.csv")       # 762,687 obs
mexico <- read.csv("Mexico/040_R12A_1219_133.csv")  # 2,204 obs
peru <- read.csv("Peru/peru_full.csv")          # 96,496 obs

# Quick summary
summary(brasil)
head(chile)
```

```python
# Or use Python
import pandas as pd

brasil = pd.read_csv("Brasil/brasil_full.csv")
chile = pd.read_csv("Chile/chile_full.csv")

print(brasil.info())
print(chile.head())
```

---

### Step 4: Re-Run Analysis (Advanced Users)

**Prerequisites:**
```r
# R packages
install.packages(c("tidyverse", "readxl", "lubridate", "zoo", "scales"))
```

```bash
# Python packages
pip install pandas numpy openpyxl PyPDF2 matplotlib seaborn
```

**Run Full Pipeline:**
```bash
cd Scripts/

# Individual country ETLs
Rscript brasil_etl.R         # → 9 Brazil tables
Rscript chile_etl.R          # → 6 Chile tables
Rscript mexico_lc_etl.R      # → 7 Mexico tables
Rscript peru_etl.R           # → 8 Peru tables

# Generate all country data
python generate_all_country_data.py

# Cross-country analysis
python generate_cross_country_analysis.py

# Master analysis (2,087 lines)
Rscript master_analysis.R

# Country profiles
Rscript country_profiles.R
```

---

### Step 5: Read Documentation

**Start with:**
1. **[RESUMEN_EJECUTIVO_TRADE_FINANCE.md](RESUMEN_EJECUTIVO_TRADE_FINANCE.md)** - Executive summary (78,000 words)
2. **[README_DATA_PIPELINE.md](data/README_DATA_PIPELINE.md)** - Data methodology
3. **Country profiles in `tables_and_graphs/[Country]/`**

**For specific tasks:**
- ETL details: `Scripts/README.md` (73,683 tokens)
- Output guide: `tables_and_graphs/README.md` (76,663 tokens)
- FFIEC processing: `FFIEC 009/README_PROCESAMIENTO.md`

---

## 📊 Git LFS Files

**Large files stored with Git LFS** (files >50MB):

1. `Brasil/brasil_full.csv` - 220 MB
2. `Chile/chile_full.csv` - 195 MB
3. `Consolidated banking statistics BIS.csv` - 136 MB
4. `Mexico/040_R12A_1219_133.csv` - 129 MB
5. `FFIEC 009/Data-nic/CSV_ATTRIBUTES_BRANCHES.CSV` - 90.7 MB
6. `FFIEC 009/Data-nic/CSV_ATTRIBUTES_CLOSED.CSV` - 82.7 MB

**To clone with LFS files:**
```bash
git lfs install
git clone https://github.com/tomasdata/Trade-Finance.git
cd Trade-Finance
git lfs pull
```

---

## ⚠️ Known Limitations

### Data Gaps
1. **Mexico**: Data ends in 2019, missing 2020-2024 period
2. **Peru**: Limited sectoral breakdowns
3. **Chile**: No firm-size categories
4. **FFIEC 009**: U.S. banks only, quarterly frequency

### Measurement Issues
1. **Underestimation**: Only captures bank-intermediated trade finance
   - Excludes: open account terms, direct buyer-supplier credit
2. **Currency Effects**: Exchange rate fluctuations affect USD comparisons
3. **Definition Variation**: Countries use different trade finance classifications
4. **Reporting Lags**: Update frequencies vary by source

### Comparability Challenges
1. Different firm-size definitions across countries
2. Sectoral classifications not fully harmonized
3. Trade finance scope varies (LCs, guarantees, forfaiting, etc.)

---

## 📚 Documentation

- **[GUIA_COMPLETA_TRADE_FINANCE.md](data/GUIA_COMPLETA_TRADE_FINANCE.md)**: Complete methodology guide
- **[RESUMEN_EJECUTIVO_TRADE_FINANCE.md](RESUMEN_EJECUTIVO_TRADE_FINANCE.md)**: Executive summary
- **[REPORTE_SISTEMATICO_BASES_DE_DATOS.md](REPORTE_SISTEMATICO_BASES_DE_DATOS.md)**: Systematic database report
- **Country Profiles**:
  - [Brazil Profile](tables_and_graphs/Brazil/BRAZIL_COUNTRY_PROFILE.md)
  - [Chile Profile](tables_and_graphs/Chile/CHILE_COUNTRY_PROFILE.md)
  - [Mexico Profile](tables_and_graphs/Mexico/MEXICO_COUNTRY_PROFILE.md)
  - [Peru Profile](tables_and_graphs/Peru/PERU_COUNTRY_PROFILE.md)

---

## 🔄 Version Control

- **Main Branch**: Stable, production-ready analysis
- **pre-data-backup Branch**: Complete data backup with LFS
- **Commits**: Include data updates, script modifications, new analysis

---

## 📧 Contact

**Tomas Fernandez**  
GitHub: [@tomasdata](https://github.com/tomasdata)  
Repository: [Trade-Finance](https://github.com/tomasdata/Trade-Finance)

---

## 📄 License

Research data is subject to source institution terms. Analysis code and documentation are open for academic use.

---

---

## ⚠️ Critical Limitations Summary

Before using this data, be aware of these key limitations:

| Issue | Impact | Countries Affected | Severity |
|-------|--------|-------------------|----------|
| **🇲🇽 Mexico: LC-only coverage** | Captures only 15-25% of TF market<br>Missing USD 19-30B in other instruments | 🇲🇽 Mexico | 🔴 **CRITICAL** |
| **🇲🇽 Mexico: 2020-2021 data gap** | No COVID-period analysis<br>Nearshoring impact not tracked | 🇲🇽 Mexico | 🔴 **HIGH** |
| **Low TF/Trade ratios** | Under-reporting or open account dominance<br>Suggests incomplete TF capture | 🇨🇱 (0.88%), 🇵🇪 (0.64%), 🇲🇽 (0.50% LC-only) | 🟡 **MEDIUM** |
| **No firm identifiers** | Cannot link to external firm-level datasets<br>Limits micro-econometric analysis | 🇧🇷 Brazil (anonymized) | 🟡 **MEDIUM** |
| **Bank-intermediated only** | Excludes non-bank TF, open account, inter-firm credit | All countries | 🟡 **MEDIUM** |
| **Different TF definitions** | Not fully comparable across regulators<br>Each country uses different account classifications | All countries | 🟢 **LOW** |
| **Missing countries** | Argentina, Colombia: FCIB survey only<br>Uruguay, Paraguay: not included | 🇦🇷 🇨🇴 🇺🇾 🇵🇾 | 🟢 **LOW** |

**🔴 Action Required**: Mexico data acquisition (comprehensive TF beyond LC) is highest priority for project completeness.

---

## 📧 Contact & Contributions

**Repository**: https://github.com/tomasdata/Trade-Finance  
**Issues**: Use GitHub Issues for data questions or bugs  
**Contributions**: Pull requests welcome for data updates or script improvements

**Data Provider Credits**:
- 🇧🇷 Banco Central do Brasil (BCB) - SCR Sistema de Crédito
- 🇨🇱 Comisión para el Mercado Financiero (CMF)
- 🇲🇽 Comisión Nacional Bancaria y de Valores (CNBV)
- 🇵🇪 Superintendencia de Banca, Seguros y AFP (SBS)
- 🏦 US Federal Reserve / FFIEC
- 🌐 Bank for International Settlements (BIS)
- 📦 CEPII (BACI Trade Database)
- 🇺🇸 US EXIM Bank
- 📋 FCIB Association

---

**Last Updated**: January 2025  
**Data Coverage**: 2015-2024 (Mexico: 2015-2019, 2022-2025)  
**Total Observations**: 1,700,000+  
**Languages**: R, Python  
**License**: Data subject to original provider terms, analysis code open for academic use
