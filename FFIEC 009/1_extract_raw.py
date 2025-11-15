"""
PASO 1: EXTRACCIÓN CRUDA SIN PÉRDIDA DE INFORMACIÓN
====================================================

Este script extrae TODA la información de los archivos Excel a CSV,
preservando absolutamente TODO:
- Todas las filas (incluyendo headers, vacías, etc.)
- Todas las columnas (incluyendo vacías)
- Todos los valores tal como están (con \n, \xa0, etc.)
- Metadatos del archivo original

Objetivo: Tener una copia EXACTA en formato más manejable (CSV)
"""

import pandas as pd
import os
from pathlib import Path
import json
from datetime import datetime
import re

# Configuración
INPUT_DIR = Path(".")
OUTPUT_DIR = Path("./extracted_raw")
OUTPUT_DIR.mkdir(exist_ok=True)

# Archivo de metadatos
METADATA_FILE = OUTPUT_DIR / "extraction_metadata.json"
metadata = {}

def extract_date_from_filename(filename):
    """Extrae fecha y trimestre del nombre del archivo"""

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

    # Patrón 1: "Dec 31 2021 - E16 (009).xls"
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

    # Patrón 2: "E16_202109.xlsx"
    pattern2 = r"E16_(\d{4})(\d{2})"
    match2 = re.search(pattern2, filename)

    if match2:
        year = match2.group(1)
        month = int(match2.group(2))
        quarter = f"Q{(month-1)//3 + 1}"
        return f"{year}{quarter}", year, quarter

    return "UNKNOWN", "UNKNOWN", "UNKNOWN"


def extract_file_to_csv(file_path):
    """Extrae todas las hojas de un archivo Excel a CSVs individuales"""

    file_name = file_path.name
    print(f"\n{'='*80}")
    print(f"Procesando: {file_name}")
    print(f"{'='*80}")

    # Extraer metadatos del nombre
    period, year, quarter = extract_date_from_filename(file_name)

    # Crear subcarpeta para este archivo
    file_output_dir = OUTPUT_DIR / f"{period}_{file_name.replace('.xls', '').replace('.xlsx', '')}"
    file_output_dir.mkdir(exist_ok=True)

    # Metadatos de este archivo
    file_metadata = {
        'source_file': file_name,
        'period': period,
        'year': year,
        'quarter': quarter,
        'extraction_date': datetime.now().isoformat(),
        'sheets': {}
    }

    try:
        # Leer archivo
        xls = pd.ExcelFile(file_path)
        print(f"  Hojas encontradas: {len(xls.sheet_names)}")

        for sheet_name in xls.sheet_names:
            print(f"\n  Extrayendo: {sheet_name}")

            # Leer hoja SIN NINGÚN PROCESAMIENTO
            df = pd.read_excel(file_path, sheet_name=sheet_name, header=None)

            # Nombre del CSV (sanitizado)
            csv_name = sheet_name.replace(' - ', '_').replace(' ', '_').replace('.', '_')
            csv_path = file_output_dir / f"{csv_name}.csv"

            # Guardar a CSV preservando TODO
            df.to_csv(csv_path, index=False, header=False)

            # Guardar metadatos de la hoja (convertir a tipos nativos de Python)
            file_metadata['sheets'][sheet_name] = {
                'csv_file': csv_path.name,
                'dimensions': [int(df.shape[0]), int(df.shape[1])],
                'non_null_cells': int(df.notna().sum().sum()),
                'total_cells': int(df.shape[0] * df.shape[1])
            }

            print(f"    ✓ Guardado: {csv_path.name}")
            print(f"    Dimensiones: {df.shape}")
            print(f"    Celdas no-nulas: {df.notna().sum().sum()} / {df.shape[0] * df.shape[1]}")

        # Guardar metadatos del archivo
        metadata_path = file_output_dir / "file_metadata.json"
        with open(metadata_path, 'w') as f:
            json.dump(file_metadata, f, indent=2)

        print(f"\n  ✓ Metadatos guardados: {metadata_path.name}")

        # Agregar a metadatos globales
        metadata[file_name] = file_metadata

        return True

    except Exception as e:
        print(f"  ✗ ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Procesa todos los archivos Excel en el directorio"""

    print("="*80)
    print(" EXTRACCIÓN CRUDA DE ARCHIVOS FFIEC 009")
    print("="*80)
    print(f"\nDirectorio de entrada: {INPUT_DIR.absolute()}")
    print(f"Directorio de salida: {OUTPUT_DIR.absolute()}\n")

    # Buscar archivos Excel (excluyendo _Cleansed duplicados por ahora)
    excel_files = []

    # Primero buscar archivos _Cleansed
    cleansed_files = list(INPUT_DIR.glob("*_Cleansed.xlsx"))

    # Luego archivos sin _Cleansed
    for pattern in ["*.xls", "*.xlsx"]:
        for file in INPUT_DIR.glob(pattern):
            # Si existe versión Cleansed, usar esa
            cleansed_version = file.with_name(file.stem + "_Cleansed.xlsx")
            if cleansed_version.exists():
                if cleansed_version not in excel_files:
                    excel_files.append(cleansed_version)
            else:
                excel_files.append(file)

    # Remover duplicados
    excel_files = sorted(list(set(excel_files)))

    print(f"Archivos encontrados: {len(excel_files)}")

    # Procesar TODOS los archivos
    if excel_files:
        successful = 0
        failed = 0

        for i, file_path in enumerate(excel_files, 1):
            print(f"\n[{i}/{len(excel_files)}] {file_path.name}")

            success = extract_file_to_csv(file_path)

            if success:
                successful += 1
            else:
                failed += 1

        # Guardar metadatos globales
        with open(METADATA_FILE, 'w') as f:
            json.dump(metadata, f, indent=2)

        print(f"\n{'='*80}")
        print(" EXTRACCIÓN COMPLETADA")
        print(f"{'='*80}")
        print(f"\nResultados en: {OUTPUT_DIR.absolute()}")
        print(f"Metadatos globales: {METADATA_FILE.name}")
        print(f"\nArchivos procesados exitosamente: {successful}")
        print(f"Archivos con errores: {failed}")
        print(f"Total: {len(excel_files)}")
    else:
        print("✗ No se encontraron archivos Excel")


if __name__ == "__main__":
    main()
