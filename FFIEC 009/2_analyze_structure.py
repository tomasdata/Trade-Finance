"""
PASO 2: ANÁLISIS DE ESTRUCTURA DE DATOS EXTRAÍDOS
===================================================

Este script analiza los CSVs extraídos para:
1. Identificar automáticamente la fila de inicio de datos
2. Detectar columnas vacías
3. Construir encabezados multi-nivel
4. Clasificar tipos de filas
5. Generar reporte detallado

No modifica nada, solo analiza y reporta.
"""

import pandas as pd
import json
from pathlib import Path
import numpy as np

# Configuración
EXTRACTED_DIR = Path("./extracted_raw")
ANALYSIS_OUTPUT = Path("./analysis_reports")
ANALYSIS_OUTPUT.mkdir(exist_ok=True)


def clean_string(s):
    """Limpiar string de caracteres especiales"""
    if pd.isna(s) or not isinstance(s, str):
        return s
    return s.replace('\n', ' ').replace('\xa0', ' ').replace('  ', ' ').strip()


def detect_data_start(df):
    """Detectar dónde empiezan los datos reales"""
    for i in range(min(20, len(df))):
        val = df.iloc[i, 1]  # Columna 1 es donde están los países
        if pd.notna(val) and isinstance(val, str):
            val_clean = val.upper().strip()
            # Buscar indicadores de inicio
            if any(keyword in val_clean for keyword in ['G-10', 'BELGIUM', 'NON G-10']):
                return i
    return None


def detect_empty_columns(df):
    """Detectar columnas completamente vacías"""
    empty_cols = []
    for col_idx in range(df.shape[1]):
        if df.iloc[:, col_idx].isna().all():
            empty_cols.append(col_idx)
    return empty_cols


def build_headers(df, data_start):
    """Construir encabezados desde las filas multi-nivel"""
    if data_start is None or data_start == 0:
        return None

    headers = []

    # Tomar las 4-5 filas antes del inicio de datos
    header_rows = list(range(max(0, data_start - 5), data_start))

    for col_idx in range(df.shape[1]):
        # Concatenar valores de las filas de encabezado
        parts = []
        for row_idx in header_rows:
            val = df.iloc[row_idx, col_idx]
            if pd.notna(val) and str(val).strip() not in ['', 'nan']:
                cleaned = clean_string(str(val))
                if cleaned and cleaned not in parts:
                    parts.append(cleaned)

        # Si no hay partes, usar el índice de columna
        if not parts:
            headers.append(f"Col_{col_idx}")
        else:
            headers.append(" | ".join(parts))

    return headers


def classify_row_type(row, row_idx, data_start):
    """Clasificar el tipo de fila"""
    if row_idx < data_start:
        return 'header'

    if row.isna().all():
        return 'empty'

    val_col1 = row[1]

    if pd.isna(val_col1):
        return 'unknown'

    if not isinstance(val_col1, str):
        return 'unknown'

    val_upper = str(val_col1).upper().strip()

    # Clasificar
    if 'GRAND TOTAL' in val_upper:
        return 'grand_total'
    elif val_upper == 'TOTAL':
        return 'subtotal'
    elif any(region in val_upper for region in [
        'G-10', 'EUROPE', 'ASIA', 'LATIN AMERICAN', 'AFRICAN',
        'CARIBBEAN', 'MIDDLE EASTERN', 'BANKING CENTER', 'INTERNATIONAL'
    ]):
        # Verificar si tiene datos numéricos
        has_numbers = sum(1 for v in row[2:] if isinstance(v, (int, float)) and pd.notna(v)) > 3
        if has_numbers:
            return 'country_data'
        else:
            return 'group_header'
    else:
        # Si tiene datos numéricos, es país
        has_numbers = sum(1 for v in row[2:] if isinstance(v, (int, float)) and pd.notna(v)) > 3
        if has_numbers:
            return 'country_data'
        else:
            return 'special_category'


