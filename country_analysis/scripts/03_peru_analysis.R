#!/usr/bin/env Rscript
# ==============================================================================
# PERÚ ANALYSIS - 7 PLOTS
# ==============================================================================
# IMPORTANT: Plots have NO titles, NO sources in images (clean axes only)
# All titles, sources, notes are in captions/captions.csv
# ==============================================================================

library(tidyverse)
library(scales)
library(viridis)

# Setup paths
setwd("/Users/tomasfernandez/Documents/Tomas/Trade-Finance/country_analysis")
plots_dir <- "plots/peru"
tables_dir <- "tables/peru"

# Create directories
dir.create(plots_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

# ==============================================================================
# LOAD DATA
# ==============================================================================
cat("\n")
cat("======================================================================\n")
cat("PERÚ ANALYSIS - GENERATING 4 PLOTS\n")
cat("======================================================================\n\n")

peru <- readRDS("data/processed/peru_processed.rds")

cat("Loading Peru processed data...\n")
cat("Period:", min(peru$date), "to", max(peru$date), "\n")
cat("Number of banks:", length(unique(peru$institucion)), "\n")
cat("Number of observations:", nrow(peru), "\n")
cat("Borrower size categories:", unique(peru$size_category) %>% sort() %>% paste(collapse = ", "), "\n")
cat("Bank types:", unique(peru$bank_type) %>% na.omit() %>% sort() %>% paste(collapse = ", "), "\n\n")

# ==============================================================================
# PER-1: TRADE FINANCE AS % OF TOTAL CREDIT (TIME SERIES)
# ==============================================================================
cat("[1/4] Generating PER-1: TF as % of Total Credit...\n")

peru_agg <- peru %>%
  group_by(date) %>%
  summarise(
    tf_total = sum(tf_usd_millions, na.rm = TRUE),
    credit_total = sum(total_credit_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    tf_pct_total = (tf_total / credit_total) * 100
  )

p1 <- ggplot(peru_agg, aes(x = date, y = tf_pct_total)) +
  geom_line(color = "#C1121F", size = 1.2) +
  geom_area(fill = "#C1121F", alpha = 0.2) +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "Foreign-Trade Loans as % of Total Credit"
    # NO title, NO caption - in captions.csv (per_01)
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    panel.grid.minor = element_blank()
  )

ggsave(file.path(plots_dir, "per_01_tf_pct_total.png"), p1, width = 10, height = 6, dpi = 300)
write.csv(peru_agg, file.path(tables_dir, "per_01_tf_pct_total.csv"), row.names = FALSE)

cat("✓ PER-1 complete\n")
cat("  - Range:", min(peru_agg$tf_pct_total, na.rm = TRUE) %>% round(2), "% to",
    max(peru_agg$tf_pct_total, na.rm = TRUE) %>% round(2), "%\n")
cat("  - Files: per_01_tf_pct_total.png, .pdf, .csv\n\n")

# ==============================================================================
# PER-2: TRADE FINANCE BY BORROWER SIZE (STACKED AREA)
# ==============================================================================
cat("[2/4] Generating PER-2: TF by Borrower Size...\n")

# Use existing size_category column
peru_by_size <- peru %>%
  filter(!is.na(size_category)) %>%
  mutate(
    size_category = factor(size_category, 
                          levels = c("Corporate", "Large", "Medium", "Small", "Micro", "Other"))
  ) %>%
  group_by(date, size_category) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  )

p2 <- ggplot(peru_by_size, aes(x = date, y = tf_usd_millions, fill = size_category)) +
  geom_area(alpha = 0.8) +
  scale_fill_viridis_d(option = "plasma") +
  scale_y_continuous(labels = comma_format()) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "Foreign-Trade Loans (USD millions)",
    fill = "Borrower Size"
    # NO title, NO caption - in captions.csv (per_02)
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    panel.grid.minor = element_blank(),
    legend.position = "right"
  )

ggsave(file.path(plots_dir, "per_02_tf_by_size.png"), p2, width = 10, height = 6, dpi = 300)
write.csv(peru_by_size, file.path(tables_dir, "per_02_tf_by_size.csv"), row.names = FALSE)

