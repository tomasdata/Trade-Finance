# 📊 PLAN DE GRÁFICOS Y TABLAS - TRADE FINANCE LATAM

**Proyecto:** Análisis Comparativo Trade Finance  
**Países:** México 🇲🇽 | Perú 🇵🇪 | Chile 🇨🇱 | Brasil 🇧🇷  
**Última actualización:** 19 noviembre 2025  
**Estado:** Datos listos con GMD integrado

---

## 📋 RESUMEN EJECUTIVO

### Datos Disponibles por País

| País | Obs | Período | Bancos | Tamaño | Geografía | Productos | Variables Trade |
|------|-----|---------|--------|--------|-----------|-----------|----------------|
| **México** | 2,204 | 2022-2025 | ✅ 53 | ❌ No | ❌ No | 1 (L/C) | ✅ GMD 2020-2024 |
| **Perú** | 13,785 | 2010-2024 | ✅ 19 | ✅ 5 | ❌ No | 1 (TF credit) | ✅ GMD 2020-2024 |
| **Chile** | 38,449 | 2015-2024 | ✅ 27 | ❌ No | ❌ No | ✅ 9 | ✅ GMD 2020-2024 |
| **Brasil** | 838,166 | 2012-2024 | ❌ No | ✅ 5 | ✅ 27 estados | ✅ 4 | ✅ GMD 2020-2024 |

**Total:** 892,604 observaciones  
**Período común:** 2022-2023 (2 años de overlap completo)  
**Fuente Trade/GDP:** Global Macro Database (BOP methodology, 2020-2024)

---

## 🎯 ESTRUCTURA DE ANÁLISIS

### TIER 1: Análisis por País (Individual)
- **México:** 10 gráficos + 10 tablas
- **Perú:** 8 gráficos + 8 tablas
- **Chile:** 8 gráficos + 8 tablas
- **Brasil:** 8 gráficos + 8 tablas

### TIER 2: Comparaciones Cross-Country
- 8 gráficos comparativos + 8 tablas
- Usar período común 2022-2023 cuando sea necesario

**TOTAL:** 42 gráficos + 42 tablas

---

## 🇲🇽 MÉXICO - 10 GRÁFICOS

### Variables Disponibles:
- `lc_liabilities`: Cartas de crédito como pasivo (USD miles)
- `total_liabilities`: Pasivo total del banco (USD miles)
- `lc_pct_liabilities`: L/C como % del pasivo total
- `institucion_std`: Nombre banco estandarizado
- `bank_type`: Foreign / Domestic / State
- `exports_usd_millions`: Exportaciones GMD (2020-2024)
- `imports_usd_millions`: Importaciones GMD (2020-2024)
- `gdp_usd_billions`: PIB anual GMD (2020-2024)

### GRÁFICO MEX-1: Evolución L/C Over Time
**Tipo:** Dual-axis line chart  
**Eje Y izq:** L/C total (USD millones)  
**Eje Y der:** L/C como % pasivos totales  
**Eje X:** Mensual 2022-2025  
**Overlay:** Banda sombreada periodo nearshoring (2023-2024)  
**Tabla asociada:** `tables/mex_01_lc_evolution.csv`
- Columnas: year_month, lc_usd_millions, lc_pct_liabilities, n_banks

**Insight esperado:** Duplicación L/C 2023→2024 (efecto nearshoring)

---

### GRÁFICO MEX-2: L/C por Tipo de Banco
**Tipo:** Box plots con puntos individuales  
**Y:** L/C como % de pasivos  
**X:** Bank type (Foreign / Domestic / State)  
**Facet:** Por año (2022, 2023, 2024)  
**Tabla asociada:** `tables/mex_02_lc_by_bank_type.csv`
- Columnas: bank_type, year, mean_lc_pct, median_lc_pct, sd, n_banks, total_lc_usd

**Insight esperado:** Bancos extranjeros mayor intensidad L/C

---

### GRÁFICO MEX-3: Top 10 Bancos por Intensidad L/C
**Tipo:** Horizontal bar chart  
**Y:** Banco  
**X:** L/C como % pasivos (promedio 2022-2025)  
**Color:** Bank type  
**Orden:** Descendente por intensidad  
**Tabla asociada:** `tables/mex_03_top10_intensity.csv`
- Columnas: banco, bank_type, avg_lc_pct, total_lc_usd_millions, n_months

