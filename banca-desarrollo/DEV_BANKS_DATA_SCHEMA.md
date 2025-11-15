# 📋 Development Banks Data Schema
**Version:** 1.0
**Purpose:** Define structure for unified dev banks TF panel

---

## 📊 Future Output Structure: `data/dev_banks_tf_panel.csv`

### Core Columns (Mandatory)

```csv
year,country,institution,institution_type,product_type,
amount_usd_millions,operation_count,
firm_size_sme_pct,firm_size_large_pct,
sector_primary,sector_primary_pct,
sector_secondary,sector_secondary_pct,
region_primary,region_primary_pct,
extraction_confidence,data_source,notes
```

### Column Definitions

| Column | Type | Units | Definition | Example |
|--------|------|-------|-----------|---------|
| **year** | int | YYYY | Fiscal year | 2023 |
| **country** | str | ISO 2-letter | Country of development bank | BR, CL, MX |
| **institution** | str | Code | Development bank code | BNDES, CORFO, NAFIN |
| **institution_type** | str | Categorical | Type of dev bank | "National", "Regional", "Sectoral", "Multilateral" |
| **product_type** | str | Categorical | Type of TF product | "LC", "Export Credit", "Guarantee", "Insurance", "Factoring", "Rediscount" |
| **amount_usd_millions** | float | USD Millions | Total volume for product/year | 1250.5 |
| **operation_count** | int | Count | Number of operations | 523 |
| **firm_size_sme_pct** | float | % | % of TF to SMEs | 35.2 |
| **firm_size_large_pct** | float | % | % of TF to large firms | 64.8 |
| **sector_primary** | str | Categorical | Top sector | "Manufactura", "Agricultura", "Servicios", "Minería" |
| **sector_primary_pct** | float | % | % of TF in top sector | 42.5 |
| **sector_secondary** | str | Categorical | Second sector | "Agricultura" |
| **sector_secondary_pct** | float | % | % in second sector | 28.3 |
| **region_primary** | str | Categorical | Geographic region with most TF | "Región Metropolitana", "Estado de São Paulo", "Sonora" |
| **region_primary_pct** | float | % | % TF in primary region | 45.2 |
| **extraction_confidence** | str | Categorical | Data quality | "LOW", "MEDIUM", "HIGH" |
| **data_source** | str | Text | PDF file name or section | "bndes_relatorio_anual_2023.pdf" |
| **notes** | str | Text | Additional info | "Manual extraction from page 42" |

---

## 🏗️ Extended Columns (Optional - For Rich Analysis)

### Product-Level Metrics (When Available)

```csv
lc_volume_usd,export_credit_volume_usd,guarantee_volume_usd,
insurance_volume_usd,factoring_volume_usd,rediscount_volume_usd,
```

### SME-Specific Metrics

```csv
sme_loan_count,sme_avg_loan_size_usd,sme_approval_rate_pct,
sme_geographic_concentration_hhi,
```

### Risk & Performance Metrics

```csv
npl_rate_pct,default_rate_pct,cost_of_guarantee_bps,
recovery_rate_pct,
```

### Growth & Dynamics

```csv
ytoy_growth_pct,covid_2020_change_pct,recovery_2021_pct,
trend_2019_2023_cagr_pct,
```

### Sectoral Detail (When Available)

```csv
sector_3,sector_3_pct,sector_4,sector_4_pct,
top_sector_export_category,
```

### Regional Detail (When Available)

```csv
region_secondary,region_secondary_pct,
coastal_vs_inland_ratio,
regional_concentration_hhi,
```

---

## 🎯 Data Extraction Priority Matrix

### **TIER 1: Essential Metrics** ⭐⭐⭐
*Must have for meaningful analysis*

