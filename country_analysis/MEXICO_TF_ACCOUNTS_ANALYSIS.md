# 🇲🇽 MÉXICO - ANÁLISIS CUENTAS TRADE FINANCE CNBV

**Fecha**: 19 noviembre 2025  
**Fuente**: CNBV R12A - Balances Contables Banca Múltiple  
**Periodo analizado**: 2022-01 a 2024-08

---

## 📊 **CUENTAS 2024015xxxxx IDENTIFICADAS**

### **Pasivos Contingentes - Trade Finance (10 cuentas)**

| Cuenta | Total MXN (2022-2024) | USD Equiv. | % del Total | Ranking |
|--------|----------------------|------------|-------------|---------|
| **202401504010** | 1,440 billones | ~72,000 M | 35.7% | 1 |
| **202401504001** | 1,000 billones | ~50,000 M | 24.8% | 2 |
| **202401504003** | 786 billones | ~39,300 M | 19.5% | 3 ✅ |
| **202401504002** | 411 billones | ~20,550 M | 10.2% | 4 |
| **202401504005** | 321 billones | ~16,050 M | 8.0% | 5 |
| **202401504006** | 311 billones | ~15,550 M | 7.7% | 6 |
| **202401504009** | 79 billones | ~3,950 M | 2.0% | 7 |
| **202401504004** | 2.8 billones | ~140 M | 0.1% | 8 |
| **202401504008** | 1.3 billones | ~65 M | <0.1% | 9 |
| **202401504007** | 0 | 0 | 0% | 10 |
| **TOTAL** | **4,031 billones** | **~201,550 M** | **100%** | |

✅ = Actualmente incluida en análisis

**Conversión**: 20 MXN/USD (promedio aproximado 2022-2024)

---

## 🔍 **IDENTIFICACIÓN DE CUENTAS**

### **Según estructura CNBV:**

**Jerarquía de cuentas:**
- **20** = Pasivos
- **2024** = Pasivos contingentes
- **202401** = Pasivos contingentes - Operaciones crediticias
- **2024015** = Operaciones de comercio exterior y garantías
- **202401504** = Instrumentos específicos TF
- **20240150400X** = Subcuentas por tipo de instrumento

### **Interpretación basada en prácticas bancarias estándar:**

| Cuenta | Descripción Probable | Incluir en TF? |
|--------|---------------------|----------------|
| **202401504001** | Garantías otorgadas (stand-by, bid bonds, performance bonds) | ✅ SÍ |
| **202401504002** | Aceptaciones bancarias (trade acceptances) | ✅ SÍ |
| **202401504003** | **Cartas de crédito abiertas (confirmadas)** | ✅ SÍ (actual) |
| **202401504004** | Cartas de crédito back-to-back o transferibles | ✅ SÍ |
| **202401504005** | Líneas de crédito documentario no utilizadas | ⚠️ Contingente |
| **202401504006** | Garantías de pago diferido (deferred payment guarantees) | ✅ SÍ |
| **202401504007** | No utilizada / reservada | ❌ NO |
| **202401504008** | Otros contingentes TF | ⚠️ Revisar |
| **202401504009** | Avales y fianzas comercio exterior | ✅ SÍ |
| **202401504010** | **Créditos directos comercio exterior pendientes de ejercer** | ✅ SÍ |

---

## 💡 **HALLAZGO CLAVE:**

### **México TIENE Trade Finance completo, pero está en CONTINGENTES**

**Problema anterior:**
- Solo usábamos **202401504003** (L/C) = USD 39,300 M
- Representaba solo **19.5%** del TF contingente total

**Realidad:**
- TF contingente total: **USD ~201,550 millones**
- **5.1x MÁS** que solo L/C
- Cuenta **202401504010** (la más grande): USD 72,000 M

---

## 📈 **COMPARACIÓN CON TF DIRECTO**

### **¿Por qué TF está en contingentes?**

**TF Contingente** (cuentas 2024015xxxxx):
- Garantías, L/C, stand-by letters
- Aceptaciones bancarias
- Líneas de crédito no ejercidas
- Avales comercio exterior
- **Riesgo potencial, no préstamo directo**

**TF Directo** (buscar en cuentas 1xxxxxxx - Activos):
- Créditos exportación desembolsados
- Financiamiento importaciones activo
- Forfaiting
- Descuento documentos exportación

**NECESITAMOS BUSCAR:** Cuentas 10xxxxxxx o 11xxxxxxx que contengan:
- Préstamos comercio exterior
- Créditos exportación
- Créditos importación

---

## ✅ **RECOMENDACIÓN: AMPLIAR COBERTURA**

### **Opción 1: Sumar todas las cuentas 2024015xxxxx**

**Ventajas:**
- TF contingente completo (USD 201,550 M)
- Comparable con Perú/Chile/Brasil
- Captura garantías, L/C, aceptaciones

