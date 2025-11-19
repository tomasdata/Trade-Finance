# PERÚ - Análisis de Tamaño de Firma: Data Disponible y Plan de Expansión

**Fecha**: 19 de noviembre de 2025  
**Status**: Data confirmada disponible, lista para expansión

---

## 1. HALLAZGOS CLAVE

### ✅ DATA DISPONIBLE (Confirmado)

**Archivo original**: `/pre-data/Peru/peru_full.csv`

**Columnas relevantes**:
- `Concepto`: Tipo de crédito (incluye "Comercio exterior")
- `size`: Tamaño de firma del deudor
- `institucion`: Banco
- `amount`: Monto en USD
- `total`: Total de crédito del banco

**Categorías de tamaño confirmadas** (para "Comercio exterior"):
- ✅ **Corporate**: 2,757 observaciones
- ✅ **Large**: 2,757 observaciones  
- ✅ **Medium**: 2,757 observaciones
- ✅ **Small**: 2,757 observaciones
- ✅ **Micro**: 2,757 observaciones

**Total**: 13,785 observaciones con desglose por tamaño (dataset balanceado perfecto)

---

## 2. STATUS ACTUAL DEL PROCESAMIENTO

### ✅ Master Processing (01_master_processing.R)

**Líneas 133-165**: El script **SÍ procesa correctamente** la columna `size`:

```r
peru <- peru_tf %>%
  mutate(
    # ... otras variables ...
    
    # Standardize size categories
    size_category = case_when(
      str_detect(size, "Corporate|Corporativ") ~ "Corporate",
      str_detect(size, "Grande|Large") ~ "Large",
      str_detect(size, "Median|Medium") ~ "Medium",
      str_detect(size, "Peque|Small") ~ "Small",
      str_detect(size, "Micro") ~ "Micro",
      TRUE ~ "Other"
    )
  ) %>%
  select(
    date, year, month, year_month,
    institucion, bank_type,
    size_category,  # ← GUARDADO EN RDS ✓
    tf_usd_millions, total_credit_usd_millions, tf_share_pct,
    exports_usd_millions, imports_usd_millions
  )
```

**Output**: `data/processed/peru_processed.rds` contiene `size_category` ✓

---

### ⚠️ Peru Analysis (03_peru_analysis.R)

**Status**: Solo usa `size_category` para **1 gráfico** de 6 totales

**Gráficos actuales**:
- **PER-1**: TF as % Total Credit (agregado total)
- **PER-2**: TF by Borrower Size (STACKED AREA) ← **ÚNICO USO de size_category**
- **PER-3**: TF by Bank Type (por tipo de banco)
- **PER-4**: Concentration (HHI + CR5, agregado total)
- **PER-5**: TF as % Exports (agregado total)
- **PER-6**: TF as % Total Trade (agregado total)

**Oportunidad**: Los gráficos PER-1, PER-4, PER-5, PER-6 podrían tener versiones adicionales desagregadas por `size_category`

---

## 3. COMPARACIÓN CON BRASIL

### Brasil (tiene análisis por tamaño extensivo):
- **BRA-2**: TF by Borrower Size (Annual grouped bars)
- **BRA-5**: Size Distribution Comparison Brazil vs Peru

### Perú (actualmente limitado):
- **PER-2**: TF by Borrower Size (Monthly stacked area)
- ❌ Falta: Análisis más profundo de concentración POR tamaño
- ❌ Falta: Tendencias temporales POR tamaño
- ❌ Falta: Bank type × Size interactions

---

## 4. GRÁFICOS ADICIONALES PROPUESTOS

### 📊 OPCIÓN 1: PER-7 - TF/Exports by Firm Size (Monthly)
**Descripción**: Ratio TF/Exports desagregado por tamaño de firma  
**Insight**: ¿Qué tamaños de firma dependen más del financiamiento bancario para exportar?

