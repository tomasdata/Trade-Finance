# RESUMEN DE CLASIFICACIÓN DE BANCOS POR PAÍS
## Country Trade Finance Analysis

**Fecha:** Noviembre 2025  
**Script base:** `01_master_processing.R`

---

## MÉXICO

### Criterios de Clasificación
Los bancos mexicanos se clasifican según los siguientes criterios basados en nombres de instituciones:

#### **Bancos Extranjeros (10 bancos)**
```r
mexico_foreign_banks <- c(
  "BANK OF AMERICA", "JP MORGAN", "MUFG", "CITI MEXICO", "MIZUHO",
  "ICBC", "BANK OF CHINA", "BARCLAYS", "SHINHAN", "SABADELL"
)
```

#### **Bancos de Desarrollo (6 bancos)**
```r
mexico_development_banks <- c(
  "BANCOMEXT", "BANOBRAS", "BANJERCITO", "NAFIN", "BABIEN", "HIPOTECARIA FED"
)
```

#### **Grandes Bancos Nacionales (9 bancos)**
```r
mexico_large_domestic <- c(
  "BANAMEX", "BBVA MEXICO", "SANTANDER", "BANORTE", "SCOTIABANK",
  "INBURSA", "BANREGIO", "BAJIO", "HSBC"  # HSBC es extranjero pero jugador doméstico mayor
)
```

### Resultados de Clasificación
- **Total de bancos únicos:** 53 bancos
- **Bancos Extranjeros:** 10 bancos
- **Bancos de Desarrollo:** 6 bancos  
- **Grandes Bancos Nacionales:** 9 bancos
- **Otros Bancos Nacionales:** 28 bancos (resto)

### Observaciones
- HSBC está clasificado como "Large Domestic" a pesar de ser extranjero, debido a su rol como jugador importante en el mercado doméstico mexicano
- Los datos cubren el período 2022-2025 con 2,204 observaciones mensuales

---

## PERÚ

### Criterios de Clasificación

#### **Bancos Extranjeros (6 bancos)**
```r
peru_foreign_banks <- c(
  "CITIBANK", "DEUTSCHE BANK", "BANK OF CHINA", "ICBC",
  "SCOTIABANK", "BBVA"  # Extranjeros a pesar de nombres locales
)
```

#### **Bancos Estatales (3 bancos)**
```r
peru_state_banks <- c(
  "BANCO DE LA NACION", "AGROBANCO", "BANCO CENTRAL"
)
```

#### **Grandes Bancos Nacionales (5 bancos)**
```r
peru_large_domestic <- c(
  "CREDITO", "BCP", "INTERBANK", "BANBIF", "CONTINENTAL"
)
```

#### **Bancos Consumo/Retail (3 bancos)**
```r
# Detectados por: "MIBANCO|FALABELLA|RIPLEY"
```

### Resultados de Clasificación
- **Total de bancos únicos:** 17 bancos
- **Bancos Extranjeros:** 6 bancos
- **Bancos Estatales:** 3 bancos
- **Grandes Bancos Nacionales:** 5 bancos
- **Bancos Consumo/Retail:** 3 bancos
- **Otros Bancos Nacionales:** 0 bancos (todos clasificados)

### Categorías de Tamaño de Prestatario
- **Corporate:** Empresas corporativas
- **Large:** Grandes empresas
- **Medium:** Medianas empresas  
- **Small:** Pequeñas empresas
- **Micro:** Microempresas

### Observaciones
- BBVA y SCOTIABANK están clasificados como extranjeros a pesar de tener nombres locales
- Los datos cubren comercio exterior con múltiples categorías de tamaño de prestatario

---

## CHILE

### Criterios de Clasificación

#### **Bancos Extranjeros (5 bancos)**
```r
chile_foreign_banks <- c(
  "BRASIL", "CHINA", "SECURITY", "PARIS", "TOKYO"
)
```

#### **Bancos Estatales (1 banco)**
```r
chile_state_banks <- c(
  "ESTADO"
)
```

