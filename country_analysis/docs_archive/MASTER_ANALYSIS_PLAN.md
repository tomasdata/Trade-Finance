# PLAN MAESTRO DE ANÁLISIS - COUNTRY TRADE FINANCE

**Fecha:** 19 de noviembre de 2025  
**Proyecto:** Análisis multi-país de trade finance en América Latina  
**Países:** México, Perú, Chile, Brasil  
**Período:** 2010-2025 (varía por país)

---

## 🎯 OBJETIVO GENERAL

Analizar la evolución del financiamiento al comercio exterior (trade finance) en 4 países de América Latina, identificando:
1. **Intensidad del trade finance** (% de crédito total / % de pasivos)
2. **Concentración bancaria** (HHI, CR5)
3. **Rol de bancos extranjeros** vs domésticos
4. **Patrones por tamaño de deudor** (donde disponible)
5. **Correlación con comercio exterior** (exports/imports)
6. **Efectos de nearshoring** (México 2024)

---

## 📊 ESTRUCTURA DE SCRIPTS

```
country_analysis/
├── scripts/
│   ├── 00_integrate_gmd.R           # [NUEVO] Integración GMD con datos bancarios
│   ├── 01_master_processing.R       # ✅ Master data prep (YA COMPLETADO)
│   ├── 02_mexico_analysis.R         # CORE + EXTRAS (ver detalle abajo)
│   ├── 03_peru_analysis.R           # CORE + EXTRAS
│   ├── 04_chile_analysis.R          # CORE + EXTRAS  
│   ├── 05_brazil_analysis.R         # CORE + EXTRAS
│   ├── 06_comparison.R              # Cross-country comparisons
│   ├── 07_integrated_report.R       # HTML/LaTeX report generator
│   └── run_all.R                    # Master execution script
```

---

## 🇲🇽 MÉXICO - ANÁLISIS DETALLADO

### Dataset Actual
- **2,204 obs** × 16 columnas (ENHANCED)
- **Período:** Ene 2022 - Ago 2025 (44 meses)
- **53 bancos:** 10 Foreign, 9 Large Domestic, 34 Other, 3 Development
- **Variables clave:** 
  - `lc_usd_millions`, `lc_mxn_billions`
  - `total_liab_usd_millions`, `total_liab_mxn_billions`
  - **`lc_pct_liabilities`** ← NUEVA (intensidad L/C)
  - `exports_usd_millions`, `imports_usd_millions`, `trade_usd_millions` (BACI 2022-2023, GMD 2024-2025)

### GRÁFICOS CORE (5 obligatorios)

#### 📈 **Plot 1: Evolución Temporal de L/C** 
**Archivo:** `plots/mexico_01_lc_evolution.png`
```r
# Eje Y1 (izquierda): L/C en USD millones (línea azul)
# Eje Y2 (derecha): L/C como % de pasivos (línea roja)
# X: Tiempo (Ene 2022 - Ago 2025, mensual)
# Línea vertical: Dic 2023 (cambio fuente BACI → GMD)
# Anotación: "Nearshoring spike 2024" (intensidad sube de 0.04% a 0.08%)
# Formato: 300 DPI, 12×8 inches, English labels
```

**Insight esperado:** Volumen creció 30% 2022→2024, intensidad se duplicó (nearshoring)

---

#### 📊 **Plot 2: L/C por Tipo de Banco**
**Archivo:** `plots/mexico_02_lc_by_bank_type.png`
```r
# Box plots (4 categorías): Foreign, Large Domestic, Other Domestic, Development
# Y: L/C intensity (lc_pct_liabilities) en escala log
# Facets: 2 paneles (2023 | 2024) para comparar pre/post nearshoring
# Color: Bank type (palette viridis)
# Overlay: Jitter points (cada banco)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Foreign banks (esp. ICBC) tienen mayor intensidad (2.9%), desarrollo cercano a 0%

---

#### 🏆 **Plot 3: Top 10 Bancos por Intensidad L/C**
**Archivo:** `plots/mexico_03_top10_intensity.png`
```r
# Barras horizontales (snapshot Dic 2024)
# Y: Banco (ordenado por intensidad descendente)
# X: lc_pct_liabilities (%)
# Color: Bank type
# Labels: Mostrar % exacto al final de cada barra
# Tabla embebida: Top 3 con volumen USD también
# Formato: 300 DPI, 10×8 inches, English
```

**Insight esperado:** ICBC #1 (2.17%), BMONEX #2 (0.29%), Santander #3 (0.19%)

---

#### 📉 **Plot 4: Concentración del Mercado**
**Archivo:** `plots/mexico_04_concentration.png`
```r
# Panel doble:
#   - Panel A: HHI over time (línea + puntos trimestrales)
#   - Panel B: CR5 (%) over time 
# X: Tiempo (2022-2025)
# Y: HHI (0-10000) | CR5 (0-100%)
# Líneas de referencia: HHI 2500 (highly concentrated)
# Formato: 300 DPI, 14×6 inches, English
```

**Insight esperado:** CR5 = 83.8% (alta concentración), BBVA 30.6% market share

---

#### 🌎 **Plot 5: Nearshoring Impact**
**Archivo:** `plots/mexico_05_nearshoring.png`
```r
# Comparison 2023 vs 2024 (2 paneles)
# Panel A: L/C volume distribución (violin plot por banco)
# Panel B: L/C intensity cambio (arrows conectando 2023→2024 por banco top 15)
# Highlight: Bancos con mayor incremento intensidad
# Estadística: t-test 2023 vs 2024 (text box)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Intensidad promedio +100% (0.04% → 0.08%), volumen +25%

