# **GUÍA COMPLETA DE VARIABLES Y DATASETS TRADE FINANCE**

## **RESUMEN EJECUTIVO**

Los datasets actuales son **SUFICIENTES** para un análisis robusto de trade finance en América Latina, con 2.7M+ registros cubriendo las 4 principales economías. No se requieren datasets adicionales para trabajar con los datos "full" existentes.

---

## **DETALE DE VARIABLES POR DATASET**

### **🇧🇷 data/brasil_full.csv (838,167 registros)**

#### **Nivel de Granularidad:** 
- **Banco** (institución financiera)
- **Estado** (UF - unidad federativa)
- **Sector CNAE** (clasificación económica)
- **Tamaño de empresa** (porte)
- **Temporal** (mensual desde 2012)

#### **Variables Principales:**

| Variable | Tipo | Descripción | Nivel Trade Finance |
|----------|------|-------------|-------------------|
| `data_base` | Fecha | Período de referencia | ✅ |
| `uf` | Categórica | Estado brasileño (AC, AL, SP, etc.) | ✅ |
| `tcb` | Categórica | Tipo de crédito bancario | ✅ |
| `cliente` | Categórica | Tipo de cliente (PJ=Persona Jurídica) | ✅ |
| `ocupacao` | Categórica | Ocupación/CNAE del cliente | ✅ |
| `cnae_secao` | Categórica | **Sector económico principal CNAE** | ✅ |
| `cnae_subclasse` | Categórica | **Subsector específico CNAE** | ✅ |
| `porte` | Categórica | **Tamaño empresa** (Micro, Pequeno, Médio, Grande) | ✅ |
| `modalidade` | Categórica | **Tipo de crédito** (PJ - Comércio exterior) | ✅ |
| `origem` | Categórica | Origen del recurso | ✅ |
| `indexador` | Categórica | Indexador (Prefixado, Pós-fixado, etc.) | ✅ |
| `numero_de_operacoes` | Numérico | Cantidad de operaciones | ✅ |

#### **Variables de Vencimiento (en miles de BRL):**
| Variable | Descripción |
|----------|-------------|
| `a_vencer_ate_90_dias` | Monto por vencer hasta 90 días |
| `a_vencer_de_91_ate_360_dias` | Monto por vencer 91-360 días |
| `a_vencer_de_361_ate_1080_dias` | Monto por vencer 1-3 años |
| `a_vencer_de_1081_ate_1800_dias` | Monto por vencer 3-5 años |
| `a_vencer_de_1801_ate_5400_dias` | Monto por vencer 5-15 años |
| `a_vencer_acima_de_5400_dias` | Monto por vencer >15 años |

#### **Variables de Cartera:**
| Variable | Descripción |
|----------|-------------|
| `vencido_acima_de_15_dias` | Monto vencido >15 días |
| `carteira_ativa` | Cartera activa total |
| `carteira_inadimplida_arrastada` | Cartera en mora |
| `ativo_problematico` | Activos problemáticos |

**🔍 NOTA:** 838,166 de 838,167 registros son "PJ - Comércio exterior" → **99.999% coverage trade finance**

#### **Sectores Económicos CNAE (Brasil):**

| Sector CNAE | Registros | Descripción |
|-------------|-----------|-------------|
| `PJ - Indústrias de transformação` | 459,656 | Industrias manufactureras |
| `PJ - Comércio; reparação de veículos` | 247,088 | Comercio y reparación de vehículos |
| `PJ - Agricultura, pecuária` | 41,920 | Agricultura y ganadería |
| `PJ - Construção` | 8,235 | Construcción |
| `PJ - Atividades administrativas` | 15,398 | Servicios administrativos |
| `PJ - Transporte, armazenagem` | 24,081 | Transporte y almacenamiento |
| `PJ - Informação e comunicação` | 7,901 | Información y comunicación |
| `PJ - Atividades profissionais` | 11,141 | Servicios profesionales |
| `PJ - Indústrias extrativas` | 10,274 | Industrias extractivas |
| `PJ - Atividades financeiras` | 3,347 | Actividades financieras |

