# 📝 CAPTIONS SYSTEM - TRADE FINANCE PLOTS

**Purpose:** Separate titles, sources, and notes from plot images for flexibility in publication.

---

## 📋 STRUCTURE

### Files in this folder:
- **captions.csv** - Main caption database (16 rows, 1 per plot)
- **README.md** - This file (usage instructions)

---

## 📊 CAPTIONS.CSV STRUCTURE

| Column | Description | Example |
|--------|-------------|---------|
| `figure_id` | Unique plot identifier | `mex_01`, `per_01`, `chl_01`, `bra_01` |
| `title` | Full descriptive title | "Outstanding Letters of Credit as Percentage of Total Liabilities" |
| `caption` | Extended description | "Time series showing the evolution of letters of credit..." |
| `source` | Data source (full name) | "CNBV (Comisión Nacional Bancaria y de Valores) R12A Balance Sheets" |
| `notes` | Methodological notes | "Data extracted from account 202401504003..." |

---

## 🎨 PLOT DESIGN PHILOSOPHY

### ✅ INCLUDED IN PLOT IMAGE:
- Clean axes with labels (e.g., "Year", "USD Millions", "Percentage")
- Legend (if multiple series)
- Grid lines (minimal, subtle)
- Data points/lines/bars

### ❌ EXCLUDED FROM PLOT IMAGE:
- **Title** → Goes in `captions.csv`
- **Source** → Goes in `captions.csv`
- **Caption** → Goes in `captions.csv`
- **Notes** → Goes in `captions.csv`

**Rationale:**
- Flexibility for different publication formats (papers, presentations, reports)
- Easy translation to other languages
- Consistent styling across documents
- Separate visual data from textual metadata

---

## 📖 USAGE EXAMPLES

### LaTeX (Academic Paper)

```latex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\textwidth]{plots/mexico/mex_01_lc_pct_liabilities.png}
  \caption{Outstanding Letters of Credit as Percentage of Total Liabilities. 
           Time series showing the evolution of letters of credit reported as 
           liabilities by Mexican banks, expressed as percentage of total bank 
           liabilities. Period: January 2022 to August 2025, monthly frequency.}
  \label{fig:mex01}
  \source{CNBV (Comisión Nacional Bancaria y de Valores) R12A Balance Sheets.}
  \note{Data extracted from account 202401504003 (Import L/C ≤180 days) divided 
        by account 200000000000 (Total Liabilities).}
\end{figure}
```

### R Markdown

```markdown
![](plots/mexico/mex_01_lc_pct_liabilities.png)

**Figure 1:** Outstanding Letters of Credit as Percentage of Total Liabilities

Time series showing the evolution of letters of credit reported as liabilities 
by Mexican banks, expressed as percentage of total bank liabilities. Period: 
January 2022 to August 2025, monthly frequency.

*Source:* CNBV (Comisión Nacional Bancaria y de Valores) R12A Balance Sheets.

*Note:* Data extracted from account 202401504003 (Import L/C ≤180 days) divided 
by account 200000000000 (Total Liabilities).
```

### PowerPoint Slide

```
[Insert image: mex_01_lc_pct_liabilities.png]

Title box: "Outstanding L/C as % of Total Liabilities"
Footer: "Source: CNBV R12A | Period: 2022-2025"
```

### Python/Pandas Integration

```python
import pandas as pd
import matplotlib.pyplot as plt

# Load captions
captions = pd.read_csv('captions/captions.csv')

# Get caption for specific plot
mex_01 = captions[captions['figure_id'] == 'mex_01'].iloc[0]

# Display plot with separate title/source
fig, ax = plt.subplots(figsize=(10, 6))
# ... plot data ...
plt.title(mex_01['title'], pad=20)
plt.figtext(0.5, 0.01, f"Source: {mex_01['source']}", 
            ha='center', fontsize=8, style='italic')
plt.savefig('plots/mexico/mex_01_lc_pct_liabilities.png', 
            dpi=300, bbox_inches='tight')
```

---

## 🔧 R SCRIPT INTEGRATION

