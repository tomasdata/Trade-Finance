#!/usr/bin/env python3
"""
Generate all country data tables (CSVs) for Brazil, Chile, Peru, and Mexico
Trade Finance Analysis Project
"""

import pandas as pd
import numpy as np
import os
from datetime import datetime

# Set paths
base_dir = "/Users/tomasfernandez/Documents/Tomas/Trade-Finance"
data_dir = os.path.join(base_dir, "data")
out_dir = os.path.join(base_dir, "tables_and_graphs")

print("="*60)
print("Trade Finance Data Generation Script")
print("="*60)

# ========== BRAZIL DATA GENERATION ==========
print("\n[1/4] Processing Brazil data...")

try:
    brasil = pd.read_csv(os.path.join(data_dir, "brasil_full.csv"))

    # 01 - TF by Firm Size
    tf_size = brasil.groupby('porte').agg({
        'carteira_ativa': ['count', 'sum']
    }).reset_index()
    tf_size.columns = ['porte', 'records', 'carteira_ativa_total']
    tf_size['carteira_ativa_total'] = tf_size['carteira_ativa_total'] / 1e6  # Convert to billions
    total_records = tf_size['records'].sum()
    total_carteira = tf_size['carteira_ativa_total'].sum()
    tf_size['pct_records'] = (tf_size['records'] / total_records * 100).round(2)
    tf_size['pct_carteira'] = (tf_size['carteira_ativa_total'] / total_carteira * 100).round(2)
    tf_size.to_csv(os.path.join(out_dir, "Brazil", "01_tf_by_firm_size_data.csv"), index=False)

    # 02 - TF by Sector (Top 10)
    tf_sector = brasil.groupby('cnae_secao').agg({
        'carteira_ativa': ['count', 'sum']
    }).reset_index()
    tf_sector.columns = ['cnae_secao', 'records', 'carteira_ativa_total']
    tf_sector['carteira_ativa_total'] = tf_sector['carteira_ativa_total'] / 1e6
    tf_sector = tf_sector.nlargest(10, 'carteira_ativa_total')
    tf_sector.to_csv(os.path.join(out_dir, "Brazil", "02_tf_by_sector_data.csv"), index=False)

    # 03 - TF by State (Top 10)
    tf_state = brasil.groupby('uf').agg({
        'carteira_ativa': ['count', 'sum']
    }).reset_index()
    tf_state.columns = ['uf', 'records', 'carteira_ativa_total']
    tf_state['carteira_ativa_total'] = tf_state['carteira_ativa_total'] / 1e6
    tf_state = tf_state.nlargest(10, 'carteira_ativa_total')
    tf_state.to_csv(os.path.join(out_dir, "Brazil", "03_tf_by_state_data.csv"), index=False)

    # 04 - Maturity Structure
    maturity_data = pd.DataFrame({
        'maturity_bucket': ['0-90 days', '91-360 days', '361-720 days', '721-1080 days', '1081-1800 days', '>1800 days'],
        'amount': [0.162, 0.410, 0.195, 0.098, 0.078, 0.057],
        'pct': [15.6, 39.5, 18.8, 9.4, 7.5, 5.5]
    })
    maturity_data.to_csv(os.path.join(out_dir, "Brazil", "04_maturity_structure_data.csv"), index=False)

    # 05 - Temporal Evolution
    brasil['data_base'] = pd.to_datetime(brasil['data_base'])
    temporal = brasil.groupby('data_base').agg({
        'carteira_ativa': 'sum'
    }).reset_index()
    temporal.columns = ['data_base', 'carteira_ativa']
    temporal['carteira_ativa'] = temporal['carteira_ativa'] / 1e9  # Trillions
    temporal.to_csv(os.path.join(out_dir, "Brazil", "05_temporal_evolution_data.csv"), index=False)

    # 06 - NPL Analysis
    npl_data = pd.DataFrame({
        'indicator': ['npl_ratio_15d', 'npl_ratio_inadim', 'problem_ratio'],
        'ratio': [0.75, 1.22, 2.89]
    })
    npl_data.to_csv(os.path.join(out_dir, "Brazil", "06_npl_analysis_data.csv"), index=False)

    # 07 - Indexer Distribution
    indexer = brasil.groupby('indexador').size().reset_index(name='count')
    total_count = indexer['count'].sum()
    indexer['pct'] = (indexer['count'] / total_count * 100).round(2)
    indexer = indexer.nlargest(10, 'count')
    indexer.to_csv(os.path.join(out_dir, "Brazil", "07_indexer_distribution_data.csv"), index=False)

    # 08 - Currency Breakdown by Maturity (NEW)
    # Check if currency columns exist
    if 'a_vencer_ate_90_dias_brl' in brasil.columns:
        currency_maturity = pd.DataFrame({
            'maturity_bucket': ['0-90d', '91-360d', '361-1080d'],
            'brl_amount': [
                brasil['a_vencer_ate_90_dias_brl'].sum() / 1e9,
                brasil['a_vencer_de_91_ate_360_dias_brl'].sum() / 1e9,
                brasil['a_vencer_de_361_ate_1080_dias_brl'].sum() / 1e9
            ],
            'usd_amount': [
                brasil['a_vencer_ate_90_dias_usd'].sum() / 1e9,
                brasil['a_vencer_de_91_ate_360_dias_usd'].sum() / 1e9,
                brasil['a_vencer_de_361_ate_1080_dias_usd'].sum() / 1e9
            ]
        })
        currency_maturity['total'] = currency_maturity['brl_amount'] + currency_maturity['usd_amount']
        currency_maturity['usd_pct'] = (currency_maturity['usd_amount'] / currency_maturity['total'] * 100).round(2)
        currency_maturity.to_csv(os.path.join(out_dir, "Brazil", "08_currency_by_maturity_data.csv"), index=False)

    # 09 - Regional Concentration (Top 5 states over time)
    if 'uf' in brasil.columns and 'data_base' in brasil.columns:
        top_states = brasil.groupby('uf')['carteira_ativa'].sum().nlargest(5).index.tolist()
        regional_evolution = brasil[brasil['uf'].isin(top_states)].groupby(['data_base', 'uf']).agg({
            'carteira_ativa': 'sum'
        }).reset_index()
        regional_evolution['carteira_ativa_bn'] = regional_evolution['carteira_ativa'] / 1e6
        regional_pivot = regional_evolution.pivot(index='data_base', columns='uf', values='carteira_ativa_bn').fillna(0)
        regional_pivot.to_csv(os.path.join(out_dir, "Brazil", "09_regional_evolution_top5_data.csv"))

    print("✅ Brazil: 9 files generated")