```r
peru_size_export <- peru %>%
  filter(!is.na(size_category)) %>%
  group_by(date, size_category) %>%
  summarise(
    tf_usd = sum(tf_usd_millions, na.rm = TRUE),
    exports_usd = mean(exports_usd_millions, na.rm = TRUE)  # Same for all
  ) %>%
  mutate(tf_pct_exports = (tf_usd / exports_usd) * 100)

# Line chart con facetas por size_category
ggplot(..., aes(x = date, y = tf_pct_exports)) +
  geom_line() +
  facet_wrap(~size_category, ncol = 2)
```

**Hipótesis esperada**: Corporate firms ~15-20%, SMEs <5% (menor acceso)

---

### 📊 OPCIÓN 2: PER-8 - Size Concentration Over Time (HHI by Size)
**Descripción**: Concentración bancaria DENTRO de cada segmento de tamaño  
**Insight**: ¿Está más concentrado el mercado Corporate o el SME?

```r
peru_size_hhi <- peru %>%
  filter(!is.na(size_category)) %>%
  group_by(date, size_category, institucion) %>%
  summarise(tf_total = sum(tf_usd_millions, na.rm = TRUE)) %>%
  group_by(date, size_category) %>%
  mutate(share = tf_total / sum(tf_total)) %>%
  summarise(hhi = sum(share^2) * 10000)

# Line chart con múltiples líneas por size_category
ggplot(..., aes(x = date, y = hhi, color = size_category)) +
  geom_line()
```

**Hipótesis esperada**: Corporate más concentrado (HHI ~2500), SME más disperso (HHI ~1500)

---

### 📊 OPCIÓN 3: PER-9 - Bank Type Specialization by Size (Heatmap)
**Descripción**: Matriz bank_type × size_category mostrando TF volumes  
**Insight**: ¿Qué bancos se especializan en qué tamaños de firma?

```r
peru_type_size <- peru %>%
  filter(!is.na(size_category), !is.na(bank_type)) %>%
  group_by(bank_type, size_category) %>%
  summarise(tf_total = sum(tf_usd_millions, na.rm = TRUE))

# Heatmap
ggplot(..., aes(x = size_category, y = bank_type, fill = tf_total)) +
  geom_tile() +
  scale_fill_viridis_c()
```

**Hipótesis esperada**: 
- Foreign banks → Corporate/Large
- State banks → Small/Micro (inclusión financiera)
- Large Domestic → Medium/Large

---

### 📊 OPCIÓN 4: PER-10 - Size Distribution Evolution (% Share Over Time)
**Descripción**: Evolución temporal de la participación de cada tamaño en TF total  
**Insight**: ¿Se está democratizando el acceso al TF o concentrándose?

```r
peru_size_share <- peru %>%
  filter(!is.na(size_category)) %>%
  group_by(date, size_category) %>%
  summarise(tf_usd = sum(tf_usd_millions, na.rm = TRUE)) %>%
  group_by(date) %>%
  mutate(share_pct = (tf_usd / sum(tf_usd)) * 100)

# Area chart 100% stacked
ggplot(..., aes(x = date, y = share_pct, fill = size_category)) +
  geom_area(position = "fill")
```

**Hipótesis esperada**: Corporate share declining post-2020 (SME recovery), but still ~40-50%

---

## 5. PRIORIZACIÓN RECOMENDADA

### 🥇 ALTA PRIORIDAD (añadir primero):
1. **PER-7**: TF/Exports by Firm Size → Policy relevance (acceso desigual)
2. **PER-10**: Size Distribution Evolution → Trend narrative (democratización vs concentración)

### 🥈 MEDIA PRIORIDAD (si hay interés):
3. **PER-8**: Size Concentration HHI → Academic depth (estructura de mercado)
4. **PER-9**: Bank Type × Size Heatmap → Specialization patterns

---

## 6. COMPARACIÓN PERÚ vs OTROS PAÍSES

| País   | Desglose por Tamaño | # Gráficos Size | Calidad Data        |
|--------|---------------------|-----------------|---------------------|
| México | ❌ NO               | 0               | Solo L/C agregado   |
| Perú   | ✅ SÍ (5 cat.)      | **1** actual    | Excelente (SBS)     |
| Chile  | ❌ NO               | 0               | CMF sin desglose    |
| Brasil | ✅ SÍ (4 cat.)      | **2** + compara | Buena (BCB SCR)     |