#### **Subsectores Específicos (cnae_subclasse):**
- Comercio atacadista por producto (café, cereales, vehículos, etc.)
- Servicios especializados (consultoría, construcción, tecnología)
- Industrias específicas (textil, alimentaria, metalúrgica)

---

### **🇨🇱 data/chile_full.csv (1,771,738 registros)**

#### **Nivel de Granularidad:**
- **Banco** (institución financiera)
- **Cuenta contable** (código específico)
- **Temporal** (mensual desde 1998-2024)

#### **Variables Principales:**

| Variable | Tipo | Descripción | Nivel Trade Finance |
|----------|------|-------------|-------------------|
| `CodigoInstitucion` | Numérico | Código banco CMF | ✅ |
| `NombreInstitucion` | Texto | Nombre del banco | ✅ |
| `CodigoCuenta` | Numérico | **Código cuenta contable** | ✅ |
| `DescripcionCuenta` | Texto | **Descripción cuenta** | ✅ |
| `Anho` | Numérico | Año | ✅ |
| `Mes` | Numérico | Mes | ✅ |

#### **Variables Monetarias (en miles de CLP):**
| Variable | Descripción |
|----------|-------------|
| `MonedaChilenaNoReajustable` | Monto en pesos chilenos sin reajustar |
| `MonedaExtranjera` | **Monto en moneda extranjera (USD)** |
| `MonedaReajustable` | Monto en moneda reajustable |
| `MonedaTotal` | Monto total |
| `MonedaReajustablePorIPC` | Monto reajustable por IPC |
| `MonedaReajustablePorTipoDeCambio` | Monto reajustable por tipo de cambio |

#### **Códigos de Trade Finance Identificados:**
```r
# Activos - Créditos comercio exterior
"143100104" # Exportaciones chilenas
"143100105" # Importaciones chilenas
"143100106" # Entre terceros países
"145400200" # Créditos de comercio exterior
"831200000" # Créditos contingentes
```

#### **Descripciones de Cuentas Trade Finance (Chile):**

| Tipo | Frecuencia | Descripción |
|------|------------|-------------|
| `Créditos de comercio exterior` | 4,504 | **Principal cuenta TF** |
| `Créditos comercio exterior exportaciones chilenas` | 6,972 | Exportaciones |
| `Créditos comercio exterior importaciones chilenas` | 6,972 | Importaciones |
| `Créditos comercio exterior entre terceros países` | 6,972 | Entre terceros países |
| `Acreditivos negociados a plazo de exportaciones chilenas` | 3,486 | Acreditivos exportación |
| `Acreditivos negociados a plazo de importaciones chilenas` | 3,486 | Acreditivos importación |
| `Otros créditos para exportaciones chilenas` | 4,504 | Otros créditos exportación |
| `Otros créditos para importaciones chilenas` | 3,486 | Otros créditos importación |
| `Financiamientos de comercio exterior` | 5,116 | Financiamiento TF |
| `Financiamientos para exportaciones chilenas` | 1,224 | Financiamiento exportaciones |
| `Financiamientos para importaciones chilenas` | 1,224 | Financiamiento importaciones |

---

### **🇵🇪 data/peru_full.csv (96,496 registros)**

#### **Nivel de Granularidad:**
- **Banco** (institución financiera)
- **Tipo de crédito** (concepto)
- **Tamaño de empresa** (size)
- **Temporal** (mensual desde 2011)

#### **Variables Principales:**

| Variable | Tipo | Descripción | Nivel Trade Finance |
|----------|------|-------------|-------------------|
| `Concepto` | Categórica | **Tipo de crédito** | ✅ |
| `institucion` | Texto | Nombre banco original | ✅ |
| `share` | Numérico | Participación porcentual | ✅ |
| `año` | Numérico | Año | ✅ |
| `mes` | Numérico | Mes | ✅ |
| `my` | Texto | Año-mes (YYYY-MM) | ✅ |
| `total` | Numérico | Monto total cartera (miles PEN) | ✅ |
| `amount` | Numérico | **Monto concepto específico** | ✅ |
| `size` | Categórica | **Tamaño empresa** | ✅ |
| `inst_clean` | Texto | Nombre banco limpio | ✅ |
| `institucion_std` | Texto | **Nombre banco estandarizado** | ✅ |

