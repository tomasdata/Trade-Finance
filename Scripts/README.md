# 📁 Carpeta Scripts - Trade Finance Project

## 🎯 Objetivo General del Proyecto

Este proyecto de **Trade Finance** analiza sistemáticamente los flujos de financiamiento comercial en América Latina, integrando múltiples fuentes de datos internacionales y locales para comprender la dinámica del financiamiento del comercio exterior en la región.

---

## 📋 Descripción Detallada de Scripts

### 1. 🌍 **Trade finance data and analysis.R** (2,087 líneas)
**Script principal y más completo del proyecto**

#### 📊 **Fuentes de Datos Integradas:**
- **BACI CEPII**: Datos bilaterales de comercio mundial (exportaciones/importaciones)
- **EXIM Bank US**: Financiamiento de exportaciones estadounidenses
- **BIS Statistics**: Estadísticas bancarias internacionales
- **FFIEC 009**: Reporte de bancos estadounidenses sobre trade finance
- **World Bank**: Datos de clasificación de países por ingresos

#### 🔍 **Análisis Realizados:**

**A. Análisis de Comercio Internacional:**
- Flujos comerciales bilaterales LATAM vs mundo
- Top países exportadores/importadores
- Análisis de concentración de mercados
- Evolución temporal del comercio regional

**B. Financiamiento EXIM Bank:**
- Distribución por programas (Guarantee, Insurance, Loan, Working Capital)
- Análisis geográfico del financiamiento
- Relación EXIM vs importaciones desde EE.UU.
- Identificación de top lenders/borrowers

**C. Estadísticas BIS (Bank for International Settlements):**
- Análisis de claims/liabilities bancarias
- Mapeo geográfico de exposiciones
- Relación claims/comercio (X+M)
- Tendencias temporales por país

**D. FFIEC 009 (Trade Finance de Bancos US):**
- Composición del trade finance por región
- Análisis de concentración
- Series temporales por subregión
- Integración con datos de comercio

#### 📈 **Visualizaciones Generadas:**
- Mapas mundiales con datos georreferenciados
- Series temporales múltiples
- Gráficos de concentración (CR3, CR5, HHI)
- Análisis de correlación trade finance vs comercio

---

### 2. 🏦 **latam banks.R** (907 líneas)
**Análisis específico por país de bancos latinoamericanos**

#### 🇵🇪 **Perú (SBS):**
- **Fuente**: Superintendencia de Banca, Seguros y AFP
- **Variables**: Créditos por tamaño de empresa (Corporate, Large, Medium, Small, Micro)
- **Tipo de crédito**: Comercio exterior, préstamos, descuentos, factoring, tarjetas
- **Análisis**: 
  - Concentración bancaria (CR3, CR5)
  - Participación relativa vs comercio total
  - Evolución por tamaño de empresa
  - Top bancos por participación

#### 🇧🇷 **Brasil:**
- **Fuente**: Datos bancarios brasileños
- **Clasificación**: CNAE (21 sectores económicos detallados)
- **Variables**: Modalidad PJ - Comércio exterior
- **Análisis sectorial**: Mayor granularidad sectorial de la región

#### 🇲🇽 **México:**
- **Fuente**: CNBV (Comisión Nacional Bancaria y de Valores)
- **Producto específico**: Cartas de crédito (concepto 202401504003)
- **Análisis**: 
  - Concentración de mercado (Top 5 share, HHI)
  - Series temporales por banco
  - Relación vs comercio total

#### 🇨🇱 **Chile:**
- **Fuente**: CMF (Comisión para el Mercado Financiero)
- **Variables**: 24 códigos de cuentas específicas de trade finance
- **Cobertura**: 1998-2024 (serie más larga del proyecto)
- **Detalle**: Nivel de cuenta individual bancaria

---

### 3. 🇨🇱 **cmf data.R** (238 líneas) ⭐ **SCRIPT CLAVE PARA API**
**Script de extracción automatizada de datos de la CMF chilena**

#### 🔌 **Capacidades API Identificadas:**

**A. Configuración API:**
```r
BASE <- "https://api.cmfchile.cl/api-sbifv3/recursos_api"
KEY   <- "ec66dcd075d873e1134d1febc068847cce99d327"
```

**B. Endpoints Disponibles:**
- **Balances**: `/balances/{año}/{mes}/instituciones`
- **Instituciones**: `/balances/{año}/instituciones/{codigo}`
- **Períodos históricos**: Soporte para periodos1 (pre-2007) y periodo2 (2008)

**C. Funcionalidades Implementadas:**

🚀 **Función `get_txt()`**: 
- Manejo robusto de errores HTTP
- Backoff exponencial con jitter
- Reintentos automáticos (hasta 5 intentos)

🏛️ **Función `get_instituciones()`**:
- Listado de instituciones financieras
- Detección automática de columnas de código/nombre
- Soporte para diferentes formatos históricos

📊 **Función `get_balances_inst_year()`**:
- Extracción de balances por banco-año
- Manejo de diferentes estructuras temporales
- Normalización de datos

