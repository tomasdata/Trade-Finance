# GMD (Global Macro Data) Integration Findings

**Date:** 19 de noviembre de 2025  
**File:** `data/GMD.csv`  
**Purpose:** Complementar datos de comercio exterior (BACI) con fuente alternativa que tiene cobertura 2024-2025

---

## 📊 Overview del Dataset GMD

- **Observaciones totales:** 57,021
- **Países:** 241 (cobertura global)
- **Período:** 1086-2030 (incluye proyecciones FMI)
- **Variables:** 71 variables macroeconómicas

### Países de Interés Disponibles

| País   | ISO3 | Período    | Obs | Exports | Imports | GDP |
|--------|------|------------|-----|---------|---------|-----|
| Mexico | MEX  | 1526-2030  | 505 | 231     | 231     | 505 |
| Peru   | PER  | 1565-2030  | 466 | 227     | 207     | 466 |
| Chile  | CHL  | 1662-2030  | 369 | 221     | 221     | 369 |
| Brazil | BRA  | 1764-2030  | 267 | 211     | 211     | 267 |

✅ **Conclusión:** Los 4 países tienen datos completos de comercio exterior en GMD

---

## 🔍 Variables Relevantes para Trade Finance

### Comercio Exterior (CORE)
- **`exports_USD`**: Exportaciones en millones de USD
- **`imports_USD`**: Importaciones en millones de USD
- **`exports_GDP`**: Exportaciones como % del PIB
- **`imports_GDP`**: Importaciones como % del PIB

### Normalización y Contexto
- **`nGDP_USD`**: PIB nominal en millones de USD (para normalizar L/C)
- **`rGDP_USD`**: PIB real en millones de USD (para análisis de crecimiento)
- **`USDfx`**: Tipo de cambio local/USD (útil para México MXN/USD)
- **`CA_USD`**: Cuenta corriente en millones de USD
- **`CA_GDP`**: Cuenta corriente como % PIB

### Inversión y Demanda Agregada
- **`inv_USD`**: Inversión total (millones USD)
- **`finv_USD`**: Inversión fija (millones USD)
- **`cons_USD`**: Consumo total (millones USD)

### Crisis Indicators (Posible overlay en gráficos)
- **`SovDebtCrisis`**: Indicador crisis deuda soberana
- **`CurrencyCrisis`**: Indicador crisis cambiaria
- **`BankingCrisis`**: Indicador crisis bancaria

### Indicadores Financieros
- **`strate`**: Tasa de interés corto plazo
- **`ltrate`**: Tasa de interés largo plazo
- **`cbrate`**: Tasa banco central
- **`M0`, `M1`, `M2`, `M3`**: Agregados monetarios
- **`REER`**: Tipo de cambio real efectivo

### Variables Fiscales
- **`govdebt_GDP`**: Deuda pública % PIB
- **`govdef_GDP`**: Déficit fiscal % PIB

---

## 📈 Datos de Comercio Exterior 2020-2024

### México (MEX)
| Year | Exports USD (M) | Imports USD (M) | X/GDP (%) | M/GDP (%) |
|------|-----------------|-----------------|-----------|-----------|
| 2020 | 439,869         | 421,750         | 39.2      | 37.6      |
| 2021 | 533,759         | 559,163         | 40.6      | 42.5      |
| 2022 | **626,159**     | **668,987**     | 42.7      | 45.7      |
| 2023 | **644,216**     | **665,599**     | 36.0      | 37.2      |
| 2024 | **628,564**     | **656,437**     | 34.3      | 35.8      |

### Perú (PER)
| Year | Exports USD (M) | Imports USD (M) | X/GDP (%) | M/GDP (%) |
|------|-----------------|-----------------|-----------|-----------|
| 2020 | 46,221          | 42,715          | 23.0      | 21.2      |
| 2021 | 66,018          | 59,056          | 29.2      | 26.1      |
| 2022 | 71,094          | 69,944          | 28.9      | 28.4      |
| 2023 | 72,465          | 63,153          | 27.2      | 23.7      |
| 2024 | **83,660**      | **65,664**      | 28.9      | 22.7      |

