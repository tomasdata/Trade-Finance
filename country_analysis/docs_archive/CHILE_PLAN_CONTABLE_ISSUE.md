# CHILE - PROBLEMA DEL PLAN CONTABLE Y SOLUCIÓN

**Fecha:** 19 de noviembre de 2025  
**Issue:** Dataset `chile_full.csv` aparenta terminar en 2021, pero en realidad tiene datos hasta 2024

---

## 🚨 PROBLEMA IDENTIFICADO

### Cambio Regulatorio CMF (2022)

**Chile cambió su plan contable bancario en enero 2022** (transición SBIF → CMF con nuevas normas IFRS 9).

**Impacto en el dataset:**

| Período | Códigos de Cuenta | Sistema | Cuentas Únicas | Match con 2021 |
|---------|-------------------|---------|----------------|----------------|
| **2015-2021** | 7-9 dígitos (ej: `1454002`) | SBIF antiguo | 173 | 100% |
| **2022-2024** | 9 dígitos (ej: `145400200`) | CMF nuevo (IFRS 9) | 709 | **0%** ❌ |

**Consecuencia:** El filtro `categoria_tf` en el ETL original solo identifica cuentas del sistema viejo → dataset procesado "termina" en 2021 aunque los datos crudos llegan a 2024.

---

## 📊 DATOS DISPONIBLES (Realidad)

```
Observaciones totales: 762,687
Período completo: 2015-2024 (10 años)

Por año:
  2015-2021: 49K-39K obs/año (decreciente, sistema viejo)
  2022-2024: 153K obs/año (constante, sistema nuevo - más cuentas)

Trade Finance específicamente:
  2015-2021: ~40K obs/año, 18-25 bancos, 165-173 cuentas
  2022-2024: ~153K obs/año, 18 bancos, 709 cuentas ✅
```

**✅ Los datos SÍ existen hasta 2024, solo falta re-mapear las cuentas**

---

## 🔍 CUENTAS TRADE FINANCE IDENTIFICADAS (2022-2024)

### Créditos de Comercio Exterior (Activos - Colocaciones)

| Código | Descripción | Suma 2022 (CLP) | Categoría |
|--------|-------------|-----------------|-----------|
| **145400200** | Créditos de comercio exterior (TOTAL) | **222 billones** | ⭐ PRINCIPAL |
| **145400202** | Otros créditos para **exportaciones** chilenas | 121 billones | Exportaciones |
| **145400204** | Otros créditos para **importaciones** chilenas | 66 billones | Importaciones |
| **145400203** | Acreditivos negociados plazo **importaciones** | 25 billones | L/C Importaciones |
| **145400201** | Acreditivos negociados plazo **exportaciones** | 1.4 billones | L/C Exportaciones |
| **143200106** | Créditos CE entre **terceros países** | 7 billones | Third-party |
| **143200104** | Créditos CE exportaciones chilenas | 5 billones | Exportaciones |
| **143100104** | Créditos CE exportaciones (categoría 1) | 0.03 billones | Exportaciones |

**Total identificado: ~448 billones CLP (~500 mil millones USD)**

### Financiamiento de Comercio Exterior (Pasivos)

| Código | Descripción | Suma 2022 (CLP) | Categoría |
|--------|-------------|-----------------|-----------|
| **244500100** | Financiamientos de comercio exterior (TOTAL) | **125 billones** | ⭐ PRINCIPAL |
| **244500101** | Financiamientos para **exportaciones** chilenas | 87 billones | Funding Export |
| **244500102** | Financiamientos para **importaciones** chilenas | 34 billones | Funding Import |
| **244250100** | Financiamientos CE (categoría 2) | 0.17 billones | Funding |
| **244250102** | Financiamientos importaciones (cat. 2) | 0.17 billones | Funding Import |

**Total identificado: ~246 billones CLP (~273 mil millones USD)**

### Garantías y Cartas de Crédito

| Código | Descripción | Suma 2022 (CLP) | Categoría |
|--------|-------------|-----------------|-----------|
| **190000204** | Garantías efectivo **entregadas** por ops exterior | 76 billones | Guarantees Out |
| **290000104** | Garantías efectivo **recibidas** por ops exterior | 35 billones | Guarantees In |
| **271000200** | Cartas de crédito operaciones circulación mercancías | 0.12 billones | L/C Stand-by |
| **246000208** | Obligaciones a favor de exportadores chilenos | 5 billones | Obligations |

### Operaciones Interbancarias Exterior

