# Data Exploration Findings - Country Analysis

**Date:** November 19, 2025  
**Status:** ✅ Data exploration complete

---

## 🔍 Key Discoveries

### Critical Finding: Different Data Granularities

| Country | Granularity | Bank-Level | Size | Sector | Geography |
|---------|-------------|------------|------|--------|-----------|
| **Mexico** | ✅ Bank-level | 53 banks | ❌ | ❌ | National |
| **Peru** | ✅ Bank-level | 19 banks | ✅ 5 sizes | ❌ | National |
| **Chile** | ✅ Bank-level | ~40 banks | ❌ | ❌ | National |
| **Brazil** | ⚠️ **AGGREGATED** | ❌ No banks | ✅ 5 sizes | ✅ 19 sectors | ✅ 27 states |

**Implication:** Brazil data is fundamentally different - aggregated by state, sector, and borrower size, but **NO individual bank information**. This limits cross-country bank-level comparisons.

---

## 🇲🇽 MEXICO - Detailed Findings

### Data Availability ✅
- **53 institutions** identified
- **Time period:** January 2022 - August 2025 (44 months)
- **Main metric:** Outstanding Letters of Credit (liabilities)
- **Currency:** MXN and USD amounts available

### Major Banks (Sample)
**Domestic Large:**
- BANAMEX (Citibanamex)
- BBVA MEXICO
- SANTANDER
- BANORTE
- HSBC

**Foreign Banks:**
- BANK OF AMERICA
- JP MORGAN
- MUFG BANK
- CITIBANK
- MIZUHO BANK
- ICBC
- BANK OF CHINA

**Specialized:**
- BAJIO
- BANREGIO
- AFIRME
- AZTECA
- INBURSA

### Analysis Feasibility
1. ✅ **L/C over time** - Have data
2. ✅ **L/C by bank type** - Can classify banks
3. ⚠️ **L/C as % of total liabilities** - Need additional balance sheet data
4. ✅ **Concentration metrics** - Can calculate HHI, CR4

### Data Quality
- ✅ Complete time series
- ✅ USD and MXN amounts
- ✅ Trade volumes (exports + imports) available
- ⚠️ **Missing:** Total liabilities needed for percentage calculations

---

## 🇵🇪 PERU - Detailed Findings

### Data Availability ✅✅
- **19 institutions** identified
- **Time period:** October 2010 - 2024 (14+ years) - **LONGEST**
- **Main metric:** "Comercio exterior" credit
- **Currency:** PEN and USD amounts available

### Foreign-Trade Credit Breakdown
**Total observations:** 13,785 rows with "Comercio exterior"  
**By borrower size:** 5 categories × 2,757 observations each

| Size | Spanish | Observations |
|------|---------|--------------|
| Corporate | Corporativo | 2,757 |
| Large | Grande | 2,757 |
| Medium | Mediano | 2,757 |
| Small | Pequeño | 2,757 |
| Micro | Microempresa | 2,757 |

### Major Banks (Sample)
**Large Domestic:**
- Banco de Crédito del Perú (BCP) - Largest
- BBVA Perú
- Scotiabank Perú
- Interbank
- BanBif

**Foreign:**
- Citibank
- Deutsche Bank
- Bank of China
- ICBC

**Consumer/SME:**
- Mibanco (microfinance)
- Banco Falabella (retail)
- Banco Ripley (retail)

### Analysis Feasibility
1. ✅ **Foreign-trade credit % of total** - Have both numerator and denominator
2. ✅ **By borrower size** - 5 categories available
3. ✅ **By bank type** - Can classify 19 banks
4. ✅ **Concentration metrics** - Can calculate HHI, CR4
5. ✅ **Time trends** - 14+ years of data

### Data Quality
- ✅✅ **EXCELLENT** - Most complete dataset
- ✅ Total credit available (for percentages)
- ✅ PEN and USD amounts
- ✅ Standardized bank names (institucion_std)
- ✅ Longest time series

---

## 🇨🇱 CHILE - Detailed Findings

### Data Availability ✅
- **~40 banks** (to be confirmed with full dataset)
- **Time period:** 2004-2024 (20+ years)
- **Main metric:** Balance sheet accounts
- **Currency:** CLP, USD, indexed currencies

### Trade Finance Accounts Identified (23 accounts)