#### **Tipos de Crédito (Concepto):**
- `Comercio exterior` → **TRADE FINANCE**
- `Préstamos` → Préstamos comerciales
- `Descuentos` → Descuento de documentos
- `Factoring` → Factoraje
- `Tarjetas de crédito` → Tarjetas de crédito
- `Arrendamiento financiero` → Leasing
- `Otros` → Otros créditos

#### **Tamaño de Empresa (size):**
- `Corporate` → Corporativo
- `Large` → Grande
- `Medium` → Mediano  
- `Small` → Pequeño
- `Micro` → Micro

---

## **COMPARATIVO DE COBERTURA**

| País | Registros | Período | Nivel Empresa | Nivel Geográfico | Nivel Sector | Nivel Temporal |
|------|-----------|---------|---------------|------------------|--------------|----------------|
| **Chile** | 1.77M | 1998-2024 (26 años) | ❌ No disponible | ❌ No disponible | ✅ Por tipo de operación | ✅ Mensual |
| **Brasil** | 838K | 2012+ | ✅ 4 niveles | ✅ Por estado | ✅ CNAE (21 sectores) | ✅ Mensual |
| **Perú** | 96K | 2011+ | ✅ 5 niveles | ❌ Nacional | ❌ Por tipo de crédito | ✅ Mensual |
| **México** | 2.2K | 2022-2025 | ❌ No disponible | ❌ Nacional | ❌ Solo cartas de crédito | ✅ Mensual |

## **¿FALTAN DATASETS?**

### **✅ CON DATOS "FULL" ACTUALES ES SUFICIENTE PARA:**

1. **Análisis de concentración bancaria** (CR3, CR5, HHI)
2. **Evolución temporal del trade finance** (tendencias 10+ años)
3. **Comparación por tamaño de empresa** (Brasil y Perú)
4. **Análisis de vencimientos y calidad de cartera** (Brasil)
5. **Relación TF vs comercio exterior** (con datos BACI)
6. **Benchmarking regional** (Chile, Brasil, Perú, México)

### **🔄 DATOS ADICIONALES (OPCIONAL):**

| País | Fuente | Valor Agregado |
|------|--------|----------------|
| Colombia | Superintendencia Financiera | Economía #4 región |
| Argentina | BCRA | Economía #3 región |
| México | CNBV completa | Datos existentes limitados a LC |

### **📊 RECOMENDACIÓN:**
**Trabajar con datasets "full" actuales es ADECUADO** para investigación robusta. Los 4 países cubiertos representan la mayor parte del PBI regional y tienen data de alta calidad (México suma cobertura reciente en cartas de crédito).

---

## **ANÁLISIS DE VARIABLES CLAVE**

### **🎯 Variables para Trade Finance:**

1. **Montos TF:**
   - Brasil: `carteira_ativa` (modalidade = PJ - Comércio exterior)
   - Chile: `MonedaExtranjera` (cuentas TF específicas)
   - Perú: `amount` (concepto = Comercio exterior)

2. **Tamaño Empresa:**
   - Brasil: `porte` (Micro/Pequeno/Médio/Grande)
   - Perú: `size` (Micro/Small/Medium/Large/Corporate)
   - Chile: No disponible (limitación principal)

3. **Sector Económico:**
   - Brasil: `cnae_secao` (21 sectores principales), `cnae_subclasse` (subsectores específicos)
   - Chile: `DescripcionCuenta` (tipo de operación TF: exportación, importación, terceros países)
   - Perú: `Concepto` (tipo de crédito: comercio exterior vs otros)

4. **Calidad Cartera:**
   - Brasil: `vencido_acima_de_15_dias`, `carteira_inadimplida_arrastada`
   - Perú/Chile: No disponible explícitamente

5. **Concentración:**
   - Todos: `institucion_std` / `NombreInstitucion` para análisis CR3/CR5

---

## **ESTADÍSTICA DESCRIPTIVA AMPLIADA POR DATASET**

### **🇧🇷 data/brasil_full.csv**

