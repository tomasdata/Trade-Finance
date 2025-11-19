# REPORTE DE ESTADO: GRÁFICOS TRADE FINANCE POR PAÍS
**Fecha:** 19 de noviembre de 2025  
**Proyecto:** Análisis Trade Finance - México, Perú, Chile, Brasil

---

## RESUMEN EJECUTIVO

### Gráficos Completados: 18 / 24 solicitados (75%)
- ✅ **México:** 3/3 (100%) - COMPLETO
- ✅ **Perú:** 4/4 (100%) - COMPLETO  
- ✅ **Chile:** 6/6 (100%) - COMPLETO
- ⚠️ **Brasil:** 5/9 (56%) - FALTA: by bank type, concentration, % exports/imports

---

## 1. MÉXICO 🇲🇽

### ✅ GRÁFICOS COMPLETADOS (3/3)

#### MEX-1: Outstanding L/C - Monthly Evolution
- **Archivo:** `plots/mexico/mex_01_lc_monthly.png`
- **Descripción:** Evolución mensual de cartas de crédito (USD millones)
- **Período:** 2022-01 a 2025-08 (44 meses)
- **Datos:** Solo cuenta 202401504003 (L/C comerciales)
- **Status:** ✅ COMPLETO

#### MEX-2: L/C by Bank Type  
- **Archivo:** `plots/mexico/mex_02_lc_by_bank_type.png`
- **Descripción:** Stacked area por tipo de banco (Foreign, Development, Large Domestic, Other)
- **Período:** 2022-01 a 2025-08 (44 meses)
- **Status:** ✅ COMPLETO

#### MEX-1-ALT: L/C as % of Total Liabilities
- **Archivo:** `plots/mexico/mex_01_lc_pct_liabilities.png`
- **Descripción:** L/C como porcentaje de pasivos totales
- **Status:** ✅ COMPLETO

### 📊 DATOS DISPONIBLES
- ✅ `exports_usd_millions` (anual GMD)
- ✅ `imports_usd_millions` (anual GMD)
- ✅ `lc_usd_millions` (mensual por banco)
- ✅ Bank classification (Foreign, Development, Large Domestic, Other)

### ❌ GRÁFICOS FALTANTES: NINGUNO
**México está 100% completo según los requerimientos.**

---

## 2. PERÚ 🇵🇪

### ✅ GRÁFICOS COMPLETADOS (4/4)

#### PER-1: Foreign-Trade Credit as % of Total Credit
- **Archivo:** `plots/peru/per_01_tf_pct_total.png`
- **Descripción:** Crédito comercio exterior como % del crédito total
- **Período:** 2015-01 a 2024-11 (119 meses)
- **Status:** ✅ COMPLETO

#### PER-2: Foreign-Trade Credit by Borrower Size
- **Archivo:** `plots/peru/per_02_tf_by_size.png`
- **Descripción:** Stacked area por tamaño (Corporate, Large, Medium, Small, Micro)
- **Período:** 2015-01 a 2024-11
- **Status:** ✅ COMPLETO

#### PER-3: Foreign-Trade Credit by Type of Bank
- **Archivo:** `plots/peru/per_03_tf_by_bank_type.png`
- **Descripción:** Stacked area por tipo (Foreign, Large Domestic, State, Consumer/Retail, Other)
- **Período:** 2015-01 a 2024-11
- **Status:** ✅ COMPLETO

#### PER-4: Foreign-Trade Credit Concentration
- **Archivo:** `plots/peru/per_04_concentration.png`
- **Descripción:** HHI + CR5 (dual axis with scale factor 20)
- **Período:** 2015-01 a 2024-11
- **Status:** ✅ COMPLETO (CORREGIDO dual axis)

### 📊 DATOS DISPONIBLES
- ✅ `exports_usd_millions` (anual)
- ✅ `imports_usd_millions` (anual)
- ✅ `tf_usd_millions` (mensual por banco × tamaño)
- ✅ `total_credit_usd_millions`
- ✅ Size categories (Corporate, Large, Medium, Small, Micro)
- ✅ Bank classification