| Metric | Why Essential | Data Source |
|--------|---------------|-------------|
| **TF Portfolio Outstanding** | Base for public/private comparison | Annual report balance sheet |
| **New Disbursements (Annual)** | Captures current activity | Annual report, section "Desembolsos" |
| **SME %** | Key for inclusion analysis | Annual report, firm size breakdown |
| **Product Mix** (LC/Credit/Guarantee) | Different products have different multipliers | Product line revenue section |
| **Top Sector %** | What TF finances | Sectoral breakdown in annual report |

### **TIER 2: Important Metrics** ⭐⭐
*Highly valuable for policy analysis*

| Metric | Why Important | Data Source |
|--------|---------------|-------------|
| **Guarantee Volumes Issued** | Shows counter-cyclical role | Guarantee program reports |
| **Regional Distribution** | Analyzes geographic equity | Regional breakdown by state/region |
| **Year-over-Year Growth %** | Captures institution dynamics | Multi-year comparison |
| **Crisis Response (2020 data)** | COVID-19 TF patterns | 2020 vs 2019 comparison |
| **Operation Count** | Efficiency/reach metric | Operations summary |

### **TIER 3: Supporting Metrics** ⭐
*Valuable context but not essential*

| Metric | Why Valuable | Data Source |
|--------|---------------|-------------|
| Cost of guarantee (bps) | Pass-through to borrowers | Guarantee cost disclosure |
| Default rate % | Credit quality | Risk management section |
| Geographic concentration HHI | Equity analysis | Regional breakdown |
| Recovery rate % | Portfolio quality | Credit risk section |

---

## 📦 Data Collection Timeline

### **Phase 1: Download (This Week)**
- ✅ Create directory structure
- ⏳ Download all accessible PDFs
- ⏳ Manual download of blocked sources

### **Phase 2: Extraction (Next Week)**
- Manual extraction of Tier 1 metrics from each institution
- OCR processing if PDF is image-based
- Validation of extracted numbers

### **Phase 3: Panel Assembly (Week 3)**
- Consolidate into `dev_banks_tf_panel.csv`
- Cross-validation with official reports
- Document all gaps/assumptions

### **Phase 4: Analysis (Week 4)**
- Compare public vs. private TF (with national banking data)
- SME access impact analysis
- Crisis response comparison (2019-2021)
- Regional equity assessment

---

## 🔄 Data Governance & Versioning

### Version Control Strategy

```
data/
├── dev_banks_tf_panel_v1.0.csv    # Initial extraction (LOW confidence)
├── dev_banks_tf_panel_v1.1.csv    # After manual validation
├── dev_banks_tf_panel_v2.0.csv    # After OCR improvement
└── dev_banks_tf_panel_FINAL.csv   # Production version
```

### Quality Assurance Checklist

- [ ] All downloaded PDFs in correct directories
- [ ] Extraction confidence assessed for each record
- [ ] Year consistency (all 2023? Mix of years?)
- [ ] Currency conversion verified (all USD millions?)
- [ ] SME % logic checked (should ≈ 100% if only product category)
- [ ] Growth metrics validated (compare with official reports)
- [ ] Sector % sum ≈ 100% (or document exclusions)
- [ ] Regional % sum ≈ 100% (or document exclusions)

---

## 🔍 Key Validation Rules

### Must-Have Validation

```python
# All rows must have these
assert df['year'].notna().all(), "Missing years"
assert df['country'].notna().all(), "Missing countries"
assert df['institution'].notna().all(), "Missing institutions"
assert df['amount_usd_millions'].notna().all(), "Missing amounts"

# Cross-checks
assert (df['firm_size_sme_pct'] + df['firm_size_large_pct'] <= 100).all(), "Size % > 100%"
assert (df['sector_primary_pct'] + df['sector_secondary_pct'] <= 100).all(), "Sector % > 100%"
assert df['amount_usd_millions'] > 0, "Negative amounts"
```

### Recommended Validation

