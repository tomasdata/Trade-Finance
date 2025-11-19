# 🇧🇷 BRAZIL TRADE FINANCE DATA - TECHNICAL DOCUMENTATION

**Data Source:** Banco Central do Brasil (BCB) - Brazilian Central Bank  
**Dataset:** Credit Operations by State, Sector, and Borrower Size (SCR System)  
**Coverage:** January 2012 - December 2024 (13 years)  
**Observations:** 838,166 state-sector-size-month records  
**Geographic Units:** 27 states (26 states + Federal District)  
**Update Frequency:** Monthly  
**Last Updated:** November 2025

---

## 📊 DATA STRUCTURE

### Primary Variables

| Variable | Description | Type | Unit | Notes |
|----------|-------------|------|------|-------|
| `date` | Date (YYYY-MM-DD) | Date | - | First day of month |
| `year` | Year | Integer | - | 2012-2024 |
| `month` | Month | Integer | 1-12 | - |
| `estado` | State code | Character | 2-letter | AC, AL, AM, ..., TO, DF |
| `estado_nome` | State name | Character | - | Full Portuguese name |
| `regiao` | Geographic region | Factor | - | 5 regions (see below) |
| `setor` | Economic sector | Factor | - | 19 sectors aggregated to 8 |
| `porte` | Borrower size | Factor | - | Micro / Small / Medium / Large / Unknown |
| `modalidade` | TF modality | Factor | - | ACC / ACE / FINIMP / NCE |
| `valor_brl_thousands` | Credit volume (BRL) | Numeric | Thousands BRL | Original currency |
| `tf_usd_millions` | Volume (USD) | Numeric | USD millions | Converted using monthly BRL/USD rate |
| `exports_usd_millions` | Monthly exports | Numeric | USD millions | From GMD (Global Macro Database) |
| `imports_usd_millions` | Monthly imports | Numeric | USD millions | From GMD (Global Macro Database) |
| `gdp_usd_billions` | Annual GDP | Numeric | USD billions | From GMD (annual, not interpolated) |

### Geographic Regions (5)

| Region | States | % of TF Volume (2024) | Economic Profile |
|--------|--------|-----------------------|------------------|
| **Southeast** | SP, RJ, MG, ES | 43.7% | Industrial hub, ports, services |
| **South** | PR, SC, RS | 37.6% | Agriculture, manufacturing, exports |
| **Center-West** | GO, MT, MS, DF | 6.3% | Agribusiness, logistics |
| **Northeast** | BA, PE, CE, RN, PB, SE, AL, MA, PI | 10.2% | Agriculture, textiles, oil |
| **North** | PA, AM, RO, AC, AP, RR, TO | 2.2% | Commodities, Amazon region |

### Economic Sectors (8 aggregated)

| Sector | Description | % of TF Volume (2024) | Key States |
|--------|-------------|------------------------|------------|
| **Manufacturing** | Industrial production | 54.8% | SP, PR, RS |
| **Wholesale/Retail** | Trade distribution | 29.5% | SP, RJ, MG |
| **Agriculture** | Farming, livestock | 5.0% | PR, RS, GO, MT |
| **Transport/Logistics** | Shipping, warehousing | 2.9% | SP, RJ, ES (ports) |
| **Mining** | Extraction industries | 1.2% | MG, PA |
| **Construction** | Building, infrastructure | 1.0% | SP, RJ |
| **IT/Communication** | Tech services | 0.9% | SP, RJ |
| **Other** | Miscellaneous | 4.7% | Various |

### Borrower Size (5 categories)

| Size | Definition | Annual Revenue (BRL) | % of TF Volume (2024) |
|------|------------|----------------------|------------------------|
| **Large** | Large corporations | > 300 million | 26.4% |
| **Medium** | Medium enterprises | 4.8 - 300 million | 53.5% |
| **Small** | Small enterprises | 360K - 4.8 million | 15.6% |
| **Micro** | Microenterprises | < 360K | 4.0% |
| **Unknown** | Not classified | - | 0.5% |