---

### GRÁFICOS EXTRAS (4 adicionales)

#### 📍 **Plot 6: L/C vs Trade Correlation** (con GMD)
**Archivo:** `plots/mexico_06_lc_trade_correlation.png`
```r
# Scatter plot: X = Trade USD billions (exports + imports), Y = L/C USD millions
# Points: Color por año (2022 azul, 2023 verde, 2024 naranja)
# Regresión lineal con IC 95%
# Correlación Pearson (text annotation)
# Facet by bank type (Foreign | Large Domestic | Other)
# Formato: 300 DPI, 14×10 inches, English
```

**Insight esperado:** Correlación positiva fuerte (r > 0.8), Foreign banks más elásticos

---

#### 📊 **Plot 7: Market Share Evolution**
**Archivo:** `plots/mexico_07_market_share.png`
```r
# Stacked area chart
# X: Tiempo (2022-2025 mensual)
# Y: % market share (0-100%)
# Layers: Top 5 bancos + "Others" (6 colores)
# Legend: Ordered by 2024 market share
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** BBVA domina (30%), concentración estable en el tiempo

---

#### 🥧 **Plot 8: Bank Type Composition**
**Archivo:** `plots/mexico_08_bank_type_pie.png`
```r
# Donut chart (snapshot Dic 2024)
# Segments: Foreign, Large Domestic, Other Domestic, Development
# Labels: % share + USD millions
# Color: Consistent con otros gráficos
# Formato: 300 DPI, 8×8 inches, English
```

**Insight esperado:** Large Domestic ~65%, Foreign ~25%, Development ~10%

---

#### 📅 **Plot 9: Seasonal Patterns**
**Archivo:** `plots/mexico_09_seasonality.png`
```r
# Heatmap: X = Mes (1-12), Y = Año (2022-2025), Fill = L/C USD millions
# Color scale: viridis (yellow = alto, purple = bajo)
# Annotations: Máximos por año
# Formato: 300 DPI, 10×8 inches, English
```

**Insight esperado:** Picos en Q4 (fin de año fiscal), valle Q1

---

### GMD Integration - México

**Nuevas variables a agregar:**
```r
# En 00_integrate_gmd.R:
mexico_gmd <- gmd %>%
  filter(ISO3 == "MEX", year >= 2022) %>%
  select(year, exports_USD, imports_USD, nGDP_USD, 
         exports_GDP, imports_GDP, CA_USD, USDfx, infl)

mexico_enhanced <- mexico_full %>%
  left_join(mexico_gmd, by = "year")

# Nuevas métricas:
mexico_enhanced <- mexico_enhanced %>%
  mutate(
    lc_pct_gdp = (lc_usd_millions / nGDP_USD) * 100,
    trade_usd_gmd = exports_USD + imports_USD,  # GMD total
    trade_intensity = (trade_usd_gmd / nGDP_USD) * 100
  )