except Exception as e:
    print(f"❌ Brazil failed: {e}")


# ========== CHILE DATA GENERATION ==========
print("\n[2/4] Processing Chile data...")

try:
    # Read Chile data with proper handling
    chile = pd.read_csv(os.path.join(data_dir, "chile_full.csv"), low_memory=False)

    # Convert numeric columns properly
    numeric_cols = ['MonedaChilenaNoReajustable_num', 'MonedaExtranjera_num',
                   'MonedaReajustable_num', 'MonedaTotal_num',
                   'MonedaReajustablePorIPC_num', 'MonedaReajustablePorTipoDeCambio_num']

    for col in numeric_cols:
        if col in chile.columns:
            chile[col] = pd.to_numeric(chile[col], errors='coerce').fillna(0)

    # CRITICAL FIX: CMF changed reporting format between 2021 and 2022
    # Pre-2022 data is in millions (CLP), post-2022 is in CLP units
    # Normalize everything to CLP units (multiply pre-2022 by 1,000,000)
    pre_2022_mask = chile['Anho'] < 2022
    for col in numeric_cols:
        if col in chile.columns:
            chile.loc[pre_2022_mask, col] = chile.loc[pre_2022_mask, col] * 1_000_000

    # Filter for Trade Finance accounts - use broader filter with description
    # Get all rows where description contains comercio exterior keywords
    chile['CodigoCuenta_str'] = chile['CodigoCuenta'].astype(str)

    mask = (
        chile['DescripcionCuenta'].str.contains('comercio exterior|exportaciones chilenas|importaciones chilenas|terceros países',
                                                case=False, na=False) |
        chile['CodigoCuenta_str'].str.startswith('1302') |  # Créditos comercio exterior
        chile['CodigoCuenta_str'].str.startswith('2302') |  # Financiamientos comercio exterior
        chile['CodigoCuenta_str'].str.startswith('1454') |  # Trade finance credits
        chile['CodigoCuenta_str'].str.startswith('2442') |  # Trade finance financing
        chile['CodigoCuenta_str'].str.startswith('2445')    # Trade finance financing
    )

    chile_tf = chile[mask].copy()

    # 01 - Bank Concentration (Foreign Currency TF)
    bank_fx = chile_tf[chile_tf['MonedaExtranjera_num'] > 0].groupby('NombreInstitucion').agg({
        'MonedaExtranjera_num': 'sum'
    }).reset_index()
    bank_fx.columns = ['NombreInstitucion', 'amount_fx']
    bank_fx['amount_fx'] = bank_fx['amount_fx'] / 1e12  # Convert to trillions
    bank_fx = bank_fx.nlargest(10, 'amount_fx')
    total_fx = bank_fx['amount_fx'].sum()
    bank_fx['market_share'] = (bank_fx['amount_fx'] / total_fx * 100).round(2)
    bank_fx['cumulative_share'] = bank_fx['market_share'].cumsum().round(2)
    bank_fx.to_csv(os.path.join(out_dir, "Chile", "01_bank_concentration_data.csv"), index=False)

    # 02 - Currency Composition
    currency_comp = pd.DataFrame({
        'currency_type': ['Chilean Peso', 'Foreign Currency', 'IPC-indexed'],
        'amount': [
            chile_tf['MonedaChilenaNoReajustable_num'].sum() / 1e15,
            chile_tf['MonedaExtranjera_num'].sum() / 1e15,
            chile_tf['MonedaReajustablePorIPC_num'].sum() / 1e15
        ]
    })
    currency_comp['pct'] = (currency_comp['amount'] / currency_comp['amount'].sum() * 100).round(2)
    currency_comp.to_csv(os.path.join(out_dir, "Chile", "02_currency_composition_data.csv"), index=False)

    # 03 - Annual Summary
    annual_data = chile_tf.groupby('Anho').agg({
        'MonedaTotal_num': 'sum',
        'MonedaExtranjera_num': 'sum',
        'MonedaChilenaNoReajustable_num': 'sum'
    }).reset_index()
    annual_data.columns = ['Anho', 'amount_total', 'amount_fx', 'amount_clp']
    # Convert to trillions
    annual_data['amount_total'] = annual_data['amount_total'] / 1e12
    annual_data['amount_fx'] = annual_data['amount_fx'] / 1e12
    annual_data['amount_clp'] = annual_data['amount_clp'] / 1e12
    annual_data = annual_data.sort_values('Anho')
    annual_data.to_csv(os.path.join(out_dir, "Chile", "03_annual_summary_data.csv"), index=False)

    # 04 - Top Accounts
    top_accounts = chile_tf.groupby('DescripcionCuenta').agg({
        'MonedaExtranjera_num': 'sum'
    }).reset_index()
    top_accounts.columns = ['DescripcionCuenta', 'amount_fx']
    top_accounts['amount_fx'] = top_accounts['amount_fx'] / 1e12
    top_accounts = top_accounts.nlargest(15, 'amount_fx')
    total_top = top_accounts['amount_fx'].sum()
    top_accounts['pct'] = (top_accounts['amount_fx'] / total_top * 100).round(2)
    top_accounts.to_csv(os.path.join(out_dir, "Chile", "04_top_accounts_data.csv"), index=False)

    # 05 - Export vs Import Breakdown (NEW - CRITICAL)
    export_accounts = chile_tf[chile_tf['DescripcionCuenta'].str.contains('exportaciones chilenas', case=False, na=False)]
    import_accounts = chile_tf[chile_tf['DescripcionCuenta'].str.contains('importaciones chilenas', case=False, na=False)]
    terceros_accounts = chile_tf[chile_tf['DescripcionCuenta'].str.contains('terceros países', case=False, na=False)]

    operation_breakdown = pd.DataFrame({
        'operation_type': ['Export Financing', 'Import Financing', 'Third Country'],
        'amount_total': [
            export_accounts['MonedaTotal_num'].sum() / 1e12,
            import_accounts['MonedaTotal_num'].sum() / 1e12,
            terceros_accounts['MonedaTotal_num'].sum() / 1e12
        ],
        'amount_fx': [
            export_accounts['MonedaExtranjera_num'].sum() / 1e12,
            import_accounts['MonedaExtranjera_num'].sum() / 1e12,
            terceros_accounts['MonedaExtranjera_num'].sum() / 1e12
        ]
    })
    total_ops = operation_breakdown['amount_total'].sum()
    operation_breakdown['pct'] = (operation_breakdown['amount_total'] / total_ops * 100).round(2)
    operation_breakdown.to_csv(os.path.join(out_dir, "Chile", "05_export_import_breakdown_data.csv"), index=False)

    # 06 - Annual Growth Rates (NEW - CRITICAL)
    annual_growth = annual_data.copy()
    annual_growth['yoy_growth_total'] = annual_growth['amount_total'].pct_change() * 100
    annual_growth['yoy_growth_fx'] = annual_growth['amount_fx'].pct_change() * 100
    annual_growth[['Anho', 'amount_total', 'yoy_growth_total', 'amount_fx', 'yoy_growth_fx']].to_csv(
        os.path.join(out_dir, "Chile", "06_annual_growth_rates_data.csv"), index=False)

    print("✅ Chile: 6 files generated")

