# 📊 INDEX - TRADE FINANCE PLOTS (17 TOTAL)

**Generated:** November 19, 2025  
**Status:** ✅ ALL COMPLETE

---

## 🗂️ QUICK NAVIGATION

### 🇲�� MÉXICO (2/2)
- **MEX-1:** L/C as % of Liabilities → `plots/mexico/mex_01_lc_pct_liabilities.png`
- **MEX-2:** L/C by Bank Type → `plots/mexico/mex_02_lc_by_bank_type.png`

### 🇵🇪 PERÚ (4/4)
- **PER-1:** TF as % of Total Credit → `plots/peru/per_01_tf_pct_total.png`
- **PER-2:** TF by Borrower Size → `plots/peru/per_02_tf_by_size.png`
- **PER-3:** TF by Bank Type → `plots/peru/per_03_tf_by_bank_type.png`
- **PER-4:** Market Concentration → `plots/peru/per_04_concentration.png`

### 🇨🇱 CHILE (6/6) ⚠️ WITH EMPALME SBIF→CMF
- **CHL-1:** TF as % of Total Loans → `plots/chile/chl_01_tf_pct_loans.png`
- **CHL-2:** TF by Bank Type → `plots/chile/chl_02_tf_by_bank_type.png`
- **CHL-3:** Market Concentration → `plots/chile/chl_03_concentration.png`
- **CHL-4:** Foreign Funding Sources → `plots/chile/chl_04_foreign_funding.png`
- **CHL-5:** L/C as % of Liabilities → `plots/chile/chl_05_lc_pct_liabilities.png`
- **CHL-6:** L/C by Bank Type → `plots/chile/chl_06_lc_by_bank_type.png`

### 🇧🇷 BRASIL (5/5) ⚠️ REGIONAL ALTERNATIVES
- **BRA-1:** TF as % of Total Credit → `plots/brazil/bra_01_tf_pct_total.png`
- **BRA-2:** TF by Borrower Size → `plots/brazil/bra_02_tf_by_size.png`
- **BRA-3:** TF by Region (Top 10 States) → `plots/brazil/bra_03_tf_by_region.png`
- **BRA-4:** Regional Concentration → `plots/brazil/bra_04_regional_concentration.png`
- **BRA-5:** Size Comparison Brasil vs Peru → `plots/brazil/bra_05_size_comparison.png`

---

## 📋 METADATA

### Captions & Sources
**File:** `captions/captions.csv` (17 entries)  
**Usage:** See `captions/README.md` for LaTeX/RMarkdown/PowerPoint integration

**Structure:**
```csv
figure_id,title,caption,source,notes
mex_01,"Outstanding Letters of Credit...","Time series showing...","CNBV R12A Balance Sheets","Data extracted from..."
```

### Data Tables
**Location:** `tables/{country}/`  
**Format:** CSV (one per plot)  
**Columns:** Vary by plot (date, values, categories, accounting_system for Chile)

### Scripts
**Location:** `scripts/`
- `02_mexico_analysis_FINAL.R` (generates MEX-1, MEX-2)
- `03_peru_analysis.R` (generates PER-1 to PER-4)
- `04_chile_analysis.R` (generates CHL-1 to CHL-6 WITH EMPALME)
- `05_brazil_analysis.R` (generates BRA-1 to BRA-5 WITH ALTERNATIVES)

---

## 🎨 PLOT SPECIFICATIONS

### Image Formats
- **PNG:** 300 DPI (presentation/web)
- **PDF:** Vector (LaTeX/academic papers)
- **Size:** 10" × 6" (standard, 12" × 6" for BRA-3 multi-line)