#### **Grandes Bancos Nacionales (6 bancos)**
```r
chile_large_domestic <- c(
  "CHILE", "CREDITO", "BCI", "SANTANDER", "ITAU", "SCOTIABANK"
)
```

### Resultados de Clasificación
- **Total de bancos únicos:** 12 bancos (período CMF 2022-2024)
- **Bancos Extranjeros:** 5 bancos
- **Bancos Estatales:** 1 banco
- **Grandes Bancos Nacionales:** 6 bancos
- **Otros Bancos Nacionales:** 0 bancos (todos clasificados)

### Características Especiales
- **Cambio contable 2022:** Transición SBIF → CMF/IFRS 9
- **Códigos antiguos (2015-2021):** Sistema SBIF (7-9 dígitos)
- **Códigos nuevos (2022-2024):** Sistema CMF (9 dígitos)
- **0% solapamiento** entre códigos antiguos y nuevos

### Tipos de Cuentas Trade Finance
- Export Financing
- Import Financing  
- Third-Party Trade
- Letters of Credit
- Foreign Funding
- Guarantees
- Interbank Foreign
- Trade Finance General

### Observaciones
- Datos agregados para 2022-2024 sin identificación individual de bancos en algunos registros
- Se utilizan tasas de cambio históricas CLP/USD por año

---

## BRASIL

### **NO HAY CLASIFICACIÓN POR BANCOS**

#### **Limitación Fundamental**
Los datos de Brasil están **agregados por el Banco Central de Brasil (BCB)** y **no incluyen identificación de bancos individuales**.

#### **Nivel de Agregación Disponible**
- **Por Estado (UF):** 27 unidades federativas
- **Por Región:** Southeast, South, Northeast, Center-West, North
- **Por Sector (CNAE):** Manufacturing, Wholesale/Retail, Agriculture, etc.
- **Por Tamaño de Prestatario:** Micro, Pequeño, Médio, Grande
- **Por Tipo de Tasa:** Pre-fixed, Post-fixed, Floating, Price Index

#### **Alternativas de Análisis**
1. **Concentración Regional:** Top 5 estados por participación
2. **Distribución por Tamaño:** Participación por tamaño de prestatario
3. **Análisis Sectorial:** Participación por sector económico
4. **Comparación Internacional:** Tamaño vs Perú

#### **Resultados de Clasificación**
- **Bancos Identificados:** **0** (datos agregados)
- **Estados con datos:** 27 estados
- **Regiones:** 5 regiones geográficas
- **Sectores:** 11 sectores principales
- **Tamaños de Prestatario:** 4 categorías

### Observaciones
- **Imposible realizar análisis de concentración bancaria**
- **No se pueden identificar bancos extranjeros vs nacionales**
- **El análisis se enfoca en dimensiones geográficas y de prestatario**

---

## RESUMEN COMPARATIVO

| País | Total Bancos | Extranjeros | Estatales/Desarrollo | Grandes Nacionales | Otros Nacionales | ¿Datos por Banco? |
|------|--------------|-------------|---------------------|-------------------|------------------|-------------------|
| **México** | 53 | 10 | 6 | 9 | 28 | ✅ Sí |
| **Perú** | 17 | 6 | 3 | 5 | 3 | ✅ Sí |
| **Chile** | 12 | 5 | 1 | 6 | 0 | ✅ Sí |
| **Brasil** | 0 | 0 | 0 | 0 | 0 | ❌ **No** |

## NOTAS METODOLÓGICAS

1. **Detección por Patrones:** Se utiliza `str_detect()` con mayúsculas para identificar bancos
2. **Clasificación Jerárquica:** Prioridad: Extranjeros → Estatales → Grandes → Otros
3. **Casos Especiales:** HSBC (México), BBVA/SCOTIABANK (Perú) tratados según contexto local
4. **Datos Faltantes:** Algunos registros pueden no incluir nombre de institución (Chile 2022-2024)
5. **Agregación Brasil:** Limitación estructural de los datos del BCB

---

**Documentación generada desde:** `country_analysis/scripts/01_master_processing.R`  
**Actualización:** Noviembre 2025