**Insight esperado:** ICBC mayor intensidad (~3%)

---

### GRÁFICO MEX-4: Concentración de Mercado
**Tipo:** Dual-line time series  
**Línea 1:** HHI (Herfindahl-Hirschman Index)  
**Línea 2:** CR5 (concentración top 5 bancos, %)  
**X:** Mensual 2022-2025  
**Línea horizontal ref:** HHI=1500 (moderada concentración)  
**Tabla asociada:** `tables/mex_04_concentration.csv`
- Columnas: year_month, hhi, cr3, cr5, cr10, top5_banks_list

**Insight esperado:** CR5 ~65%, moderada concentración

---

### GRÁFICO MEX-5: Efecto Nearshoring 2023 vs 2024
**Tipo:** Paired comparison (violin plots + means)  
**Y:** L/C USD millones por banco-mes  
**X:** 2023 vs 2024  
**Overlay:** Líneas conectando medias  
**Test estadístico:** t-test anotado  
**Tabla asociada:** `tables/mex_05_nearshoring_effect.csv`
- Columnas: year, mean_lc, median_lc, sd, growth_rate, n_obs

**Insight esperado:** +100% crecimiento year-over-year

---

### GRÁFICO MEX-6: L/C vs Comercio Exterior
**Tipo:** Scatter plot con regresión  
**Y:** L/C total (USD millones)  
**X:** Exports + Imports GMD (USD millones)  
**Puntos:** Mensual 2022-2024  
**Color:** Año  
**Línea:** Regresión lineal con IC 95%  
**Tabla asociada:** `tables/mex_06_lc_vs_trade.csv`
- Columnas: year_month, lc_usd, exports_usd, imports_usd, trade_total_usd, lc_to_trade_ratio

**Insight esperado:** Correlación L/C con volumen de comercio

---

### GRÁFICO MEX-7: Market Share L/C
**Tipo:** Stacked area chart  
**Y:** % del mercado L/C  
**X:** Mensual 2022-2025  
**Áreas:** Top 5 bancos + "Others"  
**Colores:** Paleta categórica  
**Tabla asociada:** `tables/mex_07_market_share.csv`
- Columnas: year_month, banco, lc_usd, market_share_pct

**Insight esperado:** Concentración en top 5, estable en el tiempo

---

### GRÁFICO MEX-8: Composición por Tipo de Banco
**Tipo:** Stacked bar chart (horizontal)  
**Y:** Año  
**X:** % del total L/C  
**Segmentos:** Foreign / Domestic / State  
**Anotaciones:** % exactos en cada segmento  
**Tabla asociada:** `tables/mex_08_composition_bank_type.csv`
- Columnas: year, bank_type, lc_usd, pct_of_total, n_banks

**Insight esperado:** Foreign banks dominan (~60-70%)

---

### GRÁFICO MEX-9: Estacionalidad L/C
**Tipo:** Heatmap  
**Y:** Mes (1-12)  
**X:** Año (2022, 2023, 2024)  
**Color:** L/C total (USD millones)  
**Anotaciones:** Valores en celdas  
**Tabla asociada:** `tables/mex_09_seasonality.csv`
- Columnas: year, month, lc_usd_avg, lc_pct_avg, n_banks

**Insight esperado:** Identificar patrones mensuales (Q4 mayor?)

---

### GRÁFICO MEX-10: Triple-Axis Macro View
**Tipo:** Triple-axis line chart  
**Eje Y izq:** L/C total (USD millones)  
**Eje Y der 1:** Exports + Imports (USD billones) - GMD  
**Eje Y der 2:** PIB anual (USD billones) - GMD  
**X:** Mensual 2022-2024  
**Tabla asociada:** `tables/mex_10_macro_view.csv`
- Columnas: year_month, lc_usd, trade_usd_billions, gdp_usd_billions, lc_to_gdp_pct_annual

**Insight esperado:** L/C sigue ciclo de comercio exterior

---

## 🇵🇪 PERÚ - 8 GRÁFICOS