🔄 **Función `get_balances_years_common()`**:
- Descarga automatizada para múltiples años
- Tres modos de selección de instituciones:
  - `intersect`: bancos presentes en TODOS los años
  - `union`: todos los bancos en cualquier año  
  - `atleast`: bancos en al menos k años (default 80%)

#### 📈 **Ejecución Actual:**
```r
lst <- get_balances_years_common(years = 1998:2024, mode = "union", pause_between = 0.15)
panel <- bind_rows(lst)
fwrite(panel, paste0(data,"cmf_data.csv"))
```

#### 🔥 **Descubrimientos Clave de la API:**

**✅ Datos de Trade Finance Identificados:**
- **1,104 cuentas** relacionadas con trade finance disponibles
- **168 cuentas específicas** de créditos y operaciones TF
- **24 códigos clave** identificados para análisis:

```
# Financiamientos de comercio exterior
244250100, 244250101, 244250102  # Con bancos del país
244500100, 244500101, 244500102  # Con bancos del exterior

# Créditos interbancarios TF
143100104, 143100105, 143100106  # Bancos país
143200104, 143200105, 143200106  # Bancos exterior

# Cartera comercial TF
145400200  # Créditos de comercio exterior
145400201, 145400202  # Exportaciones chilenas
145400203, 145400204  # Importaciones chilenas
145400205, 145400290  # Terceros países

# Créditos contingentes
831200000
```

**✅ Estructura de Datos por Cuenta:**
- `CodigoCuenta`: Identificador único
- `DescripcionCuenta`: Nombre detallado
- `MonedaChilenaNoReajustable`: Montos en CLP
- `MonedaExtranjera`: Montos en USD
- `MonedaTotal`: Total consolidado

**✅ Datos Reales Encontrados (Ejemplo Banco de Chile 2024):**
- Créditos comercio exterior: USD $1.9-2.0 billones
- Financiamientos exterior: USD $0.9-1.1 billones
- Datos disponibles en CLP y USD simultáneamente

**✅ Endpoint Adicional Descubierto:**
- **Tipo de cambio**: `/dolar/{año}/{mes}` - CLP/USD
- Datos históricos disponibles para conversión automática

---

### 3.1 🚀 **cmf_data_improved.R** (254 líneas) ⭐ **NUEVO SCRIPT MEJORADO**
**Versión optimizada para Trade Finance con conversión a USD**

#### 🆕 **Mejoras Implementadas:**

**A. Extracción Enfocada:**
- Filtrado específico de cuentas TF (24 códigos clave)
- Procesamiento optimizado para años recientes (2020-2024)
- Identificación automática de instituciones comunes

**B. Conversión Automática a USD:**
```r
# Obtener tipo de cambio CLP/USD para cada período
get_exchange_rate(year, month)

# Conversión automática de montos
MonedaChilenaNoReajustable_USD = MonedaChilenaNoReajustable / rate
```

**C. Archivos de Salida Mejorados:**
- `cmf_tradefinance_enhanced.csv`: Datos completos con conversión USD
- `cmf_resumen_cuentas.csv`: Resumen por tipo de cuenta
- `cmf_resumen_bancos.csv`: Resumen por institución

#### 📊 **Potencial de Expansión API:**

**✅ Aplicaciones Inmediatas:**
1. **Actualización automática mensual**: Script puede ejecutarse periódicamente
2. **Monitoreo en tiempo real**: Datos disponibles con 1-2 meses de desfase
3. **Análisis de concentración**: Datos por banco y tipo de operación
4. **Series temporales**: 26 años de datos históricos disponibles

**✅ Integración Regional:**
- Modelo replicable para SBS (Perú), CNBV (México), BACEN (Brasil)
- Estandarización de cuentas TF entre reguladores
- Análisis comparativo regional

---

### 3.2 🔄 **cmf_chile_consistent.R** (284 líneas) ⭐ **SCRIPT CONSISTENTE**
**Generador de datos Chile con estructura LATAM estandarizada**

#### 🎯 **Objetivo Principal:**
- Crear datos de Chile consistentes con Perú y Brasil
- Misma estructura: `Concepto, institucion, share, year, month, my, total, amount, size, inst_clean, institucion_std`
- Enfoque específico en trade finance categorizado

#### 📊 **Categorías Trade Finance Implementadas:**
```r
"comercio_exterior" = c("145400200", "813200600", "814200600", "821200600")
"exportaciones" = c("145400201", "145400202", "143100104", "143200104", "244250101", "244500101")
"importaciones" = c("145400203", "145400204", "143100105", "143200105", "244250102", "244500102")
"financiamiento_exterior" = c("244250100", "244500100", "244500000")
"contingentes" = c("831200000")
```

#### 🔄 **Mapeo de Tamaños de Empresa:**
- **comercio_exterior** → Corporate
- **exportaciones** → Large
- **importaciones** → Medium
- **financiamiento_exterior** → Small
- **otros_tf** → Micro

