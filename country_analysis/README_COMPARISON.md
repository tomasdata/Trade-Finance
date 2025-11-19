# COMPARATIVE ANALYSIS - 4 COUNTRIES

**Date:** November 19, 2025
**Script:** `01_comparative_analysis.R`
**Output:** 6 PNG graphs (300 DPI) + 5 CSV tables

---

## ANÁLISIS GENERADOS

### **COMP-1: Concentración de Mercado (HHI) - Chile vs Perú**
- **Período:** 2022-2024 (común)
- **Países:** Chile, Perú
- **Métrica:** Índice Herfindahl-Hirschman (HHI)
- **Archivo:** `comp_01_concentration_hhi.png`
- **Tabla:** `comp_01_concentration_hhi.csv`

**Rangos:**
- Chile: HHI 1,469 - 1,735 (concentración moderada)
- Perú: HHI 1,688 - 1,873 (concentración moderada-alta)

**Líneas de referencia:**
- 1,500: Concentración moderada
- 2,500: Concentración alta

---

### **COMP-2: L/C como % de Pasivos Totales - Chile vs México**
- **Período:** 2022-2024 (común)
- **Países:** Chile, México
- **Métrica:** Letters of Credit outstanding como % del total de pasivos bancarios
- **Archivo:** `comp_02_lc_pct_liabilities.png`
- **Tabla:** `comp_02_lc_pct_liabilities.csv`

**Rangos:**
- México: 0.055% - 0.123%
- Chile: 0.081% - 0.116%

**Nota:** Ambos países muestran niveles comparables de L/C en balance (~0.08-0.12%).

---

### **COMP-3: TF como % de Exportaciones Anuales - 4 Países**
- **Período:** 2022-2024 (común)
- **Países:** Chile, Perú, Brasil, México (L/C solamente)
- **Métrica:** Stock mensual de TF como % de exportaciones anuales
- **Archivo:** `comp_03_tf_pct_exports.png`
- **Tabla:** `comp_03_tf_pct_exports.csv`

**Rangos (2022-2024):**
- Chile: 22.0% - 35.7% (más alto)
- Brasil: 10.3% - 13.5% (medio)
- Perú: 6.4% - 9.3% (medio-bajo)
- México (L/C only): 0.04% - 0.11% (muy bajo, solo L/C)

**Nota:** México reporta solo Letters of Credit, no TF completo.

---

### **COMP-4: TF por Tamaño de Prestatario - Brasil vs Perú**

#### **COMP-4a: Volumen Absoluto (Annual Stacked Bars)**
- **Período:** Brasil 2012-2024, Perú 2010-2024
- **Métrica:** Volumen de TF en USD miles de millones (stacked bars)
- **Archivo:** `comp_04a_tf_by_size_volume.png`
- **Categorías:** Micro, Small, Medium, Large (Perú: Corporate+Large agregados)

**Facetas:** 2 paneles (Brasil arriba, Perú abajo)

---

#### **COMP-4b: Composición Porcentual (100% Stacked Bars)**
- **Período:** Brasil 2012-2024, Perú 2010-2024
- **Métrica:** Distribución porcentual por tamaño (100% stacked)
- **Archivo:** `comp_04b_tf_by_size_pct.png`

**Facetas:** 2 paneles (Brasil arriba, Perú abajo)

**Hallazgos:**
- Brasil: Dominado por Medium (~50-60%)
- Perú: Dominado por Large (~80-90%, incluye Corporate)

---

#### **COMP-4c: Tendencias por Categoría (Faceted Line Charts)**
- **Período:** Brasil 2012-2024, Perú 2010-2024
- **Métrica:** % del TF total por cada categoría de tamaño (evolución temporal)
- **Archivo:** `comp_04c_tf_by_size_trends.png`

**Facetas:** 4 paneles (Micro, Small, Medium, Large)
**Líneas:** Brasil (verde), Perú (rojo)

---

## TABLAS CSV EXPORTADAS

1. **`comp_01_concentration_hhi.csv`**
   - Columnas: `date`, `hhi`, `country`
   - 2,204 filas (Chile + Perú, 2022-2024)

2. **`comp_02_lc_pct_liabilities.csv`**
   - Columnas: `date`, `country`, `lc_pct_liabilities`
   - 2,138 filas (Chile + México, 2022-2024)

3. **`comp_03_tf_pct_exports.csv`**
   - Columnas: `date`, `country`, `tf_pct_exports`
   - 4,312 filas (4 países, 2022-2024)

4. **`comp_04_tf_by_size_monthly.csv`**
   - Columnas: `date`, `size_category`, `tf_usd_millions`, `country`, `tf_total`, `tf_pct`
   - 6,912 filas (mensual, Brasil + Perú)

5. **`comp_04_tf_by_size_annual.csv`**
   - Columnas: `year`, `size_category`, `tf_usd_millions`, `country`, `tf_total`, `tf_pct`
   - 115 filas (anual, Brasil + Perú)

---

## CARACTERÍSTICAS TÉCNICAS

### Períodos Comunes Utilizados:
- **COMP-1 (Concentración):** 2022-2024 (Chile CMF + Perú)
- **COMP-2 (L/C % Pasivos):** 2022-2024 (datos de `total_liab` disponibles)
- **COMP-3 (TF % Exportaciones):** 2022-2024 (período común a los 4 países)
- **COMP-4 (Tamaño Prestatario):** Series completas (Brasil 2012-2024, Perú 2010-2024)

### Unificación de Categorías:
**Perú → Brasil:**
- Corporate + Large → Large
- Medium → Medium
- Small → Small (Pequeno)
- Micro → Micro

### Gráficos sin Títulos:
- Todos los gráficos NO tienen títulos principales
- Todos los gráficos NO tienen captions de fuente
- Solo ejes con labels claros
- Para agregar en presentación LaTeX

---

## INTERPRETACIÓN

### **Concentración:**
Chile y Perú muestran niveles similares de concentración (HHI 1,500-1,900), indicando mercados moderadamente concentrados con 5-7 bancos principales dominando el TF.

### **L/C en Balance:**
Chile y México tienen niveles comparables de L/C como % de pasivos (~0.09%), confirmando que L/C son una fracción muy pequeña del balance bancario.

### **Intensidad TF/Exportaciones:**
- Chile: 22-36% (alta intensidad TF)
- Brasil: 10-13% (media)
- Perú: 6-9% (media-baja)
- México: 0.04-0.11% (muy baja, SOLO L/C)

La diferencia de México se explica porque reporta SOLO Letters of Credit, no TF completo.

### **Tamaño de Prestatario:**
- **Brasil:** Concentrado en Medium (50-60%), distribución más balanceada
- **Perú:** Fuertemente concentrado en Large+Corporate (80-90%)

Esto sugiere que en Brasil el TF es más accesible para empresas medianas, mientras que en Perú está dominado por corporaciones grandes.

---

**Script ejecutado:** November 19, 2025
**Total gráficos:** 6 PNG (300 DPI)
**Total tablas:** 5 CSV