### Variables Disponibles:
- `amount`: Monto trade finance (PEN miles)
- `size`: Corporate / Large / Medium / Small / Micro
- `institucion_std`: Nombre banco estandarizado
- `bank_type`: Foreign / Domestic / State / Mixed
- `total`: Cartera total del banco (PEN miles)
- `tf_pct_total`: TF como % cartera total
- `exports_usd_millions`: Exportaciones GMD (2020-2024)
- `imports_usd_millions`: Importaciones GMD (2020-2024)
- `gdp_usd_billions`: PIB anual GMD (2020-2024)

### GRÁFICO PER-1: TF como % de Crédito Total
**Tipo:** Time series con bandas de crisis  
**Y:** TF como % de cartera total  
**X:** Mensual 2010-2024  
**Línea:** Promedio ponderado por banco  
**Bandas sombreadas:**
  - 2015-2016: Desaceleración China
  - 2020 Q1-Q2: COVID-19
  - 2022 Q4: Crisis política Perú  
**Tabla asociada:** `tables/per_01_tf_pct_total.csv`
- Columnas: year_month, tf_pct_avg, tf_pen_millions, total_pen_millions, n_banks

**Insight esperado:** Caída durante crisis, recuperación 2021-2023

---

### GRÁFICO PER-2: TF por Tamaño de Empresa
**Tipo:** Stacked area chart  
**Y:** TF total (PEN millones)  
**X:** Mensual 2010-2024  
**Áreas:** 5 categorías (Corporate / Large / Medium / Small / Micro)  
**Orden:** De mayor a menor (Corporate arriba)  
**Tabla asociada:** `tables/per_02_tf_by_size.csv`
- Columnas: year_month, size, tf_pen_millions, pct_of_total

**Insight esperado:** Corporate domina (~45%), Micro marginal (~2%)

---

### GRÁFICO PER-3: TF por Tipo de Banco
**Tipo:** Box plots por año  
**Y:** TF como % cartera total  
**X:** Bank type (Foreign / Domestic / State / Mixed)  
**Facet:** Por año (selección: 2010, 2015, 2020, 2024)  
**Tabla asociada:** `tables/per_03_tf_by_bank_type.csv`
- Columnas: year, bank_type, mean_tf_pct, median_tf_pct, sd, n_banks

**Insight esperado:** Foreign banks mayor especialización TF

---

### GRÁFICO PER-4: Concentración de Mercado
**Tipo:** Dual-line time series  
**Línea 1:** HHI  
**Línea 2:** CR5 (%)  
**X:** Mensual 2010-2024  
**Líneas ref:** HHI=1500, CR5=60%  
**Tabla asociada:** `tables/per_04_concentration.csv`
- Columnas: year_month, hhi, cr3, cr5, cr10, top5_banks_list

**Insight esperado:** CR5 ~80%, BCP + Scotiabank dominan

---

### GRÁFICO PER-5: Distribución por Tamaño (5 paneles)
**Tipo:** 5 faceted time series  
**Y:** TF (PEN millones)  
**X:** Mensual 2010-2024  
**Facets:** 5 paneles verticales (Corporate, Large, Medium, Small, Micro)  
**Escalas:** Libres en Y (diferentes magnitudes)  
**Tabla asociada:** `tables/per_05_size_distribution.csv`
- Columnas: year_month, size, tf_pen_millions, pct_of_total, n_banks

**Insight esperado:** Corporate volátil, Medium estable

---

### GRÁFICO PER-6: TF vs Crecimiento PIB
**Tipo:** Scatter plot con regresión  
**Y:** Crecimiento TF year-over-year (%)  
**X:** Crecimiento PIB anual GMD (%)  
**Puntos:** Anual 2011-2024  
**Color:** Año  
**Línea:** Regresión con IC 95%  
**Tabla asociada:** `tables/per_06_tf_vs_gdp_growth.csv`
- Columnas: year, tf_growth_yoy, gdp_growth_yoy, trade_growth_yoy

**Insight esperado:** Correlación positiva TF-PIB

---

### GRÁFICO PER-7: Impacto de Crisis (indexed)
**Tipo:** Indexed time series (2019=100)  
**Líneas:**
  - TF total
  - Exports GMD
  - Imports GMD
  - PIB GMD (anual)  