### Chile (CHL)
| Year | Exports USD (M) | Imports USD (M) | X/GDP (%) | M/GDP (%) |
|------|-----------------|-----------------|-----------|-----------|
| 2020 | 79,067          | 68,043          | 31.2      | 26.9      |
| 2021 | 100,616         | 102,946         | 31.9      | 32.7      |
| 2022 | 107,323         | 119,179         | 35.5      | 39.4      |
| 2023 | 105,011         | 100,598         | 31.2      | 29.9      |
| 2024 | **110,754**     | **97,639**      | 34.0      | 30.0      |

### Brasil (BRA)
| Year | Exports USD (M) | Imports USD (M) | X/GDP (%) | M/GDP (%) |
|------|-----------------|-----------------|-----------|-----------|
| 2020 | 242,930         | 233,997         | 16.5      | 15.8      |
| 2021 | 319,233         | 309,835         | 19.1      | 18.5      |
| 2022 | 382,956         | 374,266         | 19.6      | 19.2      |
| 2023 | 393,503         | 342,080         | 18.1      | 15.7      |
| 2024 | **388,686**     | **362,852**     | 18.0      | 16.8      |

---

## 🔍 Comparación GMD vs BACI (México 2022-2023)

### Fuente BACI (integrada en mexico_full.csv actual)
```
2022: exports = 591,107 M USD | imports = 523,731 M USD
2023: exports = 602,516 M USD | imports = 527,994 M USD
```

### Fuente GMD
```
2022: exports = 626,159 M USD | imports = 668,987 M USD (+5.9% X, +27.7% M)
2023: exports = 644,216 M USD | imports = 665,599 M USD (+6.9% X, +26.1% M)
```

### 📊 Diferencias Metodológicas

| Aspecto | BACI | GMD |
|---------|------|-----|
| **Fuente** | UN Comtrade (bilateral trade flows) | FMI/World Bank/National Accounts |
| **Cobertura** | Hasta 2023 (rezago 2 años) | Hasta 2024 + proyecciones 2025-2030 |
| **Nivel** | Desagregado por partner country | Agregado total país |
| **Metodología** | HS codes, FOB/CIF adjustments | Balance of Payments (BOP) |
| **Exports** | +5.9% más alto en GMD | Posible inclusión servicios |
| **Imports** | +27.7% más alto en GMD | CIF vs FOB valuation |

### ✅ DECISIÓN DE INTEGRACIÓN

1. **Para análisis principal:** Mantener BACI 2022-2023 (más conservador, solo bienes)
2. **Para 2024-2025:** Usar GMD (única fuente disponible)
3. **Para normalización GDP:** Usar GMD `exports_GDP`, `imports_GDP` (ya calculado)
4. **Para correlaciones macro:** Usar GMD variables contextuales

### ⚠️ NOTAS METODOLÓGICAS A DOCUMENTAR

- **Discontinuidad 2023→2024:** Cambio de fuente BACI → GMD
- **Magnitud:** GMD ~6% más alto en exports, ~28% más en imports
- **Interpretación:** GMD incluye ajustes BOP que BACI no captura
- **Recomendación:** En gráficos marcar cambio de fuente con línea vertical o nota

---

## 💡 Estrategia de Integración por País

### México (Priority: ALTA)
- ✅ Ya tiene BACI 2022-2023 integrado
- 🔄 **AGREGAR GMD:**
  - `exports_USD`, `imports_USD` para 2024-2025 (llenar NAs actuales)
  - `nGDP_USD` para calcular `lc_pct_gdp` (nueva métrica)
  - `exports_GDP`, `imports_GDP` (ya normalizado)
  - `USDfx` (redundante con SAT pero útil para validación)

### Perú (Priority: MEDIA)
- 📅 Dataset actual: Oct 2010 - Dec 2024 (no tiene 2025)
- 🔄 **AGREGAR GMD:**
  - `exports_USD`, `imports_USD` para todo el período (crear correlación L/C vs comercio)
  - `nGDP_USD` para normalización
  - `rGDP_USD` para análisis de crecimiento real
  - Crisis indicators (Perú tuvo crisis política 2022-2023)

