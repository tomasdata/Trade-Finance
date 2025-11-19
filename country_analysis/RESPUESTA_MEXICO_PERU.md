# RESPUESTAS - MÉXICO Y PERÚ
**Fecha:** 19 de noviembre, 2025

---

## 1. MÉXICO: ¿Cuántos gráficos?

### **Respuesta: 4 gráficos (pero MEX-1 tiene error)**

**Gráficos diseñados:**
1. **MEX-1**: L/C como % de pasivos totales ❌ **ERROR**
2. **MEX-2**: L/C por tipo de banco ✅
3. **MEX-3**: L/C como % de exportaciones ✅
4. **MEX-4**: L/C como % de comercio total (X+M) ✅

### **Problema encontrado: MEX-1**

**Error:**
```r
Error: object 'total_liab_usd_millions' not found
```

**Causa:**
El script intenta usar `total_liab_usd_millions` pero los datos procesados de México **NO tienen** esa columna.

**Columnas disponibles en mexico_processed.rds:**
```
- date
- year, month, year_month
- cod_inst, institucion
- bank_type, bank_size
- lc_usd_millions          ← Solo L/C
- lc_mxn_billions
- exports_usd_millions
- imports_usd_millions
```

**NO hay:**
- total_liabilities
- total_credit
- balance sheet data

### **Opciones para MEX-1:**

**Opción A: Eliminar MEX-1** (Recomendado)
- México solo reporta L/C (cuenta única 202401504003)
- No tenemos datos de pasivos totales
- Gráfico no es posible con datos actuales
- Quedarían **3 gráficos funcionales**

**Opción B: Reemplazar con otro análisis**
- L/C por banco individual (Top 10)
- L/C tendencia temporal simple
- Pero ya tenemos MEX-2 (por tipo de banco)

### **Recomendación:**
✅ **Eliminar MEX-1** y dejar México con **3 gráficos:**
- MEX-1: L/C por tipo de banco
- MEX-2: L/C como % de exportaciones
- MEX-3: L/C como % de comercio total

---

## 2. PERÚ: ¿Tiene subcategorías de Trade Finance?

### **Respuesta: NO ❌**

**Verificación en datos crudos (peru_full.csv):**

**Columnas disponibles:**
```
- Concepto             ← Tipo de crédito
- institucion
- share, anio, mes
- total, amount
- size                 ← Tamaño de empresa (Corporate, Large, Medium, Small, Micro)
- tipo_cambio
- exports_usd_millions
- imports_usd_millions
```

**Valores de "Concepto":**
1. Arrendamiento financiero y Lease-back
2. **Comercio exterior** ← Trade Finance (AGREGADO)
3. Descuentos
4. Factoring
5. Otros
6. Préstamos
7. Tarjetas de crédito

**NO hay:**
- Subcategorías de "Comercio exterior"
- Código de cuenta (codigo_cuenta)
- Descripción detallada
- Desglose por tipo de TF (exportaciones, importaciones, garantías, etc.)

### **Comparación con Chile:**

| Aspecto | Chile | Perú |
|---------|-------|------|
| Subcategorías | ✅ 7 categorías | ❌ Solo agregado |
| Códigos cuenta | ✅ Sí | ❌ No |
| Detalle | Exportaciones, Importaciones, L/C, Garantías, etc. | Solo "Comercio exterior" |

**Categorías de Chile:**
- Exportaciones
- Importaciones
- Cartas de crédito
- Garantías
- Terceros países
- Interbancario exterior
- Otros

**Perú:**
- "Comercio exterior" (sin desglose)

### **Alternativas para Perú:**

**Lo que SÍ podemos desagregar:**
1. ✅ **Por tipo de banco** (Foreign, State, Large Domestic, etc.) - YA LO TENEMOS
2. ✅ **Por tamaño de empresa cliente:**
   - Corporate
   - Large
   - Medium
   - Small
   - Micro

**Gráfico adicional posible: PER-7**
- **Título:** TF by Client Size
- **Tipo:** Stacked area o stacked bar
- **Categorías:** Corporate, Large, Medium, Small, Micro
- **Muestra:** Qué tipos de empresas usan más TF

---

## RESUMEN

### México
- **Gráficos actuales:** 4 diseñados
- **Gráficos funcionales:** 3 (MEX-1 tiene error fatal)
- **Problema:** MEX-1 requiere datos de pasivos totales que no existen
- **Solución:** Eliminar MEX-1, renumerar MEX-2→MEX-1, MEX-3→MEX-2, MEX-4→MEX-3

### Perú
- **Subcategorías TF:** ❌ NO disponibles
- **Desglose disponible:** Por tipo de banco ✅ | Por tamaño de cliente ✅
- **Gráfico adicional posible:** PER-7 (TF by Client Size)

---

## ACCIONES RECOMENDADAS

### 1. México (URGENTE)
```bash
# Opción A: Eliminar MEX-1 y renumerar
- Eliminar sección MEX-1
- Renumerar: MEX-2→1, MEX-3→2, MEX-4→3
- Actualizar nombres de archivos

# Resultado: 3 gráficos limpios
```

### 2. Perú (OPCIONAL)
```bash
# Agregar PER-7: TF by Client Size
- Stacked area por tamaño (Corporate, Large, Medium, Small, Micro)
- Muestra perfil de clientes de TF
- Complementa análisis existente

# Resultado: 6→7 gráficos
```

### 3. PDFs
```bash
# Ya completado para México
✓ México: PDFs removidos (sed command ejecutado)
✓ 0 líneas PDF restantes
```

---

**¿Qué prefieres hacer con México?**
A) Eliminar MEX-1 y dejar 3 gráficos
B) Intentar obtener datos de pasivos totales (no disponibles actualmente)
C) Reemplazar MEX-1 con otro análisis

**¿Agregar PER-7 (TF by Client Size)?**
- Sí → Desagregación por tamaño de empresa cliente
- No → Dejar Perú con 6 gráficos actuales
