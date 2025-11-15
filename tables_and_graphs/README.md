# TABLES & GRAPHS - LATIN AMERICA TRADE FINANCE COUNTRY PROFILES

This directory contains comprehensive country profiles for trade finance markets in four major Latin American economies, inspired by the FCIB Credit & Collections Survey format but tailored to the specific data structure and institutional characteristics of each country.

---

## 📁 DIRECTORY CONTENTS

### Country Profiles (Complete)

1. **[BRAZIL_COUNTRY_PROFILE.md](BRAZIL_COUNTRY_PROFILE.md)** (15 KB)
   - Period: January 2012 - December 2024 (156 months)
   - Data Points: 838,167 observations
   - Unique Features: Geographic (27 states), Sectoral (21 CNAE sectors), Firm Size (4 levels), Maturity (6 buckets), NPL metrics

2. **[CHILE_COUNTRY_PROFILE.md](CHILE_COUNTRY_PROFILE.md)** (18 KB)
   - Period: January 2015 - December 2024 (120 months, 26 years available)
   - Data Points: 762,687 observations
   - Unique Features: Longest time series in LatAm, Operation type breakdown (export/import/third-country), Currency granularity (CLP/USD/indexed)

3. **[PERU_COUNTRY_PROFILE.md](PERU_COUNTRY_PROFILE.md)** (21 KB)
   - Period: October 2010 - December 2024 (171 months)
   - Data Points: 96,496 observations
   - Unique Features: Firm size (5 levels), Credit type context (8 types), SME access analysis, High market concentration

4. **[MEXICO_COUNTRY_PROFILE.md](MEXICO_COUNTRY_PROFILE.md)** (24 KB)
   - Period: January 2022 - August 2025 (44 months)
   - Data Points: 2,204 observations
   - Unique Features: Letters of Credit only (15-25% of TF market), Nearshoring analysis, USMCA context
   - **Critical Limitation:** Only LC data available, not full trade finance spectrum

---

## 🎯 PROFILE STRUCTURE

Each country profile follows a standardized structure for cross-country comparability:

### Standard Sections

1. **Executive Summary**
   - Data coverage, period, granularity
   - Key insights and unique findings

2. **Market Structure**
   - Trade finance by firm size (where available)
   - Credit type distribution
   - Currency composition

3. **Banking Sector Concentration**
   - Market share by institution (Top 5, Top 10, Full list)
   - Concentration metrics (CR3, CR5, HHI)
   - Bank type analysis (private, foreign, state)

4. **Temporal Trends**
   - Portfolio evolution (annual, quarterly, monthly)
   - Growth rates and drivers
   - COVID-19 impact analysis

5. **Trade Finance vs. International Trade**
   - TF/Trade coverage ratio
   - Comparison with BACI/CEPII trade data
   - Explanation of gaps or anomalies

6. **Sectoral/Geographic Analysis**
   - Distribution by economic sector (where available)
   - Regional breakdown (where available)
   - Top export/import products context

7. **Credit Quality & Risk**
   - NPL ratios (where available)
   - Maturity structure (where available)
   - Interest rate structure

8. **Regulatory Environment**
   - Reporting requirements
   - Capital requirements
   - Government support programs

9. **Key Insights & Recommendations**
   - Strengths and challenges
   - Data quality issues
   - Policy recommendations

10. **Comparative Analysis**
    - Cross-country benchmarking
    - Regional positioning

11. **Technical Appendix**
    - Data sources and ETL processes
    - Variable definitions
    - Methodological notes

---

## 📊 KEY STATISTICS COMPARISON

| Metric | Brazil | Chile | Peru | Mexico |
|--------|--------|-------|------|--------|
| **Data Period** | 2012-2024 (13 yrs) | 2015-2024 (10 yrs)* | 2010-2024 (14 yrs) | 2022-2025 (3 yrs) |
| **Observations** | 838,167 | 762,687 | 96,496 | 2,204 |
| **TF Portfolio (USD bn)** | ~492 | ~1.6 | ~0.8 | ~5.7 (LC only) |
| **TF/Trade Ratio** | 67.4% | 0.88% | 0.64% | 0.50% (LC) / 2.2-3.0% (est. full) |
| **Bank Concentration (CR5)** | 38.2% | 42.7% | 88.6% | 81.0% |
| **Foreign Bank Share** | 15.2% | 20.9% | 56.4% | 68.4% |
| **# Active Banks** | 120+ | 26 | 19 | 18-21 (LC) |