```

**Plot adicional con GMD:**

#### 📈 **Plot 10: L/C vs GDP & Trade** [BONUS CON GMD]
**Archivo:** `plots/mexico_10_lc_gdp_trade.png`
```r
# Triple axis plot:
#   - Y1: L/C % GDP (línea azul)
#   - Y2: Trade % GDP (línea verde - GMD)
#   - Y3: Real GDP growth (barras grises - GMD)
# X: Tiempo (2022-2025 anual)
# Correlación: L/C growth vs Trade growth
# Formato: 300 DPI, 14×8 inches, English
```

---

## 🇵🇪 PERÚ - ANÁLISIS DETALLADO

### Dataset Actual
- **13,785 obs** trade finance (de 96,495 total)
- **Período:** Oct 2010 - Dic 2024 (14 años)
- **19 bancos:** 5 Foreign, 2 Large Domestic, 3 Consumer, 9 Others
- **5 tamaños de deudor:** Corporate, Large, Medium, Small, Micro
- **Variables clave:** 
  - `amount_usd` (comercio exterior)
  - `total_usd` (crédito total) → Cálculo `tf_pct_total`
  - `size` (borrower size)

### GRÁFICOS CORE (5 obligatorios)

#### 📈 **Plot 1: TF Credit as % of Total**
**Archivo:** `plots/peru_01_tf_pct_total.png`
```r
# Línea temporal 2010-2024 (mensual)
# Y: TF credit % of total (0-15%)
# Shaded area: IC 95% (across banks)
# Crisis overlays: 
#   - 2020 COVID (vertical line roja)
#   - 2022-2023 Political crisis (shaded area gris - GMD BankingCrisis indicator)
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** TF ~8-12% del total, caída 2020, recuperación 2021-2024

---

#### 📊 **Plot 2: TF Credit by Borrower Size**
**Archivo:** `plots/peru_02_tf_by_size.png`
```r
# Stacked area chart 2010-2024
# Y: USD millions (apilado 100%)
# Layers: Corporate, Large, Medium, Small, Micro (5 colores)
# Tendencia: ¿Corporate dominando? ¿Democratización hacia SMEs?
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Corporate ~50%, Large ~30%, resto 20% (hipótesis)

---

#### 🏦 **Plot 3: TF Credit by Bank Type**
**Archivo:** `plots/peru_03_tf_by_bank_type.png`
```r
# Box plots (faceted por año: 2015, 2018, 2021, 2024)
# Y: TF credit % of total por banco
# X: Bank type (Foreign, Large Domestic, Consumer, Others)
# Color: Bank type
# Formato: 300 DPI, 14×10 inches, English
```

**Insight esperado:** Foreign banks mayor intensidad TF (especialización)

---

#### 📉 **Plot 4: Concentration Metrics**
**Archivo:** `plots/peru_04_concentration.png`
```r
# Similar a México plot 4:
# Panel A: HHI temporal
# Panel B: CR5 temporal
# Período completo 2010-2024 (anual)
# Formato: 300 DPI, 14×6 inches, English
```

**Insight esperado:** Concentración alta, BCP domina

---

#### 📊 **Plot 5: Size Distribution Evolution**
**Archivo:** `plots/peru_05_size_distribution.png`
```r
# Faceted bar charts (5 paneles para 5 años: 2014, 2016, 2018, 2021, 2024)
# Y: USD millions TF credit
# X: Size (Corporate → Micro)
# Fill: Size
# Tendencia temporal visible
# Formato: 300 DPI, 14×10 inches, English
```

**Insight esperado:** Crecimiento absoluto en todas las categorías, Corporate lidera

---

### GRÁFICOS EXTRAS (3 adicionales)

#### 📍 **Plot 6: TF Credit vs GDP Growth** (con GMD)
**Archivo:** `plots/peru_06_tf_vs_gdp.png`
```r
# Scatter plot anual 2010-2024
# X: Real GDP growth % (GMD rGDP_USD growth)
# Y: TF credit growth %
# Points: Color por período (2010-2015, 2016-2019, 2020-2024)
# Regresión lineal + IC 95%
# Formato: 300 DPI, 10×8 inches, English
```

**Insight esperado:** Correlación positiva, sensibilidad al ciclo económico

---

#### 🚨 **Plot 7: Crisis Periods Overlay**
**Archivo:** `plots/peru_07_crises.png`
```r
# Línea temporal TF credit USD (2010-2024)
# Overlay: Shaded areas para crisis periods (GMD indicators)
#   - Banking Crisis (rojo)
#   - Currency Crisis (amarillo)
#   - Sovereign Debt Crisis (naranja)
# Annotations: Eventos específicos (COVID 2020, protests 2022)
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** Caídas pronunciadas en crisis periods

---

#### 🔥 **Plot 8: Bank Specialization Matrix**
**Archivo:** `plots/peru_08_specialization_heatmap.png`
```r
# Heatmap: Y = Bancos (19), X = Size categories (5), Fill = TF share %
# Snapshot 2024
# Color: Red (alto TF %) → Blue (bajo TF %)
# Dendrograma: Cluster banks por perfil de clientes
# Formato: 300 DPI, 10×12 inches, English
```

