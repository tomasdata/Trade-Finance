# 📊 PLAN FINAL DE GRÁFICOS - SEGÚN REQUEST

**Basado en:** Request original del usuario  
**Total gráficos:** ~16 (no 42)  
**Fecha:** 19 noviembre 2025

---

## 🎯 GRÁFICOS SOLICITADOS

### 🇲🇽 MÉXICO - 2 gráficos

**MEX-1: Outstanding L/C over total liabilities**
- Tipo: Time series
- Y: L/C como % de pasivos totales
- X: Tiempo (2022-2025, mensual)
- Archivo: `plots/mexico/mex_01_lc_pct_liabilities.png`
- Tabla: `tables/mexico/mex_01_lc_pct_liabilities.csv`

**MEX-2: Outstanding L/C by type of bank**
- Tipo: Box plots o grouped bars
- Y: L/C (USD millones o %)
- X: Bank type (Foreign / Domestic / State)
- Archivo: `plots/mexico/mex_02_lc_by_bank_type.png`
- Tabla: `tables/mexico/mex_02_lc_by_bank_type.csv`

---

### 🇵🇪 PERÚ - 4 gráficos

**PER-1: Foreign-trade credit as % of total credit**
- Tipo: Time series
- Y: TF como % de cartera total
- X: Tiempo (2010-2024, mensual)
- Archivo: `plots/peru/per_01_tf_pct_total.png`
- Tabla: `tables/peru/per_01_tf_pct_total.csv`

**PER-2: Foreign-trade credit by borrower size**
- Tipo: Stacked area o grouped bars
- Y: TF (PEN millones)
- X: Tiempo o categorías (Corporate / Large / Medium / Small / Micro)
- Archivo: `plots/peru/per_02_tf_by_size.png`
- Tabla: `tables/peru/per_02_tf_by_size.csv`

**PER-3: Foreign-trade credit by type of bank**
- Tipo: Box plots o grouped bars
- Y: TF (PEN millones o %)
- X: Bank type (Foreign / Domestic / State / Mixed)
- Archivo: `plots/peru/per_03_tf_by_bank_type.png`
- Tabla: `tables/peru/per_03_tf_by_bank_type.csv`

**PER-4: Foreign-trade credit concentration**
- Tipo: Time series (HHI o CR5)
- Y: Concentration metric
- X: Tiempo (2010-2024, anual o mensual)
- Archivo: `plots/peru/per_04_concentration.png`
- Tabla: `tables/peru/per_04_concentration.csv`

---

### 🇨🇱 CHILE - 6 gráficos (2 opciones comparabilidad)

#### OPCIÓN A: Comparable con Perú/Brasil (4 plots)

**CHL-1: Foreign-trade loans as % of total loans**
- Tipo: Time series CON EMPALME
- Y: TF como % préstamos totales
- X: Tiempo (2015-2024, **serie continua post-empalme**)
- **CRÍTICO:** Empalmar SBIF (2015-2021) → CMF (2022-2024)
- Archivo: `plots/chile/chl_01_tf_pct_total_empalmed.png`
- Tabla: `tables/chile/chl_01_tf_pct_total_empalmed.csv`

**CHL-2: Foreign-trade loans by type of bank**
- Tipo: Box plots o grouped bars CON EMPALME
- Y: TF (CLP millones)
- X: Bank type (Foreign / Domestic / State)
- Archivo: `plots/chile/chl_02_tf_by_bank_type.png`
- Tabla: `tables/chile/chl_02_tf_by_bank_type.csv`

**CHL-3: Foreign-trade credit concentration**
- Tipo: Time series CON EMPALME
- Y: HHI o CR5
- X: Tiempo (2015-2024, serie continua)
- Archivo: `plots/chile/chl_03_concentration.png`
- Tabla: `tables/chile/chl_03_concentration.csv`

**CHL-4: Foreign-trade funding from foreign banks (X+M)**
- Tipo: Time series CON EMPALME
- Y: Funding de bancos extranjeros (CLP millones)
- X: Tiempo (2015-2024)
- Archivo: `plots/chile/chl_04_foreign_funding.png`
- Tabla: `tables/chile/chl_04_foreign_funding.csv`

#### OPCIÓN B: Comparable con México (2 plots)