| Código | Descripción | Suma 2022 (CLP) | Categoría |
|--------|-------------|-----------------|-----------|
| **141000200** | Operaciones con bancos del exterior | 4 billones | Interbank Assets |
| **243000200** | Operaciones con bancos del exterior | 3 billones | Interbank Liabilities |
| **141000400** | Operaciones con otras entidades exterior | 0.3 billones | Other Foreign |
| **243000400** | Operaciones con otras entidades exterior | 3 billones | Other Foreign |

### Otras Cuentas Relevantes

| Código | Descripción | Suma 2022 (CLP) | Categoría |
|--------|-------------|-----------------|-----------|
| **290000102** | Garantías efectivo recibidas por ops financieras exterior | 5 billones | Guarantees |
| **190000202** | Garantías efectivo entregadas por ops financieras exterior | 4 billones | Guarantees |
| **272000000** | Provisiones por riesgo país para ops con deudores exterior | 0.7 billones | Provisions |
| **246000304** | Obligaciones a favor de exportadores extranjeros | 0.3 billones | Obligations |

---

## 🎯 ESTRATEGIA DE SOLUCIÓN

### Opción A: Actualizar ETL Original ⚙️

**Ventaja:** Fix en la fuente, todos los análisis posteriores funcionan  
**Desventaja:** Requiere re-generar `chile_full.csv` desde archivos raw CMF

**Pasos:**
1. Ir a `/Users/tomasfernandez/Documents/Tomas/Trade-Finance/Scripts/chile_etl.R`
2. Actualizar función `categorize_account()` con códigos del plan nuevo (2022-2024)
3. Agregar lógica para detectar período: `if (year >= 2022)` usar plan nuevo
4. Re-ejecutar ETL desde archivos raw en `/pre-data/Chile/`
5. Regenerar `data/chile_full.csv` con `categoria_tf` correcta para 2022-2024

**Código actualizado sugerido:**
```r
categorize_account <- function(code, year) {
  code <- as.integer(code)
  
  # Plan Nuevo (2022-2024) - IFRS 9
  if (year >= 2022) {
    case_when(
      # Control accounts
      code %in% c(100000000, 200000000, 500000000) ~ "control",
      
      # Comercio Exterior - Créditos (Activos)
      code == 145400200 ~ "comercio_exterior",  # TOTAL CE
      code %in% c(145400201, 145400202, 143200104, 143100104) ~ "exportaciones",
      code %in% c(145400203, 145400204) ~ "importaciones",
      code %in% c(143200106, 143100106) ~ "terceros_paises",
      
      # Financiamiento CE (Pasivos)
      code %in% c(244500100, 244500101, 244250100) ~ "financiamiento_export",
      code %in% c(244500102, 244250102) ~ "financiamiento_import",
      
      # Garantías
      code %in% c(190000204, 190000202) ~ "garantias_entregadas",
      code %in% c(290000104, 290000102) ~ "garantias_recibidas",
      
      # Cartas de Crédito
      code == 271000200 ~ "cartas_credito",
      
      # Interbancario Exterior
      code %in% c(141000200, 141000400) ~ "interbancario_exterior_activo",
      code %in% c(243000200, 243000400) ~ "interbancario_exterior_pasivo",
      
      # Obligaciones
      code %in% c(246000208, 246000304) ~ "obligaciones_exportadores",
      
      # Provisiones
      code == 272000000 ~ "provisiones_riesgo_pais",
      code == 260000200 ~ "provisiones_remesas",
      
      TRUE ~ "otros"
    )
  } 
  # Plan Viejo (2015-2021) - SBIF
  else {
    case_when(
      code %in% c(200000000, 510000000, 100000000, 140000000,
                  500000000, 505000000, 145000000) ~ "control",
      code %in% c(145400200, 145400101, 145400102) ~ "comercio_exterior",
      code %in% c(145400201, 145400202, 145400105, 145400205) ~ "exportaciones",
      code %in% c(145400203, 145400204, 145400290) ~ "importaciones",
      code %in% c(143100104, 143100105, 143100106,
                  143200104, 143200105, 143200106) ~ "interbancario_exterior",
      code %in% c(244250100, 244500100, 244500200, 244000000, 244500000) ~ "financiamiento_exterior",
      code %in% c(813200600, 814200600, 821200600, 831200000) ~ "contingentes",
      TRUE ~ "otros"
    )
  }
}

# Aplicar con año
chile <- chile %>%
  mutate(
    categoria_tf = mapply(categorize_account, CodigoCuenta, Anho),
    es_control = categoria_tf == "control"
  )
```

### Opción B: Post-Processing en 01_master_processing.R 🔧

**Ventaja:** No tocar ETL original, solo fix en análisis  
**Desventaja:** Cada vez que se use `chile_full.csv` hay que recordar aplicar fix