#### **Assets - Credits (1270xxx, 1302xxx):**
1. **1270116** - Créditos comercio exterior exportaciones chilenas
2. **1270117** - Créditos comercio exterior importaciones chilenas
3. **1270118** - Créditos comercio exterior entre terceros países
4. **1270200** - Bancos del exterior
5. **1270206** - Créditos comercio exterior exportaciones chilenas
6. **1270207** - Créditos comercio exterior importaciones chilenas
7. **1270208** - Créditos comercio exterior entre terceros países
8. **1302200** - Créditos de comercio exterior
9. **1302201** - Acreditivos negociados a plazo de exportaciones chilenas
10. **1302202** - Otros créditos para exportaciones chilenas
11. **1302241** - Acreditivos negociados a plazo de importaciones chilenas
12. **1302242** - Otros créditos para importaciones chilenas

#### **Liabilities (2302xxx):**
13. **2302000** - BANCOS DEL EXTERIOR
14. **2302100** - Financiamientos de comercio exterior

#### **Other (deposits, provisions, etc.):**
15. **1100400** - Depósitos en el exterior
16. **1150300** - Instrumentos emitidos en el exterior
17. **1270290** - Provisiones para créditos con bancos del exterior
18. **1302102** - Préstamos en el exterior
19. **1350300** - Instrumentos emitidos en el exterior
20. **1360300** - Instrumentos emitidos en el exterior
21. **1400101** - Sucursales en el exterior
22. **2500300** - Obligaciones con el exterior
23. **2700402** - Provisiones especiales para créditos al exterior

### Key Insights
- **Export vs Import financing** clearly separated (codes ending 6/7 or 1/2)
- **Third-party trade** (entre terceros países) - unique category
- **Letters of credit** specifically identified ("Acreditivos negociados")
- **Foreign bank funding** tracked (liability side)

### Analysis Feasibility
1. ✅ **Foreign-trade loans % of total** - Sum 1270xxx + 1302xxx accounts
2. ✅ **By bank type** - Can classify ~40 banks
3. ✅ **Concentration metrics** - Bank-level data available
4. ✅ **Funding from foreign banks** - Account 2302xxx
5. ✅ **L/C specifically** - Accounts 1302201, 1302241
6. ✅ **Export vs Import** - Can separate
7. ⚠️ **By borrower size** - NOT AVAILABLE in data

### Data Quality
- ✅ Very detailed (23 accounts for trade finance)
- ✅ Longest time series (2004-2024)
- ✅ Multiple currency breakdowns
- ✅ Export/import/third-party distinction
- ⚠️ Large dataset (762k rows) - requires efficient processing
- ⚠️ Account codes need mapping to categories

---

## 🇧🇷 BRAZIL - Detailed Findings

### ⚠️ CRITICAL: Data Structure is Different

**Brazil data is NOT bank-level. It is aggregated by:**
1. **State (UF):** 27 Brazilian states
2. **Sector (CNAE):** 19 economic sectors
3. **Borrower Size (Porte):** 5 size categories
4. **Interest Rate Type (Indexador):** 5 types

**NO individual bank information available (tcb = "Bancário" for all)**

### Data Availability ✅ (but different)
- **Time period:** January 2012 - 2024 (12+ years)
- **838,166 observations** = State × Sector × Size × Indexer × Month combinations
- **Main metric:** Trade finance credit (pre-filtered: "PJ - Comércio exterior")
- **Currency:** BRL and USD amounts available

### Geographic Distribution (27 States)

| State | Observations | % of Total | Key Region |
|-------|-------------|-----------|------------|
| **SP** (São Paulo) | 237,339 | 28.3% | Southeast - Financial/Industrial hub |
| **RS** (Rio Grande do Sul) | 126,829 | 15.1% | South - Agribusiness/Export |
| **SC** (Santa Catarina) | 97,991 | 11.7% | South - Manufacturing |
| **PR** (Paraná) | 89,927 | 10.7% | South - Agriculture |
| **MG** (Minas Gerais) | 72,587 | 8.7% | Southeast - Mining/Manufacturing |
| **RJ** (Rio de Janeiro) | 31,412 | 3.7% | Southeast - Oil/Services |
| Others (21 states) | 181,081 | 21.6% | North, Northeast, Center-West |

**Key insight:** South + Southeast = 82% of trade finance operations

### Sector Distribution (Top 10 of 19 CNAE Sectors)

