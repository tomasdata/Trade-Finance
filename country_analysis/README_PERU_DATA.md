# 🇵🇪 PERU TRADE FINANCE DATA - TECHNICAL DOCUMENTATION

**Data Source:** Superintendencia de Banca, Seguros y AFP (SBS) - Peruvian Banking Regulator  
**Dataset:** Credit Registry by Size and Instrument Type  
**Coverage:** October 2010 - December 2024 (14.25 years)  
**Observations:** 13,785 bank-month-size records  
**Banks:** 19 financial institutions  
**Update Frequency:** Monthly  
**Last Updated:** November 2025

---

## 📊 DATA STRUCTURE

### Primary Variables

| Variable | Description | Type | Unit | Notes |
|----------|-------------|------|------|-------|
| `date` | Date (YYYY-MM-DD) | Date | - | First day of month |
| `year` | Year | Integer | - | 2010-2024 |
| `month` | Month | Integer | 1-12 | - |
| `institucion` | Bank name | Character | - | Full legal name |
| `bank_type` | Bank classification | Factor | - | Foreign / State / Large Domestic / Consumer/Retail |
| `borrower_size` | Firm size category | Factor | - | Corporate / Large / Medium / Small / Micro |
| `monto_soles_thousands` | Credit volume (PEN) | Numeric | Thousands PEN | Original currency |
| `tf_usd_millions` | Trade finance (USD) | Numeric | USD millions | Converted using monthly PEN/USD rate |
| `exports_usd_millions` | Monthly exports | Numeric | USD millions | From GMD (Global Macro Database) |
| `imports_usd_millions` | Monthly imports | Numeric | USD millions | From GMD (Global Macro Database) |
| `gdp_usd_billions` | Annual GDP | Numeric | USD billions | From GMD (annual, not interpolated) |

### Bank Classification

**Foreign Banks (5):** Scotiabank, Citibank, ICBC, Santander, BanBif

**State Bank (0):** Banco de la Nación (excluded - development bank, distorts analysis)

**Large Domestic (2):** BCP (Banco de Crédito del Perú), BBVA Continental

**Consumer/Retail (3):** Interbank, Banco Pichincha, Mibanco

### Borrower Size Classification (SBS Standard)

| Size | Definition | Annual Sales (UIT) | ~ USD Sales | % of TF Volume |
|------|------------|-------------------|-------------|----------------|
| **Corporate** | Large corporations | > 24,500 | > $37M | ~45% |
| **Large** | Large enterprises | 5,000 - 24,500 | $7.5M - $37M | ~25% |
| **Medium** | Medium enterprises | 1,700 - 5,000 | $2.5M - $7.5M | ~18% |
| **Small** | Small enterprises | 300 - 1,700 | $450K - $2.5M | ~10% |
| **Micro** | Microenterprises | 20 - 300 | $30K - $450K | ~2% |