**Pasos:**
1. En `scripts/01_master_processing.R`, agregar lógica post-load:
   ```r
   # Fix Chile 2022-2024 trade finance categorization
   chile_tf_codes_2022 <- c(
     145400200, 145400201, 145400202, 145400203, 145400204,
     143200104, 143200106, 143100104,
     244500100, 244500101, 244500102, 244250100, 244250102,
     190000204, 290000104, 271000200, 246000208,
     141000200, 243000200, 141000400, 243000400
   )
   
   chile <- chile %>%
     mutate(
       categoria_tf = if_else(
         Anho >= 2022 & CodigoCuenta %in% chile_tf_codes_2022,
         case_when(
           CodigoCuenta == 145400200 ~ "comercio_exterior",
           CodigoCuenta %in% c(145400201, 145400202, 143200104) ~ "exportaciones",
           CodigoCuenta %in% c(145400203, 145400204) ~ "importaciones",
           # ... resto de mappings
           TRUE ~ "otros"
         ),
         categoria_tf  # Mantener original para 2015-2021
       )
     )
   ```

### Opción C: Crear Script de Fix Dedicado 📝

**Ventaja:** Claridad, documentación separada  
**Desventaja:** Un paso extra en el pipeline

**Pasos:**
1. Crear `scripts/00_fix_chile_2022_tf.R`
2. Cargar `data/chile_full.csv`
3. Aplicar re-categorización para 2022-2024
4. Guardar `data/chile_full_fixed.csv`
5. Usar versión fixed en `01_master_processing.R`

---

## 📋 RECOMENDACIÓN

**Opción B (Post-Processing)** es la más práctica **AHORA** porque:

1. ✅ No requiere archivos raw CMF (que pueden no estar disponibles)
2. ✅ Se implementa rápido (1 modificación en `01_master_processing.R`)
3. ✅ Permite análisis inmediato con datos 2022-2024
4. ✅ No rompe nada existente (2015-2021 sigue funcionando)

**Luego, Opción A (ETL fix)** para producción final.

---

## 🚀 IMPLEMENTACIÓN INMEDIATA

### Paso 1: Actualizar `01_master_processing.R`

Agregar después de cargar Chile, antes del filtro trade finance:

```r
# ==============================================================================
# FIX: Chile 2022-2024 Trade Finance Categorization
# Issue: CMF changed accounting plan in 2022 (IFRS 9)
# Old codes (2015-2021): 7-9 digits, SBIF system
# New codes (2022-2024): 9 digits, CMF system
# Solution: Re-categorize accounts for 2022-2024 using new plan codes
# ==============================================================================

cat("  → Fixing Chile 2022-2024 trade finance categories...\n")

# Define TF accounts in new plan (2022-2024)
chile_tf_2022_codes <- c(
  # Créditos comercio exterior (Activos)
  145400200,  # Total CE (principal)
  145400201, 145400202,  # Export financing (L/C + otros)
  145400203, 145400204,  # Import financing (L/C + otros)
  143200104, 143200106,  # Export + third-party
  143100104,  # Export (category 1)
  
  # Financiamiento CE (Pasivos)
  244500100, 244500101, 244500102,  # Funding (total, export, import)
  244250100, 244250102,  # Funding category 2
  
  # Garantías
  190000204, 190000202,  # Guarantees given
  290000104, 290000102,  # Guarantees received
  
  # Cartas de Crédito y Obligaciones
  271000200,  # L/C stand-by
  246000208, 246000304,  # Obligations to exporters
  
  # Interbancario exterior
  141000200, 141000400,  # Assets with foreign banks
  243000200, 243000400,  # Liabilities with foreign banks
  
  # Provisiones
  272000000, 260000200  # Provisions for country risk, remittances
)

# Re-categorize for 2022-2024
chile_raw <- chile_raw %>%
  mutate(
    categoria_tf_orig = categoria_tf,  # Preserve original
    categoria_tf = case_when(
      # Keep 2015-2021 original categorization
      Anho < 2022 ~ categoria_tf,
      
      # Re-categorize 2022-2024
      Anho >= 2022 & CodigoCuenta %in% chile_tf_2022_codes ~ case_when(
        CodigoCuenta == 145400200 ~ "comercio_exterior",
        CodigoCuenta %in% c(145400201, 145400202, 143200104, 143100104) ~ "exportaciones",
        CodigoCuenta %in% c(145400203, 145400204) ~ "importaciones",
        CodigoCuenta %in% c(143200106) ~ "terceros_paises",
        CodigoCuenta %in% c(244500100, 244500101, 244250100) ~ "financiamiento_exportaciones",
        CodigoCuenta %in% c(244500102, 244250102) ~ "financiamiento_importaciones",
        CodigoCuenta %in% c(190000204, 190000202) ~ "garantias",
        CodigoCuenta %in% c(290000104, 290000102) ~ "garantias",
        CodigoCuenta == 271000200 ~ "cartas_credito",
        CodigoCuenta %in% c(246000208, 246000304) ~ "obligaciones",
        CodigoCuenta %in% c(141000200, 141000400, 243000200, 243000400) ~ "interbancario_exterior",
        CodigoCuenta %in% c(272000000, 260000200) ~ "provisiones",
        TRUE ~ "otros_tf"
      ),
      
      # 2022-2024 not in TF list
      TRUE ~ "otros"
    )
  )

cat("  → Chile TF categories updated for 2022-2024\n")
cat("     - 2015-2021: Original SBIF categorization\n")
cat("     - 2022-2024: New CMF/IFRS 9 categorization\n")
cat("     - TF accounts identified: ", length(chile_tf_2022_codes), "\n")
```

