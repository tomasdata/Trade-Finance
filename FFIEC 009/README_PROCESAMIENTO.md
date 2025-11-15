# Procesamiento de Archivos FFIEC 009

## 📋 Resumen

Este directorio contiene scripts para procesar archivos Excel FFIEC 009 (Country Exposure Lending Survey) y convertirlos a CSVs limpios y organizados **sin pérdida de información**.

## 🎯 Objetivo

Convertir archivos Excel complejos con:
- Encabezados multi-nivel
- Columnas vacías (separadores visuales)
- Estructura jerárquica de datos
- Caracteres especiales

A CSVs organizados con:
- Encabezados claros
- Metadatos completos
- Clasificación de filas
- Datos numéricos correctamente tipados

## 📁 Estructura de Carpetas

```
FFIEC 009/
├── *.xls, *.xlsx                    # Archivos originales
├── 1_extract_raw.py                 # Paso 1: Extracción cruda
├── 2_analyze_structure.py           # Paso 2: Análisis de estructura
├── 3_clean_and_organize.py          # Paso 3: Limpieza y organización
├── 4_validate_and_document.py       # Paso 4: Validación
├── extracted_raw/                   # CSVs crudos (copia exacta)
├── analysis_reports/                # Reportes de análisis
├── cleaned_data/                    # CSVs finales limpios ✓
│   └── 2024Q3/                     # Por período
│       ├── All_Banks_Table_1.csv
│       ├── All_Banks_Table_2.csv
│       └── ...
└── validation_reports/              # Reportes de validación
```

## 🚀 Cómo Usar

### Paso 1: Extracción Cruda

```bash
python3 1_extract_raw.py
```

**Qué hace:**
- Lee todos los archivos Excel (.xls y .xlsx)
- Extrae cada hoja a CSV individual
- **NO modifica nada** - copia exacta
- Genera metadatos en JSON

**Salida:** `extracted_raw/[periodo]/`

### Paso 2: Análisis de Estructura

```bash
python3 2_analyze_structure.py
```

**Qué hace:**
- Detecta fila de inicio de datos
- Identifica columnas vacías
- Construye encabezados multi-nivel
- Clasifica tipos de filas
- Genera reportes detallados

**Salida:** `analysis_reports/`

### Paso 3: Limpieza y Organización

```bash
python3 3_clean_and_organize.py
```

**Qué hace:**
- Aplica configuración documentada por tabla
- Limpia caracteres especiales (`\n`, `\xa0`, etc.)
- Elimina columnas vacías
- Construye nombres de columnas descriptivos
- Clasifica cada fila automáticamente
- Agrega metadatos completos
- Convierte tipos de datos correctamente

**Salida:** `cleaned_data/[periodo]/`

### Paso 4: Validación

```bash
python3 4_validate_and_document.py
```

**Qué hace:**
- Valida integridad de datos
- Compara original vs procesado
- Genera reportes de validación
- Confirma que no se perdió información

**Salida:** `validation_reports/`

## 📊 Estructura de CSVs Finales

Cada CSV limpio tiene la siguiente estructura:

### Columnas de Metadatos (primeras 9):

| Columna | Descripción | Ejemplo |
|---------|-------------|---------|
| `period` | Período (YYYYQX) | 2024Q3 |
| `year` | Año | 2024 |
| `quarter` | Trimestre | Q3 |
| `table` | Tipo de tabla | Table 1 |
| `table_num` | Número de tabla | 1 |
| `bank_group` | Grupo bancario | All Banks / LFI / All Others |
| `region` | Región (propagada) | G-10 and Luxembourg |
| `row_type` | Tipo de fila | country_data / region_header / subtotal / etc. |
| `original_row_idx` | Índice de fila original | 10 |

### Columna de Identificación:

| Columna | Descripción | Ejemplo |
|---------|-------------|---------|
| `country_region` | País o región | BELGIUM |

### Columnas de Datos:

Las columnas de datos tienen nombres descriptivos construidos desde los encabezados multi-nivel originales.

Ejemplo: `Claims_Ultimate_Risk_Basis_Cross_border_Claims_Total`

## 🏷️ Tipos de Filas

El campo `row_type` clasifica cada fila:

| Tipo | Descripción | Ejemplo | Tiene Datos |
|------|-------------|---------|-------------|
| `country_data` | Datos de un país | BELGIUM, CANADA | ✓ |
| `organization_data` | Datos de organización internacional | AFRICAN, ASIAN | ✓ |
| `region_header` | Encabezado de región (no tiene datos) | G-10 and Luxembourg | ✗ |
| `subtotal` | Subtotal de región | Total | ✓ |
| `grand_total` | Total general | Grand Total | ✓ |
| `empty` | Fila vacía (separador) | | ✗ |
| `special_category` | Categoría especial | Banking Centers | Varía |

## 📈 Estadísticas del Procesamiento

### Por Tabla:
- **Filas totales:** 121 (incluye headers, datos, totales, vacías)
- **Filas de datos de países:** ~91
- **Encabezados de región:** 8
- **Subtotales:** 8
- **Total general:** 1
- **Filas vacías:** 9
- **Organizaciones:** 4

### Configuración por Tabla:

| Tabla | Inicio Datos | Columnas Vacías | Columnas de Datos |
|-------|--------------|-----------------|-------------------|
| Table 1 | Fila 9 | [0, 8, 14] | 13 |
| Table 2 | Fila 6 | [0] | 8 |
| Table 3 | Fila 7 | [0, 7, 14] | 12 |
| Table 4.1 | Fila 7 | [0, 18] | 18 |
| Table 4.2 | Fila 8 | [0, 14] | 14 |

## ✅ Garantías de Calidad

1. **Sin Pérdida de Información:**
   - Todas las filas originales están presentes
   - Todos los valores numéricos se conservan
   - Filas vacías y headers se marcan pero no se eliminan

2. **Trazabilidad:**
   - Campo `original_row_idx` mantiene referencia a fila original
   - Metadatos JSON rastrean fuente de cada CSV
   - Reportes de validación comprueban integridad

3. **Tipos de Datos Correctos:**
   - Strings para países/regiones
   - Float para valores numéricos
   - NaN para valores faltantes (no strings vacíos)

4. **Consistencia:**
   - Misma estructura para todos los períodos
   - Mismo número de columnas por tipo de tabla
   - Clasificación consistente de filas

## 🔧 Problemas Resueltos

### 1. Caracteres Especiales
- **Problema:** `\n`, `\xa0`, espacios dobles en encabezados
- **Solución:** Limpieza con `clean_string()` preservando contenido

### 2. Encabezados Multi-Nivel
- **Problema:** 4 filas de encabezados jerárquicos
- **Solución:** Construcción automática concatenando filas relevantes

### 3. Columnas Vacías
- **Problema:** Separadores visuales que confunden el procesamiento
- **Solución:** Detección y eliminación automática por tabla

### 4. Tipos de Datos
- **Problema:** Pandas lee números como strings desde CSV
- **Solución:** Conversión explícita con `pd.to_numeric(errors='coerce')`

### 5. Clasificación de Filas
- **Problema:** Filas de diferentes tipos mezcladas
- **Solución:** Lógica de clasificación basada en contenido y presencia de datos numéricos

### 6. Regiones Jerárquicas
- **Problema:** Encabezados de región no tienen datos pero agrupan países
- **Solución:** Propagación de región hacia abajo hasta encontrar nueva región

## 📌 Notas Importantes

1. **Archivos _Cleansed:**
   - Los archivos con sufijo `_Cleansed.xlsx` tienen prioridad
   - Son estructuralmente idénticos a los originales
   - Probablemente contienen correcciones menores de datos

2. **Formatos .xls vs .xlsx:**
   - Ambos formatos tienen la MISMA estructura
   - El script maneja ambos automáticamente
   - Requiere librerías: `xlrd` (para .xls) y `openpyxl` (para .xlsx)

3. **Periodicidad:**
   - Datos trimestrales: Mar, Jun, Sep, Dec
   - Nomenclatura cambió en 2021:
     - Antes: "Dec 31 2020 - E16 (009).xlsx"
     - Después: "E16_202106.xlsx"

4. **Grupos Bancarios:**
   - **All Banks:** Todos los bancos
   - **LFI:** Large Financial Institutions
   - **All Others:** Otros bancos

## 🎓 Para Entender el Código

### Flujo de Datos:

```
Excel Original
    ↓
[1_extract_raw.py]
    ↓
CSV Crudo (copia exacta)
    ↓
[2_analyze_structure.py]  ← Genera reportes, no modifica datos
    ↓
[3_clean_and_organize.py]
    ↓
CSV Limpio (con metadatos)
    ↓
[4_validate_and_document.py]  ← Valida, no modifica
    ↓
Reportes de Validación
```

### Configuración Clave:

El diccionario `TABLE_CONFIG` en `3_clean_and_organize.py` contiene la configuración documentada para cada tabla:

```python
TABLE_CONFIG = {
    'Table 1': {
        'data_start': 9,           # Fila donde empiezan datos
        'empty_cols': [0, 8, 14],  # Columnas vacías a eliminar
        'header_rows': [4, 5, 6, 7], # Filas que forman encabezado
        'code_row': 7              # Fila con códigos (A), (B)
    },
    # ... más tablas
}
```

## 🚨 Troubleshooting

### "ModuleNotFoundError: No module named 'xlrd'"
```bash
pip3 install xlrd openpyxl
```

### "No such file or directory"
Asegúrate de estar en el directorio `FFIEC 009`:
```bash
cd "FFIEC 009"
python3 1_extract_raw.py
```

### "TypeError: Object of type int64 is not JSON serializable"
Ya está corregido en los scripts. Los valores numpy se convierten a int/float de Python.

### Los datos no se clasifican correctamente
Verifica que `pd.to_numeric(errors='coerce')` esté funcionando. Los datos deben ser numéricos, no strings.

## 📝 Próximos Pasos

1. **Procesar todos los archivos:**
   - Modificar `1_extract_raw.py` para procesar todos (no solo 1)
   - Ejecutar pipeline completo

2. **Análisis de datos:**
   - Los CSVs están listos para análisis
   - Filtrar por `row_type == 'country_data'` para análisis de países
   - Usar `region` para agrupaciones regionales

3. **Consolidación temporal:**
   - Combinar múltiples períodos en un solo dataset
   - Análisis de series de tiempo

## 👤 Autor

Procesamiento automático desarrollado con análisis previo exhaustivo.
Fecha: 2025

## 📄 Licencia

Datos: FFIEC (Federal Financial Institutions Examination Council)
Scripts: Para uso en proyecto Trade Finance