| Sector | Observations | % |
|--------|-------------|---|
| **Manufacturing** (Indústrias de transformação) | 459,656 | 54.8% |
| **Wholesale/Retail Trade** (Comércio) | 247,088 | 29.5% |
| **Agriculture** (Agricultura, pecuária, pesca) | 41,920 | 5.0% |
| **Transport/Logistics** (Transporte, armazenagem) | 24,081 | 2.9% |
| **Administrative Services** (Atividades administrativas) | 15,398 | 1.8% |
| **Professional/Technical** (Atividades profissionais) | 11,141 | 1.3% |
| **Mining** (Indústrias extrativas) | 10,274 | 1.2% |
| **Construction** (Construção) | 8,235 | 1.0% |
| **Information/Communication** (Informação e comunicação) | 7,901 | 0.9% |
| Others (10 sectors) | 12,472 | 1.5% |

**Key insight:** Manufacturing + Trade = 84% of trade finance

### Borrower Size Distribution

| Size | Observations | % | Portfolio (BRL trillion) | % Portfolio |
|------|-------------|---|-------------------------|-------------|
| **Medium** (Médio) | 448,617 | 53.5% | 4.29 | 16.4% |
| **Large** (Grande) | 221,235 | 26.4% | 20.79 | 79.5% |
| **Small** (Pequeno) | 130,553 | 15.6% | 0.58 | 2.2% |
| **Micro** (Micro) | 33,789 | 4.0% | 0.64 | 2.5% |
| **Unavailable** (Indisponível) | 3,972 | 0.5% | 0.32 | 1.2% |

**Key insight:** Large firms = 26% of observations but 80% of credit volume

### Total Trade Finance Portfolio
- **BRL 26.6 trillion** over 12 years
- **~USD 13-15 trillion** (at various exchange rates)

### Analysis Feasibility

#### ✅ What We CAN Do with Brazil:
1. ✅ **Foreign-trade credit by STATE** - Regional analysis (27 UFs)
2. ✅ **By borrower SIZE** - 5 categories (comparable with Peru)
3. ✅ **By SECTOR** - 19 CNAE sectors
4. ✅ **Time trends** - 2012-2024
5. ✅ **Maturity structure** - 7 maturity buckets available
6. ✅ **Credit quality** - Non-performing loans tracked
7. ✅ **Interest rate type** - Pre/Post-fixed, Floating, etc.

#### ❌ What We CANNOT Do with Brazil:
1. ❌ **Bank-level analysis** - No individual banks
2. ❌ **Bank type** - No national vs foreign distinction
3. ❌ **Concentration metrics** - No bank competition measures (HHI, CR4)
4. ❌ **Direct comparison with Mexico/Peru/Chile** on bank dimensions

### Data Quality
- ✅ Already filtered for trade finance
- ✅ Very granular (state × sector × size)
- ✅ BRL and USD amounts
- ✅ Complete maturity structure
- ⚠️ **Limitation:** No bank-level data
- ⚠️ Large dataset (838k rows)

---

## 🎯 Cross-Country Analysis Strategy

### Tier 1: Bank-Level Comparisons (Mexico, Peru, Chile ONLY)

| Analysis | Mexico | Peru | Chile |
|----------|--------|------|-------|
| **Foreign-trade credit % total** | ⚠️ Need total liabilities | ✅ Have data | ✅ Can calculate |
| **By bank type** (national/foreign) | ✅ 53 banks | ✅ 19 banks | ✅ ~40 banks |
| **Concentration** (HHI, CR4) | ✅ Can calculate | ✅ Can calculate | ✅ Can calculate |
| **Time series** | 2022-2025 | 2010-2024 | 2004-2024 |

### Tier 2: Borrower Size Analysis (Peru, Brazil ONLY)

| Analysis | Peru | Brazil |
|----------|------|--------|
| **By size** (Corporate/Large/Medium/Small/Micro) | ✅ 5 categories | ✅ 4 categories (+ unknown) |
| **Time series** | 2010-2024 | 2012-2024 |

### Tier 3: Brazil-Specific (No comparison)
- Regional patterns (27 states)
- Sector analysis (19 sectors)
- Size × Sector interactions
- South vs Southeast vs North/Northeast/Center-West

### Tier 4: Time Series Overlaps

**Optimal comparison period:** 2012-2024 (all countries overlap)

