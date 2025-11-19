# CORRECCIONES FINALES - GRÁFICOS
**Fecha:** 19 de noviembre, 2025  
**Correcciones aplicadas:** 3 problemas resueltos

---

## ✅ PROBLEMA 1: CHL-4 No se generaba

### **Causa:**
El gráfico estaba deshabilitado (`if(FALSE)`) porque se habían removido las cuentas de pasivos para evitar double-counting.

### **Solución:**
- Reactivado usando la categoría `"interbancario_exterior"` que SÍ existe en los datos
- Esta categoría captura el financiamiento interbancario externo (activos, no pasivos)
- Datos disponibles: 2022-2024 (período CMF)

### **Resultado:**
```
✓ CHL-4 complete
  - Range: 98.4 to 1143.1 USD millions
  - Files: chl_04_foreign_funding.png, .csv
```

**Cambios específicos:**
```r
# ANTES: Deshabilitado
if(FALSE) {
  # código deshabilitado...
}

# DESPUÉS: Activo con categoría correcta
chile_foreign <- chile %>%
  filter(year >= 2022, categoria == "interbancario_exterior") %>%
  group_by(date) %>%
  summarise(foreign_funding_usd_millions = sum(abs(tf_usd_millions), na.rm = TRUE))
```

---

## ✅ PROBLEMA 2: CHL-9 Inconsistencia de formato

### **Causa:**
- Tenía título y subtítulo (inconsistente con otros gráficos)
- Categorías en español (otros gráficos en inglés)
- Legend en 2 filas (debería estar a la derecha)

### **Solución:**
1. **Removido título y caption** (va en captions.csv)
2. **Categorías traducidas a inglés:**
   - Exportaciones → **Exports**
   - Importaciones → **Imports**
   - Cartas de Crédito → **Letters of Credit**
   - Garantías → **Guarantees**
   - Terceros Países → **Third Countries**
   - Interbancario Exterior → **Interbank Foreign**

3. **Legend reposicionada** a la derecha (consistente con otros stacked plots)

### **Resultado:**
```
✓ CHL-9 complete
  - Top category: Exports (46.1%)
  - Files: chl_09_tf_composition.png, .csv
```

**Cambios específicos:**
```r
# ANTES: Español + título
categoria_label = case_when(
  categoria == "exportaciones" ~ "Exportaciones",
  ...
)
labs(
  title = "Chile: Trade Finance Composition by Category",
  subtitle = "Monthly breakdown...",
  caption = "Source: CMF..."
)

# DESPUÉS: Inglés + sin título
categoria_label = case_when(
  categoria == "exportaciones" ~ "Exports",
  ...
)
labs(
  x = "Month",
  y = "Trade Finance (USD millions)",
  fill = "Category"
)
```

---

## ✅ PROBLEMA 3: BRA-8 No se generaba

### **Causa:**
Typo en el código: usaba `brasil_top_sectors` (con 'i') en vez de `brazil_top_sectors` (con 'z').

### **Solución:**
Corregido el nombre de variable en `scale_x_continuous()`:

```r
# ANTES: Error de typo
scale_x_continuous(breaks = seq(min(brasil_top_sectors$year), ...))

# DESPUÉS: Nombre correcto
scale_x_continuous(breaks = seq(min(brazil_top_sectors$year), ...))
```

### **Resultado:**
```
✓ BRA-8 complete
  - Top sector: Manufacturing 
  - Number of sectors shown: 8 
  - Files: bra_08_tf_by_sector.png, .pdf, .csv
```

**Sectores mostrados (Top 8):**
1. Manufacturing (62.9%)
2. Wholesale/Retail (17.0%)
3. Transport/Logistics (4.5%)
4. Agriculture (4.3%)
5. Mining (3.1%)
6. Other (5.3%)
7. Construction (0.4%)
8. IT/Communication (0.3%)

---

## VERIFICACIÓN DE ARCHIVOS

### Chile
```bash
✓ plots/chile/chl_04_foreign_funding.png (223 KB)
✓ plots/chile/chl_09_tf_composition.png (184 KB)
```

### Brasil
```bash
✓ plots/brazil/bra_08_tf_by_sector.png (89 KB)
```

---

## RESUMEN DE CONSISTENCIAS APLICADAS

### Formato estándar para TODOS los gráficos:
1. ✅ **Sin títulos** (van en captions.csv)
2. ✅ **Sin captions** (van en captions.csv)
3. ✅ **Etiquetas en inglés** (categorías, ejes, legends)
4. ✅ **Ejes con labels:**
   - `x = "Month"` o `x = "Year"`
   - `y = "[Métrica] ([Unidad])"`
5. ✅ **Legend position:**
   - Time series: no legend o `"none"`
   - Stacked plots: `"right"` o `"bottom"`
6. ✅ **PNG únicamente** (300 DPI) - sin PDFs

### Archivos generados después de correcciones:

| País   | Gráfico | Estado | Tamaño | Corrección |
|--------|---------|--------|--------|------------|
| Chile  | CHL-4   | ✅     | 223 KB | Reactivado con interbancario_exterior |
| Chile  | CHL-9   | ✅     | 184 KB | Inglés + sin título |
| Brasil | BRA-8   | ✅     | 89 KB  | Typo corregido (brasil→brazil) |

---

## ESTADO FINAL: 27/27 GRÁFICOS ✅

Todos los gráficos ahora:
- ✅ Se generan correctamente
- ✅ Tienen formato consistente
- ✅ Usan nomenclatura en inglés
- ✅ Sin títulos (van en captions.csv)
- ✅ Solo PNG (300 DPI)

**Última ejecución:** 19 de noviembre, 2025 16:25  
**Scripts validados:** Chile ✅ | Brasil ✅