**Insight esperado:** Bancos especializados en Corporate vs diversificados

---

### GMD Integration - Perú

**Nuevas variables:**
```r
peru_gmd <- gmd %>%
  filter(ISO3 == "PER", year >= 2010) %>%
  select(year, exports_USD, imports_USD, nGDP_USD, rGDP_USD,
         BankingCrisis, CurrencyCrisis, infl, unemp)

peru_enhanced <- peru_processed %>%
  left_join(peru_gmd, by = "year") %>%
  mutate(
    tf_pct_gdp = (amount_usd / nGDP_USD) * 100,
    trade_intensity = ((exports_USD + imports_USD) / nGDP_USD) * 100
  )
```

---

## 🇨🇱 CHILE - ANÁLISIS DETALLADO

### Dataset Actual
- **19,657 obs** trade finance (de 762,688 total balance sheet)
- **Período:** Ene 2015 - Dic 2021 (7 años) ⚠️ Termina 2021
- **27 bancos:** 5 Foreign, 1 State, 8 Large Domestic
- **23 cuentas TF** identificadas (1270xxx, 1302xxx, 2302xxx)
- **Variables clave:**
  - `MonedaTotal_num` (monto total por cuenta)
  - `categoria_tf` (categorías: Export, Import, L/C, Third-Party, Other)

### GRÁFICOS CORE (5 obligatorios)

#### 📈 **Plot 1: TF Loans % of Total**
**Archivo:** `plots/chile_01_tf_pct_total.png`
```r
# Línea temporal 2015-2021
# Y: TF loans % total loans (suma cuentas 1270xxx + 1302xxx)
# Bands: Min/Max across banks (shaded)
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** TF ~5-10% de total loans (menor que Perú)

---

#### 📊 **Plot 2: Export vs Import Financing**
**Archivo:** `plots/chile_02_export_vs_import.png`
```r
# Dual line chart 2015-2021
# Línea 1: Export financing (cuentas 127010x)
# Línea 2: Import financing (cuentas 127020x)
# Y: CLP billions
# Ratio annotation: Export/Import ratio temporal
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** Import financing > Export financing (Chile importador neto)

---

#### 💳 **Plot 3: Letters of Credit Evolution**
**Archivo:** `plots/chile_03_lc_evolution.png`
```r
# Stacked bar chart mensual 2015-2021
# Y: CLP billions L/C (cuentas 1302201, 1302241)
# Stack: Export L/C vs Import L/C
# Trend line: L/C total (overlay)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** L/C uso decreciente (shift a open account?)

---

#### 🌍 **Plot 4: Funding from Foreign Banks**
**Archivo:** `plots/chile_04_foreign_funding.png`
```r
# Línea temporal 2015-2021
# Y: Foreign bank funding (cuentas 2302xxx) en CLP billions
# Secondary Y: % of total liabilities
# Panel comparison: Chilean banks vs Foreign subsidiaries
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** Foreign funding importante para TF (especialización)

---

#### 📊 **Plot 5: Bank Concentration**
**Archivo:** `plots/chile_05_concentration.png`
```r
# Similar estructura México/Perú:
# Panel A: HHI
# Panel B: CR5
# Período 2015-2021 anual
# Formato: 300 DPI, 14×6 inches, English
```

**Insight esperado:** Concentración media (Banco de Chile, BCI, Santander)

---

### GRÁFICOS EXTRAS (3 adicionales)

#### 📍 **Plot 6: Account-Level Breakdown**
**Archivo:** `plots/chile_06_account_breakdown.png`
```r
# Faceted time series (23 paneles para 23 cuentas TF)
# X: Tiempo 2015-2021
# Y: CLP billions (escala log)
# Small multiples layout (5×5 grid)
# Formato: 300 DPI, 18×18 inches, English
```

**Insight esperado:** Identificar cuentas principales y secundarias

---

#### 🔄 **Plot 7: Third-Party Trade Operations**
**Archivo:** `plots/chile_07_third_party.png`
```r
# Línea temporal 2015-2021
# Y: Third-party trade finance (cuentas específicas)
# Annotation: % of total TF
# Bank comparison: Top 5 banks en this segment
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** Rol de Chile como hub regional (operaciones terceros)

---

#### ⚖️ **Plot 8: Guarantees Evolution**
**Archivo:** `plots/chile_08_guarantees.png`
```r
# Stacked area 2015-2021
# Y: Guarantees issued (cuentas garantías TF)
# Layers: By bank type (State, Large Domestic, Foreign)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** State bank (BancoEstado) rol en garantías

---

### GMD Integration - Chile

