"""
PASO 3 MEJORADO: LIMPIEZA Y ORGANIZACIÓN DE DATOS
===================================================

Mejoras sobre versión anterior:
1. Nombres de columnas descriptivos (no col_2, col_3)
2. Extracción correcta de período del nombre archivo
3. Eliminación de filas region_header (solo metadata, no datos)
4. Construcción robusta de encabezados multi-nivel
"""

import pandas as pd
import json
from pathlib import Path
import numpy as np
import re

# Configuración
EXTRACTED_DIR = Path("./extracted_raw")
OUTPUT_DIR = Path("./cleaned_data")
OUTPUT_DIR.mkdir(exist_ok=True)

# Configuración por tabla (basada en análisis previo)
TABLE_CONFIG = {
    'Table 1': {
        'data_start': 9,
        'empty_cols': [0, 8, 14],
        'header_rows': [4, 5, 6, 7],
        'code_row': 7
    },
    'Table 2': {
        'data_start': 6,
        'empty_cols': [0],
        'header_rows': [4, 5],
        'code_row': 5
    },
    'Table 3': {
        'data_start': 7,
        'empty_cols': [0, 7, 14],
        'header_rows': [4, 5, 6],
        'code_row': 6
    },
    'Table 4.1': {
        'data_start': 7,
        'empty_cols': [0, 18],
        'header_rows': [4, 5, 6],
        'code_row': 6
    },
    'Table 4.2': {
        'data_start': 8,
        'empty_cols': [0, 14],
        'header_rows': [5, 6, 7],
        'code_row': 7
    }
}


def clean_string(s):
    """Limpiar string preservando información"""
    if pd.isna(s) or not isinstance(s, str):
        return s

    s = s.replace('\n', ' ')
    s = s.replace('\xa0', ' ')
    s = s.replace('\r', ' ')
    s = s.replace('\t', ' ')

    while '  ' in s:
        s = s.replace('  ', ' ')

    return s.strip()


def extract_date_from_filename(filename):
    """Extrae fecha del nombre - VERSION MEJORADA"""

    # Patrón especial: "Dec (SEP) 31 2024"
    pattern_special = r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s*\([A-Z]+\)\s*\d+\s+(\d{4})'
    match = re.search(pattern_special, filename)
    if match:
        month = match.group(1)
        year = match.group(2)
        month_to_q = {
            'Mar': 'Q1', 'Jun': 'Q2', 'Sep': 'Q3', 'Dec': 'Q4'
        }
        quarter = month_to_q.get(month, 'Q?')
        return f"{year}{quarter}", year, quarter

    # Patrón normal: "Dec 31 2021"
    pattern1 = r"(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d+\s+(\d{4})"
    match1 = re.search(pattern1, filename)
    if match1:
        month_map = {
            'Mar': 'Q1', 'Jun': 'Q2', 'Sep': 'Q3', 'Dec': 'Q4',
            'Jan': 'Q1', 'Feb': 'Q1', 'Apr': 'Q2', 'May': 'Q2',
            'Jul': 'Q3', 'Aug': 'Q3', 'Oct': 'Q4', 'Nov': 'Q4'
        }
        month = match1.group(1)
        year = match1.group(2)
        quarter = month_map.get(month, 'Q?')
        return f"{year}{quarter}", year, quarter

    # Patrón 2: "E16_202109"
    pattern2 = r"E16_(\d{4})(\d{2})"
    match2 = re.search(pattern2, filename)
    if match2:
        year = match2.group(1)
        month = int(match2.group(2))
        quarter = f"Q{(month-1)//3 + 1}"
        return f"{year}{quarter}", year, quarter

    return "UNKNOWN", "UNKNOWN", "UNKNOWN"