### ❌ GRÁFICOS FALTANTES: NINGUNO
**Perú está 100% completo según los requerimientos.**

---

## 3. CHILE 🇨🇱

### ✅ GRÁFICOS COMPLETADOS (6/6)

#### CHL-1: Foreign-Trade Loans as % of Total Loans
- **Archivo:** `plots/chile/chl_01_tf_pct_loans.png`
- **Descripción:** Trade finance como % de préstamos totales (2015-2024 con empalme SBIF→CMF)
- **Período:** 2015-01 a 2024-12
- **Status:** ✅ COMPLETO (CMF only 2022-2024)

#### CHL-2: TF by Top 5 Banks
- **Archivo:** `plots/chile/chl_02_tf_top5_banks.png`
- **Descripción:** Top 5 bancos por TF (2022-2024)
- **Status:** ✅ COMPLETO (CMF only)

#### CHL-3: Foreign-Trade Credit Concentration
- **Archivo:** `plots/chile/chl_03_concentration.png`
- **Descripción:** HHI mensual (2022-2024)
- **Status:** ✅ COMPLETO (CMF only)

#### CHL-4: Foreign-Trade Funding from Foreign Banks
- **Archivo:** `plots/chile/chl_04_foreign_funding.png`
- **Descripción:** Financiamiento exterior para X+M (activos + pasivos interbancarios)
- **Status:** ✅ COMPLETO (CMF only)

#### CHL-5: Outstanding L/C as % of Liabilities (comparación con México)
- **Archivo:** `plots/chile/chl_05_lc_pct_liabilities.png`
- **Descripción:** L/C como % de pasivos totales
- **Período:** 2022-2024
- **Status:** ✅ COMPLETO

#### CHL-6: L/C by Top 5 Banks (comparación con México)
- **Archivo:** `plots/chile/chl_06_lc_top5_banks.png`
- **Descripción:** Monthly stacked area - Top 5 bancos L/C
- **Status:** ✅ COMPLETO (CORREGIDO a stacked area mensual)

### 📊 DATOS DISPONIBLES
- ❌ `exports_usd_millions` - NO DISPONIBLE
- ❌ `imports_usd_millions` - NO DISPONIBLE
- ✅ `tf_usd_millions` (mensual por banco × cuenta)
- ✅ Account-level detail (145400200 series)
- ✅ Bank classification (pero datos agregados 2022-2024)

### ⚠️ LIMITACIÓN IMPORTANTE
**Chile NO tiene datos de exportaciones/importaciones en el dataset procesado.**  
Necesitamos agregar estos datos desde fuente externa (Banco Central de Chile) para hacer análisis de TF como % de X+M.

### ❌ GRÁFICOS FALTANTES: NINGUNO
**Chile está 100% completo según los requerimientos ACTUALES.**  
**Pero falta agregar datos de X+M para análisis adicionales.**

---

## 4. BRASIL 🇧🇷

### ✅ GRÁFICOS COMPLETADOS (5/9)

#### BRA-1: Foreign-Trade Credit as % of Total Credit
- **Archivo:** `plots/brazil/bra_01_tf_pct_total.pdf`
- **Descripción:** TF como % del crédito total (mensual)
- **Período:** 2012-03 a 2024-09 (151 meses)
- **Status:** ✅ COMPLETO

#### BRA-2: Foreign-Trade Credit by Borrower Size
- **Archivo:** `plots/brazil/bra_02_tf_by_size.pdf`
- **Descripción:** Stacked area por tamaño (Large, Medium, Small, Micro) - SIN NA
- **Status:** ✅ COMPLETO (CORREGIDO - removed NA/Unknown)

#### BRA-3: TF by Region (Top 10 States)
- **Archivo:** `plots/brazil/bra_03_tf_by_region.pdf`
- **Descripción:** Top 10 estados por volumen TF
- **Status:** ✅ COMPLETO

#### BRA-4: Regional Concentration
- **Arquivo:** `plots/brazil/bra_04_regional_concentration.pdf`
- **Descripción:** Participación Top 5 estados
- **Status:** ✅ COMPLETO