### Trade Finance Modalities (4 types)

| Modality | Description | % of TF (2024) | Purpose |
|----------|-------------|----------------|---------|
| **ACC** | Adiantamento sobre Contrato de Câmbio | 42% | Pre-shipment export financing |
| **ACE** | Adiantamento sobre Cambiais Entregues | 28% | Post-shipment export financing |
| **FINIMP** | Financiamento à Importação | 25% | Import financing |
| **NCE** | Nota de Crédito à Exportação | 5% | Export credit note |

---

## 🔍 DATA SOURCE DETAILS

### Banking Data: Banco Central SCR System

**Source:** Sistema de Informações de Crédito (SCR) - Credit Information System
- **Granularity:** State × Sector × Size × Modality × Month
- **Coverage:** All financial institutions in Brazil (banks, cooperatives, fintechs)
- **Regulatory basis:** Resolution 4.571/2017 (SCR data sharing)
- **Aggregation level:** No individual banks (regional/sectoral focus)

**Key Difference from Other Countries:**
- 🚫 **No bank-level data** (only system aggregates)
- ✅ **Geographic detail** (27 states, 5 regions)
- ✅ **Sectoral detail** (19 sectors → 8 aggregated)
- ✅ **Size detail** (5 categories like Peru)
- ✅ **Modality detail** (4 TF instruments unique to Brazil)

**Source Files:** `~/Documents/Tomas/banca-desenvolvimento/brasil/`
- Monthly CSV files from BCB Data Portal (2012-01 to 2024-12)
- Processed by: `brasil_etl.R`

### Trade Data: Global Macro Database (GMD)

**Single Source Strategy:**
- **Source:** FMI/World Bank Global Macro Database
- **Coverage:** 2012-2024 (13 years available for Brazil)
- **Methodology:** Balance of Payments (BOP) from Banco Central do Brasil (BCB)
- **Frequency:**
  - Exports/Imports: Monthly (from BOP accounts)
  - GDP: Annual (NOT interpolated - real annual values)
- **Advantages:**
  - Consistent methodology across full 13-year series
  - Official BCB source (national accounts)
  - No discontinuities (single source)
  - Includes GDP for state-level normalization

**Why NOT BACI:**
- ❌ Mixing BACI (2012-2023) + GMD (2024) creates discontinuity
- ❌ Different methodologies cause 6-28% jumps in series
- ❌ BACI lacks GDP data
- ✅ GMD alone ensures consistency for full 2012-2024 period

**Data Integration:**
- Banking data: Jan 2012 - Dec 2024 (156 months from BCB SCR)
- Trade data: 2012-2024 from GMD (matches banking period)
- GDP: Annual 2012-2024 (for normalization, not monthly interpolation)
- Note: Regional GDP from IBGE (separate integration needed)

---

## 📈 DATA CHARACTERISTICS

### Temporal Coverage
- **Start:** January 2012
- **End:** December 2024
- **Duration:** 13 years (156 months)
- **Frequency:** Monthly
- **Gaps:** None (complete time series)
- **Periods Captured:**
  - Commodity boom peak (2012-2014)
  - Economic recession (2015-2016)
  - Corruption scandal (Lava Jato 2014-2018)
  - Political crisis (2016 impeachment)
  - COVID-19 pandemic (2020-2021)
  - Post-pandemic recovery (2022-2024)
  - China trade boom (2020-2024)

### Cross-Sectional Coverage
- **States:** 27 (complete Brazilian territory)
- **Regions:** 5 (IBGE standard classification)
- **Sectors:** 19 raw → 8 aggregated (Manufacturing, Wholesale/Retail, Agriculture, etc.)
- **Sizes:** 5 categories (Micro, Small, Medium, Large, Unknown)
- **Modalities:** 4 TF types (ACC, ACE, FINIMP, NCE)
- **Records per month:** ~5,400 (not all combinations present)