**Desafío:** Dataset termina en 2021, GMD tiene 2022-2024

**Decisión:** Usar GMD para contextualizar período 2015-2021 (no extender)

```r
chile_gmd <- gmd %>%
  filter(ISO3 == "CHL", year >= 2015, year <= 2021) %>%
  select(year, exports_USD, imports_USD, nGDP_USD, 
         exports_GDP, imports_GDP)

chile_enhanced <- chile_processed %>%
  left_join(chile_gmd, by = "year") %>%
  mutate(
    tf_pct_gdp = (MonedaTotal_sum_tf / nGDP_USD_clp) * 100  # Convert CLP→USD
  )
```

---

## 🇧🇷 BRASIL - ANÁLISIS DETALLADO

### Dataset Actual
- **838,166 obs** total
- **Período:** Ene 2012 - Dic 2024 (13 años)
- **Granularidad:** 27 UF (states) × 19 CNAE (sectors) × 5 Porte (sizes)
- **⚠️ NO hay bancos individuales:** Datos agregados por banco anónimo
- **Variables clave:**
  - `carteira_ativa_usd` (active portfolio USD)
  - `modalidade` (ACC, ACE, FINIMP para TF)
  - `porte` (borrower size)
  - `uf` (state), `cnae_secao` (sector)

### GRÁFICOS CORE (4 obligatorios - ajustado sin bancos)

#### 🗺️ **Plot 1: Regional Analysis - Top 10 States**
**Archivo:** `plots/brazil_01_regional_tf.png`
```r
# Faceted time series (10 paneles para top UFs)
# X: Tiempo 2012-2024
# Y: TF credit USD billions (ACC + ACE + FINIMP)
# Paneles: SP, RJ, MG, RS, PR, SC, BA, ES, CE, GO
# Color: State
# Formato: 300 DPI, 16×12 inches, English
```

**Insight esperado:** SP domina (~40%), Sur (RS, PR, SC) importante

---

#### 🏭 **Plot 2: Sector Analysis**
**Archivo:** `plots/brazil_02_sector_tf.png`
```r
# Stacked area chart 2012-2024
# Y: TF credit USD billions (apilado 100%)
# Layers: 8 sectores principales CNAE
#   - Manufacturing (top)
#   - Wholesale/Retail
#   - Agriculture
#   - Mining
#   - Transport/Logistics
#   - Others
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Manufacturing ~55%, Wholesale/Retail ~30%

---

#### 📊 **Plot 3: Size Distribution** (comparable con Perú)
**Archivo:** `plots/brazil_03_size_distribution.png`
```r
# Similar a Perú Plot 2:
# Stacked area 2012-2024
# Y: TF credit USD billions
# Layers: Grande, Médio, Pequeno, Micro, Unknown (5 categorías)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Grande domina (~50%), Médio significativo (~35%)

---

#### 🔥 **Plot 4: State × Sector Heatmap**
**Archivo:** `plots/brazil_04_state_sector_heatmap.png`
```r
# Heatmap snapshot 2024
# Y: States (27)
# X: Sectors (8 principales)
# Fill: TF credit USD millions (log scale)
# Color: viridis (yellow = alto, purple = bajo)
# Formato: 300 DPI, 14×12 inches, English
```

**Insight esperado:** SP-Manufacturing cluster, Sul-Agriculture strong

---

### GRÁFICOS EXTRAS (4 adicionales)

#### 📈 **Plot 5: Regional Inequality**
**Archivo:** `plots/brazil_05_regional_gini.png`
```r
# Línea temporal 2012-2024 (anual)
# Y: Gini coefficient of TF credit across 27 states
# Trend: ¿Concentración creciente o convergencia?
# Formato: 300 DPI, 10×8 inches, English
```

**Insight esperado:** Alta desigualdad regional persistente

---

#### 🌎 **Plot 6: North vs South Comparison**
**Archivo:** `plots/brazil_06_north_south.png`
```r
# Panel comparison:
#   - Panel A: North + Northeast (agregado)
#   - Panel B: South + Southeast (agregado)
# Y: TF credit USD billions
# X: Tiempo 2012-2024
# Ratio annotation: Sul/Norte
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Sul/Sudeste ~85%, Norte/Nordeste ~15%

---

#### 🏭 **Plot 7: Manufacturing vs Services**
**Arquivo:** `plots/brazil_07_manufacturing_vs_services.png`
```r
# Dual line chart 2012-2024
# Linha 1: Manufacturing TF
# Linha 2: Services TF (Wholesale + Transport + IT)
# Y: USD billions
# Ratio temporal annotation
# Formato: 300 DPI, 12×8 inches, English (with Portuguese sector names)
```

**Insight esperado:** Manufacturing 3-4× maior que Services

---

#### 📊 **Plot 8: TF Modality Evolution**
**Arquivo:** `plots/brazil_08_modality_evolution.png`
```r
# Stacked area 2012-2024
# Y: USD billions
# Layers: ACC, ACE, FINIMP, Others
# Export financing (ACC+ACE) vs Import financing (FINIMP)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Export financing > Import (Brasil exportador commodities)

