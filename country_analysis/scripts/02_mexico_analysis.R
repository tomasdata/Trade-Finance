# ==============================================================================
# MEXICO TRADE FINANCE ANALYSIS - FINAL
# ==============================================================================
# Description: Generate 2 plots requested (L/C analysis)
# Data: mexico_processed.rds (2,204 obs, 2022-2025, 53 banks)
# Output: plots/mexico/*.png, plots/mexico/*.pdf, tables/mexico/*.csv
# Author: Tomás Fernández
# Date: November 2025
# ==============================================================================
# IMPORTANT: Plots have NO titles, NO sources (in captions/captions.csv)
# ==============================================================================

# Setup ------------------------------------------------------------------------
library(tidyverse)
library(scales)
library(viridis)

# Set paths
base_path <- "/Users/tomasfernandez/Documents/Tomas/Trade-Finance/country_analysis"
setwd(base_path)

# Create output directories
dir.create("plots/mexico", showWarnings = FALSE, recursive = TRUE)
dir.create("tables/mexico", showWarnings = FALSE, recursive = TRUE)

# Load data --------------------------------------------------------------------
cat("Loading Mexico processed data...\n")
mexico <- readRDS("data/processed/mexico_processed.rds")

# Check structure
cat("\nData structure:\n")
cat("Period:", min(mexico$date), "to", max(mexico$date), "\n")
cat("Number of banks:", n_distinct(mexico$institucion), "\n")
cat("Number of observations:", nrow(mexico), "\n\n")

# ==============================================================================
# MEX-1: Outstanding L/C (Monthly Evolution)
# ==============================================================================
cat("[1/4] Generating MEX-1: Outstanding L/C (Monthly)...\n")

mexico_monthly <- mexico %>%
  group_by(date, year, month) %>%
  summarise(
    lc_usd_millions = sum(lc_usd_millions, na.rm = TRUE),
    n_banks = n_distinct(institucion),
    .groups = "drop"
  )

# Export table
write_csv(mexico_monthly, "tables/mexico/mex_01_lc_monthly.csv")