### Volume Statistics (2024)
- **Total TF Credit:** USD 6.94 trillion (cumulative 2012-2024)
- **Annual average:** USD 534 billion/year
- **2024 monthly avg:** USD 48.2 billion/month
- **TF as % of total credit:** ~8-12% (varies by state/sector)
- **Largest state:** São Paulo (22% of national TF)
- **Largest sector:** Manufacturing (55% of TF)
- **Largest size:** Medium enterprises (53.5% of TF)

---

## 🔧 DATA PROCESSING PIPELINE

### 1. ETL: `banca-desenvolvimento/brasil/brasil_etl.R`
```r
# Extracts from BCB SCR system:
# - Filter: ACC, ACE, FINIMP, NCE modalities
# - Aggregates: State × Sector × Size × Modality × Month
# - Standardizes: 19 sectors → 8 categories
# - Merges: BACI trade data (2012-2023)
# - Converts: BRL to USD using BCB monthly rates
# - Outputs: brasil_full.csv (838,166 observations)
```

### 2. Processing: `country_analysis/scripts/01_master_processing.R`
```r
# Loads brasil_full.csv
# - Validates: State codes, region assignments
# - Classifies: Sectors (8 categories)
# - Aggregates: Size distribution metrics
# - Adds: Regional GDP shares (for normalization)
# - Outputs: brasil_processed.rds
```

### 3. Integration: `country_analysis/scripts/00_integrate_gmd.R` (Pending)
```r
# Will add:
# - GMD exports/imports for 2024
# - State-level GDP (IBGE data)
# - Regional inequality metrics (Gini, Theil)
# - Commodity price indices (soy, iron ore, coffee)
# - China trade share (Brazil's top partner)
```

---

## 📊 DATA QUALITY NOTES

### Strengths
✅ **Official source:** Banco Central regulatory data (mandatory reporting)  
✅ **Complete coverage:** All financial institutions in Brazil  
✅ **Long series:** 13 years (2012-2024)  
✅ **Geographic detail:** 27 states, 5 regions (unique among 4 countries)  
✅ **Sectoral detail:** 8 economic sectors  
✅ **Size detail:** 5 borrower categories (like Peru)  
✅ **Modality detail:** 4 TF instruments (ACC, ACE, FINIMP, NCE)  
✅ **High frequency:** Monthly granularity  
✅ **838K observations:** Largest dataset among 4 countries  

### Limitations
⚠️ **No bank-level data:** Cannot analyze individual institutions  
⚠️ **No bank types:** Cannot compare Foreign vs Domestic vs State banks  
⚠️ **No concentration metrics:** HHI, CR5 not calculable (no bank detail)  
⚠️ **Aggregated:** State-sector-size totals only, no individual loans  
⚠️ **Missing combinations:** Not all state×sector×size combos present each month  
⚠️ **Trade data transition:** BACI (2012-2023) → GMD (2024), methodology change  
⚠️ **Regional GDP:** Need separate IBGE data for state-level normalization  

### Data Validation
- ✅ Total TF matches BCB aggregate credit statistics
- ✅ State volumes consistent with MDIC export data (e.g., SP, RS, PR lead)
- ✅ Sector distribution matches industrial production (manufacturing dominates)
- ✅ Size distribution stable (medium enterprises ~53%)
- ✅ Modality mix consistent (ACC+ACE ~70%, FINIMP ~25%)
- ✅ Regional patterns stable (Southeast+South ~80% of TF)

---

## 🔗 RELATED DOCUMENTATION

- **Regional Analysis:** Brazil unique (27 states), other countries bank-level
- **Size Comparison:** Brazil vs Peru (both have 5 size categories)
- **GMD Integration:** See `GMD_INTEGRATION_FINDINGS.md` for BACI→GMD transition
- **Analysis Plan:** See `MASTER_ANALYSIS_PLAN.md` - Section 5 (8 Brazil plots)
- **Sector Detail:** Brazil has 8 sectors, others lack sectoral breakdowns

---