**Variables complementarias relevantes**
- `sr`: superintendencia regional del BCB (S1–S4) → 37.3% de los registros proviene de S1, 8.5% S2, 11.6% S3, 3.4% S4 y 39.1% sin clasificación (permite mapas macro-regionales y benchmarking regulatorio).
- `numero_de_operacoes`: conteo mensual de créditos TF por banco-estado-sector. Totaliza 3.14M operaciones (mediana 26, P90 73, P99 256), suficiente para métricas de productividad y tasas de aprobación.
- Buckets `a_vencer_*`: perfilan el gap de liquidez. Las sumas agregadas (miles de BRL) son: 0-90d **6.65 tn**, 91-360d **10.5 tn**, 361-1080d **5.19 tn**, 1081-1800d **2.59 tn**, 1801-5400d **1.47 tn**, >5400d **0.01 tn** → confirma que 91-360 días concentra 39% del stock TF brasileño.
- `vencido_acima_de_15_dias`, `carteira_inadimplida_arrastada`, `ativo_problematico`: aunque la mediana es 0, las colas P99 alcanzan entre BRL 1.8-11.7 mn; suman BRL 0.90 tn y permiten construir tasas de NPL con `carteira_ativa`.
- `indexador`: 52.6% Prefixado, 26.8% Pós-fixado, 19.2% Flutuantes, resto <1% → se puede cuantificar riesgo de tasa/benchmark SELIC.
- Conversión monetaria: el BCB publica los saldos en **miles de BRL**. El script `Scripts/brasil_etl.R` lee el crudo en `pre-data/Brasil/brasil_full.csv`, aplica el PTAX mensual oficial (`pre-data/Brasil/brl_usd_monthly_ptax.csv`, serie SGS 10813) y agrega columnas duplicadas en BRL corrientes (`*_brl`) y USD (`*_usd`) para cada variable monetaria, además de campos `X_exports`, `M_imports`, `trade` calculados con BACI.

**Distribución por tamaño de empresa (cartera activa en BRL corrientes)**

| Porte | Registros | % Registros | % Cartera Activa |
|-------|-----------|-------------|------------------|
| PJ - Médio | 448,617 | 53.5% | 16.1% |
| PJ - Grande | 221,235 | 26.4% | 78.1% |
| PJ - Pequeno | 130,553 | 15.6% | 2.2% |
| PJ - Micro | 33,789 | 4.0% | 2.4% |
| PJ - Indisponível | 3,972 | 0.5% | 1.2% |

**Indicadores monetarios (miles de BRL)**
- `Σ carteiras ativas`: BRL 26.6 tn (media 31.8 mn; mediana 2.75 mn; P90 50.1 mn; P99 508.4 mn).
- `Σ vencido_acima_de_15_dias`: BRL 0.20 tn (P99 3.6 mn) → ratio cartera vencida/carteira ativa ≈ 0.8%.
- `Σ carteira_inadimplida_arrastada`: BRL 0.16 tn; `Σ ativo_problematico`: BRL 0.54 tn.
- `numero_de_operacoes` promedio 41 → útil para tasas de aprobación por banco, `sr` o `porte`.

### **🇨🇱 data/chile_full.csv**

**Cobertura y variables adicionales**
- 1,771,737 filas, 30 instituciones y 1,118 códigos contables (`CodigoCuenta`) desde 1998-2024.
- Variables `Moneda*` (CLP corrientes) permiten composición multimoneda:
  - `MonedaTotal`: CLP 3.44e17 (mediana CLP 179; P90 CLP 5.7e8; P99 CLP 1.98e12).
  - `MonedaExtranjera`: CLP 7.48e16 (mediana 0; P90 CLP 6.2e6; P99 CLP 3.10e11) → base para aislar TF en divisas.
  - `MonedaChilenaNoReajustable`: CLP 1.67e17; `MonedaReajustablePorIPC`: CLP 1.02e17; `MonedaReajustablePorTipoDeCambio`: CLP 4.70e14 (altísima escasez de datos distintos de cero, ideal para identificar cuentas con cobertura cambiaria explícita).
- Sólo 1.6% del stock en moneda extranjera menciona “comercio exterior” en `DescripcionCuenta`, por lo que conviene usar el catálogo CMF para identificar todos los códigos TF.