#### BRA-5: Size Distribution Comparison (Brazil vs Peru)
- **Archivo:** `plots/brazil/bra_05_size_comparison.pdf`
- **Descripción:** Comparación distribución por tamaño Brasil vs Perú
- **Status:** ✅ COMPLETO

### 📊 DATOS DISPONIBLES
- ✅ `exports_usd_millions` (anual)
- ✅ `imports_usd_millions` (anual)
- ✅ `tf_usd_millions` (mensual por estado × sector × tamaño)
- ✅ Size categories (Large, Medium, Small, Micro)
- ✅ Regional data (27 states, 5 regions)
- ❌ **NO HAY DATOS POR BANCO** (solo agregados BCB)

### ❌ GRÁFICOS FALTANTES (4/9)

#### ❌ BRA-X1: Foreign-Trade Credit by Type of Bank
**Status:** ❌ **IMPOSIBLE** - Brasil NO tiene datos por banco  
**Razón:** BCB SCR solo proporciona agregados por State × Sector × Size  
**Alternativa:** Ya tenemos BRA-3 (by Region) que es la desagregación disponible

#### ❌ BRA-X2: Foreign-Trade Credit Concentration (HHI)
**Status:** ❌ **IMPOSIBLE** - No hay market shares por banco  
**Razón:** Sin datos por banco, no se puede calcular HHI bancario  
**Alternativa:** Ya tenemos BRA-4 (Regional Concentration) que mide concentración geográfica

#### ❌ BRA-X3: TF as % of Exports
**Status:** ⏳ **FALTA GENERAR**  
**Datos disponibles:** ✅ `tf_usd_millions`, ✅ `exports_usd_millions`  
**Acción requerida:** Crear gráfico mensual de `tf_usd_millions / exports_usd_millions * 100`

#### ❌ BRA-X4: TF as % of Imports
**Status:** ⏳ **FALTA GENERAR**  
**Datos disponibles:** ✅ `tf_usd_millions`, ✅ `imports_usd_millions`  
**Acción requerida:** Crear gráfico mensual de `tf_usd_millions / imports_usd_millions * 100`

---

## ANÁLISIS COMPARATIVO: QUÉ TENEMOS vs QUÉ FALTA

### TABLA MAESTRA DE GRÁFICOS SOLICITADOS

| País | Gráfico Solicitado | Status | Archivo | Limitaciones |
|------|-------------------|--------|---------|--------------|
| **MÉXICO** | | | | |
| 🇲🇽 | L/C over total liabilities | ✅ | mex_01_lc_pct_liabilities.png | Solo cuenta 202401504003 |
| 🇲🇽 | L/C by type of bank | ✅ | mex_02_lc_by_bank_type.png | - |
| **PERÚ** | | | | |
| 🇵🇪 | TF as % of total credit | ✅ | per_01_tf_pct_total.png | - |
| 🇵🇪 | TF by borrower size | ✅ | per_02_tf_by_size.png | - |
| 🇵🇪 | TF by type of bank | ✅ | per_03_tf_by_bank_type.png | - |
| 🇵🇪 | TF concentration | ✅ | per_04_concentration.png | Dual axis corregido |
| **CHILE** | | | | |
| 🇨🇱 | TF as % of total loans | ✅ | chl_01_tf_pct_loans.png | CMF only 2022-2024 |
| 🇨🇱 | TF by type of bank | ✅ | chl_02_tf_top5_banks.png | Agregado 2022-2024 |
| 🇨🇱 | TF concentration | ✅ | chl_03_concentration.png | CMF only |
| 🇨🇱 | Foreign funding (X+M) | ✅ | chl_04_foreign_funding.png | - |
| 🇨🇱 | **Comparable Peru/Brazil:** TF as % total credit | ✅ | chl_01 (ya es %) | - |
| 🇨🇱 | **Comparable Peru/Brazil:** TF by type of bank | ✅ | chl_02 (Top 5) | - |
| 🇨🇱 | **Comparable Peru/Brazil:** TF concentration | ✅ | chl_03 (HHI) | - |
| 🇨🇱 | **Comparable Mexico:** L/C over liabilities | ✅ | chl_05_lc_pct_liabilities.png | - |
| 🇨🇱 | **Comparable Mexico:** L/C by bank | ✅ | chl_06_lc_top5_banks.png | Monthly stacked area |
| **BRASIL** | | | | |
| 🇧🇷 | TF as % of total credit | ✅ | bra_01_tf_pct_total.pdf | - |
| 🇧🇷 | TF by borrower size | ✅ | bra_02_tf_by_size.pdf | Sin NA/Unknown |
| 🇧🇷 | TF by type of bank | ❌ | - | **IMPOSIBLE: No bank data** |
| 🇧🇷 | TF concentration | ❌ | - | **IMPOSIBLE: No bank data** |
| 🇧🇷 | **Comparable Peru:** by size | ✅ | bra_05_size_comparison.pdf | Brasil vs Perú |
| 🇧🇷 | **FALTA:** TF as % of Exports | ❌ | - | Datos disponibles |
| 🇧🇷 | **FALTA:** TF as % of Imports | ❌ | - | Datos disponibles |