## 📝 KEY FINDINGS FOR ANALYSIS

### 1. Regional Distribution (2024)
- **Southeast (43.7%):** São Paulo 22%, Rio de Janeiro 12%, Minas Gerais 7%, Espírito Santo 3%
  - Industrial hub, major ports (Santos, Rio)
  - Manufacturing + services
- **South (37.6%):** Paraná 14%, Rio Grande do Sul 13%, Santa Catarina 11%
  - Agriculture (soy, wheat, tobacco)
  - Manufacturing (automotive, textiles)
- **Northeast (10.2%):** Bahia 4%, Pernambuco 3%, others 3%
  - Agriculture, textiles, oil (Bahia)
- **Center-West (6.3%):** Goiás 2.5%, Mato Grosso 2%, Mato Grosso do Sul 1.5%, DF 0.3%
  - Agribusiness (soy capital: MT)
- **North (2.2%):** Pará 1%, Amazonas 0.8%, others 0.4%
  - Mining (Carajás), Amazon region

### 2. Sectoral Composition (2024)
- **Manufacturing (54.8%):** Automotive, machinery, chemicals, food processing
  - Concentrated in SP, PR, RS
- **Wholesale/Retail (29.5%):** Trade distribution, import/export intermediaries
  - All major cities
- **Agriculture (5.0%):** Soy, corn, wheat, livestock
  - PR, RS, GO, MT (agribusiness states)
- **Transport/Logistics (2.9%):** Port operations, shipping, warehousing
  - ES, RJ, SP (port cities)
- **Other sectors (<2% each):** Mining, construction, IT, services