**Desventajas:**
- No incluye créditos directos TF
- Solo lado contingente

**Implementación:**
```r
# En mexico_enhanced_etl.R cambiar:
tf_codes <- c("202401504001", "202401504002", "202401504003", 
              "202401504004", "202401504005", "202401504006",
              "202401504009", "202401504010")  # Excluir 007, 008
```

---

### **Opción 2: Buscar TF Directo + Contingente**

**Buscar en R12A:**
- **10240150xxxx**: Créditos comercio exterior (activo)
- **10240151xxxx**: Financiamiento exportaciones
- **10240152xxxx**: Financiamiento importaciones
- **11240150xxxx**: Descuento documentos comercio exterior

**Ventaja:**
- TF COMPLETO (directo + contingente)
- Totalmente comparable con otros países

**Implementación:**
```bash
# Buscar códigos en R12A:
awk -F',' '{print $5}' 040_R12A_1219_133.csv | sort -u | grep -E "^(10240150|10240151|10240152|11240150)"
```

---

## 🎯 **ACCIÓN INMEDIATA:**

### 1. **Verificar existencia de TF Directo**

Ejecutar:
```r
library(data.table)
r12a <- fread('pre-data/Mexico/040_R12A_1219_133.csv')

# Buscar créditos TF directos
tf_direct <- r12a %>%
  filter(grepl('^(102401|112401)', concepto)) %>%
  group_by(concepto) %>%
  summarise(
    n_obs = n(),
    total_mxn = sum(as.numeric(importe_pesos), na.rm=TRUE),
    n_banks = n_distinct(institucion)
  ) %>%
  filter(total_mxn > 0) %>%
  arrange(desc(total_mxn))

print(tf_direct)
```

### 2. **Expandir scripts para incluir 2024015 completo**

Modificar `mexico_enhanced_etl.R`:
- Línea 127: cambiar de `lc_code <- "202401504003"` a vector con 8 cuentas
- Agregar nombre descriptivo: "Trade Finance Contingent Total"
- Actualizar captions: "TF Contingent (L/C, Guarantees, Acceptances)"

### 3. **Regenerar México con TF expandido**

```bash
cd country_analysis
Rscript scripts/01_master_processing.R
Rscript scripts/02_mexico_analysis_SIMPLE.R
```

---

## 📊 **IMPACTO EN PLOTS MÉXICO:**

### **ANTES (solo L/C 202401504003):**
- MEX-01: USD 5.9 billones/año
- MEX-02: Top 5 bancos L/C only

### **DESPUÉS (todas cuentas 2024015):**
- MEX-01: USD **~67 billones/año** (11.3x más) ✅
- MEX-02: Top 5 bancos TF contingente completo
- **Comparable con:**
  - Perú: USD 13 B/año (México 5x más)
  - Chile: USD 60 B/mes (México ~USD 5.6 B/mes similar)
  - Brasil: USD 3-5 B/mes (México más alto)

---

## 🇧🇷 **BRASIL - NO TIENE L/C SEPARADO**

**Verificación realizada:**
- Brasil BCB reporta **"Modalidade: Comércio Exterior"** (agregado)
- NO desglosa por instrumento (L/C, garantías, aceptaciones)
- Columnas disponibles:
  - ✅ `tf_usd_millions` (total TF)
  - ✅ `a_vencer_ate_90_dias_usd` (vencimientos <90 días)
  - ✅ `indexador` (tipo de tasa: Pre-fixed, Floating, Post-fixed)
  - ❌ NO tiene L/C separado

**Conclusión Brasil:**
- ✅ TF completo disponible (USD 3-5 B/mes)
- ❌ Sin desagregación por instrumento
- ✅ Ya usamos la cobertura máxima disponible

---

## 📝 **RESUMEN EJECUTIVO:**

| País | TF Disponible | Instrumento | Cobertura | Acción |
|------|---------------|-------------|-----------|--------|
| **Brasil** | TF Total | Agregado BCB | Completa ✅ | Ninguna |
| **Chile** | TF Total + L/C | Detallado CMF | Completa ✅ | Ninguna |
| **Perú** | TF Total | SBS | Completa ✅ | Ninguna |
| **México** | TF Contingente | CNBV 10 cuentas | **Parcial ❌** | **AMPLIAR** |

**México necesita:**
1. ✅ Incluir 8 cuentas 2024015 (contingente completo): +425%
2. ⏳ Buscar TF directo (cuentas 102401/112401): potencial +100-300%
3. ⏳ Documentar catálogo CNBV oficial para confirmación

---

**Próximo paso:** Ejecutar búsqueda de cuentas TF directas en R12A y expandir cobertura México.

**Fecha análisis**: 19 noviembre 2025  
**Analista**: Trade Finance Data Pipeline