#### 📈 **Características de Salida:**
- **Período**: 2015-2024 (10 años recientes)
- **Moneda**: USD con conversión automática CLP/USD
- **Formato**: Igual a `peru_full.csv` y `brasil_full.csv`
- **Archivo**: `chile_full.csv` (reemplaza al anterior)

#### ✅ **Ventajas sobre Datos Anteriores:**
- **Consistencia regional**: Estructura unificada LATAM
- **Categorización TF**: 5 categorías específicas vs datos brutos
- **Datos limpios**: Formato numérico estándar, sin caracteres chilenos
- **Shares calculados**: Participación por concepto y período
- **Tamaño empresa**: Clasificación consistente con otros países

---

### 4. 📊 **Hardy data analysis.R** (83 líneas)
**Datos académicos para investigación de trade finance**

#### 📚 **Fuentes de Datos:**
- **BryanHardy_JMP_FirmData_forMP.dta**: Datos a nivel de firma
- **BryanHardy_JMP_LoanData_forMP.dta**: Datos a nivel de préstamo
- **HardySaffie_CCT_Data.dta**: Datos de programas de transferencia condicionada

#### 🎯 **Uso Potencial:**
- Validación de resultados con datos académicos
- Análisis microeconómico del trade finance
- Investigación de impacto de programas sociales

---

## 🔄 **Flujo de Trabajo Integrado**

### 1. **Procesamiento de Datos**
```
Datos Internacionales (BACI, EXIM, BIS) 
    ↓
Datos Regulatorios Locales (CMF, SBS, CNBV)
    ↓
Datos Académicos (Hardy)
    ↓
Integración y Análisis
```

### 2. **Análisis por Nivel**
- **Macroeconómico**: Flujos comerciales internacionales
- **Sectorial**: Análisis por industria/CNAE
- **Bancario**: Concentración y participación de mercado
- **Firm-level**: Datos de empresas individuales

---

## 🎯 **TODO LIST - Mejoras Identificadas Basadas en API CMF**

### 🚀 **Mejoras Inmediatas (High Priority)**

#### API CMF Chile - Descubrimientos Específicos:
- [x] **Identificar 1,104 cuentas de trade finance disponibles**
- [x] **Extraer 24 códigos clave de TF específicos**
- [x] **Implementar conversión automática CLP/USD**
- [x] **Crear script consistente con estructura LATAM (cmf_chile_consistent.R)**
- [x] **Categorizar cuentas TF en 5 conceptos principales**
- [x] **Generar datos compatibles con peru_full.csv y brasil_full.csv**
- [ ] **Implementar actualización automática mensual con datos TF**
- [ ] **Expandir análisis a todas las instituciones comunes**

#### Integración de Datos Regionales:
- [x] **Estandarizar estructura Chile con Perú y Brasil**
- [x] **Crear mapeo de categorías TF consistente**
- [x] **Implementar clasificación de tamaño de empresa unificada**
- [ ] **Validar correspondencia de cuentas TF entre países**
- [ ] **Implementar replicación para SBS (Perú) y CNBV (México)**

### 📊 **Análisis Expandidos (Medium Priority)**

#### Cobertura Geográfica:
- [ ] **Incorporar Argentina (BCRA)**
- [ ] **Agregar Colombia (Superfinanciera)**
- [ ] **Expandir a Centroamérica**

#### Análisis Avanzados:
- [ ] **Modelos de concentración HHI por país**
- [ ] **Análisis de correlación con variables macroeconómicas**
- [ ] **Estudios de causalidad trade finance vs crecimiento**

### 🔧 **Mejoras Técnicas (Low Priority)**

#### Optimización:
- [ ] **Paralelizar descargas de API**
- [ ] **Implementar caching de datos**
- [ ] **Crear sistema de logging de errores**

#### Visualización:
- [ ] **Dashboard interactivo con Shiny**
- [ ] **Mapas dinámicos con plotly**
- [ ] **Reportes automáticos en PDF/HTML**

---

## 💡 **Recomendaciones Estratégicas**

### 1. **Aprovechamiento API CMF**
El script `cmf data.R` es una **mina de oro** para datos actualizados. Recomendamos:
- Implementar ejecución programada (mensual)
- Expandir a otras cuentas regulatorias
- Crear alertas para cambios significativos

### 2. **Replicabilidad Regional**
El modelo chileno puede replicarse en:
- **Perú**: API SBS (si existe)
- **México**: API CNBV (disponible)
- **Brasil**: API BACEN (disponible)

### 3. **Integración con Fuentes Internacionales**
Los datos locales pueden enriquecerse con:
- **IMF**: Datos de balanza de pagos
- **World Bank**: Indicadores de desarrollo
- **OECD**: Estadísticas de comercio internacional

---

## 📞 **Contacto y Soporte**

Para dudas sobre los scripts o sugerencias de mejora:
- **API CMF**: Documentación disponible en https://api.cmfchile.cl
- **Fuentes de datos**: Verificar disponibilidad y actualización periódica
- **Integración**: Considerar diferencias en clasificaciones industriales entre países

---

*Última actualización: Noviembre 2024*
*Versión: 1.0*