**X:** Mensual 2019-2024  
**Línea ref:** 100 (nivel pre-crisis)  
**Bandas:** COVID-19 (2020 Q1-Q2), Crisis política (2022 Q4)  
**Tabla asociada:** `tables/per_07_crisis_impact.csv`
- Columnas: year_month, tf_index, exports_index, imports_index, gdp_index_annual

**Insight esperado:** Caída 2020, recuperación asimétrica

---

### GRÁFICO PER-8: Especialización Bancaria (Heatmap)
**Tipo:** Heatmap  
**Y:** Banco (19 instituciones)  
**X:** Tamaño empresa (5 categorías)  
**Color:** % del portfolio TF del banco en esa categoría  
**Anotaciones:** Valores % en celdas  
**Orden Y:** Por especialización (clustering)  
**Tabla asociada:** `tables/per_08_bank_specialization.csv`
- Columnas: banco, bank_type, size, tf_pen_millions, pct_of_bank_tf, pct_of_size_market

**Insight esperado:** Segmentación de mercado por tamaño

---

## 🇨🇱 CHILE - 8 GRÁFICOS

### Variables Disponibles:
- `MonedaTotal`: Monto total (CLP miles)
- `MonedaExtranjera`: Monto USD (CLP miles)
- `CodigoCuenta`: Código cuenta contable
- `DescripcionCuenta`: Descripción cuenta
- `NombreInstitucion`: Nombre banco
- `bank_type`: Foreign / Domestic / State
- `account_group`: Export / Import / L/C / Guarantees / Foreign Funding / etc.
- `exports_usd_millions`: Exportaciones GMD (2020-2024)
- `imports_usd_millions`: Importaciones GMD (2020-2024)
- `gdp_usd_billions`: PIB anual GMD (2020-2024)

### GRÁFICO CHL-1: TF como % de Préstamos Totales
**Tipo:** Time series con línea de quiebre  
**Y:** TF como % préstamos totales  
**X:** Mensual 2015-2024  
**Línea vertical:** Enero 2022 (cambio SBIF→CMF/IFRS9)  
**Anotación:** "Cambio contable" en línea vertical  
**Tabla asociada:** `tables/chl_01_tf_pct_total.csv`
- Columnas: year_month, tf_clp_millions, total_loans_clp_millions, tf_pct, accounting_system

**Insight esperado:** Salto 2021→2022 por mejor identificación cuentas

---

### GRÁFICO CHL-2: Financiamiento Exportaciones vs Importaciones
**Tipo:** Dual-line time series  
**Línea 1:** Financiamiento exportaciones (CLP millones)  
**Línea 2:** Financiamiento importaciones (CLP millones)  
**X:** Mensual 2015-2024  
**Área sombreada:** Diferencia (net trade financing)  
**Tabla asociada:** `tables/chl_02_export_vs_import.csv`
- Columnas: year_month, export_financing_clp, import_financing_clp, net_financing_clp, exports_imports_ratio

**Insight esperado:** Importaciones > Exportaciones (Chile importador neto TF)

---

### GRÁFICO CHL-3: Evolución Cartas de Crédito
**Tipo:** Stacked bar chart  
**Y:** L/C total (CLP millones)  
**X:** Mensual 2015-2024  
**Segmentos:**
  - L/C exportaciones chilenas
  - L/C importaciones chilenas
  - L/C terceros países  
**Tabla asociada:** `tables/chl_03_lc_evolution.csv`
- Columnas: year_month, lc_exports_clp, lc_imports_clp, lc_thirdparty_clp, lc_total_clp

**Insight esperado:** L/C importaciones dominan, terceros países marginal

---

### GRÁFICO CHL-4: Financiamiento de Bancos Extranjeros
**Tipo:** Dual-axis time series  
**Eje Y izq:** Monto funding extranjero (CLP millones)  
**Eje Y der:** % del total TF  
**X:** Mensual 2015-2024  
**Línea ref:** 25% (promedio histórico)  
**Tabla asociada:** `tables/chl_04_foreign_funding.csv`
- Columnas: year_month, foreign_funding_clp, tf_total_clp, foreign_pct, n_banks_with_foreign

