#!/usr/bin/env python3
"""
Assemble FFIEC 009 LAC Exposure Panel
======================================

Extracts USA banking exposure to Latin America & Caribbean countries from
FFIEC 009 cleaned data and creates a unified time-series panel.

Outputs:
    - tables_and_graphs/FFIEC/ffiec_lac_exposure_panel.csv
    - tables_and_graphs/FFIEC/ffiec_lac_exposure_by_country.csv
    - tables_and_graphs/FFIEC/ffiec_lac_trade_finance_panel.csv
"""

import pandas as pd
from pathlib import Path
import numpy as np

# Configuration
FFIEC_CLEAN_DIR = Path("FFIEC 009/cleaned_data")
OUTPUT_DIR = Path("tables_and_graphs/FFIEC")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# LAC countries (UPPERCASE as in FFIEC data)
LAC_COUNTRIES = {
    # Countries with banking data
    'BRAZIL', 'CHILE', 'MEXICO', 'PERU',
    # FCIB survey countries
    'ARGENTINA', 'COLOMBIA', 'COSTA RICA', 'ECUADOR',
    # Other major LAC economies
    'BOLIVIA', 'DOMINICAN REPUBLIC', 'EL SALVADOR', 'GUATEMALA',
    'HONDURAS', 'JAMAICA', 'NICARAGUA', 'PANAMA', 'PARAGUAY',
    'TRINIDAD AND TOBAGO', 'URUGUAY', 'VENEZUELA',
    # Caribbean
    'BAHAMAS', 'BARBADOS', 'BELIZE', 'CAYMAN ISLANDS', 'HAITI',
    'TURKS AND CAICOS', 'ANGUILLA', 'ARUBA', 'CURACAO',
    'BRITISH VIRGIN ISLANDS', 'NETHERLAND ANTILLES'
}

def load_ffiec_period(period_dir: Path, version: str = "complete") -> pd.DataFrame:
    """Load all tables for a given FFIEC period."""

    period_name = period_dir.name.replace(f"_{version}", "")
    year = int(period_name[:4])
    quarter = period_name[5:]

    tables = []

    for table_file in period_dir.glob("*.csv"):
        if table_file.name.startswith('.'):
            continue

        df = pd.read_csv(table_file, low_memory=False)

        # Extract metadata from filename
        # Example: All_Banks_Table_1.csv -> bank_group=All Banks, table=1
        filename = table_file.stem
        parts = filename.split('_')

        if len(parts) >= 3:
            # Handle bank group (could be "All Banks", "LFI", "All Others")
            if parts[0] == "All" and parts[1] == "Banks":
                bank_group = "All Banks"
                table_num = parts[-1]
            elif parts[0] == "All" and parts[1] == "Others":
                bank_group = "All Others"
                table_num = parts[-1]
            elif parts[0] == "LFI":
                bank_group = "LFI"
                table_num = parts[-1]
            else:
                continue

            df['bank_group'] = bank_group
            df['table_num'] = table_num
            df['year'] = year
            df['quarter'] = quarter
            df['period'] = period_name

            tables.append(df)

    if not tables:
        return pd.DataFrame()

    return pd.concat(tables, ignore_index=True)

def extract_lac_exposure(df: pd.DataFrame) -> pd.DataFrame:
    """Filter for LAC countries and relevant metrics."""

    if df.empty:
        return df

    # Filter for LAC countries
    if 'country_region' in df.columns:
        lac_df = df[df['country_region'].isin(LAC_COUNTRIES)].copy()
    else:
        return pd.DataFrame()

    # Filter out region headers (keep only country data)
    if 'row_type' in lac_df.columns:
        lac_df = lac_df[lac_df['row_type'] != 'region_header']

    return lac_df

def main():
    print("🌎 Assembling FFIEC 009 LAC Exposure Panel")
    print("=" * 60)

    all_periods = []

    # Process all _complete versions (have country_region column)
    period_dirs = sorted(FFIEC_CLEAN_DIR.glob("*_complete"))

    print(f"\n📂 Found {len(period_dirs)} periods to process")

    for period_dir in period_dirs:
        print(f"   Processing: {period_dir.name}")

        period_df = load_ffiec_period(period_dir, version="complete")

        if period_df.empty:
            print(f"      ⚠️  No data found")
            continue

        lac_df = extract_lac_exposure(period_df)

        if not lac_df.empty:
            all_periods.append(lac_df)
            print(f"      ✓ {len(lac_df)} LAC records")

    if not all_periods:
        print("\n❌ No LAC data found!")
        return

    # Combine all periods
    print(f"\n🔗 Combining {len(all_periods)} periods...")
    panel = pd.concat(all_periods, ignore_index=True)

    print(f"   Total records: {len(panel):,}")
    print(f"   Countries: {panel['country_region'].nunique()}")
    print(f"   Period range: {panel['period'].min()} to {panel['period'].max()}")

    # Save full panel
    output_file = OUTPUT_DIR / "ffiec_lac_exposure_panel.csv"
    panel.to_csv(output_file, index=False)
    print(f"\n✅ Saved: {output_file}")
    print(f"   Size: {len(panel):,} rows × {len(panel.columns)} columns")

    # Create by-country summary
    print("\n📊 Creating country-level summaries...")

    # Extract Trade Finance column if available
    tf_cols = [col for col in panel.columns if 'Trade' in col or 'trade' in col]

    if tf_cols:
        print(f"   Found TF columns: {tf_cols}")

        # Focus on Table 1 for main exposure metrics
        table1 = panel[panel['table_num'] == '1'].copy()

        if not table1.empty and 'Trade_Finance' in table1.columns:
            # Trade Finance panel
            tf_panel = table1[['year', 'quarter', 'period', 'bank_group',
                              'country_region', 'Trade_Finance']].copy()

            tf_panel['Trade_Finance'] = pd.to_numeric(tf_panel['Trade_Finance'], errors='coerce')

            # Remove nulls
            tf_panel = tf_panel[tf_panel['Trade_Finance'].notna()]

            tf_output = OUTPUT_DIR / "ffiec_lac_trade_finance_panel.csv"
            tf_panel.to_csv(tf_output, index=False)
            print(f"\n✅ Saved Trade Finance Panel: {tf_output}")
            print(f"   Records: {len(tf_panel):,}")

            # By country aggregation
            country_summary = tf_panel.groupby('country_region').agg({
                'Trade_Finance': ['count', 'mean', 'sum', 'min', 'max'],
                'period': ['min', 'max']
            }).round(2)

            country_summary.columns = ['_'.join(col).strip() for col in country_summary.columns]
            country_summary = country_summary.sort_values('Trade_Finance_sum', ascending=False)

            country_output = OUTPUT_DIR / "ffiec_lac_exposure_by_country.csv"
            country_summary.to_csv(country_output)
            print(f"\n✅ Saved Country Summary: {country_output}")
            print(f"   Countries: {len(country_summary)}")

            # Print top 10
            print("\n🏆 Top 10 LAC Countries by Total TF Exposure:")
            print(country_summary.head(10)[['Trade_Finance_sum', 'Trade_Finance_mean', 'period_min', 'period_max']])

    print("\n" + "=" * 60)
    print("✅ FFIEC LAC Panel Assembly Complete!")
    print("\nOutputs:")
    print(f"   1. {OUTPUT_DIR / 'ffiec_lac_exposure_panel.csv'}")
    print(f"   2. {OUTPUT_DIR / 'ffiec_lac_trade_finance_panel.csv'}")
    print(f"   3. {OUTPUT_DIR / 'ffiec_lac_exposure_by_country.csv'}")

if __name__ == "__main__":
    main()
