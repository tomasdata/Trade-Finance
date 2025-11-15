# Trade Finance Research Project

## 📊 Project Overview

This repository contains a comprehensive research project analyzing trade finance markets across Latin America and global banking systems. The project integrates multiple data sources to provide insights into trade credit availability, market structure, and cross-country patterns.

**Principal Investigator**: Tomas Fernandez  
**Last Updated**: November 2025  
**Status**: Active Research

---

## 🎯 Research Objectives

1. **Analyze trade finance market structure** across Brazil, Chile, Mexico, and Peru
2. **Measure SME access** to trade credit instruments
3. **Compare cross-country patterns** in trade finance provision
4. **Track temporal evolution** of trade finance markets (2015-2024+)
5. **Quantify bank concentration** and market dynamics

---

## 📁 Repository Architecture

```
Trade-Finance/
│
├── pre-data/                           # Raw and intermediate data
│   ├── Brasil/                         # Brazil Central Bank data
│   ├── Chile/                          # Chilean Financial Market Commission data
│   ├── Mexico/                         # Mexican Banking Commission data
│   ├── Peru/                           # Peruvian Banking Superintendency data
│   ├── FFIEC 009/                      # U.S. bank international exposure data
│   ├── Consolidated banking statistics BIS.csv  # Bank for International Settlements
│   ├── baci_trade_cty.csv             # International trade flows (BACI-CEPII)
│   ├── WUI_Data.csv                    # World Uncertainty Index
│   └── exim auth.csv                   # U.S. Export-Import Bank authorizations
│
├── Scripts/                            # Data processing and analysis
│   ├── brasil_etl.R                    # Brazil data extraction and transformation
│   ├── chile_etl.R                     # Chile data processing
│   ├── mexico_lc_etl.R                 # Mexico letters of credit analysis
│   ├── peru_etl.R                      # Peru data processing
│   ├── generate_all_country_data.py    # Automated data generation
│   ├── generate_cross_country_analysis.py  # Cross-country comparisons
│   ├── fcib_pdf_extract.py             # FCIB survey extraction
│   └── country_profiles.R              # Generate country profiles
│
├── tables_and_graphs/                  # Generated analysis outputs
│   ├── Brazil/                         # Brazilian market analysis
│   ├── Chile/                          # Chilean market analysis
│   ├── Mexico/                         # Mexican market analysis
│   ├── Peru/                           # Peruvian market analysis
│   ├── Cross_Country_Comparisons/      # Comparative analysis
│   ├── BIS/                            # Global banking statistics
│   └── EXIM/                           # U.S. export credit analysis
│
├── documents/                          # Source documents and surveys
│   └── FCIB_Credit_Collections_Survey/ # Monthly FCIB surveys (2023-2025)
│
├── data/                               # Documentation and guides
│   └── GUIA_COMPLETA_TRADE_FINANCE.md  # Complete methodology guide
│
└── presentations/                      # Research presentations
    └── Trade_Finance.tex               # Main presentation
```

---

## 📊 Data Sources & Coverage

### 1. **Brazil** 🇧🇷
- **Source**: Banco Central do Brasil (SCR - Sistema de Informações de Crédito)
- **File**: `Brasil/brasil_full.csv` (220 MB via Git LFS)
- **Period**: 2015-2024
- **Granularity**: Monthly, firm-level
- **Coverage**: 
  - Trade finance credit by firm size (micro, small, medium, large)
  - Sectoral breakdown (industry, commerce, services, agriculture)
  - Regional distribution (all 27 states)
  - Maturity structure
  - NPL rates
  - Currency composition (BRL vs USD)
- **Limitations**: 
  - Firm identifiers are anonymized
  - Only includes bank-intermediated trade credit
  - Excludes non-bank trade finance

### 2. **Chile** 🇨🇱
- **Source**: Comisión para el Mercado Financiero (CMF)
- **File**: `Chile/chile_full.csv` (195 MB via Git LFS)
- **Period**: 2015-2024
- **Granularity**: Monthly, bank-level
- **Coverage**:
  - Letters of credit issued
  - Import/export credit lines
  - Currency breakdown (CLP, USD, EUR)
  - Bank concentration
  - Top 10 banks market share
- **Limitations**:
  - No firm-size breakdown
  - Limited sectoral information
  - Focus on documented credits only