**Insight esperado:** ~25% TF financiado por líneas externas

---

### GRÁFICO CHL-5: Concentración de Mercado
**Tipo:** Dual-line time series  
**Línea 1:** HHI  
**Línea 2:** CR5 (%)  
**X:** Mensual 2015-2024  
**Líneas ref:** HHI=1500, CR5=60%  
**Tabla asociada:** `tables/chl_05_concentration.csv`
- Columnas: year_month, hhi, cr3, cr5, cr10, top5_banks_list

**Insight esperado:** CR5 ~72%, Banco de Chile + Santander lideran

---

### GRÁFICO CHL-6: Desglose 40 Cuentas TF (Small Multiples)
**Tipo:** Small multiples (8x5 grid)  
**Y:** Monto (CLP millones)  
**X:** Anual 2015-2024  
**Facets:** 40 cuentas trade finance identificadas  
**Orden:** Por volumen promedio (descendente)  
**Tabla asociada:** `tables/chl_06_account_breakdown.csv`
- Columnas: year, account_code, account_description, clp_millions, pct_of_tf

**Insight esperado:** Identificar principales instrumentos TF Chile

---

### GRÁFICO CHL-7: Comercio Entre Terceros Países
**Tipo:** Time series  
**Y:** Financiamiento terceros países (CLP millones)  
**X:** Mensual 2015-2024  
**Línea:** Con área bajo curva  
**Tabla asociada:** `tables/chl_07_third_party_trade.csv`
- Columnas: year_month, thirdparty_clp, pct_of_tf, n_banks

**Insight esperado:** Marginal pero existente (Chile como hub regional?)

---

### GRÁFICO CHL-8: Evolución Garantías TF
**Tipo:** Stacked area chart  
**Y:** Garantías TF (CLP millones)  
**X:** Mensual 2015-2024  
**Áreas:** Por tipo de garantía (si identificable en cuentas)  
**Tabla asociada:** `tables/chl_08_guarantees.csv`
- Columnas: year_month, guarantees_clp, guarantees_pct_tf, n_banks

**Insight esperado:** ~10% del TF son garantías

---

## 🇧🇷 BRASIL - 8 GRÁFICOS

### Variables Disponibles:
- `carteira_ativa`: Cartera activa TF (BRL miles)
- `uf`: Estado (27 estados)
- `cnae_secao`: Sector económico (8 sectores principales)
- `porte`: Tamaño empresa (Micro / Pequeno / Médio / Grande)
- `modalidade`: Modalidad (ACC / ACE / FINIMP / NCE)
- `numero_de_operacoes`: Número de operaciones
- `vencimientos`: 6 categorías de plazo
- `exports_usd_millions`: Exportaciones GMD (2020-2024)
- `imports_usd_millions`: Importaciones GMD (2020-2024)
- `gdp_usd_billions`: PIB anual GMD (2020-2024)

### GRÁFICO BRA-1: Top 10 Estados (Faceted Time Series)
**Tipo:** Faceted time series (10 paneles)  
**Y:** TF (BRL millones)  
**X:** Mensual 2012-2024  
**Facets:** Top 10 estados (SP, RJ, MG, PR, SC, RS, BA, CE, PE, GO)  
**Escalas:** Libres en Y  
**Tabla asociada:** `tables/bra_01_top10_states.csv`
- Columnas: year_month, uf, tf_brl_millions, pct_of_national, n_operations

**Insight esperado:** SP domina (~40%), Sur+Sudeste ~81%

---

### GRÁFICO BRA-2: 8 Sectores Económicos
**Tipo:** Stacked area chart  
**Y:** TF total (BRL millones)  
**X:** Mensual 2012-2024  
**Áreas:** 8 sectores CNAE principales  
**Orden:** Por volumen promedio (descendente)  
**Tabla asociada:** `tables/bra_02_sectors.csv`
- Columnas: year_month, cnae_secao, tf_brl_millions, pct_of_total

**Insight esperado:** Manufactura domina (~55%), Comercio (~30%)

---