def analyze_csv(csv_path, sheet_name, period):
    """Analizar un CSV individual"""
    print(f"\n{'='*70}")
    print(f"Analizando: {sheet_name}")
    print(f"{'='*70}")

    df = pd.read_csv(csv_path, header=None)

    # Detectar estructura
    data_start = detect_data_start(df)
    empty_cols = detect_empty_columns(df)
    headers = build_headers(df, data_start)

    print(f"  Dimensiones: {df.shape}")
    print(f"  Inicio de datos: fila {data_start}")
    print(f"  Columnas vacías: {empty_cols}")

    # Clasificar filas
    row_types = {
        'header': 0,
        'empty': 0,
        'group_header': 0,
        'country_data': 0,
        'subtotal': 0,
        'grand_total': 0,
        'special_category': 0,
        'unknown': 0
    }

    row_details = []

    for i in range(len(df)):
        row = df.iloc[i]
        row_type = classify_row_type(row, i, data_start if data_start else 999)
        row_types[row_type] += 1

        row_details.append({
            'row_idx': i,
            'row_type': row_type,
            'col1_value': clean_string(str(row[1])) if pd.notna(row[1]) else None
        })

    print(f"\n  Clasificación de filas:")
    for rtype, count in row_types.items():
        if count > 0:
            print(f"    {rtype}: {count}")

    # Crear reporte
    analysis = {
        'sheet_name': sheet_name,
        'period': period,
        'csv_file': csv_path.name,
        'dimensions': [int(df.shape[0]), int(df.shape[1])],
        'data_start_row': int(data_start) if data_start else None,
        'empty_columns': [int(c) for c in empty_cols],
        'data_columns': int(df.shape[1] - len(empty_cols) - 1),  # -1 for country col
        'headers': headers,
        'row_type_counts': {k: int(v) for k, v in row_types.items()},
        'row_details': row_details[:20]  # Solo primeras 20 para el reporte
    }

    return analysis


def main():
    """Analizar todos los CSVs extraídos"""

    print("="*80)
    print(" ANÁLISIS DE ESTRUCTURA - DATOS EXTRAÍDOS")
    print("="*80)

    # Buscar carpetas extraídas
    extracted_folders = [d for d in EXTRACTED_DIR.iterdir() if d.is_dir()]

    if not extracted_folders:
        print("✗ No se encontraron carpetas extraídas")
        return

    print(f"\nCarpetas encontradas: {len(extracted_folders)}")

    for folder in extracted_folders:
        print(f"\n{'='*80}")
        print(f"Procesando: {folder.name}")
        print(f"{'='*80}")

        # Leer metadatos
        metadata_file = folder / "file_metadata.json"
        if not metadata_file.exists():
            print("✗ No se encontró archivo de metadatos")
            continue

        with open(metadata_file, 'r') as f:
            metadata = json.load(f)

        period = metadata.get('period', 'UNKNOWN')

        # Analizar cada CSV (solo tablas de All Banks para empezar)
        csv_files = list(folder.glob("All_Banks_*.csv"))

        analyses = {}

        for csv_file in csv_files:
            sheet_name = csv_file.stem.replace('_', ' ')
            analysis = analyze_csv(csv_file, sheet_name, period)
            analyses[sheet_name] = analysis

        # Guardar análisis
        output_file = ANALYSIS_OUTPUT / f"analysis_{folder.name}.json"
        with open(output_file, 'w') as f:
            json.dump(analyses, f, indent=2)

        print(f"\n✓ Análisis guardado: {output_file.name}")

        # Crear reporte legible
        report_file = ANALYSIS_OUTPUT / f"report_{folder.name}.txt"
        with open(report_file, 'w') as f:
            f.write(f"REPORTE DE ANÁLISIS - {folder.name}\n")
            f.write("="*80 + "\n\n")

            for sheet_name, analysis in analyses.items():
                f.write(f"\n{sheet_name}\n")
                f.write("-"*80 + "\n")
                f.write(f"Dimensiones: {analysis['dimensions']}\n")
                f.write(f"Inicio datos: fila {analysis['data_start_row']}\n")
                f.write(f"Columnas vacías: {analysis['empty_columns']}\n")
                f.write(f"Columnas de datos: {analysis['data_columns']}\n\n")

                f.write("Tipos de filas:\n")
                for rtype, count in analysis['row_type_counts'].items():
                    if count > 0:
                        f.write(f"  {rtype}: {count}\n")

                f.write("\nEncabezados detectados:\n")
                if analysis['headers']:
                    for i, header in enumerate(analysis['headers']):
                        if header and 'Col_' not in header:
                            f.write(f"  Col {i}: {header[:80]}\n")

                f.write("\n")

        print(f"✓ Reporte guardado: {report_file.name}")

    print(f"\n{'='*80}")
    print(" ANÁLISIS COMPLETADO")
    print(f"{'='*80}")
    print(f"\nReportes en: {ANALYSIS_OUTPUT.absolute()}")
    print("\n✓ Revisa los reportes .txt para ver el análisis")
    print("✓ Revisa los .json para datos detallados")


if __name__ == "__main__":
    main()