def build_column_names_robust(df_raw, table_num):
    """Construye nombres de columnas de forma robusta"""
    config = TABLE_CONFIG.get(f'Table {table_num}', TABLE_CONFIG['Table 1'])

    header_rows = config['header_rows']
    code_row = config['code_row']
    empty_cols = config['empty_cols']

    column_names = []

    for col_idx in range(df_raw.shape[1]):
        # Saltar columnas vacías
        if col_idx in empty_cols:
            continue

        # Columna 1 es siempre país/región
        if col_idx == 1:
            column_names.append('country_region')
            continue

        # Para otras columnas, construir nombre
        parts = []

        # Luego agregar descripciones de TODAS las filas de header
        for row_idx in header_rows + [code_row]:
            if row_idx < len(df_raw):
                val = df_raw.iloc[row_idx, col_idx]
                if pd.notna(val):
                    val_str = str(val).strip()
                    # Filtrar valores vacíos o inútiles
                    if val_str and val_str not in ['', 'nan', ' '] and not val_str.isspace():
                        cleaned = clean_string(val_str)
                        # Solo agregar si tiene contenido real
                        if cleaned and len(cleaned) > 1 and not cleaned.isspace():
                            # Truncar si es muy largo
                            if len(cleaned) > 35:
                                # Intentar cortar en palabra
                                words = cleaned.split()
                                cleaned = ' '.join(words[:4]) if len(words) > 4 else cleaned[:35]
                            # Evitar duplicados
                            if cleaned not in parts:
                                parts.append(cleaned)

        if parts:
            # Crear nombre limpio
            name = '_'.join(parts)
            # Remover caracteres problemáticos
            name = re.sub(r'[^\w\s-]', '_', name)
            name = re.sub(r'[\s-]+', '_', name)
            name = re.sub(r'_+', '_', name)  # Múltiples underscores → uno
            name = name.strip('_')
            name = name[:100]  # Limitar longitud
            column_names.append(name)
        else:
            # Fallback
            column_names.append(f'col_{col_idx}')

    return column_names


def process_sheet_improved(csv_path, sheet_info, period, year, quarter):
    """Procesar hoja con mejoras"""

    print(f"\n  Procesando: {sheet_info['table_name']} ({sheet_info['bank_group']})")

    # Leer CSV crudo
    df_raw = pd.read_csv(csv_path, header=None)

    # Configuración
    table_num = sheet_info['table_num']
    config = TABLE_CONFIG.get(f'Table {table_num}', TABLE_CONFIG['Table 1'])

    data_start = config['data_start']
    empty_cols = config['empty_cols']

    # Construir nombres de columnas ANTES de convertir a numérico
    column_names = build_column_names_robust(df_raw, table_num)

    # AHORA convertir columnas numéricas (excepto columna 1 = país)
    for col in df_raw.columns:
        if col != 1:
            df_raw[col] = pd.to_numeric(df_raw[col], errors='coerce')

    # Extraer datos
    df_data = df_raw.iloc[data_start:].copy()
    cols_to_keep = [i for i in range(df_raw.shape[1]) if i not in empty_cols]
    df_data = df_data.iloc[:, cols_to_keep]
    df_data = df_data.reset_index(drop=True)
    df_data.columns = column_names

    # Clasificar filas y construir región
    row_types = []
    regions = []
    current_region = None

    for i in range(len(df_data)):
        country_val = df_data.iloc[i, 0]  # country_region
        numeric_data = df_data.iloc[i, 1:]

        if pd.isna(country_val):
            row_type = 'empty'
        elif not isinstance(country_val, str):
            row_type = 'data_row'
        else:
            val_upper = clean_string(str(country_val)).upper()

            # Grand Total
            if 'GRAND TOTAL' in val_upper:
                row_type = 'grand_total'
            # Subtotal
            elif val_upper.strip() == 'TOTAL':
                row_type = 'subtotal'
            # Region headers
            elif any(kw in val_upper for kw in ['G-10', 'EASTERN EUROPE', 'LATIN AMERICA',
                                                  'ASIA AND PACIFIC', 'AFRICA', 'BANKING CENTER',
                                                  'INTERNATIONAL', 'NON G-10', 'OTHER E. EUROPE',
                                                  'OTHER ASIA', 'NON-G']):
                num_count = sum(1 for v in numeric_data if isinstance(v, (int, float)) and pd.notna(v))
                if num_count > 2:
                    row_type = 'country_data'
                else:
                    row_type = 'region_header'
                    current_region = clean_string(str(country_val))
            # Organizations
            elif any(kw in val_upper for kw in ['AFRICAN', 'ASIAN', 'CARIBBEAN',
                                                  'EUROPEAN', 'LATIN AMERICAN', 'MIDDLE EASTERN']):
                num_count = sum(1 for v in numeric_data if isinstance(v, (int, float)) and pd.notna(v))
                if num_count > 2:
                    row_type = 'organization_data'
                else:
                    row_type = 'special_category'
            # Default
            else:
                num_count = sum(1 for v in numeric_data if isinstance(v, (int, float)) and pd.notna(v))
                if num_count > 2:
                    row_type = 'country_data'
                else:
                    row_type = 'special_category'

        row_types.append(row_type)
        regions.append(current_region if current_region else 'Unknown')

    # Agregar metadatos
    df_data.insert(0, 'period', period)
    df_data.insert(1, 'year', year)
    df_data.insert(2, 'quarter', quarter)
    df_data.insert(3, 'table', sheet_info['table_name'])
    df_data.insert(4, 'table_num', table_num)
    df_data.insert(5, 'bank_group', sheet_info['bank_group'])
    df_data.insert(6, 'region', regions)
    df_data.insert(7, 'row_type', row_types)
    df_data.insert(8, 'original_row_idx', list(range(data_start, data_start + len(df_data))))

    # Limpiar country_region
    if 'country_region' in df_data.columns:
        df_data['country_region'] = df_data['country_region'].apply(clean_string)

    print(f"    Filas: {len(df_data)}")
    print(f"    Columnas datos: {len(column_names) - 1}")

    # Mostrar tipos
    type_counts = pd.Series(row_types).value_counts()
    print(f"    Tipos: {dict(type_counts)}")

    # NUEVO: Crear versión filtrada (SOLO country_data para análisis)
    df_filtered = df_data[df_data['row_type'] == 'country_data'].copy()

    print(f"    Filas de países (solo country_data): {len(df_filtered)}")

    return df_data, df_filtered


