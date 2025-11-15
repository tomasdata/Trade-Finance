# 🇲🇽 Pre-data México — Cartas de Crédito CNBV

Este directorio contiene los archivos crudos necesarios para construir el dataset procesado de cartas de crédito mexicanas que vivirá posteriormente en `data/`. Todo el material proviene del regulador CNBV y está expresado en **pesos mexicanos corrientes**; ningún cálculo en USD se ha realizado aún.

## 📄 Archivos disponibles

| Archivo | Descripción | Cobertura | Observaciones |
|---------|-------------|-----------|---------------|
| `040_R12A_1219_133.csv` | Extracto mensual del formulario R12A (sector 40 – banca múltiple) con todas las cuentas contables reportadas por institución. Columnas: `sector`, `periodo` (`AAAAMM`), `institucion` (código CNBV de 6 dígitos), `orden_presentacion`, `concepto` (código contable) e `importe_pesos`. | 202201 – 202508, 2.95M filas, 54 instituciones, 1,321 conceptos. | Incluye el concepto **202401504003** (cartas de crédito) requerido para trade finance; el resto de los conceptos se mantienen para trazabilidad y controles. |
| `mxnusd.csv` | Serie diaria del tipo de cambio fix del SAT (columna `para solventar obligaciones`) con separador `;`. Columnas: `fecha`, `Determinacion`, `Publicacion DOF`, `para solventar obligaciones`. | 2015-01-01 – 2024-12-31 | Necesitamos agregar una columna `tc` numérica en MXN/USD y convertirla a frecuencia mensual (último dato hábil de cada mes). |

### 📚 Diccionario rápido de campos

| Campo | Significado | Notas |
|-------|-------------|-------|
| `sector` | Identificador del sector regulado dentro de R12A. El valor **40** corresponde a banca múltiple (instituciones de crédito). | Otros sectores (sociedades financieras, sofomes) no aparecen en este extracto. |
| `periodo` | Mes de referencia en formato `AAAAMM`. | En el ETL se separa en `year`, `month`, `year_month`. |
| `institucion` | Código numérico CNBV (6 dígitos con ceros a la izquierda). | Se normaliza a `cod_inst` sin ceros para empatar con mapas internos; el valor `000005` es el agregado del sistema y se descarta. |
| `orden_presentacion` | Orden en que la cuenta aparece en los estados financieros regulatorios. | Solo útil si se desea replicar la estructura original del reporte. |
| `concepto` | Código contable CNBV. | El universo incluye 1,321 conceptos; para trade finance usamos `202401504003` → “Cartas de crédito contingentes” dentro de pasivos contingentes. |
| `importe_pesos` | Saldo o flujo del concepto en pesos corrientes. | En el ETL se convierte a `amount_mxn` y luego a USD con el fix SAT. |

**Concepto TF:** Según el catálogo CNBV de estados financieros, `202401504003` pertenece al rubro “Pasivos contingentes – Cartas de crédito” (instrumentos emitidos por bancos mexicanos). Si necesitas otros conceptos relacionados (p.ej. garantías stand-by, financiamientos de comercio exterior), deben pedirse en el mismo R12A especificando los códigos `20240150xxxx`. 

## 🔁 Plan de traspaso a `data/`

1. **Filtrado del concepto TF**  
   - Mantener únicamente `concepto == "202401504003"` para cartas de crédito sumando por `periodo + institucion`.  
   - Conservar el resto de columnas (`sector`, `orden_presentacion`) para auditoría, pero marcar que no se usan aguas arriba.

2. **Normalización temporal**  
   - Descomponer `periodo` en `year = as.integer(substr(periodo, 1, 4))` y `month = as.integer(substr(periodo, 5, 6))`.  
   - Crear `year_month = sprintf(\"%04d-%02d\", year, month)` para alinear con los scripts (`latam banks.R` usa este formato).

3. **Conversión MXN → USD**  
   - Leer `mxnusd.csv` con `readr::read_delim(sep = ';')`, reemplazar comas decimales por puntos y convertir `para solventar obligaciones` a numérico (`tc`).  
   - Agregar `year`, `month` y seleccionar el último valor disponible de cada mes (o promedio, definir en script).  
   - En el dataset principal agregar `amount_usd = importe_pesos / tc` y `amount_usdk = amount_usd / 1e3`. Mantener `importe_pesos` para referencia.

4. **Enriquecimiento con comercio BACI**  
   - Unir `X_mexico` y `M_mexico` (exportaciones/importaciones anuales) ya creados en `Scripts/latam banks.R` para obtener `trade = X + M`.  
   - Permite replicar gráficos de `share_trade` y métricas CR3/CR5 como en Perú/Brasil.

5. **Salida estandarizada**  
   - Guardar el resultado en `data/mexico_lc.csv` (o `mexico_full.csv`) con las columnas:  
     `year`, `month`, `year_month`, `cod_inst`, `institucion`, `amount_mxn`, `amount_usd`, `amount_usdk`, `tc`, `X`, `M`, `trade`, y cualquier metadato de control.  
   - Documentar la nueva tabla en `data/GUIA_COMPLETA_TRADE_FINANCE.md` bajo un bloque 🇲🇽.

## ✅ Próximos pasos sugeridos

1. Crear script ETL (`Scripts/mexico_lc_etl.R`) que ejecute los pasos anteriores y escriba en `data/`.  
2. Modificar `Scripts/latam banks.R` para leer desde `data/mexico_lc.csv` en lugar del archivo crudo y así mantener el análisis desacoplado de la ingesta.  
3. Incorporar chequeos básicos (conteo de instituciones, rango temporal, suma en MXN/USD) antes de exportar para asegurar consistencia con el archivo original.

Con este README queda documentado qué hay en `pre-data/Mexico/`, cómo debe transformarse y qué campos convertir a USD para integrarse con el resto del proyecto.