**Principales cuentas TF (MonedaExtranjera, CLP corrientes)**

| Descripción CMF | Suma ME | % del total ME |
|-----------------|---------|----------------|
| Créditos de comercio exterior | CLP 7.25e14 | 0.97% |
| Financiamientos de comercio exterior | CLP 4.29e14 | 0.57% |
| Comercio exterior entre terceros países | CLP 2.55e13 | 0.03% |
| Comercio exterior exportaciones chilenas | CLP 2.25e13 | 0.03% |

*(El código 145400200 concentra la mayor parte del saldo reportado; las líneas de importación aparecen subdeclaradas, por lo que se recomienda contrastar con series CMF agregadas antes de automatizar dashboards.)*

**Concentración bancaria en moneda extranjera**

| Banco | % del stock ME 1998-2024 |
|-------|--------------------------|
| Banco de Crédito e Inversiones | 20.1% |
| Itaú Corpbanca | 7.4% |
| Banco Santander-Chile | 6.5% |
| Scotiabank Chile | 4.6% |
| Banco de Chile | 4.1% |

El resto de 25 bancos acumula 57.3%, proporcionando base para indicadores CR5/HHI por tipo de cuenta.

### **🇵🇪 data/peru_full.csv**

**Variables adicionales**
- `share`: participación (%) de cada banco-concepto-tamaño; media 1.52%, mediana 0.0008%, P99 21.6%, con valores extremos de 100% cuando un banco es único en un segmento → simplifica benchmarking competitivo sin recalcular totals.
- `my`: llave AAAA-MM que asegura ordenamiento temporal y facilita merges con macro series.
- `institucion_std`: 19 bancos estandarizados; los cinco principales concentran 78.6% del monto TF.

**Montos por tipo de crédito (`amount` en miles de PEN)**

| Concepto | Registros | Suma | Promedio |
|----------|-----------|------|----------|
| Préstamos | 13,509 | 18,007,010 | 1,333 |
| Comercio exterior | 13,483 | 2,875,356 | 213 |
| Arrendamiento financiero y Lease-back | 10,528 | 2,209,592 | 210 |
| Otros 1/ | 13,495 | 1,363,408 | 101 |
| Arrendamiento financiero y Lease-back** | 2,962 | 1,086,972 | 367 |
| Descuentos | 13,476 | 857,357 | 64 |
| Factoring | 13,438 | 702,885 | 52 |
| Tarjetas de crédito | 13,482 | 577,245 | 43 |

**Distribución por tamaño de empresa**

| Size | Suma (miles PEN) | % del total |
|------|------------------|-------------|
| Corporate | 10,013,950 | 36.2% |
| Medium | 7,138,860 | 25.8% |
| Large | 7,125,523 | 25.7% |
| Small | 2,853,499 | 10.3% |
| Micro | 547,991 | 2.0% |

En comercio exterior puro, Corporate (47.6%) + Large (41.1%) explican 88.7% del saldo, mientras que Micro+Small apenas 0.4%, evidenciando la brecha de acceso TF para PYMES exportadoras.

**Concentración TF (Concepto = Comercio exterior)**

| Banco (`institucion_std`) | % del monto TF |
|---------------------------|----------------|
| BBVA Perú | 28.7% |
| Banco de Crédito del Perú | 21.2% |
| Scotiabank Perú | 20.0% |
| Interbank | 11.0% |
| BanBif | 7.7% |

El resto de 14 bancos suma 11.4%. El dataset 2010-2024 mensual (96,495 filas) reporta simultáneamente `total` (cartera completa del banco) y `amount` (línea específica), de modo que la penetración TF sobre balance (`amount/total`) viene “lista para usar” para análisis de intensidad financiera.

---

### **🇲🇽 data/mexico_full.csv**

**Cobertura y estructura**
- 2,204 filas mensuales (`year_month` 2022-01 → 2025-08) para 53 bancos reportados por la CNBV.
- Campos principales: `cod_inst` (código CNBV sin ceros a la izquierda), `institucion` estandarizado, `amount_mxn` (pesos corrientes), `tipo_cambio` (fix SAT mensual), `amount_usd` y `amount_usd_thousands`.
- Columnas `X_exports`, `M_imports`, `trade` ya vienen pobladas con comercio BACI anual (exportaciones/importaciones MX vs. mundo → trade = X+M) para permitir ratios `LC/Trade` sin pasos extra.