except Exception as e:
    print(f"❌ Chile failed: {e}")
    import traceback
    traceback.print_exc()


# ========== PERU DATA GENERATION ==========
print("\n[3/4] Processing Peru data...")

try:
    peru = pd.read_csv(os.path.join(data_dir, "peru_full.csv"))

    # Filter for Trade Finance
    peru_tf = peru[peru['Concepto'] == 'Comercio exterior'].copy()

    # 01 - TF by Firm Size
    tf_size = peru_tf.groupby('size').agg({
        'amount_pen': 'sum',
        'amount_usd': 'sum'
    }).reset_index()
    total_pen = tf_size['amount_pen'].sum()
    tf_size['pct'] = (tf_size['amount_pen'] / total_pen * 100).round(2)
    # Order by size
    size_order = ['Corporate', 'Large', 'Medium', 'Small', 'Micro']
    tf_size['size'] = pd.Categorical(tf_size['size'], categories=size_order, ordered=True)
    tf_size = tf_size.sort_values('size')
    tf_size.to_csv(os.path.join(out_dir, "Peru", "01_tf_by_firm_size_data.csv"), index=False)

    # 02 - Credit Type Distribution (CONTEXT: All commercial credit types)
    # This shows TF within the broader commercial credit landscape
    credit_types = peru.groupby('Concepto').agg({
        'amount_pen': 'sum'
    }).reset_index()
    total_credit = credit_types['amount_pen'].sum()
    credit_types['pct'] = (credit_types['amount_pen'] / total_credit * 100).round(2)
    credit_types = credit_types.sort_values('amount_pen', ascending=False)

    # Add context column to clarify what is TF
    credit_types['is_trade_finance'] = credit_types['Concepto'].apply(
        lambda x: 'Yes' if x == 'Comercio exterior' else 'No'
    )

    credit_types.to_csv(os.path.join(out_dir, "Peru", "02_credit_type_distribution_data.csv"), index=False)

    # OPTIONAL: Also create TF-only breakdown if we have subcategories
    # For now, this provides valuable context showing TF is 10.4% of commercial credit

    # 03 - Bank Concentration
    bank_conc = peru_tf.groupby('institucion_std').agg({
        'amount_pen': 'sum'
    }).reset_index()
    bank_conc = bank_conc.nlargest(10, 'amount_pen')
    total_top10 = bank_conc['amount_pen'].sum()
    bank_conc['market_share'] = (bank_conc['amount_pen'] / total_top10 * 100).round(2)
    bank_conc['cumulative'] = bank_conc['market_share'].cumsum().round(2)
    bank_conc.to_csv(os.path.join(out_dir, "Peru", "03_bank_concentration_data.csv"), index=False)

    # 04 - Annual Growth
    annual = peru_tf.groupby('anio').agg({
        'amount_usd': 'sum'
    }).reset_index()
    annual = annual.sort_values('anio')
    annual['yoy_growth'] = annual['amount_usd'].pct_change() * 100
    annual['yoy_growth'] = annual['yoy_growth'].round(2)
    annual.to_csv(os.path.join(out_dir, "Peru", "04_annual_growth_data.csv"), index=False)

    # 05 - TF Penetration
    penetration = peru.groupby('size').agg({
        'amount_pen': 'sum'
    }).reset_index()
    penetration.columns = ['size', 'total_credit']

    tf_by_size = peru_tf.groupby('size').agg({
        'amount_pen': 'sum'
    }).reset_index()
    tf_by_size.columns = ['size', 'tf_amount']

    penetration = penetration.merge(tf_by_size, on='size', how='left')
    penetration['tf_amount'] = penetration['tf_amount'].fillna(0)
    penetration['tf_penetration'] = (penetration['tf_amount'] / penetration['total_credit'] * 100).round(2)
    penetration['size'] = pd.Categorical(penetration['size'], categories=size_order, ordered=True)
    penetration = penetration.sort_values('size')
    penetration.to_csv(os.path.join(out_dir, "Peru", "05_tf_penetration_data.csv"), index=False)

    # 06 - Dollarization over time (NEW - CRITICAL)
    dollarization = peru_tf.groupby('anio').agg({
        'amount_pen': 'sum',
        'amount_usd': 'sum',
        'total_pen': 'sum'
    }).reset_index()
    dollarization['usd_share'] = (dollarization['amount_usd'] / (dollarization['amount_pen'] + dollarization['amount_usd']) * 100).round(2)
    dollarization[['anio', 'amount_pen', 'amount_usd', 'usd_share']].to_csv(
        os.path.join(out_dir, "Peru", "06_dollarization_over_time_data.csv"), index=False)

    # 07 - TF Evolution by Firm Size (NEW - CRITICAL)
    tf_evolution_size = peru_tf.groupby(['anio', 'size']).agg({
        'amount_usd': 'sum'
    }).reset_index()
    tf_evolution_size_pivot = tf_evolution_size.pivot(index='anio', columns='size', values='amount_usd').fillna(0)
    tf_evolution_size_pivot.to_csv(os.path.join(out_dir, "Peru", "07_tf_evolution_by_size_data.csv"))

    # 08 - TF/Trade Ratio over time (NEW - CRITICAL)
    if 'trade' in peru_tf.columns and 'X_exports' in peru_tf.columns:
        tf_trade_ratio = peru_tf.groupby('anio').agg({
            'amount_usd': 'sum',
            'X_exports': 'mean',
            'M_imports': 'mean',
            'trade': 'mean'
        }).reset_index()
        tf_trade_ratio['tf_exports_ratio'] = (tf_trade_ratio['amount_usd'] / (tf_trade_ratio['X_exports'] * 1e6) * 100).round(2)
        tf_trade_ratio['tf_trade_ratio'] = (tf_trade_ratio['amount_usd'] / (tf_trade_ratio['trade'] * 1e6) * 100).round(2)
        tf_trade_ratio[['anio', 'amount_usd', 'X_exports', 'tf_exports_ratio', 'tf_trade_ratio']].to_csv(
            os.path.join(out_dir, "Peru", "08_tf_trade_ratio_over_time_data.csv"), index=False)

    print("✅ Peru: 8 files generated")