**CHL-5: Outstanding L/C over total liabilities**
- Tipo: Time series CON EMPALME
- Y: L/C como % pasivos totales
- X: Tiempo (2015-2024)
- Archivo: `plots/chile/chl_05_lc_pct_liabilities.png`
- Tabla: `tables/chile/chl_05_lc_pct_liabilities.csv`

**CHL-6: Outstanding L/C by type of bank**
- Tipo: Box plots o grouped bars
- Y: L/C (CLP millones)
- X: Bank type
- Archivo: `plots/chile/chl_06_lc_by_bank_type.png`
- Tabla: `tables/chile/chl_06_lc_by_bank_type.csv`

---

### 🇧🇷 BRASIL - 4 gráficos

**BRA-1: Foreign-trade credit as % of total credit**
- Tipo: Time series
- Y: TF como % cartera total
- X: Tiempo (2012-2024, mensual)
- **NOTA:** Brasil no tiene bancos individuales (agregado)
- Archivo: `plots/brazil/bra_01_tf_pct_total.png`
- Tabla: `tables/brazil/bra_01_tf_pct_total.csv`

**BRA-2: Foreign-trade credit by borrower size**
- Tipo: Stacked area o grouped bars
- Y: TF (BRL millones)
- X: Tiempo o categorías (Micro / Pequeno / Médio / Grande)
- Archivo: `plots/brazil/bra_02_tf_by_size.png`
- Tabla: `tables/brazil/bra_02_tf_by_size.csv`

**BRA-3: Foreign-trade credit by type of bank**
- Tipo: ⚠️ **NO DISPONIBLE** (Brasil no tiene bancos)
- Alternativa: Agregar por estado o sector
- Archivo: `plots/brazil/bra_03_tf_by_region.png`
- Tabla: `tables/brazil/bra_03_tf_by_region.csv`

**BRA-4: Foreign-trade credit concentration**
- Tipo: ⚠️ **NO DISPONIBLE** (sin bancos, sin HHI)
- Alternativa: Concentración regional (Gini o top 5 estados)
- Archivo: `plots/brazil/bra_04_regional_concentration.png`
- Tabla: `tables/brazil/bra_04_regional_concentration.csv`

**BRA-5: Size comparison with Peru**
- Tipo: Grouped bars (side by side)
- Y: % del TF total
- X: Tamaño (5 categorías)
- Grupos: Brasil vs Perú
- Archivo: `plots/brazil/bra_05_size_comparison_peru.png`
- Tabla: `tables/brazil/bra_05_size_comparison_peru.csv`

---

## 🎨 ESPECIFICACIONES TÉCNICAS

### Gráficos (SIN títulos, SIN fuentes en imagen)

**Formato:**
- PNG: 300 DPI, 8" × 6"
- PDF: Vector format
- **NO incluir:**
  - Títulos (irán en caption externo)
  - Fuentes (irán en caption externo)
  - Notas metodológicas en imagen

**Incluir SOLO:**
- Ejes etiquetados (sin título descriptivo)
- Leyenda (si necesario)
- Datos limpios y claros

### Captions (Archivo separado)

**Archivo:** `captions/captions.csv`

Columnas:
- `figure_id`: mex_01, per_01, etc.
- `title`: Título descriptivo completo
- `caption`: Descripción del gráfico
- `source`: Fuente de datos (CNBV, SBS, CMF, BCB)
- `notes`: Notas metodológicas (empalme Chile, etc.)

---

## 🔧 EMPALME CHILE (SBIF → CMF)

### Problema
- **SBIF (2015-2021):** 11 cuentas TF identificadas
- **CMF (2022-2024):** 29 cuentas TF identificadas
- **Overlap:** 0% (códigos completamente diferentes)

### Solución de Empalme

**Opción 1: Factor de Empalme (Recommended)**

```r
# Calcular factor basado en cuentas comunes conceptualmente
# Ej: "Créditos comercio exterior" existe en ambos sistemas

# 1. Identificar monto 2021-12 SBIF
tf_2021_sbif <- chile_sbif %>% 
  filter(year == 2021, month == 12) %>%
  summarise(tf_total = sum(amount))

# 2. Identificar monto 2022-01 CMF  
tf_2022_cmf <- chile_cmf %>%
  filter(year == 2022, month == 1) %>%
  summarise(tf_total = sum(amount))

# 3. Calcular factor
empalme_factor <- tf_2021_sbif / tf_2022_cmf

# 4. Ajustar serie SBIF
chile_sbif_adjusted <- chile_sbif %>%
  mutate(amount_adjusted = amount * empalme_factor)

# 5. Combinar series
chile_empalmed <- bind_rows(
  chile_sbif_adjusted %>% mutate(system = "SBIF"),
  chile_cmf %>% mutate(system = "CMF")
)
```