---

### GMD Integration - Brasil

```r
brazil_gmd <- gmd %>%
  filter(ISO3 == "BRA", year >= 2012) %>%
  select(year, exports_USD, imports_USD, nGDP_USD, rGDP_USD,
         exports_GDP, imports_GDP, infl, unemp)

brazil_enhanced <- brazil_processed %>%
  left_join(brazil_gmd, by = "year") %>%
  mutate(
    tf_pct_gdp = (carteira_ativa_usd / nGDP_USD) * 100,
    trade_intensity = ((exports_USD + imports_USD) / nGDP_USD) * 100
  )
```

---

## 🌎 COMPARACIÓN CROSS-COUNTRY (Script 06)

### TIER 1: Bank-Level Comparisons (México, Perú, Chile SOLO)

#### 📊 **Plot 1: TF Intensity Comparison**
**Archivo:** `plots/comparison_01_tf_intensity.png`
```r
# Synchronized time series (período común: 2015-2021)
# Línea 1: México L/C % liabilities
# Línea 2: Perú TF % total credit
# Línea 3: Chile TF % total loans
# Y: % (0-15%)
# X: Tiempo (quarterly)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** Perú mayor intensidad (~10%), México menor (~0.1%), Chile medio (~5%)

---

#### 📉 **Plot 2: Bank Concentration Comparison**
**Archivo:** `plots/comparison_02_concentration.png`
```r
# Dual panel:
#   - Panel A: HHI for 3 countries
#   - Panel B: CR5 for 3 countries
# X: Tiempo (2015-2021 anual)
# Lines: 3 países (color coded)
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** México más concentrado, Perú/Chile similares

---

### TIER 2: Size Analysis (Perú, Brasil SOLO)

#### 📊 **Plot 3: Size Distribution Comparison**
**Archivo:** `plots/comparison_03_size_patterns.png`
```r
# Faceted stacked areas (2 paneles)
#   - Panel A: Perú (5 sizes)
#   - Panel B: Brasil (5 sizes)
# Y: TF credit % (normalized 100%)
# X: Tiempo (2012-2024, período común)
# Formato: 300 DPI, 14×10 inches, English
```

**Insight esperado:** Brasil más orientado a Grande, Perú más diversificado

---

### TIER 3: Macro Correlations (4 países con GMD)

#### 📍 **Plot 4: TF Credit vs Trade Volume**
**Archivo:** `plots/comparison_04_tf_vs_trade.png`
```r
# Scatter plot (4 colores para 4 países)
# X: Trade volume % GDP (GMD exports_GDP + imports_GDP)
# Y: TF credit % GDP (calculado para cada país)
# Points: 1 por país-año (2015-2024)
# Regresión: 4 líneas (1 por país) + overall
# Formato: 300 DPI, 12×10 inches, English
```

**Insight esperado:** Correlación positiva fuerte, México más elástico (nearshoring)

---

#### 🚨 **Plot 5: Crisis Impact Analysis**
**Archivo:** `plots/comparison_05_crisis_impact.png`
```r
# Indexed time series (2019 = 100)
# Per��odo: 2019-2024 (captura COVID + recovery)
# Y: TF credit index (100 = pre-COVID)
# Lines: 4 países
# Shaded areas: Crisis periods (GMD indicators)
# Annotations: Recovery rates por país
# Formato: 300 DPI, 14×8 inches, English
```

**Insight esperado:** V-shape recovery 2020-2021, México overperformance 2024 (nearshoring)

---

#### 🏭 **Plot 6: Nearshoring Proxy**
**Archivo:** `plots/comparison_06_nearshoring.png`
```r
# Panel comparison México vs otros 3
#   - Panel A: México TF growth % (2022-2024)
#   - Panel B: Peru, Chile, Brazil promedio
# Y: TF credit growth % YoY
# Bars: Por año (2022, 2023, 2024)
# Statistical test: México 2024 vs others (t-test)
# Formato: 300 DPI, 12×8 inches, English
```

**Insight esperado:** México spike 2024 (~25% growth) vs otros (~5%)

