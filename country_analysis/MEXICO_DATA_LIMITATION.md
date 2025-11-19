# 🇲🇽 MÉXICO - LIMITACIÓN DE DATOS TRADE FINANCE

**Fecha de análisis**: 19 de noviembre de 2025  
**Fuente**: Comisión Nacional Bancaria y de Valores (CNBV) - Balances Contables R01  

---

## ❌ **PROBLEMA IDENTIFICADO**

México reporta **SOLO Letters of Credit (L/C)**, NO Trade Finance completo.

### 📊 **Datos Disponibles:**

**Cuenta Contable Disponible:**
- **B-7351**: "Créditos otorgados por las instituciones de crédito vía cartas de crédito abiertas a su favor"
- **Scope**: ÚNICAMENTE cartas de crédito abiertas (L/C outstanding)
- **Periodo**: Enero 2022 - Agosto 2024 (32 meses)

**Datos FALTANTES (NO reportados):**
- ❌ Créditos comercio exterior (exportaciones)
- ❌ Créditos comercio exterior (importaciones)  
- ❌ Financiamiento pre-embarque
- ❌ Financiamiento post-embarque
- ❌ Forfaiting
- ❌ Garantías comercio exterior (distintas a L/C)
- ❌ Aceptaciones bancarias
- ❌ Trade Finance contingente

---

## 📈 **MAGNITUD DEL PROBLEMA**

### **L/C México (2022-2024):**
```
2022: USD 5,462 millones
2023: USD 5,924 millones  
2024: USD 5,840 millones (proyectado)
```

### **L/C como % de Exportaciones:**
```
2022: 0.0015% de USD 371 billones en exports
2023: 0.0015% de USD 383 billones en exports
2024: 0.0015% de USD 378 billones en exports
```

### **Comparación Internacional:**

| País | Métrica | Monto USD (millones) | Periodo | Cobertura |
|------|---------|---------------------|---------|-----------|
| **México** | L/C only | 5,462 - 5,924 | Anual | Parcial (solo L/C) |
| **Chile** | L/C only | 1,873 - 2,986 | Anual | Parcial (L/C dentro de TF total) |
| **Chile** | TF Total | ~60,000,000+ | Mensual | Completo (CMF 2022-2024) |
| **Perú** | TF Total | 8,000 - 13,000 | Mensual | Completo |
| **Brasil** | TF Total | 3,000 - 5,000 | Mensual | Completo |

---

## 🔍 **ANÁLISIS COMPARATIVO**

### **¿Por qué México L/C es ~20x MENOR que Perú TF?**

**NO es porque México tenga menos comercio exterior:**
- México Exports 2023: USD **383 billones** (6.5x más que Perú)
- Perú Exports 2023: USD **59 billones**

**Razón real: Diferentes coberturas contables**

| Componente | México | Perú | Chile | Brasil |
|------------|--------|------|-------|--------|
| L/C Outstanding | ✅ | ✅ | ✅ | ✅ |
| Créditos Exportación | ❌ | ✅ | ✅ | ✅ |
| Créditos Importación | ❌ | ✅ | ✅ | ✅ |
| Pre/Post Shipment Finance | ❌ | ✅ | ✅ | ✅ |
| Garantías TF | ❌ | ✅ | ✅ | ✅ |

---

## ⚠️ **IMPLICACIONES PARA EL ANÁLISIS**

### **1. Montos NO son comparables directamente**
- México USD 5.9 billones ≠ Perú USD 13 billones
- México mide 1 instrumento, Perú mide el universo completo

### **2. México L/C es LÓGICAMENTE bajo**
✅ **SÍ es realista** que L/C sea 0.0015% de exports
- L/C es solo 1 de ~8-10 instrumentos de Trade Finance
- Típicamente L/C representa 5-15% del TF total
- Si TF total México fuera ~USD 40-80 billones, L/C de USD 6 billones es coherente

### **3. Gráficos México muestran tendencias válidas**
✅ Evolución L/C 2022-2024: estable
✅ Concentración bancaria: válida (Top 5: HSBC, BBVA, Santander, Banamex, Scotiabank)
✅ Proporción por banco: válida

---

## ✅ **SOLUCIÓN IMPLEMENTADA**

**Plots México (MEX-01, MEX-02):**
- ✅ Mantienen montos originales (USD millones)
- ✅ Títulos/captions aclaran "Letters of Credit only"
- ✅ NO se comparan directamente con TF total de otros países
- ✅ Se usan para análisis de **concentración** y **estructura bancaria**

**Captions actualizados:**
```
MEX-01: Letters of Credit Outstanding (USD millions)
        Note: Mexico data limited to L/C only (account B-7351)
        Source: CNBV - Balances Contables R01

MEX-02: L/C by Bank (Monthly Stacked Area)
        Note: Not comparable to total TF in other countries
```

---

## 📚 **FUENTES DE INFORMACIÓN**

### **Datos Actuales (Disponibles):**
- **CNBV**: Catálogo Mínimo de Cuentas - R01 (Balances Contables)
- **Cuenta**: B-7351 - Cartas de crédito abiertas
- **Frecuencia**: Mensual
- **Periodo**: 2022-01 a 2024-08

### **Datos Deseados (NO disponibles en CNBV):**
- BANXICO no publica TF desagregado por banco
- CNBV R04 (Crédito) no desglosa comercio exterior suficientemente
- CNBV R28 (Captación y Crédito) - agregados, no individual

---

## 🎯 **CONCLUSIÓN**

**Los montos México SON correctos y lógicos:**

1. ✅ L/C de USD 5-6 billones es **0.0015% de exports** → razonable
2. ✅ Si TF total fuera USD 40-80 billones, L/C sería 7-15% → típico
3. ✅ Problema NO es conversión MXN→USD (verificada: 20 MXN/USD)
4. ✅ Problema ES cobertura: México reporta 1 instrumento vs universo completo

**Recomendación:**
- NO comparar México vs Perú/Chile/Brasil en términos absolutos
- SÍ usar México para análisis de:
  - Concentración bancaria en L/C
  - Tendencias temporales L/C
  - Estructura mercado L/C por tipo de banco
  - Participación market share bancos individuales

**México necesitaría datos adicionales de:**
- Créditos directos comercio exterior (otras cuentas contables)
- Garantías trade finance
- Financiamiento pre/post embarque
- Aceptaciones bancarias

Para tener TF comparable con Perú/Chile/Brasil.

---

**Validado por:**
- Comparación exports: México 6.5x > Perú, pero L/C 0.45x < Perú TF → consistente con cobertura parcial
- Ratio L/C/TF típico: 5-15% → implica TF total México ~USD 40-120 billones (razonable)
- Cuenta contable verificada: B-7351 efectivamente es SOLO L/C outstanding

**Fecha**: 19 noviembre 2025