**Opción 2: Ratio a Total Loans**

```r
# Usar TF/Total Loans para suavizar discontinuidad
chile_empalmed <- chile %>%
  mutate(
    tf_pct_total = tf_amount / total_loans * 100
  )
# Este ratio es más estable que valores absolutos
```

**Opción 3: Doble Eje Temporal**

```r
# Mostrar ambas series con nota de break
ggplot(chile, aes(x = date, y = tf_amount)) +
  geom_line() +
  geom_vline(xintercept = as.Date("2022-01-01"), 
             linetype = "dashed", color = "red") +
  annotate("text", x = as.Date("2022-01-01"), y = max_y,
           label = "Accounting change\n(SBIF→CMF)", vjust = -0.5)
```

**RECOMENDACIÓN:** Usar Opción 2 (ratio) para gráficos comparativos

---

## 📋 ESTRUCTURA DE CARPETAS FINAL

```
country_analysis/
├── plots/
│   ├── mexico/       → 2 PNG + 2 PDF
│   ├── peru/         → 4 PNG + 4 PDF
│   ├── chile/        → 6 PNG + 6 PDF (con empalme)
│   └── brazil/       → 4-5 PNG + PDF
│
├── tables/
│   ├── mexico/       → 2 CSV
│   ├── peru/         → 4 CSV
│   ├── chile/        → 6 CSV
│   └── brazil/       → 4-5 CSV
│
├── captions/
│   ├── captions.csv  → Títulos, fuentes, notas para TODOS
│   └── README.md     → Instrucciones de uso
│
└── scripts/
    ├── 02_mexico_analysis.R      → 2 plots
    ├── 03_peru_analysis.R        → 4 plots
    ├── 04_chile_analysis.R       → 6 plots (CON empalme)
    ├── 05_brazil_analysis.R      → 4-5 plots
    └── 99_generate_captions.R    → Genera captions.csv
```

---

## ✅ CHECKLIST IMPLEMENTACIÓN

### México (2 plots)
- [ ] MEX-1: L/C % liabilities (sin título/fuente)
- [ ] MEX-2: L/C by bank type (sin título/fuente)
- [ ] Tabla CSV para cada uno
- [ ] Captions en archivo separado

### Perú (4 plots)
- [ ] PER-1: TF % total
- [ ] PER-2: TF by size
- [ ] PER-3: TF by bank type
- [ ] PER-4: Concentration
- [ ] Tablas CSV
- [ ] Captions

### Chile (6 plots CON EMPALME)
- [ ] **Implementar empalme SBIF→CMF**
- [ ] CHL-1: TF % total (serie empalmada)
- [ ] CHL-2: TF by bank type (serie empalmada)
- [ ] CHL-3: Concentration (serie empalmada)
- [ ] CHL-4: Foreign funding (serie empalmada)
- [ ] CHL-5: L/C % liabilities (serie empalmada)
- [ ] CHL-6: L/C by bank type (serie empalmada)
- [ ] Tablas CSV con columna "accounting_system"
- [ ] Captions con nota de empalme

### Brasil (4-5 plots)
- [ ] BRA-1: TF % total (agregado, sin bancos)
- [ ] BRA-2: TF by size
- [ ] BRA-3: Alternativa "by bank type" (regional?)
- [ ] BRA-4: Alternativa concentration (regional Gini?)
- [ ] BRA-5: Size comparison con Perú
- [ ] Tablas CSV
- [ ] Captions

### Captions File
- [ ] Crear `captions/captions.csv`
- [ ] 16 filas (1 por gráfico)
- [ ] Columnas: figure_id, title, caption, source, notes
- [ ] README explicando uso

---

## 📊 TOTAL FINAL

**Gráficos:** 16 (2+4+6+4)  
**Tablas:** 16  
**Captions:** 1 archivo CSV con 16 entradas  

**NO incluir:**
- ❌ Nearshoring analysis
- ❌ Seasonality patterns
- ❌ Market share evolution
- ❌ Top 10 rankings
- ❌ Crisis impact detallado
- ❌ Regional/sectoral Brasil (excepto alternativas)

---

**Última actualización:** 19 noviembre 2025  
**Status:** Plan corregido según request original