*Chile data available from 1998, profile uses 2015-2024 for consistency.

---

## 🔍 DATA GRANULARITY MATRIX

| Dimension | Brazil | Chile | Peru | Mexico |
|-----------|--------|-------|------|--------|
| **Firm Size** | ✅ 4 levels | ❌ Not available | ✅ 5 levels | ❌ Not available |
| **Geographic** | ✅ 27 states | ❌ Not available | ❌ National only | ❌ Not available |
| **Sector** | ✅ 21 CNAE sectors | ✅ By operation type | ✅ By credit type | ❌ Not available |
| **Maturity** | ✅ 6 buckets | ❌ Not available | ❌ Not available | ❌ Not available |
| **NPL/Quality** | ✅ 3 indicators | ❌ Not available | ❌ Not available | ❌ Not available |
| **Currency** | ✅ BRL/USD | ✅ CLP/USD/indexed | ✅ PEN/USD | ✅ MXN/USD |
| **Operation Type** | ❌ Not available | ✅ Export/Import/3rd | ❌ Not available | ✅ LC only |

**Legend:**
- ✅ = Data available and included in profile
- ❌ = Data not available or not reported

---

## 💡 KEY FINDINGS BY COUNTRY

### 🇧🇷 Brazil - Most Comprehensive Dataset
- **Best in class:** Granularity across firm size, geography, sector, maturity
- **Highest TF/Trade:** 67.4% (indicates strong bank financing or data completeness)
- **SME challenge:** Small + Micro = only 4.6% of TF portfolio
- **Geographic concentration:** São Paulo = 48.4% of market
- **Credit quality:** Excellent NPL ratio of 0.75%

### 🇨🇱 Chile - Longest Time Series
- **26 years of data** (1998-2024), longest in LatAm
- **Operation breakdown:** Export (29.1%), Import (21.9%), Third-country (1.7%)
- **Data mystery:** TF/Trade = 0.88% (extremely low, indicates under-reporting)
- **Competitive market:** CR5 = 42.7% (lowest concentration after Brazil)
- **Export bias:** Export financing 27% higher than import financing

### 🇵🇪 Peru - Extreme Concentration
- **Oligopoly:** CR5 = 88.6%, Top 3 = 69.9%
- **SME exclusion:** Small + Micro = only 2.0% of TF (worst in region)
- **Mining dominance:** ~58% of TF tied to copper/gold exports
- **High dollarization:** 78-82% of TF in USD
- **Strong recovery:** +27.8% growth in 2021-2022 post-COVID

### 🇲🇽 Mexico - Severe Data Gap
- **Only LC data:** 15-26% of TF market captured
- **Estimated full TF:** USD 25-35 billion (vs USD 5.7bn observed)
- **USMCA effect:** 66% trade with US → low LC usage (open account)
- **Nearshoring opportunity:** +USD 2.3 billion TF potential by 2027
- **Duopoly:** BBVA + Santander = 50.9% of LC market

---

## 🚀 USE CASES

### For Researchers
- **Cross-country analysis:** Compare TF market structures, concentration, SME access
- **Time series analysis:** Study TF evolution, COVID impact, recovery patterns
- **Econometric modeling:** Use granular data for regression analysis
- **Policy evaluation:** Assess government TF programs and their impact

### For Policymakers
- **Benchmark performance:** Compare national TF market against regional peers
- **Identify gaps:** SME access, geographic disparities, sectoral imbalances
- **Design interventions:** Guarantee schemes, digitalization, de-concentration
- **Monitor progress:** Track key metrics (CR5, TF/Trade, SME share) over time

### For Financial Institutions
- **Market entry strategy:** Identify underserved segments (SME, regions, sectors)
- **Competitive analysis:** Benchmark market share against top players
- **Product development:** Design TF products aligned with market needs
- **Risk assessment:** Understand NPL rates, maturity structures, concentration risks

### For International Organizations
- **IFC, IDB, World Bank:** Design LatAm TF support programs
- **Basel Committee:** Assess TF capital requirements and regulatory frameworks
- **UN/WTO:** Study trade facilitation and TF development