### Chile (Priority: MEDIA)
- 📅 Dataset actual: Jan 2015 - Dec 2021 (termina en 2021!)
- 🔄 **AGREGAR GMD:**
  - `exports_USD`, `imports_USD` 2015-2021 (período coincidente)
  - `nGDP_USD` para normalización
  - Copper prices correlation (si disponible, aunque GMD no tiene commodities)

### Brasil (Priority: BAJA)
- 📅 Dataset actual: Jan 2012 - Dec 2024 (completo)
- 🔄 **AGREGAR GMD:**
  - `exports_USD`, `imports_USD` agregado nacional (para comparar con suma estados)
  - `nGDP_USD` para normalización agregada
  - Regional GDP (si GMD tiene breakdown, pero probablemente no)

---

## 📋 Columnas GMD a Integrar

### Mínimas (CORE)
```r
gmd_cols_core <- c(
  "countryname", "ISO3", "year",
  "exports_USD", "imports_USD",
  "nGDP_USD"
)
```

### Extendidas (ANÁLISIS AVANZADO)
```r
gmd_cols_extended <- c(
  "countryname", "ISO3", "year",
  
  # Trade
  "exports_USD", "imports_USD", 
  "exports_GDP", "imports_GDP",
  "CA_USD", "CA_GDP",
  
  # GDP
  "nGDP_USD", "rGDP_USD", "rGDP_pc",
  
  # FX
  "USDfx", "REER",
  
  # Crises
  "SovDebtCrisis", "CurrencyCrisis", "BankingCrisis",
  
  # Monetary
  "strate", "ltrate", "cbrate", "infl"
)
```

---

## 🎯 Nuevas Métricas Posibles con GMD

### 1. Normalización por GDP
```r
lc_pct_gdp = (lc_usd_millions / nGDP_USD) * 100
trade_finance_intensity = (total_tf_credit / nGDP_USD) * 100
```

### 2. Correlación Trade Finance vs Comercio
```r
correlation(lc_usd_millions, exports_USD + imports_USD)
elasticity = d(lc_usd) / d(trade_usd)
```

### 3. Crisis Overlays
```r
# Marcar períodos de crisis en gráficos temporales
crisis_periods <- gmd %>% 
  filter(BankingCrisis == 1 | CurrencyCrisis == 1)
```

### 4. Comparación Regional
```r
# México vs Latam average
mexico_trade_gdp vs mean(latam_countries$exports_GDP)
```

### 5. Nearshoring Proxy
```r
# México trade share crecimiento vs región
mexico_growth_rate vs brazil_growth_rate
```

---

## 🚀 Próximos Pasos

### 1. Crear Script de Integración GMD
```bash
country_analysis/scripts/00_integrate_gmd.R
```

**Funciones:**
- `load_gmd_data()` → Carga GMD.csv
- `extract_country_trade(country, years)` → Extrae trade data específico
- `merge_with_banking_data(banking_df, gmd_df)` → Merge por año
- `calculate_gdp_metrics(df)` → Calcula ratios L/C % GDP

### 2. Actualizar ETL Scripts
- `pre-data/Mexico/mexico_enhanced_etl.R` → Agregar GMD 2024-2025
- Similar para Peru/Chile/Brazil (si necesario)

### 3. Actualizar 01_master_processing.R
- Asegurar que GMD columns se preserven en RDS files
- Agregar summary stats de GMD variables

### 4. Documentar en README
- Sección "Data Sources" → Agregar GMD descripción
- Tabla comparativa BACI vs GMD
- Notas metodológicas sobre discontinuidad

---

## 📝 Referencias

**GMD Dataset:**
- Fuente: Combinación FMI, World Bank, National Statistical Offices
- Metodología: Balance of Payments (BOP) para comercio exterior
- Actualización: Anual con proyecciones quinquenales
- Cobertura: 241 países, 1086-2030

**BACI Dataset:**
- Fuente: CEPII, basado en UN Comtrade
- Metodología: Bilateral trade flows, HS codes
- Actualización: Rezago 2 años (último año completo 2023)
- Cobertura: ~200 países, trade partners desagregados

**Recomendación:** Usar ambas fuentes de forma complementaria, documentando diferencias.