### GRÁFICO BRA-3: 5 Tamaños de Empresa (comparar con Perú)
**Tipo:** Stacked area chart  
**Y:** TF total (BRL millones)  
**X:** Mensual 2012-2024  
**Áreas:** 5 tamaños (Micro / Pequeno / Médio / Grande)  
**Nota:** Panel comparativo con Perú (2 paneles lado a lado)  
**Tabla asociada:** `tables/bra_03_size_distribution.csv`
- Columnas: year_month, porte, tf_brl_millions, pct_of_total, avg_operation_size_brl

**Insight esperado:**
- Brasil: Médio domina obs (54%), Grande volumen (80%)
- Perú: Corporate domina ambos (~45%)

---

### GRÁFICO BRA-4: Heatmap Estado × Sector (2024)
**Tipo:** Heatmap  
**Y:** Estados (27)  
**X:** Sectores (8)  
**Color:** TF (BRL millones) en 2024  
**Anotaciones:** Valores en celdas (top 20 combinaciones)  
**Tabla asociada:** `tables/bra_04_state_sector_heatmap.csv`
- Columnas: uf, cnae_secao, tf_brl_millions_2024, pct_of_state, pct_of_sector

**Insight esperado:** SP Manufactura domina, especialización regional

---

### GRÁFICO BRA-5: Desigualdad Regional (Gini)
**Tipo:** Time series  
**Y:** Gini coefficient (concentración geográfica TF)  
**X:** Anual 2012-2024  
**Línea ref:** 0.5 (alta desigualdad)  
**Tabla asociada:** `tables/bra_05_regional_gini.csv`
- Columnas: year, gini_coefficient, top5_states_pct, top10_states_pct

**Insight esperado:** Gini ~0.58, alta concentración persistente

---

### GRÁFICO BRA-6: Norte vs Sur (Dual Panel)
**Tipo:** Dual panel time series  
**Panel 1:** Región Norte (AC, AM, AP, PA, RO, RR, TO)  
**Panel 2:** Región Sur (PR, SC, RS)  
**Y:** TF (BRL millones)  
**X:** Mensual 2012-2024  
**Tabla asociada:** `tables/bra_06_north_vs_south.csv`
- Columnas: year_month, region, tf_brl_millions, pct_of_national, n_operations

**Insight esperado:** Sur 10x más TF que Norte (brecha enorme)

---

### GRÁFICO BRA-7: Manufactura vs Servicios
**Tipo:** Dual-line time series  
**Línea 1:** Industrias de transformação (Manufactura)  
**Línea 2:** Sectores servicios (agregados)  
**X:** Mensual 2012-2024  
**Área sombreada:** Diferencia  
**Tabla asociada:** `tables/bra_07_manufacturing_vs_services.csv`
- Columnas: year_month, manufacturing_brl, services_brl, mfg_to_services_ratio

**Insight esperado:** Manufactura domina TF (~2:1 ratio)

---

### GRÁFICO BRA-8: Modalidades TF (ACC/ACE/FINIMP/NCE)
**Tipo:** Stacked area chart  
**Y:** TF (BRL millones)  
**X:** Mensual 2012-2024  
**Áreas:** 4 modalidades
  - ACC (Adiantamento sobre Contrato de Câmbio) - Pre-export
  - ACE (Adiantamento sobre Cambiais Entregues) - Post-export
  - FINIMP (Financiamento à Importação) - Import financing
  - NCE (Nota de Crédito à Exportação) - Export credit notes  
**Tabla asociada:** `tables/bra_08_modalities.csv`
- Columnas: year_month, modalidade, tf_brl_millions, pct_of_total, avg_operation_size

**Insight esperado:** ACC domina (pre-export financing más usado)

---

## 🌎 COMPARACIONES CROSS-COUNTRY - 8 GRÁFICOS

### COMP-1: Intensidad TF (3 países con bancos)
**Tipo:** Triple-line time series  
**Líneas:**
  - México: L/C como % pasivos totales
  - Perú: TF como % cartera total
  - Chile: TF como % préstamos totales  
**X:** Mensual, período común 2022-2023  
**Tabla asociada:** `tables/comp_01_tf_intensity.csv`
- Columnas: year_month, country, tf_intensity_pct, tf_local_currency_millions