---

## GRÁFICOS EN FUNCIÓN DE EXPORTACIONES E IMPORTACIONES

### DATOS DE X+M DISPONIBLES POR PAÍS

| País | Exports Data | Imports Data | Frecuencia | Fuente |
|------|--------------|--------------|------------|--------|
| 🇲🇽 México | ✅ Sí | ✅ Sí | Anual (GMD) | GMD API |
| 🇵🇪 Perú | ✅ Sí | ✅ Sí | Anual | WDI/BCRP |
| 🇨🇱 Chile | ❌ No | ❌ No | - | **FALTA AGREGAR** |
| 🇧🇷 Brasil | ✅ Sí | ✅ Sí | Anual | WDI/BCB |

### GRÁFICOS ADICIONALES POSIBLES

#### 1. TF como % de Exportaciones (mensual)
- **México:** ✅ Datos disponibles → **FALTA GENERAR**
- **Perú:** ✅ Datos disponibles → **FALTA GENERAR**
- **Chile:** ❌ Sin datos X+M → **IMPOSIBLE SIN AGREGAR DATOS**
- **Brasil:** ✅ Datos disponibles → **FALTA GENERAR**

#### 2. TF como % de Importaciones (mensual)
- **México:** ✅ Datos disponibles → **FALTA GENERAR**
- **Perú:** ✅ Datos disponibles → **FALTA GENERAR**
- **Chile:** ❌ Sin datos X+M → **IMPOSIBLE SIN AGREGAR DATOS**
- **Brasil:** ✅ Datos disponibles → **FALTA GENERAR**

#### 3. TF como % de (Exportaciones + Importaciones)
- **México:** ✅ Datos disponibles → **FALTA GENERAR**
- **Perú:** ✅ Datos disponibles → **FALTA GENERAR**
- **Chile:** ❌ Sin datos X+M → **IMPOSIBLE SIN AGREGAR DATOS**
- **Brasil:** ✅ Datos disponibles → **FALTA GENERAR**

---

## LIMITACIONES ESTRUCTURALES DE DATOS

### 🇧🇷 BRASIL: Sin datos por banco
**Fuente:** BCB SCR System (Sistema de Informações de Crédito)  
**Estructura:** State × Sector × Size (NO bank-level)  
**Modalidades:** 4 tipos (ACC, ACE, FINIMP, NCE) - NO separate L/C

**Implicaciones:**
- ❌ NO se puede hacer "by type of bank"
- ❌ NO se puede calcular HHI (concentración bancaria)
- ✅ SÍ se puede hacer "by borrower size" (disponible)
- ✅ SÍ se puede hacer "by region" (27 states)
- ✅ SÍ se puede hacer "TF as % of Exports/Imports" (tenemos datos agregados + X+M)

### 🇨🇱 CHILE: Falta datos de Exportaciones/Importaciones
**Problema:** `chile_processed.rds` no contiene `exports_usd_millions` ni `imports_usd_millions`