```python
# Consistency checks
assert df['extraction_confidence'].isin(['LOW', 'MEDIUM', 'HIGH']).all()

# Outlier detection
assert (df['ytoy_growth_pct'] > -100) & (df['ytoy_growth_pct'] < 500), "Extreme growth"

# Product consistency
products_by_country = {
    'Colombia': ['LC', 'Export Credit', 'Guarantee', 'Rediscount'],
    'Brasil': ['LC', 'Export Credit', 'Guarantee', 'Insurance'],
    'Chile': ['Guarantee'],  # CORFO mainly guarantees
    'México': ['Export Credit', 'Guarantee', 'Insurance'],
}
```

---

## 🎯 Expected Output Statistics

Once panel is complete:

### Records Expected
- **Institutions:** 17 (+ CABEI if accessible)
- **Countries:** 12 + 3 multilateral
- **Years:** Primarily 2023 (some 2024 if available)
- **Product Types:** ~8 (LC, Export Credit, Guarantee, Insurance, Factoring, Rediscount, etc.)
- **Total Rows:** ~50-100 (17 institutions × mix of product types)

### Data Completeness Expected

| Metric | Expected Completion % | Confidence |
|--------|----------------------|------------|
| TF Portfolio | 95% | HIGH - all annual reports |
| SME % | 60% | MEDIUM - not all report this |
| Product Mix | 70% | MEDIUM - varies by institution |
| Sector % | 80% | HIGH - most report this |
| Regional % | 50% | LOW - some countries confidential |
| Growth % | 85% | MEDIUM - compare year-to-year |

---

## 🔗 Integration with National TF Data

### Comparison Framework

Once both dev banks and national banking data are in CSV format:

```python
# Calculate public/private TF share by country
public_tf = dev_banks_panel[dev_banks_panel.country == 'BR'].amount_usd_millions.sum()
private_tf = national_banking_data[national_banking_data.country == 'BR'].amount_usd_millions.sum()

public_share_pct = 100 * public_tf / (public_tf + private_tf)
```

### Analysis Questions Enabled

1. **"Is public TF 20-30% as estimated?"** → Quantify actual share
2. **"Did dev banks expand during COVID-19?"** → Compare 2019 vs. 2020 vs. 2021
3. **"Are dev banks pro-SME?"** → Compare SME % (dev banks vs. private banks)
4. **"Is guarantee effectiveness documented?"** → Measure cost vs. private bank spread
5. **"Are there regional equity gaps?"** → Compare HHI (dev banks vs. private)

---

## 📝 Documentation Templates

### Per-Institution Extraction Notes

```markdown
## BNDES 2023 Extraction

**File:** bndes_relatorio_anual_2023.pdf
**Pages Reviewed:** 1-200
**Data Quality:** MEDIUM

### Extracted Metrics
- **TF Portfolio:** $X billion (page 85, Balance Sheet)
- **SME Share:** X% (page 42, Beneficiaries section)
- **Product Mix:** (table page 55)
  - Letters of Credit: X%
  - Export Credit: X%
  - Guarantees: X%

### Notes
- 2020 data from page 120 for COVID analysis
- Regional breakdown only available at portfolio level (not TF-specific)
- Guarantee multiplier estimated based on industry practice (20-30% private TF enabled)

### Confidence Assessment
- TF Portfolio: HIGH (official balance sheet)
- SME Share: MEDIUM (derived from beneficiary count)
- Regional Detail: LOW (aggregated only)
```

---

## 🚀 Next Steps

1. **Directories Created:** ✅
2. **Schema Defined:** ✅ (this document)
3. **Extraction Script:** ✅ Created (extract_devbanks_metrics.py)
4. **PDFs to Download:** ⏳ Manual browser downloads needed
5. **Data Extraction:** ⏳ Manual + script processing
6. **Panel Assembly:** ⏳ Consolidate into CSV
7. **Validation:** ⏳ Quality checks
8. **Integration:** ⏳ Combine with national banking data

---

**Status:** Ready for data collection phase