**Insight esperado:** Perú mayor intensidad TF, México L/C limitado

---

### COMP-2: Concentración Bancaria (HHI + CR5)
**Tipo:** Panel dual  
**Panel 1:** HHI por país (3 líneas)  
**Panel 2:** CR5 por país (3 líneas)  
**X:** Anual 2015-2024  
**Líneas ref:** HHI=1500, CR5=60%  
**Tabla asociada:** `tables/comp_02_concentration.csv`
- Columnas: year, country, hhi, cr3, cr5, cr10

**Insight esperado:** Perú más concentrado (CR5 80%), México moderado (65%)

---

### COMP-3: Distribución por Tamaño (Perú vs Brasil)
**Tipo:** Grouped bar chart  
**Y:** % del TF total  
**X:** Tamaño empresa (5 categorías)  
**Grupos:** Perú vs Brasil  
**Período:** Promedio 2020-2024  
**Tabla asociada:** `tables/comp_03_size_comparison.csv`
- Columnas: size_category, peru_pct, brazil_pct, peru_avg_millions, brazil_avg_millions

**Insight esperado:**
- Perú: Corporate 45%
- Brasil: Médio 54%, Grande 27% (más democratizado)

---

### COMP-4: TF vs Comercio Exterior (4 países scatter)
**Tipo:** Scatter plot con 4 colores  
**Y:** TF total (USD millones, normalizado)  
**X:** Exports + Imports GMD (USD millones)  
**Puntos:** Mensual 2022-2023 (período común)  
**Color:** País  
**Línea:** Regresión por país  
**Tabla asociada:** `tables/comp_04_tf_vs_trade.csv`
- Columnas: year_month, country, tf_usd_millions, trade_usd_millions, tf_to_trade_ratio

**Insight esperado:** Brasil mayor volumen, correlación positiva todos

---

### COMP-5: Impacto COVID-19 (indexed 2019=100)
**Tipo:** 4 líneas indexed  
**Líneas:** TF total por país  
**X:** Mensual 2019-2024  
**Base:** 2019=100  
**Banda:** COVID-19 (2020 Q1-Q2)  
**Tabla asociada:** `tables/comp_05_crisis_impact.csv`
- Columnas: year_month, country, tf_index_2019_100, recovery_rate

**Insight esperado:** Caída heterogénea, recuperación Brasil más lenta

---

### COMP-6: Nearshoring Proxy (México vs Otros)
**Tipo:** Indexed comparison (2022=100)  
**Líneas:**
  - México L/C (indexed)
  - Perú TF (indexed)
  - Chile TF (indexed)
  - Brasil TF (indexed)  
**X:** Mensual 2022-2024  
**Anotación:** México crecimiento excepcional  
**Tabla asociada:** `tables/comp_06_nearshoring_proxy.csv`
- Columnas: year_month, country, tf_index_2022_100, growth_rate_yoy

**Insight esperado:** México +100% (nearshoring), otros estables

---

### COMP-7: TF como % PIB (4 países)
**Tipo:** 4-line time series  
**Y:** TF como % PIB anual GMD  
**X:** Anual 2020-2024  
**Líneas:** México, Perú, Chile, Brasil  
**Tabla asociada:** `tables/comp_07_tf_to_gdp.csv`
- Columnas: year, country, tf_usd_millions, gdp_usd_billions, tf_to_gdp_pct

**Insight esperado:** Perú mayor ratio TF/PIB (economía más dependiente TF)

---

### COMP-8: Especialización Bancaria Cross-Country
**Tipo:** Heatmap 3D (países × bank types × TF intensity)  
**Y:** País (México, Perú, Chile)  
**X:** Bank type (Foreign / Domestic / State)  
**Color:** TF intensity promedio (%)  
**Tabla asociada:** `tables/comp_08_bank_specialization.csv`
- Columnas: country, bank_type, avg_tf_intensity_pct, n_banks, total_tf_usd

**Insight esperado:** Foreign banks mayor intensidad TF en los 3 países

---

## 📋 ESTÁNDARES DE GRÁFICOS

### Especificaciones Técnicas