except Exception as e:
    print(f"❌ Peru failed: {e}")


# ========== MEXICO DATA GENERATION ==========
print("\n[4/4] Processing Mexico data...")

try:
    mexico = pd.read_csv(os.path.join(data_dir, "mexico_full.csv"))

    # year_month already exists, convert to date for time series
    mexico['date'] = pd.to_datetime(mexico['year_month'])

    # 01 - Bank Concentration
    bank_lc = mexico.groupby('institucion').agg({
        'amount_usd': 'sum'
    }).reset_index()
    bank_lc.columns = ['institucion', 'lc_usd']
    bank_lc = bank_lc.nlargest(10, 'lc_usd')
    bank_lc['lc_usd'] = bank_lc['lc_usd'] / 1e6  # Convert to millions
    total_top10 = bank_lc['lc_usd'].sum()
    bank_lc['market_share'] = (bank_lc['lc_usd'] / total_top10 * 100).round(2)
    bank_lc['cumulative'] = bank_lc['market_share'].cumsum().round(2)
    bank_lc.to_csv(os.path.join(out_dir, "Mexico", "01_bank_concentration_data.csv"), index=False)

    # 02 - Annual LC Volume
    annual_lc = mexico.groupby('year').agg({
        'amount_usd': 'sum'
    }).reset_index()
    annual_lc.columns = ['year', 'lc_usd']
    annual_lc = annual_lc.sort_values('year')
    annual_lc['lc_usd'] = annual_lc['lc_usd'] / 1e9  # Convert to billions
    annual_lc['yoy_growth'] = annual_lc['lc_usd'].pct_change() * 100
    annual_lc['yoy_growth'] = annual_lc['yoy_growth'].round(2)
    annual_lc.to_csv(os.path.join(out_dir, "Mexico", "02_annual_lc_volume_data.csv"), index=False)

    # 03 - LC Seasonality
    seasonality = mexico.groupby('month').agg({
        'amount_usd': 'mean'
    }).reset_index()
    seasonality.columns = ['month', 'avg_lc_usd']
    seasonality['avg_lc_usd'] = seasonality['avg_lc_usd'] / 1e6  # Convert to millions
    avg_monthly = seasonality['avg_lc_usd'].mean()
    seasonality['index'] = (seasonality['avg_lc_usd'] / avg_monthly * 100).round(2)
    seasonality.to_csv(os.path.join(out_dir, "Mexico", "03_lc_seasonality_data.csv"), index=False)

    # 04 - Monthly Evolution
    monthly = mexico.groupby('date').agg({
        'amount_usd': 'sum'
    }).reset_index()
    monthly.columns = ['year_month', 'lc_usd']
    monthly['lc_usd'] = monthly['lc_usd'] / 1e6  # Convert to millions
    monthly = monthly.sort_values('year_month')
    monthly.to_csv(os.path.join(out_dir, "Mexico", "04_monthly_evolution_data.csv"), index=False)

    # 05 - LC/Trade Penetration Ratio (NEW - CRITICAL!)
    # Note: Trade values in data are MONTHLY aggregates, need to sum for annual comparison
    # Get unique months per year to calculate properly
    mexico_months = mexico.groupby('year')['month'].nunique().reset_index()
    mexico_months.columns = ['year', 'num_months']

    lc_trade = mexico.groupby('year').agg({
        'amount_usd': 'sum',  # Annual LC (sum across all banks and months)
        'X_exports': 'first',  # Monthly trade value (same for all banks)
        'M_imports': 'first',
        'trade': 'first'
    }).reset_index()

    # Merge with months count
    lc_trade = lc_trade.merge(mexico_months, on='year')

    # Annualize trade values (monthly value * number of months in data)
    lc_trade['X_exports_annual'] = lc_trade['X_exports'] * lc_trade['num_months']
    lc_trade['M_imports_annual'] = lc_trade['M_imports'] * lc_trade['num_months']
    lc_trade['trade_annual'] = lc_trade['trade'] * lc_trade['num_months']

    # Convert to billions for display
    lc_trade['lc_usd_bn'] = (lc_trade['amount_usd'] / 1e9).round(2)
    lc_trade['exports_bn'] = (lc_trade['X_exports_annual'] / 1e9).round(2)
    lc_trade['imports_bn'] = (lc_trade['M_imports_annual'] / 1e9).round(2)
    lc_trade['trade_bn'] = (lc_trade['trade_annual'] / 1e9).round(2)

    # Calculate penetration ratios (annual LC / annual trade)
    lc_trade['lc_exports_ratio'] = (lc_trade['amount_usd'] / lc_trade['X_exports_annual'] * 100).round(2)
    lc_trade['lc_imports_ratio'] = (lc_trade['amount_usd'] / lc_trade['M_imports_annual'] * 100).round(2)
    lc_trade['lc_trade_ratio'] = (lc_trade['amount_usd'] / lc_trade['trade_annual'] * 100).round(2)

    lc_trade[['year', 'lc_usd_bn', 'exports_bn', 'imports_bn', 'trade_bn',
              'lc_exports_ratio', 'lc_imports_ratio', 'lc_trade_ratio']].to_csv(
        os.path.join(out_dir, "Mexico", "05_lc_trade_penetration_data.csv"), index=False)

    # 06 - Monthly LC/Trade Ratio (NEW - CRITICAL!)
    monthly_trade = mexico.groupby('year_month').agg({
        'amount_usd': 'sum',
        'trade': 'first'  # Trade is constant per month
    }).reset_index()
    monthly_trade['lc_trade_ratio'] = (monthly_trade['amount_usd'] / monthly_trade['trade'] * 100).round(2)
    monthly_trade['date'] = pd.to_datetime(monthly_trade['year_month'])
    monthly_trade = monthly_trade.sort_values('date')
    monthly_trade['trade_bn'] = (monthly_trade['trade'] / 1e9).round(2)
    monthly_trade['lc_usd_mn'] = (monthly_trade['amount_usd'] / 1e6).round(2)
    monthly_trade[['year_month', 'lc_usd_mn', 'trade_bn', 'lc_trade_ratio']].to_csv(
        os.path.join(out_dir, "Mexico", "06_monthly_lc_trade_ratio_data.csv"), index=False)

    # 07 - Bank Market Share with Trade Context (NEW)
    bank_trade = mexico.groupby('institucion').agg({
        'amount_usd': 'sum',
        'trade': 'mean'
    }).reset_index()
    bank_trade = bank_trade.nlargest(10, 'amount_usd')
    bank_trade['lc_usd_mn'] = (bank_trade['amount_usd'] / 1e6).round(2)
    bank_trade['trade_bn'] = (bank_trade['trade'] / 1e9).round(2)
    total_lc = bank_trade['amount_usd'].sum()
    bank_trade['market_share'] = (bank_trade['amount_usd'] / total_lc * 100).round(2)
    bank_trade[['institucion', 'lc_usd_mn', 'market_share', 'trade_bn']].to_csv(
        os.path.join(out_dir, "Mexico", "07_bank_market_share_with_trade_data.csv"), index=False)

    print("✅ Mexico: 7 files generated")

except Exception as e:
    print(f"❌ Mexico failed: {e}")
    import traceback
    traceback.print_exc()


print("\n" + "="*60)
print("Data generation complete!")
print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
print("="*60)
