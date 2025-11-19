# Country Trade Finance Analysis - Data Documentation

**Analysis Period:** 2010-2025 (varies by country)  
**Countries:** Mexico, Peru, Chile, Brazil  
**Focus:** Trade finance operations across Latin America  
**Date:** November 19, 2025

---

## 📊 Dataset Overview

| Country | Rows | Period | Key Variable | Banks | Granularity |
|---------|------|--------|--------------|-------|-------------|
| **Mexico** | 2,204 | 2022-2025 | Letters of Credit liabilities | 53 | Monthly, by bank |
| **Peru** | 96,495 | 2010-2024 | Foreign-trade credit | 19 | Monthly, by bank, by size |
| **Chile** | 762,688 | 2004-2024 | Bank balance sheet accounts | ~40 | Monthly, by bank, by account |
| **Brazil** | 838,167 | 2011-2024 | Credit operations | ~100+ | Monthly, by bank, state, sector, size |

---

## 🇲🇽 MEXICO

### Data Structure
**File:** `mexico_full.csv`  
**Source:** CNBV (Comisión Nacional Bancaria y de Valores)  
**Period:** January 2022 - August 2025 (44 months)

### Columns (12)
```
year, month, year_month          # Time identifiers
cod_inst, institucion             # Bank code and name
amount_mxn, tipo_cambio           # Amount in MXN and exchange rate
amount_usd, amount_usd_thousands  # Amount in USD
X_exports, M_imports, trade       # Trade volumes (exports + imports)
```

### Key Variables
- **Main metric:** Outstanding Letters of Credit reported as **liabilities** by banks
- **Unit:** Mexican Pesos (MXN) and USD
- **Trade distinction:** Exports vs Imports available (though not in L/C breakdown)

### Bank Types (53 institutions)
**Major domestic banks:**
- BANAMEX, BBVA MEXICO, SANTANDER, HSBC
- BANORTE, SCOTIABANK, INBURSA

**Foreign banks:**
- BANK OF AMERICA, JP MORGAN, MUFG
- CITIBANK, MIZUHO, ICBC, BANK OF CHINA

**Specialized/smaller:**
- BAJIO, BANREGIO, AFIRME, AZTECA
- COMPARTAMOS, BANCOPPEL

### Analysis Requirements
1. **Outstanding L/C as % of total liabilities** → Need to get total liabilities data
2. **Outstanding L/C by type of bank** → Classify banks (domestic/foreign, size)

### Data Quality
- ✅ Complete time series 2022-2025
- ⚠️ Need total liabilities to calculate % → May need additional data
- ✅ Bank codes standardized

---

## 🇵🇪 PERU

### Data Structure
**File:** `peru_full.csv`  
**Source:** SBS (Superintendencia de Banca, Seguros y AFP)  
**Period:** October 2010 - 2024 (14+ years)

### Columns (21)
```
anio, mes, year_month              # Time identifiers
institucion, institucion_std       # Bank name (original and standardized)
Concepto                           # Credit type/concept
size                               # Borrower size
total, amount                      # Total credit and specific amount
total_pen, amount_pen              # In PEN (Peruvian Sol)
total_usd, amount_usd              # In USD
share                              # Market share
X_exports, M_imports, trade        # Trade volumes
```

### Key Variables
- **Main metric:** Foreign-trade credit ("Comercio exterior")
- **Unit:** PEN and USD
- **Granularity:** By bank, by borrower size, monthly

### Credit Concepts (8 types)
1. **Comercio exterior** ← **PRIMARY FOCUS**
2. Arrendamiento financiero y Lease-back
3. Descuentos
4. Factoring
5. Préstamos
6. Tarjetas de crédito
7. Otros

### Borrower Sizes (5 categories)
- **Corporate** (Corporativo)
- **Large** (Grande)
- **Medium** (Mediano)
- **Small** (Pequeño)
- **Micro** (Microempresa)

Each: 2,757 observations (13,785 / 5)

### Bank Types (19 institutions)
**Major banks:**
- Banco de Crédito del Perú (BCP)
- BBVA Perú
- Scotiabank Perú
- Interbank
- BanBif