---

## 📄 REPORTE INTEGRADO (Script 07)

### Secciones del HTML Report

1. **Executive Summary** (1 página)
   - Key findings bullets (10-15 items)
   - Main charts thumbnails (1 por país)
   - Cross-country insights

2. **Methodology** (2-3 páginas)
   - Data sources table: CNBV, SBS, CMF, BCB, BACI, GMD
   - Sample periods por país
   - Trade finance definitions
   - Bank classifications
   - Limitations

3. **México** (8-10 páginas)
   - All 9-10 plots embedded
   - Interpretation paragraphs
   - Statistical tables (summary stats, correlations)
   - Bank classification table

4. **Perú** (8-10 páginas)
   - All 8 plots
   - Size analysis deep dive
   - Crisis periods analysis
   - Bank specialization table

5. **Chile** (8-10 páginas)
   - All 8 plots
   - Account-level breakdown table
   - L/C vs other instruments comparison
   - Foreign funding analysis

6. **Brasil** (8-10 páginas)
   - All 8 plots
   - Regional inequality analysis
   - Sector composition tables
   - Modality breakdown

7. **Cross-Country Analysis** (6-8 páginas)
   - All 6 comparison plots
   - Statistical tests tables
   - Correlation matrices
   - Policy implications

8. **Appendices**
   - Data dictionaries (4 países)
   - Complete bank lists with classifications
   - Account code mappings (Chile)
   - Modality definitions (Brasil)
   - GMD variables descriptions

### LaTeX Tables for Paper

```r
# 07_integrated_report.R should generate:
#
# table1_summary_stats.tex - Summary statistics 4 countries
# table2_bank_classification.tex - Bank classifications
# table3_concentration.tex - HHI & CR5 by country-year
# table4_correlation_matrix.tex - TF vs macro variables
# table5_crisis_impact.tex - Growth rates pre/post crises
# table6_size_distribution.tex - Peru vs Brazil comparison
# table7_gmg_integration.tex - BACI vs GMD differences
```

---

## 🚀 EJECUCIÓN DEL PLAN

### Orden de Prioridad

**FASE 1: Integración GMD (PRIMERO)**
```r
# scripts/00_integrate_gmd.R
# - Función load_gmd_data()
# - Función merge_gmd_by_country()
# - Generar *_enhanced.csv con GMD columns
# - Tiempo estimado: 2-3 horas
```

**FASE 2: Actualizar Master Processing**
```r
# scripts/01_master_processing.R
# - Asegurar GMD columns en RDS
# - Calcular *_pct_gdp metrics
# - Re-ejecutar para generar RDS con GMD
# - Tiempo estimado: 1 hora
```

**FASE 3: Scripts de Análisis por País** (paralelo posible)
```r
# scripts/02_mexico_analysis.R     → 5 core + 5 extras = 10 plots
# scripts/03_peru_analysis.R       → 5 core + 3 extras = 8 plots  
# scripts/04_chile_analysis.R      → 5 core + 3 extras = 8 plots
# scripts/05_brazil_analysis.R     → 4 core + 4 extras = 8 plots
# Tiempo estimado: 6-8 horas TOTAL (1.5-2h por país)
```

**FASE 4: Comparación Cross-Country**
```r
# scripts/06_comparison.R          → 6 plots comparativos
# Tiempo estimado: 3-4 horas
```

**FASE 5: Reporte Integrado**
```r
# scripts/07_integrated_report.R   → HTML + LaTeX tables
# Tiempo estimado: 4-5 horas
```

**FASE 6: Documentación**
```r
# scripts/run_all.R                → Master runner
# README.md                        → Comprehensive guide
# Tiempo estimado: 2 horas
```

---

## 📝 ESTÁNDARES DE CÓDIGO

### Plot Standards
```r
# Todos los plots deben seguir:

# 1. Resolución
ggsave(filename, plot, width = 14, height = 8, dpi = 300, units = "in")

# 2. Theme
theme_minimal() +
  theme(
    text = element_text(size = 12, family = "Arial"),
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 12),
    legend.position = "bottom"
  )

# 3. Colors (consistent)
bank_type_colors <- c(
  "Foreign" = "#E41A1C",
  "Large Domestic" = "#377EB8",
  "Other Domestic" = "#4DAF4A",
  "Development" = "#984EA3"
)

# 4. Labels (English)
labs(
  title = "Letters of Credit Evolution in Mexico",
  subtitle = "Monthly outstanding L/C by bank type, 2022-2025",
  x = "Date",
  y = "L/C Outstanding (USD millions)",
  caption = "Source: CNBV (R12 A Balance). GMD trade data for 2024-2025."
)

# 5. Annotations
annotate("text", x = date_point, y = value, 
         label = "Nearshoring\nspike", 
         hjust = 0, vjust = 1, size = 3.5)
```