**Resolución:** 300 DPI (publication quality)  
**Formato salida:** PNG + PDF  
**Dimensiones:** 8" × 6" (landscape), 6" × 8" (portrait para facets verticales)  
**Fuente:** Arial 10pt (títulos), 8pt (ejes)  
**Colores:** Paleta colorblind-friendly (viridis, RColorBrewer Set2)  
**Idioma:** Inglés (para publicación)

### Elementos Obligatorios

✅ **Título descriptivo** (arriba)  
✅ **Ejes etiquetados** con unidades  
✅ **Leyenda** (cuando aplique)  
✅ **Fuente de datos** (abajo): "Source: CNBV/SBS/CMF/BCB, GMD"  
✅ **Nota metodológica** (si necesario): "Note: Chile accounting change 2022"  
✅ **Fecha generación** (abajo derecha): "Generated: Nov 2025"

### Carpetas de Salida

```
country_analysis/
├── plots/
│   ├── mexico/          ← MEX-1 a MEX-10
│   ├── peru/            ← PER-1 a PER-8
│   ├── chile/           ← CHL-1 a CHL-8
│   ├── brazil/          ← BRA-1 a BRA-8
│   └── comparison/      ← COMP-1 a COMP-8
│
└── tables/
    ├── mexico/          ← mex_01.csv a mex_10.csv
    ├── peru/            ← per_01.csv a per_08.csv
    ├── chile/           ← chl_01.csv a chl_08.csv
    ├── brazil/          ← bra_01.csv a bra_08.csv
    └── comparison/      ← comp_01.csv a comp_08.csv
```

---

## 🚀 PLAN DE EJECUCIÓN

### Fase 1: Scripts de Análisis
- [ ] `02_mexico_analysis.R` - Genera 10 gráficos + 10 tablas
- [ ] `03_peru_analysis.R` - Genera 8 gráficos + 8 tablas
- [ ] `04_chile_analysis.R` - Genera 8 gráficos + 8 tablas
- [ ] `05_brazil_analysis.R` - Genera 8 gráficos + 8 tablas
- [ ] `06_comparison.R` - Genera 8 gráficos + 8 tablas

### Fase 2: Validación
Para cada gráfico:
1. ✅ Generar gráfico PNG + PDF
2. ✅ Exportar tabla CSV con datos subyacentes
3. ✅ Verificar insights esperados
4. ✅ Documentar hallazgos en `reports/`

### Fase 3: Reporte Integrado
- [ ] `07_integrated_report.R` - Compila todo en HTML
- [ ] Incluye 42 gráficos + análisis narrativo
- [ ] Referencias cruzadas a tablas
- [ ] Conclusiones y policy implications

---

## ✅ CHECKLIST POR GRÁFICO

Para cada uno de los 42 gráficos:

- [ ] **Código R documentado** (con comentarios)
- [ ] **Gráfico PNG** (300 DPI, publication quality)
- [ ] **Gráfico PDF** (vector format)
- [ ] **Tabla CSV** (datos subyacentes)
- [ ] **Insight verificado** (coincide con expectativa o documenta sorpresa)
- [ ] **Metadatos** (fecha generación, fuente, nota metodológica)

---

## 📊 RESUMEN CUANTITATIVO

**Total gráficos:** 42  
- México: 10  
- Perú: 8  
- Chile: 8  
- Brasil: 8  
- Comparaciones: 8

**Total tablas:** 42 (1 por cada gráfico)

**Scripts necesarios:**
- `02_mexico_analysis.R`
- `03_peru_analysis.R`
- `04_chile_analysis.R`
- `05_brazil_analysis.R`
- `06_comparison.R`
- `07_integrated_report.R`

**Librerías R requeridas:**
```r
library(tidyverse)      # Data manipulation + ggplot2
library(scales)         # Axis formatting
library(patchwork)      # Plot composition
library(ggsci)          # Color palettes
library(viridis)        # Colorblind-friendly colors
library(ineq)           # Gini coefficient (Brasil)
library(zoo)            # Time series (indexing)
```

---

**Última actualización:** 19 noviembre 2025  
**Estado:** Plan definido, listo para implementación  
**Siguiente paso:** Crear `02_mexico_analysis.R` y comenzar Fase 1