**Foreign banks:**
- Citibank
- Deutsche Bank
- Bank of China
- ICBC

**Specialized:**
- Mibanco
- Banco Falabella
- Banco Ripley

### Analysis Requirements
1. **Foreign-trade credit as % of total credit** ✅ Have both variables
2. **By borrower size** ✅ Have 5 size categories
3. **By type of bank** → Need to classify (national/foreign, state/private)
4. **Concentration metrics** ✅ Can calculate HHI, CR4

### Data Quality
- ✅ Longest time series (2010-2024)
- ✅ Most granular (size breakdown)
- ✅ Both PEN and USD available
- ✅ Total credit available for % calculation

---

## 🇨🇱 CHILE

### Data Structure
**File:** `chile_full.csv`  
**Source:** SBIF/CMF (Comisión para el Mercado Financiero)  
**Period:** 2004-2024 (20+ years)

### Columns (23)
```
Anho, Mes, year_month                  # Time identifiers
CodigoInstitucion, NombreInstitucion   # Bank code and name
CodigoCuenta, DescripcionCuenta        # Account code and description
MonedaTotal_num                         # Total amount
MonedaChilenaNoReajustable_num         # CLP non-indexed
MonedaExtranjera_num                    # Foreign currency
MonedaReajustable_num                   # Indexed currency
MonedaReajustablePorIPC_num            # CPI-indexed
MonedaReajustablePorTipoDeCambio_num   # FX-indexed
categoria_tf                            # Trade finance category flag
```

### Key Variables
- **Main metric:** Foreign-trade loans identified by account descriptions
- **Unit:** Chilean Pesos (CLP thousands)
- **Currency breakdown:** CLP, USD, indexed currencies

### Relevant Account Codes (Trade Finance)
Based on sample, accounts include:
- "Créditos comercio exterior exportaciones chilenas"
- "Créditos comercio exterior importaciones chilenas"
- "Créditos comercio exterior entre terceros países"
- Need to identify balance sheet codes for L/C liabilities

### Bank Types (~40+ institutions)
**Major banks:**
- Banco de Chile
- Banco del Estado de Chile
- Banco de Crédito e Inversiones (BCI)
- Scotiabank Chile

**Foreign:**
- Banco do Brasil
- Other international banks

### Analysis Requirements
1. **Foreign-trade loans as % of total loans** ✅ Can extract from balance sheet
2. **By type of bank** → Classify (state/private, national/foreign)
3. **Concentration metrics** ✅ Can calculate
4. **Funding from foreign banks** → Identify specific liability accounts