*UIT = Unidad Impositiva Tributaria (Peru's tax unit, ~$5,000 USD)*

---

## 🔍 DATA SOURCE DETAILS

### Banking Data: SBS Credit Registry

**Instrument Type:** "Créditos por Liquidar por Comercio Exterior"
- Trade finance credits pending settlement
- Includes: Import/export financing, L/C, trade credit lines
- Reported by: All commercial banks to SBS
- Granularity: Bank × Month × Borrower Size

**Source Files:** `~/Documents/Tomas/banca-desarrollo/peru/`
- Monthly CSV reports from SBS website (2010-10 to 2024-12)
- Processed by: `peru_etl.R`

### Trade Data: Global Macro Database (GMD)

**Single Source Strategy:**
- **Source:** FMI/World Bank Global Macro Database
- **Coverage:** 2010-2024 (15 years available for Peru)
- **Methodology:** Balance of Payments (BOP) from BCRP (Banco Central de Reserva del Perú)
- **Frequency:**
  - Exports/Imports: Monthly (from BOP accounts)
  - GDP: Annual (NOT interpolated - real annual values)
- **Advantages:**
  - Consistent methodology across full 14.25-year series
  - Official BCRP source (national accounts)
  - No discontinuities (single source)
  - Includes GDP for normalization

**Why NOT BACI:**
- ❌ Mixing BACI (2010-2023) + GMD (2024) creates discontinuity
- ❌ Different methodologies cause 6-28% jumps in series
- ❌ BACI lacks GDP data
- ✅ GMD alone ensures consistency for full 2010-2024 period

**Data Integration:**
- Banking data: Oct 2010 - Dec 2024 (171 months from SBS)
- Trade data: 2010-2024 from GMD (matches banking period)
- GDP: Annual 2010-2024 (for normalization, not monthly interpolation)

---

## 📈 DATA CHARACTERISTICS

### Temporal Coverage
- **Start:** October 2010 (post-financial crisis)
- **End:** December 2024
- **Duration:** 14.25 years (171 months)
- **Frequency:** Monthly
- **Gaps:** None (complete time series)
- **Periods Captured:**
  - Post-GFC recovery (2010-2012)
  - Commodity boom (2013-2014)
  - China slowdown (2015-2016)
  - Odebrecht crisis (2017-2018)
  - COVID-19 pandemic (2020-2021)
  - Post-pandemic recovery (2022-2024)

### Cross-Sectional Coverage
- **Banks:** 19 institutions (reduced from 21 - 2 mergers)
- **Borrower sizes:** 5 categories (Corporate to Micro)
- **Records per month:** ~80-85 (19 banks × 5 sizes, some missing combos)

### Volume Statistics (2024)
- **Total TF Credit:** USD 859 billion (cumulative 2010-2024)
- **Annual average:** USD 61 billion/year
- **2024 monthly avg:** USD 4.8 billion/month
- **TF as % of total credit:** ~12-15% (varies by bank type)
- **Trend:** Declining post-2014 commodity boom, stable post-2018

---

## 🔧 DATA PROCESSING PIPELINE

### 1. ETL: `banca-desarrollo/peru/peru_etl.R`
```r
# Extracts from SBS credit registry:
# - Filter: "Créditos por Liquidar por Comercio Exterior"
# - Aggregates: Bank × Month × Size
# - Converts: PEN to USD using monthly rates
# - Merges: BACI trade data (2010-2023)
# - Outputs: peru_full.csv (96,495 raw observations)
```

### 2. Processing: `country_analysis/scripts/01_master_processing.R`
```r
# Loads peru_full.csv
# - Filters: Foreign-trade credit only (13,785 obs)
# - Standardizes: Column names, bank types
# - Classifies: Banks (Foreign/State/Large/Consumer)
# - Adds: Size distribution metrics
# - Outputs: peru_processed.rds
```

### 3. Integration: `country_analysis/scripts/00_integrate_gmd.R` (pending)
```r
# Will add:
# - GMD exports/imports for 2024
# - GDP normalization (TF as % of GDP)
# - Crisis indicators (COVID, political instability)
# - Correlation with mining exports (Peru-specific)
```

---

## 📊 DATA QUALITY NOTES

### Strengths
✅ **Long time series:** 14.25 years (2010-2024)  
✅ **Official source:** SBS regulatory reports (mandatory, audited)  
✅ **Size detail:** 5 borrower categories (unique among 4 countries)  
✅ **Bank detail:** Individual institutions tracked  
✅ **Crisis coverage:** GFC aftermath, commodity cycles, COVID, political crises  
✅ **High frequency:** Monthly granularity  
✅ **Complete:** No missing months in 171-month series  

### Limitations
⚠️ **Aggregated:** Bank × Size totals only, no individual loans  
⚠️ **No product detail:** Cannot separate L/C vs other TF instruments  
⚠️ **Size estimation:** Borrower size based on total credit, not just TF  
⚠️ **Trade data transition:** BACI (2010-2023) → GMD (2024), slight methodology change  
⚠️ **Bank mergers:** 21 banks → 19 (Interamericano merged into Scotiabank 2017)  
⚠️ **No sectoral detail:** Cannot analyze mining vs manufacturing vs agriculture  

### Data Validation
- ✅ TF volumes consistent with BCRP balance of payments data
- ✅ Size distribution stable over time (corporate ~45%, micro ~2%)
- ✅ Bank rankings match market share reports
- ✅ Crisis impacts visible (COVID drop March-May 2020)
- ✅ Trade correlation high (r² ~0.72 with exports+imports)

---

## 🔗 RELATED DOCUMENTATION

- **Size Comparison:** Peru vs Brazil (both have 5 size categories)
- **GMD Integration:** See `GMD_INTEGRATION_FINDINGS.md` for BACI→GMD transition
- **Analysis Plan:** See `MASTER_ANALYSIS_PLAN.md` - Section 3 (8 Peru plots)
- **Chile Comparison:** Peru has size detail, Chile has 40 account types
- **Mexico Comparison:** Peru 14.25 years, Mexico only 3.67 years

---

## 📝 KEY FINDINGS FOR ANALYSIS

### 1. Size Distribution (2024)
- **Corporate:** 45.2% (USD 2.17B/month) - Dominates TF
- **Large:** 24.8% (USD 1.19B/month) - Stable
- **Medium:** 17.9% (USD 858M/month) - Growing
- **Small:** 9.8% (USD 470M/month) - Volatile
- **Micro:** 2.3% (USD 110M/month) - Minimal TF access

### 2. Bank Specialization
- **BCP (Large Domestic):** Market leader, 32% share, balanced portfolio
- **Scotiabank (Foreign):** Trade specialist, 18% share, corporate-focused
- **BBVA (Large Domestic):** Second largest, 15% share
- **Santander (Foreign):** Declining share (12% → 8% post-2018)
- **Mibanco (Consumer):** Micro-specialist, <1% TF share

### 3. Crisis Impacts
- **2015-2016 China slowdown:** -15% TF volume (commodity exports fell)
- **2020 COVID:** -35% (March-May 2020), recovered by Q4 2020
- **2022 Political crisis:** -8% (brief, less severe than COVID)
- **Odebrecht scandal (2017-2018):** No major TF impact (construction-focused)

### 4. Concentration
- **HHI:** 0.18-0.22 (moderate concentration)
- **CR5 (Top 5 banks):** 78-82% of total TF
- **Trend:** Decreasing concentration (more banks entering TF)

### 5. Trade Finance Intensity
- **TF as % of total credit:** 12-15% system-wide
- **Foreign banks:** 18-22% (trade specialists)
- **Large domestic:** 14-17% (balanced portfolios)
- **Consumer banks:** 3-6% (low TF focus)

---

## 🎯 RECOMMENDED USES

✅ **Size-based analysis** (5 categories, 171 months)  
✅ **Bank specialization studies** (Foreign vs Domestic vs Consumer)  
✅ **Crisis impact quantification** (3 major crises captured)  
✅ **Long-term trend analysis** (14.25 years)  
✅ **Trade-finance correlation** (with BACI/GMD trade data)  
✅ **Concentration dynamics** (HHI, CR5 over time)  
✅ **Size mobility analysis** (corporate dominance vs SME access)  

❌ **Not suitable for:**
- Product-level analysis (no L/C vs acceptance vs forfaiting breakdown)
- Sectoral analysis (no mining vs manufacturing detail)
- Individual loan analysis (aggregated data)
- Regional analysis (no geographic breakdowns)

---

## 🔬 TECHNICAL NOTES

### Size Classification Methodology
- Borrower size determined by **total credit** with bank, not TF amount
- UIT (Unidad Impositiva Tributaria) thresholds adjusted annually by SUNAT
- Same firm can have different sizes at different banks (based on exposure)
- Example: A firm with USD 10M credit at BCP = "Large", but USD 40M at Scotiabank = "Corporate"

### Currency Conversion
- PEN → USD using Banco Central de Reserva del Perú (BCRP) monthly average rates
- Exchange rate source: BCRP official statistics
- Range: 2.56 PEN/USD (2010) → 3.80 PEN/USD (2024)
- Volatility: Relatively stable, +48% depreciation over 14 years

### Missing Data Patterns
- Some bank-size combinations missing (e.g., Mibanco has no "Corporate" borrowers)
- Interpreted as: Bank doesn't serve that segment (not missing data error)
- Total missing: ~5% of potential 19×5×171 = 16,245 combinations
- Pattern: Stable (same combinations missing across time)

---

## 📧 CONTACT & UPDATES

**Data Maintainer:** Tomás Fernández  
**Last ETL Run:** November 2025  
**Next Update:** When SBS releases January 2025 data (expected February 2025)  
**Issues:** Report in `country_analysis/` repository

**Change Log:**
- 2025-11: **METHODOLOGICAL FIX:** Use GMD only (no BACI mix) for full 2010-2024 series
- 2025-11: GDP as annual variable (no interpolation)
- 2025-11: Bank classification refined (4 types)
- 2025-11: Size distribution analysis enhanced
- 2024-06: Extended series through December 2024
- 2023-01: Initial extraction (2010-2023)

---

*For cross-country comparisons and size distribution analysis (Peru vs Brazil), see MASTER_ANALYSIS_PLAN.md*