size_totals <- peru_by_size %>%
  group_by(size_category) %>%
  summarise(total = sum(tf_usd_millions, na.rm = TRUE)) %>%
  arrange(desc(total))

cat("✓ PER-2 complete\n")
cat("  - Top size category:", size_totals$size_category[1], "with USD",
    round(size_totals$total[1], 0), "millions\n")
cat("  - Files: per_02_tf_by_size.png, .pdf, .csv\n\n")

# ==============================================================================
# PER-3: TRADE FINANCE BY BANK TYPE (MONTHLY STACKED AREA)
# ==============================================================================
cat("[3/4] Generating PER-3: TF by Bank Type (Monthly Stacked Area)...\n")

# Aggregate MONTHLY by bank type
peru_by_type_monthly <- peru %>%
  filter(!is.na(bank_type)) %>%
  group_by(date, bank_type) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  )

# Stacked area plot
p3 <- ggplot(peru_by_type_monthly, aes(x = date, y = tf_usd_millions, fill = bank_type)) +
  geom_area(alpha = 0.8, position = "stack") +
  scale_fill_viridis_d() +
  scale_y_continuous(labels = comma_format(), expand = expansion(mult = c(0, 0.05))) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Month",
    y = "Foreign-Trade Loans (USD millions)",
    fill = "Bank Type"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave(file.path(plots_dir, "per_03_tf_by_bank_type.png"), p3, width = 10, height = 6, dpi = 300)
write.csv(peru_by_type_monthly, file.path(tables_dir, "per_03_tf_by_bank_type.csv"), row.names = FALSE)

# Calculate totals for summary
type_totals <- peru_by_type_monthly %>%
  group_by(bank_type) %>%
  summarise(total = sum(tf_usd_millions, na.rm = TRUE)) %>%
  arrange(desc(total))

cat("✓ PER-3 complete (MONTHLY STACKED AREA)\n")
cat("  - Top bank type:", type_totals$bank_type[1], "with USD",
    round(type_totals$total[1], 0), "millions\n")
cat("  - Files: per_03_tf_by_bank_type.png, .csv\n\n")

# ==============================================================================
# PER-4: CONCENTRATION (HHI AND CR5)
# ==============================================================================
cat("[4/4] Generating PER-4: Market Concentration...\n")

peru_concentration <- peru %>%
  group_by(date, institucion) %>%
  summarise(
    tf_total = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(date) %>%
  mutate(
    tf_share = tf_total / sum(tf_total, na.rm = TRUE)
  ) %>%
  summarise(
    # HHI: sum of squared market shares (0-10000 scale)
    hhi = sum(tf_share^2, na.rm = TRUE) * 10000,
    # CR5: sum of top 5 banks' shares
    cr5 = sum(sort(tf_share, decreasing = TRUE)[1:min(5, length(tf_share))], na.rm = TRUE) * 100,
    .groups = "drop"
  )

# Dual Y-axis plot: HHI (left, 0-2500) and CR5 (right, 0-100% FULL SCALE)
# Scale factor: 25 (so CR5 0-100% → 0-2500 on left axis, shows FULL CR5 range)
# HHI ~1977-2142, CR5 ~90-93.7% - this lets CR5 show its full potential 0-100%
p4 <- ggplot(peru_concentration, aes(x = date)) +
  # HHI line (left axis)
  geom_line(aes(y = hhi), color = "#C1121F", linewidth = 1.2) +
  # CR5 line (right axis, scaled by factor 25 to use FULL 0-100% scale)
  geom_line(aes(y = cr5 * 25), color = "#003049", linewidth = 1.2, linetype = "dashed") +
  
  scale_y_continuous(
    name = "HHI",
    limits = c(0, 2500),
    breaks = seq(0, 2500, 500),
    sec.axis = sec_axis(~ . / 25, name = "CR5 (%)", breaks = seq(0, 100, 20))
  ) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    x = "Year"
    # NO title, NO caption - in captions.csv (per_04)
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    axis.title.y.left = element_text(color = "#C1121F"),
    axis.text.y.left = element_text(color = "#C1121F"),
    axis.title.y.right = element_text(color = "#003049"),
    axis.text.y.right = element_text(color = "#003049"),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  ) +
  # Manual legend using annotations
  annotate("segment", x = as.Date("2012-01-01"), xend = as.Date("2013-01-01"), 
           y = 9500, yend = 9500, color = "#C1121F", size = 1.2) +
  annotate("text", x = as.Date("2013-06-01"), y = 9500, label = "HHI", 
           hjust = 0, color = "#C1121F", size = 4) +
  annotate("segment", x = as.Date("2012-01-01"), xend = as.Date("2013-01-01"), 
           y = 9000, yend = 9000, color = "#003049", size = 1.2, linetype = "dashed") +
  annotate("text", x = as.Date("2013-06-01"), y = 9000, label = "CR5", 
           hjust = 0, color = "#003049", size = 4)

