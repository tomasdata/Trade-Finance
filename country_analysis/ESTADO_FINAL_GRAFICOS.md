# ESTADO FINAL DE GRÁFICOS - ANÁLISIS POR PAÍS
**Fecha:** 19 de noviembre, 2025  
**Estado:** COMPLETO - Sin PDFs, con desagregación

---

## ✅ CHILE (9/9 gráficos)

### Gráficos Originales
1. **CHL-1**: TF como % de cartera de créditos (mensual)
2. **CHL-2**: TF por tipo de banco (stacked area mensual, 2022+)
3. **CHL-3**: Concentración HHI (mensual)
4. **CHL-4**: Financiamiento exterior (líneas mensuales)
5. **CHL-5**: L/C como % de pasivos (mensual)
6. **CHL-6**: L/C por Top 5 bancos (stacked area mensual, 2022+)

### Gráficos con Datos GMD
7. **CHL-7**: TF como % de Exportaciones (mensual, 2022+)
   - Rango: 22.0% - 35.7%
   - Metodología: TF mensual / Exportaciones anuales

8. **CHL-8**: TF como % de Comercio Total (X+M) (mensual, 2022+)
   - Rango: 10.4% - 18.2%
   - Metodología: TF mensual / (Exportaciones + Importaciones) anuales

### Gráfico de Desagregación
9. **CHL-9**: ✨ COMPOSICIÓN POR CATEGORÍA (stacked area mensual, 2022+)
   - Exportaciones: 46.1%
   - Garantías: 26.0%
   - Importaciones: 24.3%
   - Terceros Países: 2.4%
   - Interbancario Exterior: 1.3%
   - Cartas de Crédito: 0.03%
   - Nota: Excluye categoría "otros"

**Formatos:** PNG únicamente (300 DPI) - ✅ Sin PDFs

---

## ✅ PERÚ (6/6 gráficos)

### Gráficos Originales
1. **PER-1**: TF como % de cartera de créditos (mensual)
2. **PER-2**: TF por tipo de banco (barras agrupadas anuales)
3. **PER-3**: TF por tipo de banco (stacked area mensual, 2022+)
4. **PER-4**: TF por Top 5 bancos (barras agrupadas anuales)

### Gráficos con Datos GMD
5. **PER-5**: TF como % de Exportaciones (mensual)
   - Rango: 5.5% - 15.1%
   - Metodología: TF mensual / Exportaciones anuales

6. **PER-6**: TF como % de Comercio Total (X+M) (mensual)
   - Rango: 2.9% - 7.1%
   - Metodología: TF mensual / (Exportaciones + Importaciones) anuales

**Nota:** Perú no tiene desagregación por subcuentas en los datos disponibles

**Formatos:** PNG únicamente (300 DPI) - ✅ Sin PDFs

---

## ✅ MÉXICO (4/4 gráficos)

### Gráficos Originales
1. **MEX-1**: L/C por tipo de banco (barras agrupadas anuales)
2. **MEX-2**: L/C por Top 10 bancos (barras horizontales)

### Gráficos con Datos GMD
3. **MEX-3**: L/C como % de Exportaciones (mensual)
   - Rango: 0.04% - 0.11%
   - Metodología: L/C mensual / Exportaciones anuales
   - Nota: México reporta solo Letters of Credit (cuenta única)

4. **MEX-4**: L/C como % de Comercio Total (X+M) (mensual)
   - Rango: 0.02% - 0.05%
   - Metodología: L/C mensual / (Exportaciones + Importaciones) anuales

**Nota:** México no tiene desagregación (solo reporta una cuenta: L/C 202401504003)

**Formatos:** PNG únicamente (300 DPI) - ✅ Sin PDFs

---

## ✅ BRASIL (8/8 gráficos)

### Gráficos Originales
1. **BRA-1**: TF como % de cartera de créditos (mensual)
2. **BRA-2**: TF por tipo de banco (barras agrupadas anuales)
3. **BRA-3**: TF por Top 10 bancos (barras horizontales)
4. **BRA-4**: Concentración HHI (línea mensual)
5. **BRA-5**: TF por región (barras apiladas anuales)

### Gráficos con Datos GMD
6. **BRA-6**: TF como % de Exportaciones (mensual)
   - Rango: 10.3% - 23.7%
   - Metodología: TF mensual / Exportaciones anuales
   - Corrección aplicada: carteira_ativa_usd / 1e9 (no /1e6)

7. **BRA-7**: TF como % de Comercio Total (X+M) (mensual)
   - Rango: 5.2% - 12.0%
   - Metodología: TF mensual / (Exportaciones + Importaciones) anuales

### Gráfico de Desagregación
8. **BRA-8**: ✨ TF POR SECTOR (stacked bar anual, Top 10 sectores)
   - Manufacturing: 62.9%
   - Wholesale/Retail: 17.0%
   - Other: 5.3%
   - Transport/Logistics: 4.5%
   - Agriculture: 4.3%
   - Mining: 3.1%
   - Construction: 0.4%
   - IT/Communication: 0.3%

**Formatos:** PNG únicamente (300 DPI) - ✅ Sin PDFs

---

## RESUMEN EJECUTIVO