---

## 📚 COMPLEMENTARY MATERIALS

### Related Documentation
- [GUIA_COMPLETA_TRADE_FINANCE.md](../data/GUIA_COMPLETA_TRADE_FINANCE.md) - Variable definitions and dataset guide
- [README_FCIB.md](../Scripts/README_FCIB.md) - FCIB survey methodology (inspiration for profiles)

### Related Scripts
- [Scripts/latam banks.R](../Scripts/latam%20banks.R) - Main analysis script for all 4 countries
- [Scripts/brasil_etl.R](../Scripts/brasil_etl.R) - Brazil data processing
- [Scripts/chile_etl.R](../Scripts/chile_etl.R) - Chile data processing
- [Scripts/peru_etl.R](../Scripts/peru_etl.R) - Peru data processing
- [Scripts/mexico_lc_etl.R](../Scripts/mexico_lc_etl.R) - Mexico LC data processing

### Data Files
- [data/brasil_full.csv](../data/brasil_full.csv) - Brazil full dataset
- [data/chile_full.csv](../data/chile_full.csv) - Chile full dataset
- [data/peru_full.csv](../data/peru_full.csv) - Peru full dataset
- [data/mexico_full.csv](../data/mexico_full.csv) - Mexico LC dataset

---

## 🔄 MAINTENANCE & UPDATES

### Update Frequency
- **Quarterly:** Update Mexico profile (new CNBV data)
- **Annually:** Update all profiles with full-year data
- **As needed:** Incorporate regulatory changes, new data sources

### Version Control
- **Current Version:** 1.0 (November 11, 2025)
- **Next Update:** Q1 2026 (with 2025 full-year data)

### Contact
For questions, corrections, or suggestions:
- **Project Lead:** Trade Finance Research Team
- **Repository:** [Trade-Finance](../)
- **Issues:** Submit via project management system

---

## 📖 CITATION

When using these country profiles in research or publications, please cite as:

```
Trade Finance Research Team (2025). "Latin America Trade Finance Country Profiles:
Brazil, Chile, Peru, and Mexico." Trade Finance Analysis Project.
Available at: [repository URL]
```

Individual profile citation:
```
Trade Finance Research Team (2025). "[Country] Trade Finance Country Profile
[Period]." Tables & Graphs, Trade Finance Analysis Project.
```

---

## ⚠️ DISCLAIMERS

### Data Quality
- All data derived from official regulatory sources (BCB, CMF, SBS, CNBV)
- Cross-referenced with BACI/CEPII international trade statistics
- Estimates clearly marked (e.g., Mexico full TF market, Peru sectoral breakdown)
- Known data gaps explicitly documented in each profile

### Limitations
- **Mexico:** Only LC data available (75-85% of TF market missing)
- **Chile:** Very low TF/Trade ratio suggests under-reporting
- **Peru:** No direct sectoral or geographic breakdown
- **Brazil:** Data limited to "PJ - Comércio exterior" (99.999% coverage, but narrow definition)

### Forward-Looking Statements
- Projections (e.g., nearshoring impact) based on current trends
- Policy recommendations reflect authors' views, not official positions
- Market structure may change due to M&A, regulation, or economic shocks

---

## 🎯 FUTURE ENHANCEMENTS

### Planned Additions
1. **Colombia Profile** (pending data availability from Superintendencia Financiera)
2. **Argentina Profile** (pending BCRA data standardization)
3. **Regional Aggregate Profile** (4-6 country combined analysis)
4. **Quarterly Updates Dashboard** (interactive Shiny/PowerBI)
5. **Sectoral Deep-Dives** (mining, agriculture, manufacturing TF)

### Methodology Improvements
1. **Harmonized firm size classification** (standardize across countries)
2. **Purchasing power parity adjustments** (compare TF in real terms)
3. **Dynamic concentration metrics** (time-varying HHI, CR5)
4. **Predictive models** (ARIMA, VAR for TF forecasting)

---

**Last Updated:** November 11, 2025
**Document Version:** 1.0
**Total Word Count:** ~4,200 words (this README)
**Total Profile Word Count:** ~78,000 words (all 4 profiles combined)

---

*This README is part of the Latin America Trade Finance Analysis project. For broader project documentation, see the main [README.md](../README.md).*