### 3. Size Distribution (2024)
- **Medium (53.5%):** Dominates TF (like Peru corporate dominance)
- **Large (26.4%):** Second largest
- **Small (15.6%):** Growing share
- **Micro (4.0%):** Minimal TF access (higher than Peru's 2%)
- **Unknown (0.5%):** Not classified

### 4. Modality Evolution
- **ACC (42%):** Pre-shipment financing, stable share
- **ACE (28%):** Post-shipment, growing (more efficient)
- **FINIMP (25%):** Import financing, stable
- **NCE (5%):** Export notes, declining (less used)
- **Trend:** Shift from ACC to ACE (payment terms improvement)

### 5. Crisis Impacts
- **2015-2016 Recession:** -25% TF volume (commodity crash + political crisis)
- **2020 COVID:** -18% (Q2 2020), recovered by Q1 2021 (China demand)
- **2024 Recovery:** Back to 2014 peak levels (commodity super-cycle)

### 6. Regional Inequality
- **Gini coefficient:** ~0.58 (high inequality, Southeast dominates)
- **Top 5 states (SP, PR, RS, RJ, SC):** 72% of total TF
- **North region:** Only 2.2% (infrastructure deficits)
- **Trend:** Increasing concentration (Southeast+South growing faster)

---

## 🎯 RECOMMENDED USES

✅ **Regional/State analysis** (27 states, 5 regions - UNIQUE)  
✅ **Sectoral analysis** (8 sectors - manufacturing, agriculture, trade)  
✅ **Size distribution** (5 categories, compare with Peru)  
✅ **Modality analysis** (4 TF instruments - ACC, ACE, FINIMP, NCE)  
✅ **Regional inequality** (Gini, Theil indices)  
✅ **North vs South comparison** (development gaps)  
✅ **Manufacturing vs Agriculture** (industrial vs commodity financing)  
✅ **Trade-TF correlation** (with BACI/GMD, by state)  

⚠️ **Limited use for:**
- Bank-level analysis (no individual banks)
- Bank type comparison (no Foreign vs Domestic)
- Concentration metrics (no bank detail)
- Market share analysis (no banks)

❌ **Not suitable for:**
- Individual bank strategies
- Bank specialization studies
- HHI, CR5 concentration (need bank-level data)
- Foreign vs domestic comparison

---

## 🔬 TECHNICAL NOTES

### Size Classification (BCB Standard)
- Based on **annual gross revenue** (Receita Bruta Anual)
- Threshold values (BRL):
  - Microempresa: < 360,000 BRL (~$70K USD)
  - Pequeno: 360K - 4.8M BRL (~$70K - $940K USD)
  - Médio: 4.8M - 300M BRL (~$940K - $58M USD)
  - Grande: > 300M BRL (~$58M USD)
- Updated annually by BNDES/SEBRAE standards

### Regional Classification (IBGE)
- **Norte:** AC, AP, AM, PA, RO, RR, TO (7 states)
- **Nordeste:** AL, BA, CE, MA, PB, PE, PI, RN, SE (9 states)
- **Centro-Oeste:** DF, GO, MT, MS (4 states)
- **Sudeste:** ES, MG, RJ, SP (4 states)
- **Sul:** PR, RS, SC (3 states)

### Currency Conversion
- BRL → USD using Banco Central do Brasil PTAX monthly average rates
- Exchange rate source: BCB official statistics
- Range: 2.04 BRL/USD (2012) → 5.18 BRL/USD (2024)
- Volatility: Very high (154% depreciation over 13 years, COVID spike to 5.85)

### Missing Combinations
- Not all State × Sector × Size × Modality combinations present each month
- Pattern: Small states + small sectors + micro size often missing
- Interpretation: No financing activity in that segment (not data error)
- Impact: ~35% of potential combinations missing (stable pattern)

### Modality Definitions (BCB Official)
- **ACC:** Advances on FX contracts before shipment (manufacturer gets cash upfront)
- **ACE:** Advances on delivered FX (post-shipment, lower risk)
- **FINIMP:** Import financing (deferred payment, typically 180-360 days)
- **NCE:** Export credit note (promissory note issued by bank)

---

## 📧 CONTACT & UPDATES

**Data Maintainer:** Tomás Fernández  
**Last ETL Run:** November 2025  
**Next Update:** When BCB releases January 2025 data (expected February 2025)  
**Issues:** Report in `country_analysis/` repository

**Change Log:**
- 2025-11: **METHODOLOGICAL FIX:** Use GMD only (no BACI mix) for full 2012-2024 series
- 2025-11: GDP as annual variable (no interpolation)
- 2025-11: Enhanced sectoral classification (8 sectors)
- 2025-11: Regional inequality metrics added
- 2025-11: Size distribution refined
- 2024-06: Extended series through December 2024
- 2023-01: Initial extraction (2012-2023)

---

## 🌎 BRAZIL IN CONTEXT (vs Other 3 Countries)

| Aspect | Brazil | Mexico | Peru | Chile |
|--------|--------|--------|------|-------|
| **Data Level** | State/Sector/Size | Bank | Bank/Size | Bank/Account |
| **Banks** | ❌ None | 53 | 19 | 27 |
| **Geography** | ✅ 27 states | ❌ | ❌ | ❌ |
| **Sectors** | ✅ 8 sectors | ❌ | ❌ | ❌ |
| **Size** | ✅ 5 categories | ❌ | ✅ 5 categories | ❌ |
| **Products** | ✅ 4 modalities | 1 (L/C) | 1 (TF credit) | 9 categories |
| **Time Span** | 13 years | 3.7 years | 14.2 years | 10 years |
| **Observations** | 838,166 | 2,204 | 13,785 | 38,449 |

**Brazil's Unique Value:**
- 🌟 **Only country with geographic detail** (27 states, regional inequality analysis)
- 🌟 **Only country with sectoral detail** (manufacturing vs agriculture vs services)
- 🌟 **Only country with modality detail** (ACC, ACE, FINIMP, NCE)
- 🌟 **Largest dataset** (838K observations, 13 years)

**Brazil's Limitation:**
- ⚠️ **No bank-level data** (cannot analyze concentration, market shares, bank strategies)

---

*For cross-country comparisons (regional vs bank-level analysis), see MASTER_ANALYSIS_PLAN.md*