### Estado de Completitud
| País   | Gráficos | Ratio X | Ratio X+M | Desagregación | PDFs |
|--------|----------|---------|-----------|---------------|------|
| Chile  | 9/9 ✅   | ✅      | ✅        | ✅ Categorías | ❌   |
| Perú   | 6/6 ✅   | ✅      | ✅        | N/A           | ❌   |
| México | 4/4 ✅   | ✅      | ✅        | N/A (L/C)     | ❌   |
| Brasil | 8/8 ✅   | ✅      | ✅        | ✅ Sectores   | ❌   |

**TOTAL:** 27/27 gráficos completados (100%)

### Correcciones Aplicadas

#### 1. Chile - Unidades y Cuentas
- **Problema:** Ratios >1000% por error en unidades
- **Solución 1:** Cambio de /1,000 a /1,000,000 en conversión
- **Solución 2:** Eliminación de 12 cuentas de pasivos (double-counting)
- **Solución 3:** Eliminación de cuenta padre 145400200 (duplicación)
- **Resultado:** 887,640% → 22-36% ✅

#### 2. Stock vs Flow - Todos los Países
- **Problema:** Scripts sumaban 12 meses de saldos (stock), no flow
- **Solución:** Cambio a metodología mensual: TF_mensual / Trade_anual
- **Resultado:** Ratios reducidos ~12x, metodología correcta ✅

#### 3. Brasil - Unidades
- **Problema:** Ratios >10,000% por error en denominador
- **Solución:** Cambio de carteira_ativa_usd/1e6 a /1e9
- **Resultado:** 10,277% → 10.3-23.7% ✅

#### 4. PDFs Eliminados
- **Acción:** Eliminación física de 18 PDFs + remoción de ggsave(.pdf) en scripts
- **Chile:** 5 líneas PDF removidas
- **Perú:** 4 líneas PDF removidas
- **Resultado:** Solo PNG (300 DPI) en todos los scripts ✅

### Desagregación Implementada

#### Chile (CHL-9)
- **Tipo:** Stacked area mensual por categoría
- **Periodo:** 2022-2024
- **Categorías:** Exportaciones, Importaciones, Garantías, Terceros Países, Interbancario Exterior, Cartas de Crédito
- **Exclusión:** Categoría "otros" (para mejor visualización)
- **Principal:** Exportaciones (46.1%)

#### Brasil (BRA-8)
- **Tipo:** Stacked bar anual por sector
- **Periodo:** Histórico completo
- **Sectores:** Top 10 (Manufacturing, Wholesale/Retail, Agriculture, etc.)
- **Principal:** Manufacturing (62.9%)

### Metodología Final

**TF como % de Exportaciones:**
```
(TF_stock_mensual / Exportaciones_anuales) × 100
```

**TF como % de Comercio Total:**
```
(TF_stock_mensual / (Exportaciones_anuales + Importaciones_anuales)) × 100
```

**Rationale:**
- TF data = STOCK (saldo del mes), no acumulado
- Trade data = FLOW (total anual)
- Muestra evolución mensual del stock relativo al comercio anual

---

## ARCHIVOS GENERADOS

### Plots (PNG, 300 DPI)
```
plots/
├── chile/
│   ├── chl_01_tf_pct_loans.png
│   ├── chl_02_tf_by_bank_type.png
│   ├── chl_03_concentration.png
│   ├── chl_04_foreign_funding.png
│   ├── chl_05_lc_pct_liabilities.png
│   ├── chl_06_lc_by_bank_type.png
│   ├── chl_07_tf_pct_exports.png
│   ├── chl_08_tf_pct_trade.png
│   └── chl_09_tf_composition.png
├── peru/
│   ├── per_01_tf_pct_loans.png
│   ├── per_02_tf_by_bank_type.png
│   ├── per_03_tf_by_bank_type_monthly.png
│   ├── per_04_tf_by_bank.png
│   ├── per_05_tf_pct_exports.png
│   └── per_06_tf_pct_trade.png
├── mexico/
│   ├── mex_01_lc_by_bank_type.png
│   ├── mex_02_lc_by_bank.png
│   ├── mex_03_lc_pct_exports.png
│   └── mex_04_lc_pct_trade.png
└── brazil/
    ├── bra_01_tf_pct_loans.png
    ├── bra_02_tf_by_bank_type.png
    ├── bra_03_tf_by_bank.png
    ├── bra_04_concentration.png
    ├── bra_05_tf_by_region.png
    ├── bra_06_tf_pct_exports.png
    ├── bra_07_tf_pct_trade.png
    └── bra_08_tf_by_sector.png
```

### Tables (CSV)
```
tables/
├── chile/ (9 archivos)
├── peru/ (6 archivos)
├── mexico/ (4 archivos)
└── brazil/ (8 archivos)
```

**Total:** 27 PNG + 27 CSV

---

## PRÓXIMOS PASOS SUGERIDOS

1. **Comparación Cross-Country:**
   - Gráfico comparativo de ratios TF/Exportaciones (4 países)
   - Gráfico comparativo de ratios TF/Trade (4 países)
   - Análisis de brechas y oportunidades

2. **Análisis de Tendencias:**
   - Tendencias temporales pre/post-COVID
   - Correlación con ciclos económicos
   - Impacto de eventos macroeconómicos

3. **Profundización Sectorial:**
   - Análisis sectorial para Chile (similar a Brasil)
   - Identificación de sectores prioritarios por país

4. **Documento Final:**
   - Integración con análisis FCIB
   - Recomendaciones de política
   - Benchmarking internacional

---

**Última actualización:** 19 de noviembre, 2025  
**Scripts validados:** Chile ✅ | Perú ✅ | México ✅ | Brasil ✅