| Period | Mexico | Peru | Chile | Brazil |
|--------|--------|------|-------|--------|
| 2004-2009 | ❌ | ❌ | ✅ | ❌ |
| 2010-2011 | ❌ | ✅ | ✅ | ❌ |
| **2012-2021** | ❌ | ✅ | ✅ | ✅ |
| **2022-2024** | ✅ | ✅ | ✅ | ✅ |
| 2025 | ✅ | ❌ | ❌ | ❌ |

---

## 📋 Revised Analysis Plan

### Scripts to Create

#### **01_master_processing.R**
- Load all 4 countries
- Standardize date formats
- Classify bank types (Mexico, Peru, Chile)
- Create trade finance categories (Chile account mapping)
- Calculate totals and percentages
- Save processed RDS objects

#### **02_mexico_analysis.R**
- Outstanding L/C over time (absolute and growth)
- L/C by bank type (national vs foreign, size categories)
- Top 10 banks by L/C
- Concentration metrics (HHI, CR4)
- Correlation with exports/imports

#### **03_peru_analysis.R**
- Foreign-trade credit % of total credit
- By borrower size (5 categories) - time trends
- By bank type (national vs foreign)
- Top 10 banks
- Concentration metrics (HHI, CR4)
- Size distribution evolution

#### **04_chile_analysis.R**
- Foreign-trade loans % of total loans (1270xxx + 1302xxx)
- Export vs Import financing trends
- L/C specifically (accounts 1302201, 1302241)
- By bank type
- Top 10 banks
- Concentration metrics
- Funding from foreign banks (liability 2302xxx)

#### **05_brazil_analysis.R**
- **Regional analysis:** By state (top 10 + regions)
- **Sector analysis:** By CNAE (top 10 sectors)
- **Size analysis:** By porte (comparable with Peru)
- **Time trends:** 2012-2024
- **Credit quality:** NPL rates by state/sector/size
- **Maturity structure:** Short vs long-term by sector

#### **06_comparison_tier1.R** (Bank-level: Mexico, Peru, Chile)
- Foreign-trade credit trends (indexed to 2022=100)
- Bank type shares (national vs foreign)
- Concentration comparison (HHI time series)
- Crisis periods (COVID-19 impact)

#### **07_comparison_tier2.R** (Size: Peru, Brazil)
- Size distribution comparison
- Large vs SME trends
- Size × Time interactions
- COVID impact by size

#### **08_integrated_report.R**
- HTML report with all plots
- LaTeX tables
- Methodology documentation
- Data quality notes
- Interpretation guides

#### **09_run_all.R**
- Master execution script
- Progress reporting
- Error handling
- Timing benchmarks

---

## ⚠️ Data Gaps & Limitations

### Mexico
- ❌ **Total liabilities not available** - Cannot calculate L/C as % of total
  - **Workaround:** Report absolute amounts and growth rates
  - **Alternative:** Get balance sheet data separately

### Chile
- ❌ **No borrower size breakdown** - Cannot compare with Peru/Brazil on this dimension
- ⚠️ **Complex account structure** - Need careful mapping to avoid double-counting

### Brazil
- ❌ **No bank-level data** - Cannot compare with other countries on bank dimensions
  - **Strength:** Unique regional and sectoral insights not available elsewhere
  - **Strength:** Size breakdown comparable with Peru

### All Countries
- ⚠️ **Different time periods** - Need careful alignment for comparisons
- ⚠️ **Different definitions** - What counts as "trade finance" varies by country

---

## ✅ Next Steps

1. **Create 01_master_processing.R** ✅ Ready to start
   - Load all datasets
   - Standardize structures
   - Classify banks (Mexico, Peru, Chile)
   - Map Chile accounts
   - Save processed data

2. **Bank classifications needed:**
   - Mexico: 53 banks → National/Foreign, Size
   - Peru: 19 banks → National/Foreign, State/Private
   - Chile: ~40 banks → National/Foreign, State/Private

3. **Chile account mapping:**
   - Assets: Sum 1270xxx + 1302xxx for total trade finance loans
   - Liabilities: Use 2302xxx for foreign funding
   - L/C: Use 1302201 + 1302241 specifically

4. **Mexico balance sheet data:**
   - Option A: Find total liabilities in CNBV R12 reports
   - Option B: Report L/C in absolute terms only

---

**Status:** ✅ Data exploration complete - Ready to begin analysis scripts  
**Last Updated:** November 19, 2025