ggsave(file.path(plots_dir, "per_04_concentration.png"), p4, width = 10, height = 6, dpi = 300)
write.csv(peru_concentration, file.path(tables_dir, "per_04_concentration.csv"), row.names = FALSE)

cat("✓ PER-4 complete\n")
cat("  - HHI range:", min(peru_concentration$hhi, na.rm = TRUE) %>% round(0), "to",
    max(peru_concentration$hhi, na.rm = TRUE) %>% round(0), "\n")
cat("  - CR5 range:", min(peru_concentration$cr5, na.rm = TRUE) %>% round(1), "% to",
    max(peru_concentration$cr5, na.rm = TRUE) %>% round(1), "%\n")
cat("  - Files: per_04_concentration.png, .pdf, .csv\n\n")

# ==============================================================================
# PER-5: TF as % of Exports (MONTHLY - TF stock as % of annual exports)
# ==============================================================================
cat("[5/6] Generating PER-5: TF as % of Exports (Monthly)...\n")

# Calculate MONTHLY TF stock as % of ANNUAL exports
peru_vs_exports <- peru %>%
  group_by(year, month) %>%
  summarise(
    tf_month = sum(tf_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),  # Annual exports
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    tf_pct_exports = (tf_month / exports_annual) * 100
  ) %>%
  arrange(date)

# Export table
write_csv(peru_vs_exports %>% select(date, year, month, tf_month, exports_annual, tf_pct_exports), 
          "tables/peru/per_05_tf_pct_exports.csv")

# Create plot (NO title, NO source, clean only)
p5 <- ggplot(peru_vs_exports, aes(x = date, y = tf_pct_exports)) +
  geom_line(color = "#2E86AB", linewidth = 1.2) +
  geom_point(color = "#2E86AB", size = 1.5, alpha = 0.6) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Month",
    y = "Monthly TF Stock as % of Annual Exports"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot (PNG only)
ggsave("plots/peru/per_05_tf_pct_exports.png", p5, 
       width = 10, height = 6, dpi = 300)

cat("✓ PER-5 complete\n")
cat("  - Range:", 
    round(min(peru_vs_exports$tf_pct_exports, na.rm = TRUE), 2), "% to",
    round(max(peru_vs_exports$tf_pct_exports, na.rm = TRUE), 2), "%\n")
cat("  - Files: per_05_tf_pct_exports.png, .csv\n\n")

# ==============================================================================
# PER-6: TF as % of Trade (MONTHLY - TF stock as % of annual exports+imports)
# ==============================================================================
cat("[6/6] Generating PER-6: TF as % of Total Trade (Monthly)...\n")

# Calculate MONTHLY TF stock as % of ANNUAL trade (exports + imports)
peru_vs_trade <- peru %>%
  group_by(year, month) %>%
  summarise(
    tf_month = sum(tf_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),  # Annual exports
    imports_annual = first(imports_usd_millions),  # Annual imports
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    trade_annual = exports_annual + imports_annual,
    tf_pct_trade = (tf_month / trade_annual) * 100
  ) %>%
  arrange(date)

# Export table
write_csv(peru_vs_trade %>% select(date, year, month, tf_month, exports_annual, imports_annual, trade_annual, tf_pct_trade), 
          "tables/peru/per_06_tf_pct_trade.csv")

# Create plot (NO title, NO source, clean only)
p6 <- ggplot(peru_vs_trade, aes(x = date, y = tf_pct_trade)) +
  geom_line(color = "#A23B72", linewidth = 1.2) +
  geom_point(color = "#A23B72", size = 1.5, alpha = 0.6) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Month",
    y = "Monthly TF Stock as % of Annual Trade (Exports + Imports)"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot (PNG only)