### Load captions in R

```r
library(tidyverse)

# Load captions
captions <- read_csv("captions/captions.csv")

# Get caption for specific plot
get_caption <- function(fig_id) {
  captions %>% 
    filter(figure_id == fig_id) %>% 
    pull(caption)
}

# Example
mex_01_caption <- get_caption("mex_01")
```

### Generate plot WITHOUT title/source

```r
# México Plot 1: L/C % Liabilities
p <- ggplot(mexico_monthly, aes(x = date, y = lc_pct_liabilities)) +
  geom_line(color = "#2E86AB", size = 1.2) +
  geom_area(fill = "#2E86AB", alpha = 0.2) +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  labs(
    x = "Month",
    y = "L/C as % of Total Liabilities"
    # NO title here
    # NO caption here
    # NO source here
  ) +
  theme_minimal() +
  theme(
    plot.title = element_blank(),      # Ensure no title
    plot.caption = element_blank(),    # Ensure no caption
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 9)
  )

# Save clean plot
ggsave("plots/mexico/mex_01_lc_pct_liabilities.png", p,
       width = 8, height = 6, dpi = 300)
```

---

## 📑 SPECIAL NOTES

### Chile Empalme Note

All Chile plots include this critical note:

> "CRITICAL NOTE: Accounting change January 2022 (SBIF→CMF). Series spliced 
> using ratio-to-total-loans method to ensure comparability. SBIF period uses 
> 11 identified accounts, CMF period uses 29 accounts. The increase in 2022 
> reflects better identification of trade finance accounts under IFRS9, not 
> necessarily real growth."

**Why important:**
- Volume jump 2021→2022 is methodological, not economic
- Comparisons across 2022 break require caution
- Ratio-based metrics (TF/Total Loans) more stable than absolute values

### Brazil Data Limitations

Brazil plots note:

> "Brazil data aggregated by state, sector, and borrower size. No individual 
> bank-level data available in public SCR extracts."

**Implications:**
- Cannot calculate bank-level concentration (HHI/CR5)
- "By bank type" plots replaced with regional/sectoral alternatives
- Comparisons with Peru/Chile limited to size distribution

---

## 🌐 TRANSLATION READY

All captions in English for international publication. To translate:

1. Copy `captions.csv` → `captions_es.csv`
2. Translate `title`, `caption`, `notes` columns to Spanish
3. Keep `figure_id` and `source` in English (standardized)
4. Load appropriate file based on output language

```r
# Select language
lang <- "en"  # or "es", "pt", etc.
captions_file <- paste0("captions/captions_", lang, ".csv")
captions <- read_csv(captions_file)
```

---

## 📊 CAPTION INVENTORY

**Total plots:** 16

| Country | Plots | Figure IDs |
|---------|-------|------------|
| México | 2 | mex_01, mex_02 |
| Perú | 4 | per_01, per_02, per_03, per_04 |
| Chile | 6 | chl_01, chl_02, chl_03, chl_04, chl_05, chl_06 |
| Brasil | 5 | bra_01, bra_02, bra_03, bra_04, bra_05 |

**Missing plots:** None (all 16 defined)

---

## ✅ QUALITY CHECKLIST

For each caption entry:

- [ ] **figure_id** matches filename (e.g., `mex_01` → `mex_01_lc_pct_liabilities.png`)
- [ ] **title** is concise but descriptive (max 100 characters)
- [ ] **caption** provides full context (150-300 words)
- [ ] **source** includes full institution name + dataset
- [ ] **notes** explain any methodological issues (empalme, data gaps, etc.)

---

## 🔄 UPDATE WORKFLOW

When adding new plots:

1. Generate plot image WITHOUT title/source
2. Save to `plots/{country}/{figure_id}_descriptive_name.png`
3. Add row to `captions.csv` with all 5 columns
4. Update this README if needed
5. Commit both image and caption together

---

**Last updated:** 19 November 2025  
**Maintained by:** Tomás Fernández  
**Questions:** Check PLOTS_FINAL_PLAN.md for overall structure