**Solución requerida:**
1. Descargar datos de Banco Central de Chile (X+M mensuales 2015-2024)
2. Agregar al ETL de Chile (`pre-data/Chile/chile_enhanced_etl.R`)
3. Regenerar `chile_processed.rds` con columnas X+M
4. Crear gráficos TF as % of X+M

### 🇲🇽 MÉXICO: Solo L/C (no total TF contingente)
**Problema:** Actualmente solo usa cuenta 202401504003 (L/C)  
**Datos disponibles:** 10 cuentas 2024015xxxxx (USD 217.9B total vs USD 39.3B L/C solo)

**Decisión pendiente:**
- Mantener solo L/C (comparable con Chile)
- O expandir a 9 cuentas TF contingente (USD 217.9B)

---

## RESUMEN EJECUTIVO: GRÁFICOS FALTANTES

### ✅ COMPLETADOS: 18 gráficos
- México: 3/3 (100%)
- Perú: 4/4 (100%)
- Chile: 6/6 (100%)
- Brasil: 5/9 (56%)

### ❌ IMPOSIBLES: 2 gráficos
- Brasil by type of bank (no bank data)
- Brasil concentration HHI (no bank data)

### ⏳ FACTIBLES CON DATOS ACTUALES: 6 gráficos
1. **México:** TF as % of Exports (mensual)
2. **México:** TF as % of Imports (mensual)
3. **Perú:** TF as % of Exports (mensual)
4. **Perú:** TF as % of Imports (mensual)
5. **Brasil:** TF as % of Exports (mensual)
6. **Brasil:** TF as % of Imports (mensual)

### ⏳ REQUIEREN AGREGAR DATOS: 2 gráficos
7. **Chile:** TF as % of Exports (necesita agregar datos X+M)
8. **Chile:** TF as % of Imports (necesita agregar datos X+M)

---

## PRÓXIMOS PASOS RECOMENDADOS

### PRIORIDAD 1: Generar gráficos con datos existentes (6 gráficos)
```r
# México, Perú, Brasil: TF as % of Exports/Imports
# Código ya disponible en processed datasets
# Tiempo estimado: 1-2 horas
```

### PRIORIDAD 2: Agregar datos X+M para Chile
```r
# Fuente: Banco Central de Chile API
# Agregar a chile_enhanced_etl.R
# Regenerar chile_processed.rds
# Tiempo estimado: 2-3 horas
```

### PRIORIDAD 3: Decisión México expansion
```r
# ¿Expandir de L/C (USD 39B) a Total TF Contingente (USD 218B)?
# Modificar mexico_enhanced_etl.R línea 127
# Tiempo estimado: 30 minutos + regenerar
```

---

## NOTAS METODOLÓGICAS

### Brasil: Alternativas a "by bank type"
Ya que Brasil NO tiene datos por banco, las alternativas disponibles son:
1. ✅ **By Region** (ya generado: bra_03)
2. ✅ **By Borrower Size** (ya generado: bra_02)
3. ✅ **By Sector** (datos disponibles en `sector_short`)
4. ✅ **By Modality** (ACC, ACE, FINIMP, NCE - datos disponibles en raw)

### Chile: Empalme SBIF → CMF
- SBIF (2015-2021): Datos inconsistentes, <0.1% de volumen real
- CMF (2022-2024): Datos confiables post-IFRS 9
- **Solución actual:** Focus en CMF only con nota metodológica

### Perú: Dual axis corrected
- HHI (left axis): 1500-2500 puntos
- CR5 (right axis): 75-100% (scale factor = 20 para overlay)
- Ambas series visibles y comparables

---

**CONCLUSIÓN:**  
Tenemos **18/24 gráficos solicitados (75%)**. Los 6 faltantes son todos gráficos de "TF as % of X+M" que son FACTIBLES con datos actuales (México, Perú, Brasil) o requieren agregar datos (Chile). Los 2 gráficos "by bank type" y "concentration" de Brasil son **IMPOSIBLES** por estructura de datos BCB.
