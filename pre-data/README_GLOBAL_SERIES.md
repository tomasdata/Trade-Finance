# Insumos Globales y Académicos (pre-data/)

Este README documenta las bases ubicadas en `pre-data/` que complementan los ETL nacionales para el proyecto de trade finance. En cada caso se resumen las variables principales y las posibles aplicaciones dentro del análisis (presentación, scripts, paneles comparativos).

---

## 1. `exim auth.csv` — Export-Import Bank of the United States

- **Cobertura y tamaño:** 51,414 operaciones; fiscal years 2007‑2025; 152 países destino.
- **Programas:** `Guarantee`, `Insurance`, `Loan`, `Working Capital`.
- **Variables clave:** fechas (Decision/Effective/Expiration), país, programa, montos aprobados/desembolsados, flags de small business / woman owned / minority, NAICS/SIC, tasa de interés, plazo.
- **Magnitudes:** USD 115 Bn (Garantías), 71 Bn (Seguros), 43 Bn (Préstamos), 29 Bn (Working Capital) aprobados 2007‑2025.
- **Preparación:** leer con `encoding='latin1'`, `low_memory=False`, convertir montos removiendo comas y crear `year_month` desde `Decision Date`.
- **Aplicaciones en el proyecto:**
  - **Presentación (`Trade_Finance.tex`):** capítulo “Oferta oficial” → graficar EXIM por país/programa vs. saldos TF domésticos para evidenciar la brecha.
  - **`Scripts/Trade finance data and analysis.R`:** sumar EXIM/Comercio (BACI) por país, integrar mapas y series históricas.
  - **`latam banks.R`:** usar EXIM como variable externa (¿mayor EXIM → mayor `carteira_ativa`?). Se puede fusionar por país y año/mes.

---

## 2. Bases Hardy & Saffie (académicas)

### `BryanHardy_JMP_FirmData_forMP.dta`
- **Observaciones:** 2,687 firmas chilenas (ticker, `StartDate`, `PublicDate`).
- **Variables:** 
  - Identificación y sector (`Name`, `Sector`, `Branch`, `Activity`, `SectorENG`)
  - Información contable: `Tot_Assets`, `Long_Assets`, `Short_Assets`, etc.
  - Fechas de inicio y apertura en bolsa (permite análisis histórico de acceso a capital).
- **Cobertura temporal:** 1991‑2015 (según el paper). Series anuales.
- **Uso:** analizar cómo shocks de TF impactan los balances corporativos; se puede cruzar con el ETL Chile (`data/chile_full.csv`) agregando las cuentas TF por banco y luego asignando a firmas según su banco principal (cuando se cuente con la llave).

### `BryanHardy_JMP_LoanData_forMP.dta`
- **Observaciones:** base de préstamos bancarios (loan-level) asociada al mismo estudio.
- **Variables típicas:** ID del préstamo, fecha de originación, monto, banco originador, moneda, estado (on/off balance).
- **Uso:** permite estudiar la transmisión de shocks de financiamiento bancario a nivel de crédito individual, complemento a `latam banks.R` si se quiere un zoom micro de Chile.

### `HardySaffie_CCT_Data.dta`
- **Observaciones:** ~4,700 (panel). 
- **Variables:**
  - `ticker`, `date`, `quarter`, `year`, `firm_id`
  - Indicadores macro y de firma: `US_Tbill_1yr_avg`, `firm_size`, `log_PPE`, `lag1_extsales_share`, `exporter`, etc.
  - Derivadas de crecimiento (`d_log_*`) para capital fijo, empleo, tipo de cambio.
- **Uso:** soporta análisis econométrico de shock de crédito/comercio en empresas chilenas (Hardy & Saffie). Puede cruzarse con los saldos CMF (nuestro ETL Chile) para extender resultados.

> Ambas bases se leen con `pd.read_stata()` (o `haven::read_dta()` en R). Conviene convertir ticker/fecha al mismo formato que los datasets bancarios antes de hacer merges.
>
> **Scripts relacionados:** `Scripts/Hardy data analysis.R` ya carga `FirmData`, `LoanData` y `CCT_Data`; solo hace falta actualizar `folder/data` para apuntar a este repo y comenzar a generar los gráficos/tablas del paper usando los ETL como inputs adicionales.

---

## 3. `Consolidated banking statistics BIS.csv`

- **Fuente:** BIS Consolidated Banking Statistics (formato CSV).
- **Columnas típicas:** `Reporting country`, `Counterparty country`, `Instrument`, `Exposure (claims/liabilities)`, `Currency`, `Quarter`. Algunas versiones incluyen desglose por tipo de banco y vencimiento.
- **Uso:** 
  - Medir la dependencia de cada país de bancos internacionales y compararla con la profundidad del TF local (`carteira_ativa_usd`, `amount_usd`, `MonedaExtranjera_num`).
  - Incorporar en `Scripts/Trade finance data and analysis.R` una sección de “exposición internacional vs. TF doméstico”.
  - Estimar indicadores de riesgo sistémico para la presentación (porcentaje de crédito transfronterizo respecto al TF doméstico).

---

## 4. `WUI_Data.csv` — World Uncertainty Index

- **Formato:** CSV semicolon (`;`). Columnas: `year` + 142 países (ISO3). Filas trimestrales `YYYYqQ`.
- **Cobertura:** 2000q1 – 2025q3 (última descarga).
- **Uso:** proxy de incertidumbre macro. Para integrarlo:
  1. Convertir a formato largo (`year-quarter`, `ISO3`, `WUI`) y reemplazar comas por puntos.
  2. Mapear ISO3 a BRA/CHL/PER/MEX y promediar los saldos TF mensuales a trimestre (o aplicar forward-fill).
  3. **Aplicaciones:** `latam banks.R` (regresiones share TF o shocks) y `Trade_Finance.tex` (mostrar episodios de incertidumbre vs. contracción TF).

---

## 5. Otros insumos globales

- `country_correspondence.csv` y `income levels.xlsx`: tablas auxiliares para asignar región/income level a cada país (se usan en `Scripts/Trade finance data and analysis.R`).
- `baci_trade_cty.csv` + `country_codes_V202501.csv`: comercio bilateral (CEPII) ya integrado en los ETL para `X_exports`, `M_imports`, `trade`.

---

### Integración con los scripts existentes

- **`Scripts/Trade finance data and analysis.R`**: ya usa `country_correspondence`/`income levels`. Se puede extender para:
  - Leer `exim auth.csv` (agrupando por país/programa).
  - Incluir `Consolidated banking statistics BIS` y `WUI_Data` como drivers macro.
- **`Scripts/latam banks.R`**: puede incorporar WUI (por país) o BIS exposure para explicar variaciones de share TF.
- **`Scripts/Hardy data analysis.R`**: al apuntar a `pre-data/`, queda listo para construir gráficos académicos con las tres bases de Hardy y cruzarlas con los ETL de Chile.
- **Presentación (`Trade_Finance.tex`)**: usar estos insumos para enriquecer secciones de oferta global (EXIM), impacto micro (Hardy), riesgo sistémico (BIS) e incertidumbre (WUI).

> Recomendación: crear ETL específicos (ej. `exim_etl.R`, `wui_etl.R`) que limpien estas series y escriban versiones listas en `data/`, siguiendo el patrón de los países. Mantener este README actualizado cuando se agreguen nuevas fuentes.