### Design
- ✅ **NO titles** in images (clean axes only)
- ✅ **NO sources** in images
- ✅ Clean theme (`theme_minimal()`)
- ✅ Color schemes:
  - México: Blue (#2E86AB)
  - Perú: Red (#D91023) + viridis
  - Chile: Red (#E63946) + blues
  - Brasil: Green (#009C3B) + blue (#002776)

---

## 🔍 SPECIAL FEATURES

### Chile: SBIF→CMF Accounting Transition (2022)
**Implementation:**
- Visual break line at 2022-01-01 (dotted gray)
- Annotation "Accounting Transition"
- Column `accounting_system` in CSV tables (SBIF/CMF)
- Moving averages (MA3, MA6) smooth transition
- CRITICAL NOTE in captions

**Files affected:** CHL-1 to CHL-6 (all 6 plots)

### Brasil: Regional Alternatives (NO Bank Data)
**Alternatives:**
- BRA-3: TF by **region** (Top 10 states) instead of "by bank type"
- BRA-4: **Regional CR5** instead of bank HHI
- Notes explain limitation in captions

**Justification:** BCB aggregates data, NO individual banks available

---

## 📊 KEY FINDINGS SUMMARY

### México (2022-2025)
- L/C: 0.055%-0.123% of liabilities (low, stable)
- Domestic banks: 97.9% (USD 20,415M) vs Foreign 2.1% (USD 445M)

### Perú (2010-2024)
- TF: 0.79%-1.82% of total credit
- Size: Large 92.1% (corporate-focused)
- Concentration: HIGH (HHI 1688-2245, CR5 83.5%-93.8%)
- Foreign banks: 45% of TF (dominant)

### Chile (2015-2024)
- Accounting change 2022 (SBIF→CMF, 11→29 accounts)
- Concentration: MODERATE (HHI 1313-1729)
- 5 bank types identified
- 10-year series with empalme

### Brasil (2012-2024)
- TF: 65-266 billion BRL (growing trend)
- Size: Médio 53.8% (SME-focused, contrast with Perú)
- Regional: São Paulo dominates (40-45% national)
- CR5 regional: 71.1%-85.7% (high geographic concentration)

---

## 📚 DOCUMENTATION

### Main Reports
- **VALIDATION_REPORT.md** - Comprehensive validation (17/17 PASS)
- **RESUMEN_EJECUTIVO_FINAL.md** - Executive summary (Spanish)
- **PLOTS_FINAL_PLAN.md** - Original plan (corrected from 42 to 17)
- **PROGRESS_SUMMARY_FINAL.md** - Detailed progress log

### Data Documentation
- **README_MEXICO_DATA.md** - México data details
- **README_PERU_DATA.md** - Perú data details
- **README_CHILE_DATA.md** - Chile data + SBIF→CMF issue
- **README_BRASIL_DATA.md** - Brasil data + size validation
- **README_GMD_INTEGRATION.md** - GMD methodology

### Technical
- **CHILE_PLAN_CONTABLE_ISSUE.md** - Accounting transition diagnostic
- **captions/README.md** - Captions system usage
- **QUICK_START.md** - How to run scripts

---

## 🚀 USAGE EXAMPLES

### LaTeX (Academic Paper)
```latex
\begin{figure}[ht]
\centering
\includegraphics[width=0.8\textwidth]{plots/mexico/mex_01_lc_pct_liabilities.pdf}
\caption{Outstanding Letters of Credit as Percentage of Total Liabilities. 
Time series showing evolution of L/C outstanding in Mexican banking system. 
Source: CNBV R12A Balance Sheets (2022-2025).}
\label{fig:mex_01}
\end{figure}
```

### R Markdown
```r
captions <- read_csv("captions/captions.csv")
mex_01_caption <- captions %>% filter(figure_id == "mex_01")

knitr::include_graphics("plots/mexico/mex_01_lc_pct_liabilities.png")
```

### PowerPoint
1. Insert PNG: `plots/mexico/mex_01_lc_pct_liabilities.png`
2. Add title from `captions.csv` row `mex_01`
3. Add source as footer

---

## ✅ VALIDATION STATUS

**Date:** November 19, 2025  
**Result:** ✅ **17/17 PASS** (100%)  
**Critical Errors:** 0  
**Minor Warnings:** 3 (documented, acceptable)

### Checklist
- [x] NO titles in images (17/17)
- [x] NO sources in images (17/17)
- [x] PNG 300 DPI (17/17)
- [x] PDF vector (17/17)
- [x] CSV tables (17/17)
- [x] Captions in captions.csv (17/17)
- [x] Chile empalme (6/6)
- [x] Brasil alternatives (5/5)

---

**For detailed information, see VALIDATION_REPORT.md**