# Create plot (NO title, NO source, clean only)
p1 <- ggplot(mexico_monthly, aes(x = date, y = lc_usd_millions)) +
  geom_line(color = "#2E86AB", linewidth = 1.2) +
  geom_area(fill = "#2E86AB", alpha = 0.2) +
  scale_y_continuous(
    labels = comma_format(),
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Outstanding L/C (USD millions)"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot
ggsave("plots/mexico/mex_01_lc_monthly.png", p1, 
       width = 10, height = 6, dpi = 300)

cat("✓ MEX-1 complete\n")
cat("  - Range: USD", round(min(mexico_monthly$lc_usd_millions), 0), "to",
    round(max(mexico_monthly$lc_usd_millions), 0), "millions\n")
cat("  - Files: mex_01_lc_monthly.png, .csv\n\n")

# ==============================================================================
# MEX-2: L/C as % of Total Liabilities (Monthly)
# ==============================================================================
cat("[2/5] Generating MEX-2: L/C as % of Total Liabilities...\n")

mexico_vs_liab <- mexico %>%
  group_by(date, year, month) %>%
  summarise(
    lc_usd_millions = sum(lc_usd_millions, na.rm = TRUE),
    total_liab_usd_millions = sum(total_liab_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    lc_pct_liabilities = (lc_usd_millions / total_liab_usd_millions) * 100
  )

# Export table
write_csv(mexico_vs_liab, "tables/mexico/mex_02_lc_pct_liabilities.csv")

# Create plot (NO title, NO source, clean only)
p2 <- ggplot(mexico_vs_liab, aes(x = date, y = lc_pct_liabilities)) +
  geom_line(color = "#A23B72", linewidth = 1.2) +
  geom_area(fill = "#A23B72", alpha = 0.2) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "L/C as % of Total Liabilities"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot
ggsave("plots/mexico/mex_02_lc_pct_liabilities.png", p2, 
       width = 10, height = 6, dpi = 300)

cat("✓ MEX-2 complete\n")
cat("  - Range:", 
    round(min(mexico_vs_liab$lc_pct_liabilities, na.rm = TRUE), 3), "% to",
    round(max(mexico_vs_liab$lc_pct_liabilities, na.rm = TRUE), 3), "%\n")
cat("  - Files: mex_02_lc_pct_liabilities.png, .csv\n\n")

# ==============================================================================
# MEX-3: Outstanding L/C by Type of Bank
# ==============================================================================
cat("[3/5] Generating MEX-3: L/C by Bank Type...\n")

# Simplify bank_type classification
mexico <- mexico %>%
  mutate(
    bank_type_simple = case_when(
      str_detect(bank_type, "Foreign") ~ "Foreign",
      str_detect(bank_type, "State") ~ "State",
      TRUE ~ "Domestic"
    )
  )

# Aggregate by bank type and MONTH (keep temporal granularity)
mexico_by_type <- mexico %>%
  group_by(bank_type_simple, date, year, month) %>%
  summarise(
    lc_usd_millions = sum(lc_usd_millions, na.rm = TRUE),
    n_banks = n_distinct(institucion),
    .groups = "drop"
  )

# Export table
write_csv(mexico_by_type, "tables/mexico/mex_03_lc_by_bank_type.csv")

# Create plot - MONTHLY evolution (NO title, NO source, clean only)
p3 <- ggplot(mexico_by_type, aes(x = date, y = lc_usd_millions, fill = bank_type_simple)) +
  geom_area(position = "stack", alpha = 0.8) +
  scale_fill_viridis_d(option = "plasma", begin = 0.2, end = 0.8) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  scale_y_continuous(
    labels = comma_format(),
    expand = expansion(mult = c(0, 0.1))
  ) +
  labs(
    x = "Month",
    y = "Outstanding L/C (USD millions)",
    fill = "Bank Type"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot
ggsave("plots/mexico/mex_03_lc_by_bank_type.png", p3, 
       width = 8, height = 6, dpi = 300)

cat("✓ MEX-3 complete\n")
cat("  - Foreign banks L/C:", 
    round(sum(mexico_by_type %>% filter(bank_type_simple == "Foreign") %>% pull(lc_usd_millions)), 0),
    "USD millions\n")
cat("  - Domestic banks L/C:", 
    round(sum(mexico_by_type %>% filter(bank_type_simple == "Domestic") %>% pull(lc_usd_millions)), 0),
    "USD millions\n")
cat("  - Files: mex_03_lc_by_bank_type.png, .csv\n\n")

# ==============================================================================
# MEX-4: L/C as % of Exports (MONTHLY - L/C stock as % of annual exports)
# ==============================================================================
cat("[4/5] Generating MEX-4: L/C as % of Exports (Monthly)...\n")

# Calculate MONTHLY L/C stock as % of ANNUAL exports
mexico_vs_exports <- mexico %>%
  group_by(year, month) %>%
  summarise(
    lc_month = sum(lc_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),  # Annual exports
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    lc_pct_exports = (lc_month / exports_annual) * 100
  ) %>%
  arrange(date)

# Export table
write_csv(mexico_vs_exports %>% select(date, year, month, lc_month, exports_annual, lc_pct_exports), 
          "tables/mexico/mex_04_lc_pct_exports.csv")

# Create plot (NO title, NO source, clean only)
p4 <- ggplot(mexico_vs_exports, aes(x = date, y = lc_pct_exports)) +
  geom_line(color = "#2E86AB", linewidth = 1.2) +
  geom_point(color = "#2E86AB", size = 1.5, alpha = 0.6) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Monthly L/C Stock as % of Annual Exports"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot (PNG only)
ggsave("plots/mexico/mex_04_lc_pct_exports.png", p4, 
       width = 10, height = 6, dpi = 300)

cat("✓ MEX-3 complete\n")
cat("  - Range:", 
    round(min(mexico_vs_exports$lc_pct_exports, na.rm = TRUE), 3), "% to",
    round(max(mexico_vs_exports$lc_pct_exports, na.rm = TRUE), 3), "%\n")
cat("  - Files: mex_03_lc_pct_exports.png, .csv\n\n")

# ==============================================================================
# MEX-4: L/C as % of Trade (MONTHLY - L/C stock as % of annual exports+imports)
# ==============================================================================
cat("[4/4] Generating MEX-4: L/C as % of Total Trade (Monthly)...\n")

# Calculate MONTHLY L/C stock as % of ANNUAL trade (exports + imports)
mexico_vs_trade <- mexico %>%
  group_by(year, month) %>%
  summarise(
    lc_month = sum(lc_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),  # Annual exports
    imports_annual = first(imports_usd_millions),  # Annual imports
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    trade_annual = exports_annual + imports_annual,
    lc_pct_trade = (lc_month / trade_annual) * 100
  ) %>%
  arrange(date)

# Export table
write_csv(mexico_vs_trade %>% select(date, year, month, lc_month, exports_annual, imports_annual, trade_annual, lc_pct_trade), 
          "tables/mexico/mex_04_lc_pct_trade.csv")

# Create plot (NO title, NO source, clean only)
p5 <- ggplot(mexico_vs_trade, aes(x = date, y = lc_pct_trade)) +
  geom_line(color = "#A23B72", linewidth = 1.2) +
  geom_point(color = "#A23B72", size = 1.5, alpha = 0.6) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Monthly L/C Stock as % of Annual Trade (Exports + Imports)"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot (PNG only)
ggsave("plots/mexico/mex_05_lc_pct_trade.png", p5, 
       width = 10, height = 6, dpi = 300)

cat("✓ MEX-5 complete\n")
cat("  - Range:", 
    round(min(mexico_vs_trade$lc_pct_trade, na.rm = TRUE), 3), "% to",
    round(max(mexico_vs_trade$lc_pct_trade, na.rm = TRUE), 3), "%\n")
cat("  - Files: mex_05_lc_pct_trade.png, .csv\n\n")

# ==============================================================================
# MEX-6: L/C BY TOP 5 BANKS (STACKED AREA - MONTHLY)
# ==============================================================================
cat("[6/6] Generating MEX-6: L/C by Top 5 Banks...\n")

# Calculate top 5 banks by L/C volume
top_lc_banks <- mexico %>%
  filter(!is.na(institucion)) %>%
  group_by(institucion) %>%
  summarise(
    total_lc = sum(lc_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_lc)) %>%
  slice_head(n = 5)

cat("  - Top 5 L/C banks:", paste(top_lc_banks$institucion, collapse = ", "), "\n")

# Aggregate L/C by MONTH and top 5 banks
mexico_lc_top5_monthly <- mexico %>%
  filter(institucion %in% top_lc_banks$institucion) %>%
  group_by(date, institucion) %>%
  summarise(
    lc_usd_millions = sum(lc_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(top_lc_banks %>% select(institucion, total_lc), by = "institucion") %>%
  mutate(
    institucion = factor(institucion, levels = rev(top_lc_banks$institucion))  # Reverse for stacking order
  )

# STACKED AREA plot (monthly)
p6 <- ggplot(mexico_lc_top5_monthly, aes(x = date, y = lc_usd_millions, fill = institucion)) +
  geom_area(alpha = 0.8) +
  scale_fill_viridis_d(option = "turbo", begin = 0.1, end = 0.9) +
  scale_y_continuous(labels = comma_format()) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Outstanding L/C (USD millions)",
    fill = "Bank"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/mexico/mex_06_lc_top5_banks.png", p6, width = 10, height = 6, dpi = 300)

# Export table (monthly data)
mexico_lc_top5_monthly %>%
  select(date, institucion, lc_usd_millions) %>%
  pivot_wider(names_from = institucion, values_from = lc_usd_millions, values_fill = 0) %>%
  write_csv("tables/mexico/mex_06_lc_top5_banks.csv")

cat("✓ MEX-6 complete\n")
cat("  - Top L/C bank:", top_lc_banks$institucion[1], "(USD", round(top_lc_banks$total_lc[1], 0), "millions total)\n")
cat("  - Files: mex_06_lc_top5_banks.png, .csv\n\n")

# Summary ----------------------------------------------------------------------
cat(rep("=", 70), "\n", sep = "")
cat("MEXICO ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n✓ 6/6 plots generated (1 volume + 1 balance ratio + 1 by type + 2 trade ratios + 1 top 5)\n")
cat("\nOutputs:\n")
cat("  plots/mexico/\n")
cat("    - mex_01_lc_monthly.png (300 DPI)\n")
cat("    - mex_02_lc_pct_liabilities.png (300 DPI)\n")
cat("    - mex_03_lc_by_bank_type.png (300 DPI)\n")
cat("    - mex_04_lc_pct_exports.png (300 DPI)\n")
cat("    - mex_05_lc_pct_trade.png (300 DPI)\n")
cat("    - mex_06_lc_top5_banks.png (300 DPI)\n")
cat("\n  tables/mexico/\n")
cat("    - mex_01_lc_monthly.csv\n")
cat("    - mex_02_lc_pct_liabilities.csv\n")
cat("    - mex_03_lc_by_bank_type.csv\n")
cat("    - mex_04_lc_pct_exports.csv\n")
cat("    - mex_05_lc_pct_trade.csv\n")
cat("    - mex_06_lc_top5_banks.csv\n")
cat("\nCaptions:\n")
cat("  See captions/captions.csv for titles, sources, and notes\n")
cat("\nKey findings:\n")
cat("  1. L/C volume range: USD", round(min(mexico_monthly$lc_usd_millions), 0), 
    "to", round(max(mexico_monthly$lc_usd_millions), 0), "millions\n")
cat("  2. L/C as % of liabilities:", round(mean(mexico_vs_liab$lc_pct_liabilities), 3), "% (avg)\n")
cat("  3. Foreign banks dominate L/C market\n")
cat("  4. L/C as % of exports:", round(mean(mexico_vs_exports$lc_pct_exports), 2), "% (annual avg)\n")
cat("  5. L/C as % of trade:", round(mean(mexico_vs_trade$lc_pct_trade), 2), "% (annual avg)\n")
cat(rep("=", 70), "\n", sep = "")
