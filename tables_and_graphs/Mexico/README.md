# Mexico Trade Finance - Data Tables

This folder contains data tables extracted from the Mexico Letters of Credit dataset (2,204 observations, 2022-2025).

## ⚠️ CRITICAL LIMITATION

**Mexico data covers ONLY letters of credit (LC)**, representing approximately **15-26% of the full trade finance market**. The estimated total TF market is USD 25-35 billion (vs USD 5.7bn LC observed).

## Files

### 01_bank_concentration_data.csv
Top 10 banks by LC volume.

**Columns:**
- `institucion`: Bank name (CNBV standard)
- `lc_usd`: LC portfolio in USD millions
- `market_share`: % of top 10 total
- `cumulative`: Cumulative market share

**Key Finding:** BBVA México + Santander = 50.9% (duopoly), CR5 = 81.0%.

---

### 02_annual_lc_volume_data.csv
Annual LC volumes and year-over-year growth (2022-2025*).

**Columns:**
- `year`: Year
- `lc_usd`: Total LC in USD billions
- `yoy_growth`: Year-over-year growth %

**Trend:** Stable USD 5.4-5.9 billion range, +3.8% CAGR.

*2025 includes only Jan-Aug (annualized projection: USD 5.94bn).

---

### 03_lc_seasonality_data.csv
Monthly LC seasonality index (average = 100).

**Columns:**
- `month`: Month (1-12)
- `avg_lc_usd`: Average LC per month in USD millions
- `index`: Seasonality index (100 = average)

**Pattern:** Peak in October-November (+7-10% above average) for holiday season preparation.

---

### 04_monthly_evolution_data.csv
Monthly LC volumes time series (Jan 2022 - Aug 2025).

**Columns:**
- `year_month`: Date (YYYY-MM-DD format)
- `lc_usd`: Total LC in USD millions

**Nearshoring Impact:** +7.7% LC growth since 2023, lagging FDI growth (+19.3%).

---

## Data Source
- **Original file:** `data/mexico_full.csv`
- **ETL script:** `Scripts/mexico_lc_etl.R`
- **Regulatory source:** Comisión Nacional Bancaria y de Valores (CNBV) - Report R12A Section 133
- **Profile:** [MEXICO_COUNTRY_PROFILE.md](../MEXICO_COUNTRY_PROFILE.md)

## Usage Notes
- All monetary values in **USD** (millions or billions as indicated)
- Only **letters of credit** data (import + export, not distinguished)
- Exchange rate: SAT FIX monthly average (MXN/USD)
- Time series: Very short (3 years, 2022-2025)
- No firm size, sectoral, or geographic breakdown

## Key Insights
- **Extreme concentration:** CR5 = 81.0% (tied with Peru as most concentrated)
- **Foreign bank dominance:** 68.4% market share (BBVA, Santander, HSBC, etc.)
- **Low LC usage:** LC/Trade = 0.50% (vs 15-25% international benchmark)
- **USMCA effect:** 66% trade with US enables open account (reduces LC need)
- **Data crisis:** 75-85% of TF market NOT captured (pre/post-export finance, loans, guarantees missing)

## Nearshoring Opportunity
- **Potential:** +USD 2.3 billion incremental TF by 2027
- **Sectors:** Auto parts, electronics, medical devices, aerospace
- **Regions:** Nuevo León, Chihuahua, Baja California, Querétaro

## Policy Recommendations
1. **Urgently expand CNBV reporting** to cover full TF spectrum (not just LC)
2. De-concentrate market: CR5 target from 81% to 65% by 2028
3. Create USD 2 billion Bancomext guarantee fund for SME TF
4. Digital TF platform for nearshoring-linked transactions

## Next Steps
To generate visualizations from these CSVs:
1. Import into Excel/Google Sheets/Tableau/PowerBI
2. Create bar chart for bank concentration (highlight BBVA + Santander duopoly)
3. Line chart for annual evolution with nearshoring annotation (2023+)
4. Line chart for monthly seasonality (mark October-November peaks)
5. **Important:** Add footnote to all graphs: "LC only, represents 15-26% of total TF market"
6. Reference the country profile for full context and limitations

## Recommended Caveats
When using Mexico data, always note:
- "Data represents letters of credit only, not full trade finance portfolio"
- "Estimated total TF market: USD 25-35 billion (4-7x larger than observed)"
- "Low LC/Trade ratio (0.5%) reflects USMCA integration and intra-firm trade"

---

**Last Updated:** 2025-11-11
**Contact:** Trade Finance Research Team