### Summary Stats Pattern
```r
# Al inicio de cada script de análisis:
cat("\n=== COUNTRY ANALYSIS: [COUNTRY NAME] ===\n")
cat("Dataset: [observations] observations, [period]\n")
cat("Key metric: [definition]\n")
cat("Time range: [start] - [end]\n\n")

# Al final de cada plot:
cat("✓ Saved: [filename]\n")
```

---

## 🎯 MÉTRICAS DE ÉXITO

### Outputs Esperados

**Archivos Generados:**
- 📊 **42 plots PNG** (10 México + 8 Perú + 8 Chile + 8 Brasil + 6 Comparison + 2 extras)
- 📄 **1 HTML report** (~40-50 páginas)
- 📝 **7 LaTeX tables** (.tex files)
- 💾 **4 RDS files** (processed data con GMD)
- 📋 **1 README.md** completo

**Documentación:**
- ✅ Metodología clara (fuentes, definiciones, limitaciones)
- ✅ Interpretación de hallazgos (cada plot con insight)
- ✅ Tablas de clasificación de bancos
- ✅ Data dictionaries por país
- ✅ Referencias a literatura (si relevante)

**Reproducibilidad:**
- ✅ `run_all.R` ejecuta todo en < 30 minutos
- ✅ Cada script standalone (puede correr independiente)
- ✅ Logs de ejecución (console output guardado)
- ✅ Versionado claro (README indica versiones R packages)

---

## ⚠️ NOTAS IMPORTANTES

### Diferencias Metodológicas a Documentar

1. **México:** L/C son **pasivos** (bank perspective), no créditos (borrower perspective)
2. **Perú/Chile/Brasil:** Trade finance son **activos** crediticios
3. **Comparación intensity:** No directamente comparable (denominadores distintos)
4. **Brasil:** Sin bancos individuales → Análisis regional/sectorial, no bancario
5. **Chile:** Dataset termina 2021 → No comparable post-COVID
6. **BACI vs GMD:** Discontinuidad en 2023/2024 (marcar en gráficos)
7. **Currency effects:** MXN/USD, PEN/USD, CLP/USD, BRL/USD volatilities pueden distorsionar trends USD

### Limitaciones a Mencionar

- **México:** Corto período (2022-2025), solo L/C (otros instrumentos no capturados)
- **Perú:** Tamaño de deudor disponible (único con granularidad), pero definition de "comercio exterior" puede incluir más que trade finance
- **Chile:** Dataset viejo (hasta 2021), mapping de cuentas puede tener errores
- **Brasil:** Datos agregados (sin bancos), modalidades pueden no cubrir todo TF
- **GMD:** Proyecciones FMI (2025-2030) no son observaciones reales
- **BACI:** Rezago 2 años, cobertura incompleta 2024-2025

---

## 📚 REFERENCIAS

### Data Sources
- **CNBV:** [cnbv.gob.mx](https://www.cnbv.gob.mx) - R12 A Balance
- **SBS Perú:** [sbs.gob.pe](https://www.sbs.gob.pe) - Reporte Crediticio
- **CMF Chile:** [cmfchile.cl](https://www.cmfchile.cl) - Información Financiera
- **BCB Brasil:** [bcb.gov.br](https://www.bcb.gov.br) - SCR
- **BACI:** [cepii.fr](http://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=37) - Trade Database
- **GMD:** (Fuente a confirmar - parece compilación FMI/World Bank)

### Literatura Relevante (a expandir)
- Amiti & Weinstein (2011): Exports and Financial Shocks
- Paravisini et al. (2015): How Are Small Exporters Affected by Financial Shocks?
- Niepmann & Schmidt-Eisenlohr (2017): International Trade, Risk and the Role of Banks
- IMF (2024): Nearshoring and Trade Finance in Latin America

---

**FIN DEL PLAN MAESTRO**

**Próximo paso:** Ejecutar scripts en orden (00 → 01 → 02-05 → 06 → 07)

**Status actual:**
- ✅ 00_integrate_gmd.R → PENDIENTE (crear)
- ✅ 01_master_processing.R → COMPLETO (actualizado con México enhanced)
- ⏳ 02_mexico_analysis.R → PENDIENTE
- ⏳ 03-07 → PENDIENTES

**Fecha actualización:** 19 de noviembre de 2025