def main():
    """Procesar con mejoras"""

    print("="*80)
    print(" LIMPIEZA MEJORADA - FFIEC 009")
    print("="*80)

    extracted_folders = [d for d in EXTRACTED_DIR.iterdir() if d.is_dir()]

    if not extracted_folders:
        print("✗ No hay carpetas extraídas")
        return

    for folder in extracted_folders:
        print(f"\n{'='*80}")
        print(f"Procesando: {folder.name}")
        print(f"{'='*80}")

        # Leer metadatos
        metadata_file = folder / "file_metadata.json"
        if not metadata_file.exists():
            continue

        with open(metadata_file, 'r') as f:
            metadata = json.load(f)

        # Extraer período MEJORADO
        source_file = metadata.get('source_file', '')
        period, year, quarter = extract_date_from_filename(source_file)

        print(f"Archivo: {source_file}")
        print(f"Período detectado: {period} (Q{quarter} {year})")

        # Crear carpetas de salida
        output_folder_full = OUTPUT_DIR / f"{period}_complete"
        output_folder_clean = OUTPUT_DIR / f"{period}_data_only"
        output_folder_full.mkdir(exist_ok=True)
        output_folder_clean.mkdir(exist_ok=True)

        # Procesar hojas
        for sheet_name, sheet_meta in metadata['sheets'].items():
            if 'Table' not in sheet_name:
                continue

            parts = sheet_name.split(' - ')
            if len(parts) != 2:
                continue

            bank_group = parts[0].strip()
            table_name = parts[1].strip()

            table_num_match = re.search(r'Table ([\d.]+)', table_name)
            if not table_num_match:
                continue

            table_num = table_num_match.group(1)
            csv_path = folder / sheet_meta['csv_file']

            if not csv_path.exists():
                continue

            sheet_info = {
                'table_name': table_name,
                'table_num': table_num,
                'bank_group': bank_group
            }

            try:
                df_full, df_filtered = process_sheet_improved(
                    csv_path, sheet_info, period, year, quarter
                )

                # Guardar versión completa
                file_base = f"{bank_group.replace(' ', '_')}_{table_name.replace(' ', '_').replace('.', '_')}"

                full_path = output_folder_full / f"{file_base}.csv"
                df_full.to_csv(full_path, index=False)
                print(f"    ✓ Completo: {full_path.name}")

                # Guardar versión solo datos
                clean_path = output_folder_clean / f"{file_base}.csv"
                df_filtered.to_csv(clean_path, index=False)
                print(f"    ✓ Solo datos: {clean_path.name}")

            except Exception as e:
                print(f"    ✗ Error: {e}")
                import traceback
                traceback.print_exc()

    print(f"\n{'='*80}")
    print(" COMPLETADO")
    print(f"{'='*80}")
    print(f"\nDatos en: {OUTPUT_DIR.absolute()}")
    print("\nDos versiones generadas:")
    print("  1. [periodo]_complete/    - TODAS las filas (headers, empty, etc.)")
    print("  2. [periodo]_data_only/   - SOLO datos útiles (sin headers/empty)")


if __name__ == "__main__":
    main()