### Paso 2: Verificar fix

```r
# Verificación
chile_tf_check <- chile_raw %>%
  filter(categoria_tf != "otros", categoria_tf != "control") %>%
  group_by(Anho) %>%
  summarise(
    obs = n(),
    bancos = n_distinct(CodigoInstitucion),
    cuentas = n_distinct(CodigoCuenta),
    sum_monto = sum(abs(MonedaTotal_num), na.rm=TRUE) / 1e12  # Trillones CLP
  )

print(chile_tf_check)
```

**Output esperado:**
```
   Anho    obs bancos cuentas sum_monto
  <dbl>  <int>  <int>   <int>     <dbl>
1  2015  ~40K     25     165      ~150
2  2016  ~40K     24     169      ~160
3  2017  ~35K     21     169      ~155
4  2018  ~35K     20     169      ~160
5  2019  ~30K     19     173      ~165
6  2020  ~30K     19     173      ~170
7  2021  ~30K     18     173      ~175
8  2022  ~25K     18      25      ~700   ← NUEVO
9  2023  ~25K     18      25      ~750   ← NUEVO
10 2024  ~25K     18      25      ~800   ← NUEVO
```

### Paso 3: Re-ejecutar master processing

```bash
cd /Users/tomasfernandez/Documents/Tomas/Trade-Finance/country_analysis
Rscript scripts/01_master_processing.R
```

---

## 📊 IMPACTO EN ANÁLISIS

Con este fix, Chile tendrá:

**Antes (solo 2015-2021):**
- 7 años de datos
- ~280K obs trade finance
- Termina en 2021 (no captura COVID recovery ni 2022-2024)

**Después (2015-2024):**
- **10 años de datos** ✅
- ~355K obs trade finance (+75K)
- Captura todo COVID (2020-2024)
- **Comparable con otros países** (México/Perú/Brasil tienen 2022-2024)

**Nuevos análisis posibles:**
- Crisis COVID completa (2020-2024)
- Recuperación post-pandemia
- Inflación 2022-2023
- Comparación cross-country 2022-2024 (antes solo hasta 2021)

---

## ⚠️ NOTA IMPORTANTE

**En plots y reportes, marcar el cambio metodológico:**

```r
# En gráficos temporales, agregar línea vertical
geom_vline(xintercept = as.Date("2022-01-01"), 
           linetype = "dashed", color = "gray50") +
annotate("text", x = as.Date("2022-01-01"), y = max_y * 0.9,
         label = "Plan contable CMF\n(IFRS 9)", 
         hjust = -0.1, size = 3)

# En tablas y reportes, nota al pie
"Note: Chile implemented new accounting plan (CMF/IFRS 9) in January 2022. 
Account codes changed from SBIF 7-digit to CMF 9-digit system. 
Trade finance accounts were remapped to ensure comparability across periods."
```

---

## 📚 REFERENCIAS

**Cambio Regulatorio:**
- [CMF Chile - Compendio de Normas Contables](https://www.cmfchile.cl/institucional/legislacion_normativa/normativa.php)
- IFRS 9 - Financial Instruments (implementado 2022 en Chile)
- [Superintendencia de Bancos (ex-SBIF) → Comisión para el Mercado Financiero (CMF)](https://www.cmfchile.cl)

**Documentación del cambio:**
- Circular CMF N° (fecha 2021-2022) sobre nuevo plan de cuentas
- Tablas de equivalencia SBIF → CMF (si disponibles)

---

**STATUS:** 🔴 PENDIENTE DE IMPLEMENTACIÓN  
**PRIORIDAD:** 🔥 ALTA (bloquea análisis Chile 2022-2024)  
**TIEMPO ESTIMADO:** 30-60 minutos implementación + testing

**Próximo paso:** Implementar Opción B en `01_master_processing.R`