### 3. **Mexico** 🇲🇽
- **Source**: Comisión Nacional Bancaria y de Valores (CNBV)
- **File**: `Mexico/040_R12A_1219_133.csv` (129 MB via Git LFS)
- **Period**: 2015-2019
- **Granularity**: Monthly, bank-level
- **Coverage**:
  - Letters of credit volumes
  - Bank-level issuance
  - Seasonality patterns
- **Limitations**:
  - **Data coverage ends in 2019** (major limitation)
  - No firm-size breakdown
  - Limited to letters of credit only

### 4. **Peru** 🇵🇪
- **Source**: Superintendencia de Banca, Seguros y AFP (SBS)
- **File**: `Peru/peru_full.csv`
- **Period**: 2015-2024
- **Granularity**: Monthly, firm-size categories
- **Coverage**:
  - Trade credit by firm size
  - Credit type distribution
  - Dollarization ratios
  - Bank concentration
- **Limitations**:
  - No sectoral breakdown
  - Limited regional data

### 5. **FFIEC 009** 🏦
- **Source**: Federal Financial Institutions Examination Council (U.S.)
- **Directory**: `FFIEC 009/`
- **Period**: 2015Q2-2024Q4 (quarterly)
- **Coverage**:
  - U.S. bank exposure to foreign countries
  - Cross-border claims by country
  - Trade finance facilities
  - Large bank reporting (>$30B assets)
- **Limitations**:
  - Only captures U.S. bank activity
  - Quarterly frequency
  - Aggregated country-level data

### 6. **BIS Consolidated Banking Statistics** 🌐
- **Source**: Bank for International Settlements
- **File**: `Consolidated banking statistics BIS.csv` (136 MB via Git LFS)
- **Period**: 2015-2024
- **Granularity**: Quarterly, country-pairs
- **Coverage**:
  - Global banking exposure by reporting country
  - Claims by counterparty sector
  - Maturity breakdown
- **Limitations**:
  - Does not isolate trade finance
  - Reporting standards vary by country

### 7. **BACI International Trade Data** 📦
- **Source**: CEPII (Centre d'Études Prospectives et d'Informations Internationales)
- **File**: `baci_trade_cty.csv`
- **Period**: 2015-2023
- **Coverage**:
  - Bilateral trade flows
  - Product-level detail (HS codes)
- **Use**: Calculate trade finance penetration ratios

### 8. **U.S. EXIM Bank Authorizations** 🇺🇸
- **Source**: Export-Import Bank of the United States
- **File**: `exim auth.csv`
- **Period**: 2015-2024
- **Coverage**:
  - Export credit authorizations to Latin America
  - Program mix (insurance, guarantees, loans)
  - Small business participation

### 9. **FCIB Surveys** 📋
- **Source**: Finance, Credit & International Business Association
- **Directory**: `documents/`
- **Period**: 2023-2025 (monthly)
- **Coverage**:
  - Credit manager sentiment
  - Collection periods by country
  - Credit terms trends

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

## 🚀 Quick Start

### Prerequisites
```bash
# R packages
install.packages(c("tidyverse", "readxl", "lubridate", "zoo"))

# Python packages
pip install pandas numpy openpyxl PyPDF2
```

### Generate All Analysis
```bash
# From Scripts/ directory
Rscript brasil_etl.R
Rscript chile_etl.R
Rscript mexico_lc_etl.R
Rscript peru_etl.R

python generate_all_country_data.py
python generate_cross_country_analysis.py

Rscript country_profiles.R
```

### Access Pre-Generated Tables
```bash
# All analysis outputs are in tables_and_graphs/
cd tables_and_graphs/

# Country-specific
ls Brazil/
ls Chile/
ls Mexico/
ls Peru/

# Cross-country comparisons
ls Cross_Country_Comparisons/
```

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

## 🙏 Acknowledgments

Data sources:
- Banco Central do Brasil
- Comisión para el Mercado Financiero (Chile)
- Comisión Nacional Bancaria y de Valores (Mexico)
- Superintendencia de Banca, Seguros y AFP (Peru)
- Bank for International Settlements
- FFIEC / Federal Reserve
- CEPII-BACI
- FCIB Association

---

**Last Updated**: November 15, 2025  
**Version**: 1.0  
**Build Status**: ✅ All pipelines operational