**Magnitudes agregadas (cartas de crédito, miles de USD)**

| Año | Monto LC (USD) |
|-----|----------------|
| 2022 | 5.46 bn |
| 2023 | 5.92 bn |
| 2024 | 5.84 bn |
| 2025* | 3.64 bn |

*\* Ene-Ago 2025 solamente.*

El stock acumulado 2022-2025 asciende a **USD 20.9 bn** (≈ MXN 392.8 bn). La mediana mensual por banco es 0 (la serie es esparsa), pero P90 alcanza USD 35.1M y P99 USD 150.8M, lo que confirma la alta concentración en pocos jugadores.

**Concentración bancaria (share USD 2022-2025)**

| Banco | % del monto |
|-------|-------------|
| BBVA México | 29.8% |
| Santander | 21.1% |
| HSBC | 12.8% |
| Banorte | 10.7% |
| Monex | 6.7% |

Los cinco bancos concentran **81%** del saldo de cartas de crédito, alineado con los hallazgos previos en CNBV. El ETL `Scripts/mexico_lc_etl.R` toma `pre-data/Mexico/040_R12A_1219_133.csv`, elimina el registro agregado (`cod_inst = 5`), aplica el fix del SAT (`pre-data/Mexico/mxnusd.csv`) y cruza con BACI (`pre-data/country_codes_V202501.csv` + `baci_trade_cty.csv`) para generar `data/mexico_full.csv`, listo para integrarse con los análisis en `latam banks.R` y las visualizaciones en presentations/.

---

## **CONCLUSIONES FINALES**

### **✅ FORTALEZAS:**
- **Cobertura temporal excepcional** (Chile: 26 años)
- **Granularidad por tamaño de empresa** (Brasil, Perú)
- **Datos sectoriales detallados** (Brasil: CNAE, Chile: tipo operación, Perú: tipo crédito)
- **Datos de vencimiento** (Brasil)
- **Consistencia metodológica** entre países

### **⚠️ LIMITACIONES:**
- Chile sin datos por tamaño de empresa
- Perú sin datos geográficos detallados
- Chile sin desagregación sectorial económica (solo por tipo de operación TF)
- Diferentes clasificaciones contables entre países

### **🚀 RECOMENDACIÓN FINAL:**
**LOS DATASETS "FULL" ACTUALES SON COMPLETAMENTE SUFICIENTES** para análisis avanzado de trade finance en América Latina. No se requiere incorporar datasets adicionales para investigación de alta calidad.

La combinación de los 4 países proporciona una base sólida para:
- **Análisis sectorial** (Brasil líder con CNAE)
- **Tesis académicas** con robustez metodológica
- **Análisis de políticas públicas** sectoriales
- **Benchmarking bancario** por sector y tamaño
- **Investigación de mercado** regional

---

## **APÉNDICE: ESTRUCTURA DEL PROYECTO**

### **Scripts Principales:**
- `Scripts/Trade finance data and analysis.R` → Análisis integrado internacional
- `Scripts/latam banks.R` → Análisis detallado por país
- `Scripts/cmf data.R` → Extracción datos Chile
- `Scripts/Hardy data analysis.R` → Datos académicos

### **Datasets Secundarios (mencionados en scripts):**
- `BACI_HS92_V202501/` → Comercio bilateral mundial
- `exim auth.csv` → EXIM Bank US
- `Locational banking statistics.csv` → BIS banking data
- `country_correspondence.csv` → Correspondencia países
- `income levels.xlsx` → Clasificación ingresos World Bank

### **Fuentes de Datos por País:**
- **Brasil**: Banco Central do Brasil
- **Chile**: Comisión para el Mercado Financiero (CMF)
- **Perú**: Superintendencia de Banca, Seguros y AFP (SBS)
- **México**: Comisión Nacional Bancaria y de Valores (CNBV)

---

*Documento creado: 2025-11-11*
*Análisis basado en datasets disponibles en /data/**