**Conclusión**: Perú tiene la MEJOR data de tamaño después de Brasil, pero está **subutilizada** (1 vs 2 gráficos)

---

## 7. LIMITACIONES IDENTIFICADAS

### ❌ NO disponible en data original:
- **Subcategorías de "Comercio exterior"** (tipo de producto: L/C, factoring, garantías)
  - A diferencia de Chile que tiene 6 subcategorías
  - Perú solo reporta "Comercio exterior" agregado
  
- **Geographic breakdown** (por región/departamento)
  - A diferencia de Brasil que tiene análisis regional (BRA-3, BRA-4)
  - SBS no publica desglose territorial en data pública

### ⚠️ Potencial problema de multicolinealidad:
- La columna `size` en peru_full.csv podría estar **imputada/inferida** del monto (`amount`)
- Verificar si SBS reporta tamaño real del deudor o es clasificación ex-post

**Acción**: Revisar metodología SBS para confirmar si `size` es:
- (A) Autodeclarado por el banco ← IDEAL
- (B) Calculado por SBS basado en deuda total ← POTENCIAL ENDOGENEIDAD

---

## 8. SIGUIENTES PASOS SUGERIDOS

### Paso 1: Verificación de calidad (30 min)
```r
# Verificar si hay variación temporal en size_category para mismas firmas
peru %>%
  group_by(institucion, size_category) %>%
  summarise(n_months = n_distinct(date)) %>%
  filter(n_months > 12) %>%
  head(20)

# Buscar reclasificaciones sospechosas (firma cambia de Small → Corporate en 1 mes)
```

### Paso 2: Implementar PER-7 y PER-10 (1 hora)
- Añadir a `03_peru_analysis.R` después de PER-6
- Actualizar `captions/captions.csv` con nuevos entries
- Regenerar todos los plots

### Paso 3: Comparación cross-country (opcional, 2 horas)
- Crear script `07_cross_country_size_comparison.R`
- Gráfico: Peru vs Brasil size distribution (actualizar BRA-5)
- Gráfico: TF/Exports by size (Peru Corporate vs Brasil Corporate)

---

## 9. REFERENCIAS TÉCNICAS

**Archivos clave**:
- Original: `/pre-data/Peru/peru_full.csv` (col 9: `size`)
- Procesado: `/data/processed/peru_processed.rds` (col 7: `size_category`)
- Script análisis: `/scripts/03_peru_analysis.R` (líneas 84-127: PER-2)
- Captions: `/captions/captions.csv` (per_02: size description)

**Variables disponibles en RDS**:
```
$ date                       : Date (2010-10 to 2024-12)
$ year                       : int (2010-2024)
$ month                      : int (1-12)
$ year_month                 : chr "2010-10"
$ institucion                : chr (banco estandarizado)
$ bank_type                  : chr (5 categorías)
$ size_category              : chr (5 categorías) ← DISPONIBLE ✓
$ tf_usd_millions            : num
$ total_credit_usd_millions  : num
$ tf_share_pct               : num
$ exports_usd_millions       : num (GMD)
$ imports_usd_millions       : num (GMD)
```

---

## 10. CONCLUSIÓN

**STATUS**: ✅ Data de tamaño de firma **CONFIRMADA DISPONIBLE** y **PROCESADA CORRECTAMENTE**

**PROBLEMA**: Subutilización en análisis actual (1 de 6 gráficos usa `size_category`)

**SOLUCIÓN**: Expandir a 3-4 gráficos adicionales enfocados en:
1. Desigualdad de acceso (TF/Exports by size)
2. Evolución temporal (Size share trends)
3. Estructura de mercado (Concentration by size)
4. Especialización bancaria (Bank type × Size)

**PRIORIDAD**: ALTA - Perú tiene mejor data granular que Chile y comparable con Brasil, pero está desaprovechada

**EFFORT**: Bajo (data ya está en RDS, solo necesita nuevos ggplot blocks)

**IMPACTO**: Alto (policy relevance sobre acceso desigual al trade finance para SMEs vs grandes corporativos)

---

**Contacto**: GitHub Copilot  
**Repo**: tomasdata/Trade-Finance  
**Branch**: main
