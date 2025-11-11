# Trade Finance Data Pipeline Overview

Este documento resume las fuentes **pre-data**, los ETL disponibles en `Scripts/`, y las salidas en `data/` que usa el proyecto para los análisis de trade finance. El objetivo es saber **qué serie alimenta cada dataset**, cuál es el proceso de conversión (TC, unidades) y cómo se enlaza con BACI para métricas TF/Comercio.

---

## 1. Brasil

| Componente | Ubicación | Descripción |
|------------|-----------|-------------|
| **Crudo BCB** | `pre-data/Brasil/brasil_full.csv` | Panel IF.Data (modalidade = `PJ - Comércio exterior`) con montos en **miles de BRL** por banco‑UF‑sector. |
| **Tipo de cambio** | `pre-data/Brasil/brl_usd_monthly_ptax.csv` | Serie PTAX mensual (SGS 10813) “Taxa de câmbio – dólar americano (venda)” en BRL/USD. |
| **ETL** | `Scripts/brasil_etl.R` | Convierte miles de BRL → BRL → USD, agrega `ptax_brl_per_usd`, y suma `X_exports`, `M_imports`, `trade` usando BACI (código 76). |
| **Salida** | `data/brasil_full.csv` | Dataset listo para análisis: incluye columnas originales, duplicados en BRL (`*_brl`), USD (`*_usd`) y comercio BACI. |

**Uso en trade finance**
- Permite ratios TF/Trade al tener `carteira_ativa_usd` vs `trade`.
- `sr`, `porte`, `cnae_*` habilitan cortes regionales y sectoriales.
- Conversión a USD facilita comparables regionales con Perú/México y series globales (BIS, EXIM).

---

## 2. México

| Componente | Ubicación | Descripción |
|------------|-----------|-------------|
| **Crudo CNBV** | `pre-data/Mexico/040_R12A_1219_133.csv` | Formulario R12A, sector 40, concepto `202401504003` (cartas de crédito) en **pesos corrientes**. |
| **Tipo de cambio** | `pre-data/Mexico/mxnusd.csv` | Serie diaria “para solventar obligaciones” (SAT); el ETL toma el último valor mensual. |
| **ETL** | `Scripts/mexico_lc_etl.R` | Normaliza `year/month`, descarta `cod_inst=5` (agregado), convierte MXN → USD y agrega BACI (cód. 484). |
| **Salida** | `data/mexico_full.csv` | Contiene montos MXN (`amount_mxn`), USD (`amount_usd`), `tipo_cambio`, y `X/M/trade`. |

**Uso en trade finance**
- Serié única de cartas de crédito bancarias; se puede medir concentración (CR3/CR5) y `LC / Comercio total`.
- Datos en USD listos para comparables y dashboards.

---

## 3. Perú

| Componente | Ubicación | Descripción |
|------------|-----------|-------------|
| **Crudo SBS** | `pre-data/Peru/peru_full.csv` | Tabla consolidada (concepto, banco, tamaño) en **miles de soles**. |
| **Tipo de cambio** | `pre-data/Peru/Mensuales-*.csv` | Serie BCRP **PN01215PM** “Tipo de cambio interbancario - Venta, fin de periodo” (mensual). |
| **ETL** | `Scripts/peru_etl.R` | Une SBS + BCRP, calcula `total_pen/amount_pen` y `total_usd/amount_usd`, añade comercio BACI (cód. 604). |
| **Salida** | `data/peru_full.csv` | Conserva columnas originales + PEN/USD + `tipo_cambio` + `X/M/trade`. |

**Uso en trade finance**
- Permite analizar `amount_usd` por tamaño (`size`) y banco (`institucion_std`) y compararlo con `trade`.
- La columna `share` sigue referenciando la participación SBS (%), útil para validación cruzada.

---

## 4. Chile

| Componente | Ubicación | Descripción |
|------------|-----------|-------------|
| **Crudo CMF** | `pre-data/Chile/chile_full.csv` | Dump histórico 1998‑2024 con 30 bancos × 1,118 cuentas contables; montos en CLP/moneda extranjera. |
| **ETL** | `Scripts/chile_etl.R` | Filtra 2015+, convierte `Moneda*` a numérico, crea `year_month`, etiqueta cuentas TF (comercio exterior, exportaciones, importaciones, interbancario, financiamiento, contingentes) y calcula `share_categoria`. |
| **Salida** | `data/chile_full.csv` | Dataset limpio con columnas originales + `_num`, `categoria_tf`, flag `es_control`, totales y shares mensuales. |

**Uso en trade finance**
- `MonedaExtranjera_num` (USD) permite comparar saldos TF vs comercio exterior sin TC adicional.
- `categoria_tf` replica los 5 grupos definidos en el README (comercio exterior, exportaciones, importaciones, financiamiento exterior, contingentes) y deja el resto como `otros`.
- `share_categoria` ayuda a medir la participación de cada banco/cuenta dentro del total mensual de la categoría seleccionada.

---

## 5. Insumos globales (utilizados en `Scripts/Trade finance data and analysis.R`)

| Archivo | Ubicación | Función |
|---------|-----------|---------|
| `country_correspondence.csv` | `pre-data/` | Mapear países a región/subregión (UN) para BACI y análisis global. |
| `income levels.xlsx` | `pre-data/` | Niveles de ingreso del Banco Mundial (se usa para clasificaciones y paneles). |
| `baci_trade_cty.csv` + `country_codes_V202501.csv` | `pre-data/` | Comercio bilateral (FOB) usado por todos los ETL para `X/M/trade`. |
| `Consolidated banking statistics BIS.csv` | `pre-data/` | Datos BIS (claims/ liabilities) para secciones internacionales del script principal. |
| `exim auth.csv` | `pre-data/` | Programa EXIM Bank (autorizaciones) para comparar oferta de trade finance. |
| `Hardy*.dta` | `pre-data/` | Bases académicas (firm/loan-level). Aún no tienen ETL local; se leen directamente con `haven::read_dta` cuando se necesiten. |

**Nota sobre rutas:** todos los scripts estaban apuntando a `G:/Mi unidad/...`. Ahora que los archivos están en `pre-data/`, se recomienda reemplazar esa ruta por `here::here()` o similar para evitar dependencias externas.

---

## 6. Flujo general

1. **Ingesta**: Copiar o descargar los archivos crudos oficiales en `pre-data/<País>/`.
2. **ETL**: Ejecutar el script correspondiente (`brasil_etl.R`, `mexico_lc_etl.R`, `peru_etl.R` o `cmf data.R`). Cada ETL:
   - Limpia llaves (`year/month`, `cod_inst`, `institucion_std`).
   - Conecta con la serie oficial de TC (PTAX, SAT, BCRP).
   - Convierte los montos a unidades comparables (BRL/PEN/MXN → USD).
   - Enlaza BACI para `X_exports`, `M_imports`, `trade`.
3. **Consumo**: Los datasets resultantes en `data/` alimentan:
   - `Scripts/latam banks.R` (análisis bancario país por país).
   - `Scripts/Trade finance data and analysis.R` (secciones comparativas y paneles globales).
   - `presentations/Trade_Finance.tex` (gráficos/tablas en LaTeX).

Este ciclo garantiza coherencia entre los distintos módulos del proyecto y facilita agregar nuevos países o instrumentos manteniendo la misma arquitectura.