ggsave("plots/peru/per_06_tf_pct_trade.png", p6, 
       width = 10, height = 6, dpi = 300)

cat("✓ PER-6 complete\n")
cat("  - Range:", 
    round(min(peru_vs_trade$tf_pct_trade, na.rm = TRUE), 2), "% to",
    round(max(peru_vs_trade$tf_pct_trade, na.rm = TRUE), 2), "%\n")
cat("  - Files: per_06_tf_pct_trade.png, .csv\n\n")

# ==============================================================================
# PER-7: TF BY TOP 5 BANKS (STACKED AREA - MONTHLY)
# ==============================================================================
cat("[7/7] Generating PER-7: TF by Top 5 Banks...\n")

# Calculate top 5 banks by TF volume
top_tf_banks <- peru %>%
  filter(!is.na(institucion)) %>%
  group_by(institucion) %>%
  summarise(
    total_tf = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_tf)) %>%
  slice_head(n = 5)

cat("  - Top 5 TF banks:", paste(top_tf_banks$institucion, collapse = ", "), "\n")

# Aggregate TF by MONTH and top 5 banks
peru_tf_top5_monthly <- peru %>%
  filter(institucion %in% top_tf_banks$institucion) %>%
  group_by(date, institucion) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(top_tf_banks %>% select(institucion, total_tf), by = "institucion") %>%
  mutate(
    institucion = factor(institucion, levels = rev(top_tf_banks$institucion))  # Reverse for stacking order
  )

# STACKED AREA plot (monthly)
p7 <- ggplot(peru_tf_top5_monthly, aes(x = date, y = tf_usd_millions, fill = institucion)) +
  geom_area(alpha = 0.8) +
  scale_fill_viridis_d(option = "turbo", begin = 0.1, end = 0.9) +
  scale_y_continuous(labels = comma_format()) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "Foreign-Trade Credit (USD millions)",
    fill = "Bank"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/peru/per_07_tf_top5_banks.png", p7, width = 10, height = 6, dpi = 300)

# Export table (monthly data)
peru_tf_top5_monthly %>%
  select(date, institucion, tf_usd_millions) %>%
  pivot_wider(names_from = institucion, values_from = tf_usd_millions, values_fill = 0) %>%
  write_csv("tables/peru/per_07_tf_top5_banks.csv")

cat("✓ PER-7 complete\n")
cat("  - Top TF bank:", top_tf_banks$institucion[1], "(USD", round(top_tf_banks$total_tf[1], 0), "millions total)\n")
cat("  - Files: per_07_tf_top5_banks.png, .csv\n\n")

# ==============================================================================
# SUMMARY
# ==============================================================================
cat("======================================================================\n")
cat("PERÚ ANALYSIS COMPLETE\n")
cat("======================================================================\n")
cat("✓ 7/7 plots generated (4 original + 2 trade-based + 1 top 5)\n\n")

cat("Outputs:\n")
cat("  plots/peru/\n")
cat("    - per_01_tf_pct_total.png (300 DPI)\n")
cat("    - per_02_tf_by_size.png (300 DPI)\n")
cat("    - per_03_tf_by_bank_type.png (300 DPI)\n")
cat("    - per_04_concentration.png (300 DPI)\n")
cat("    - per_05_tf_pct_exports.png (300 DPI)\n")
cat("    - per_06_tf_pct_trade.png (300 DPI)\n")
cat("    - per_07_tf_top5_banks.png (300 DPI)\n\n")

cat("  tables/peru/\n")
cat("    - per_01_tf_pct_total.csv\n")
cat("    - per_02_tf_by_size.csv\n")
cat("    - per_03_tf_by_bank_type.csv\n")
cat("    - per_04_concentration.csv\n")
cat("    - per_05_tf_pct_exports.csv\n")
cat("    - per_06_tf_pct_trade.csv\n")
cat("    - per_07_tf_top5_banks.csv\n\n")

cat("Captions:\n")
cat("  See captions/captions.csv for titles, sources, and notes\n")
cat("  (figure_id: per_01, per_02, per_03, per_04)\n\n")

cat("======================================================================\n")