**Comparability with Peru/Brazil:**
5. **Foreign-trade credit as % of total credit** (same as #1)
6. **By bank type** (same as #2)

**Comparability with Mexico:**
7. **Outstanding L/C as % of total liabilities** → Need to find L/C accounts
8. **L/C by bank type**

### Data Quality
- ✅ Longest time series (2004-2024)
- ✅ Most comprehensive (full balance sheet)
- ⚠️ Requires account mapping to identify trade finance
- ⚠️ Large dataset (762k rows) - need efficient processing

---

## 🇧🇷 BRAZIL

### Data Structure
**File:** `brasil_full.csv`  
**Source:** BCB (Banco Central do Brasil) - SCR (Sistema de Informações de Crédito)  
**Period:** 2011-2024 (13+ years)

### Columns (50)
```
data_base, year, month, year_month     # Time identifiers
uf, sr                                  # State (UF) and region
tcb                                     # Bank type code
cliente, ocupacao                       # Client type, occupation
cnae_secao, cnae_subclasse             # Sector codes
porte                                   # Borrower size
modalidade                              # Credit modality
origem                                  # Origin (national/foreign)
indexador                               # Interest rate indexer
numero_de_operacoes                     # Number of operations
a_vencer_ate_90_dias                    # To mature in 0-90 days
... (maturity buckets)
carteira_ativa_brl, carteira_ativa_usd  # Active portfolio BRL/USD
X_exports, M_imports, trade             # Trade volumes
```

### Key Variables
- **Main metric:** Foreign-trade credit by modality
- **Unit:** Brazilian Reais (BRL) and USD
- **Granularity:** By bank, state, sector, size, modality

### Credit Modalities (need to identify trade finance)
Examples from sample:
- ACC (Adiantamento sobre Contrato de Câmbio) - **Export financing**
- ACE (Adiantamento sobre Cambiais Entregues) - **Export financing**
- FINIMP (Financiamento à Importação) - **Import financing**
- Others (need full list)

### Borrower Sizes (porte)
Need to verify categories - likely similar to Peru:
- Corporate/Large
- Medium
- Small
- Micro

### Bank Origin (origem)
- **Nacional** (National banks)
- **Estrangeiro** (Foreign banks)
- **Others**

### Analysis Requirements
1. **Foreign-trade credit as % of total credit** ✅ Can filter by modality
2. **By borrower size** ✅ Have porte variable
3. **By type of bank** ✅ Have origem variable
4. **Concentration metrics** ✅ Can calculate by bank (tcb)

**Comparability with Peru:**
5. **By borrower size breakdown** ✅ Both have size classification

### Data Quality
- ✅ Most granular (state, sector, size all available)
- ✅ Both BRL and USD amounts
- ⚠️ Large dataset (838k rows)
- ⚠️ Need to identify all trade finance modalities
- ⚠️ Bank names may need cleaning/standardization

---

## 🔄 Cross-Country Comparability

### ✅ Available in All Countries
1. **Foreign-trade credit as % of total credit**
   - Mexico: L/C liabilities as % (proxy)
   - Peru: Comercio exterior / total
   - Chile: Trade finance loans / total loans
   - Brazil: ACC+ACE+FINIMP / total credit

2. **By type of bank** (National vs Foreign)
   - Mexico: Have bank names → classify
   - Peru: Have bank names → classify  
   - Chile: Have bank names → classify
   - Brazil: Have origem variable ✅

3. **Concentration metrics** (HHI, CR4)
   - All: Can calculate from bank-level data

### ⚠️ Partially Available
4. **By borrower size**
   - Peru: ✅ 5 categories
   - Brazil: ✅ Have porte
   - Chile: ❌ Not in data
   - Mexico: ❌ Not in data

5. **Letters of Credit specifically**
   - Mexico: ✅ Main variable
   - Chile: ⚠️ Need to find L/C accounts
   - Peru: ⚠️ May not separate L/C from other trade credit
   - Brazil: ⚠️ May not separate L/C

### 🎯 Analysis Strategy

**Phase 1: Country-Specific (as requested)**
- Mexico: L/C analysis
- Peru: Full trade finance with size breakdown
- Chile: Loans + L/C analysis
- Brazil: Trade finance by size and modality

**Phase 2: Comparable Metrics**
- Foreign-trade credit % (all)
- By bank type (all)
- Concentration (all)
- By size (Peru + Brazil only)

**Phase 3: Regional Insights**
- LATAM trends over time
- Role of foreign banks
- Impact of crisis periods
- Size distribution patterns

---

## 📝 Data Processing TO-DO

### Immediate Tasks
1. ✅ Copy all 4 CSV files
2. ✅ Initial exploration completed
3. ⏳ Map Chile accounts to trade finance categories
4. ⏳ Identify Brazil trade finance modalities
5. ⏳ Classify banks by type (all countries)
6. ⏳ Get Mexico total liabilities data

### Data Cleaning Needs
- **Mexico:** Standardize bank names, handle missing institutions
- **Peru:** Already clean (institucion_std exists)
- **Chile:** Map thousands of accounts to categories
- **Brazil:** Identify complete list of trade finance modalities

### Metadata Needed
- Bank classifications (ownership, origin, size)
- Account code mappings (Chile)
- Modality definitions (Brazil)
- Exchange rate sources verification

---

## 📚 Data Sources

- **Mexico:** CNBV - R12 A Balance (Financial Statements)
- **Peru:** SBS - Credit Registry (Reporte Crediticio)
- **Chile:** CMF (ex-SBIF) - Financial Information (Información Financiera)
- **Brazil:** BCB - Credit Information System (SCR)

---

**Last Updated:** November 19, 2025  
**Status:** Data exploration complete, ready for processing scripts
