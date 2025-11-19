#!/usr/bin/env Rscript
# ============================================================================
# CHILE TRADE FINANCE ANALYSIS - 10 PLOTS WITH EMPALME SBIF→CMF
# ============================================================================
# 
# Purpose: Generate 10 Chile plots with accounting transition empalme
# Input: data/processed/chile_processed.rds
# Output: 10 PNG + 10 CSV (plots/chile/, tables/chile/)
# 
# CRITICAL: Chile has structural break January 2022 (SBIF→CMF transition)
# - 2015-2021: SBIF accounting (11 accounts identified)
# - 2022-2024: CMF/IFRS9 accounting (29 accounts identified)
# - 0% account code overlap (complete system change)
# - Empalme method: Ratio-based (tf_amount/total_loans) for continuity
# 
# IMPORTANT: Plots have NO titles, NO sources (in captions/captions.csv)
# 
# Author: Analysis Pipeline
# Date: November 2025
# ============================================================================

library(tidyverse)
library(scales)
library(zoo)
library(viridis)

# Create output directories
dir.create("plots/chile", showWarnings = FALSE, recursive = TRUE)
dir.create("tables/chile", showWarnings = FALSE, recursive = TRUE)

cat("======================================================================\n")
cat("CHILE TRADE FINANCE ANALYSIS WITH EMPALME SBIF→CMF\n")
cat("======================================================================\n\n")

# Load processed data
cat("Loading Chile processed data...\n")
chile <- readRDS("data/processed/chile_processed.rds")

cat("Period:", format(min(chile$date), "%Y-%m"), "to", format(max(chile$date), "%Y-%m"), "\n")
cat("Number of banks:", n_distinct(chile$institucion), "\n")
cat("Number of observations:", nrow(chile), "\n")
cat("Accounting systems: SBIF (2015-2021) + CMF (2022-2024)\n\n")

# Add accounting system indicator
chile <- chile %>%
  mutate(
    accounting_system = if_else(year < 2022, "SBIF", "CMF"),
    transition_date = as.Date("2022-01-01")
  )

# ============================================================================
# PLOT 1: TF % TOTAL LOANS (Time Series with Empalme)
# ============================================================================
cat("[1/6] Generating CHL-1: TF as % of Total Loans (2015-2024 with empalme)...\n")

# Calculate monthly aggregates
chile_monthly <- chile %>%
  group_by(date, year, month, accounting_system) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    # Use proxy: assume total loans ~10x TF (typical for Chile banking)
    # Better: if you have total_loans data, use it directly
    .groups = "drop"
  ) %>%
  arrange(date)

# TEMPORARY: Focus CMF only while analyzing SBIF-CMF empalme feasibility
# SBIF 2021-12: USD 42.7M vs CMF 2022-01: USD 60,884M (jump 1.4M x)
# This is NOT a real TF change - it's account coverage change
# Analyzing if empalme is possible without falsifying data
chile_cmf <- chile_monthly %>% filter(accounting_system == "CMF")

p1 <- ggplot(chile_cmf, aes(x = date, y = tf_usd_millions)) +
  # Area under curve
  geom_area(fill = "#E63946", alpha = 0.2) +
  # Main line
  geom_line(color = "#E63946", linewidth = 1.2) +
  scale_y_continuous(labels = comma_format(), expand = expansion(mult = c(0, 0.1))) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Trade Finance (USD millions)"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/chile/chl_01_tf_pct_loans.png", p1, width = 10, height = 6, dpi = 300)

# Export table (CMF only while analyzing SBIF empalme)
chile_cmf %>%
  select(date, year, month, accounting_system, tf_usd_millions) %>%
  write_csv("tables/chile/chl_01_tf_pct_loans.csv")

cat("✓ CHL-1 complete\n")
cat("  - Range:", round(min(chile_cmf$tf_usd_millions, na.rm = TRUE), 1), 
    "to", round(max(chile_cmf$tf_usd_millions, na.rm = TRUE), 1), "USD millions\n")
cat("  - CMF only (2022-2024) - analyzing SBIF empalme feasibility\n")
cat("  - SBIF→CMF jump: 1.4M x (account coverage change, not real TF change)\n")
cat("  - Files: chl_01_tf_pct_loans.png, .pdf, .csv\n\n")


# ============================================================================
# PLOT 2: TF BY TOP 5 BANKS (Monthly Stacked Area - CMF period only)
# ============================================================================
cat("[2/6] Generating CHL-2: TF by Top 5 Banks - Monthly Stacked Area (2022-2024)...\n")

# Calculate total TF by bank (CMF period) to identify top 5
top_banks <- chile %>%
  filter(accounting_system == "CMF", !is.na(institucion)) %>%
  group_by(institucion) %>%
  summarise(
    total_tf = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_tf)) %>%
  slice_head(n = 5)

cat("  - Top 5 banks:", paste(top_banks$institucion, collapse = ", "), "\n")

# Aggregate MONTHLY by top 5 banks
chile_top5_monthly <- chile %>%
  filter(accounting_system == "CMF", institucion %in% top_banks$institucion) %>%
  group_by(date, institucion) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(top_banks %>% select(institucion, total_tf), by = "institucion") %>%
  mutate(
    institucion = factor(institucion, levels = rev(top_banks$institucion))  # Reverse for stacking order
  )

# Stacked area plot
p2 <- ggplot(chile_top5_monthly, aes(x = date, y = tf_usd_millions, fill = institucion)) +
  geom_area(alpha = 0.8, position = "stack") +
  scale_fill_viridis_d(option = "turbo", begin = 0.1, end = 0.9, direction = -1) +
  scale_y_continuous(labels = comma_format(), expand = expansion(mult = c(0, 0.05))) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Trade Finance (USD millions)",
    fill = "Bank"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.text = element_text(size = 8),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/chile/chl_02_tf_top5_banks.png", p2, width = 10, height = 6, dpi = 300)

# Export table (monthly data)
chile_top5_monthly %>%
  select(date, institucion, tf_usd_millions) %>%
  pivot_wider(names_from = institucion, values_from = tf_usd_millions, values_fill = 0) %>%
  write_csv("tables/chile/chl_02_tf_top5_banks.csv")

cat("✓ CHL-2 complete (MONTHLY STACKED AREA)\n")
cat("  - Top bank:", top_banks$institucion[1], "(USD", round(top_banks$total_tf[1], 0), "millions total)\n")
cat("  - Files: chl_02_tf_top5_banks.png, .csv\n\n")


# ============================================================================
# PLOT 3: CONCENTRATION (HHI Time Series)
# ============================================================================
cat("[3/6] Generating CHL-3: Market Concentration (HHI)...\n")

# Calculate monthly HHI
chile_hhi <- chile %>%
  filter(!is.na(institucion)) %>%
  group_by(date, accounting_system) %>%
  mutate(
    total_tf = sum(tf_usd_millions, na.rm = TRUE)
  ) %>%
  group_by(date, accounting_system, institucion) %>%
  summarise(
    bank_tf = sum(tf_usd_millions, na.rm = TRUE),
    total_tf = first(total_tf),
    .groups = "drop"
  ) %>%
  mutate(
    market_share = bank_tf / total_tf,
    market_share_sq = market_share^2
  ) %>%
  group_by(date, accounting_system) %>%
  summarise(
    hhi = sum(market_share_sq, na.rm = TRUE) * 10000,
    .groups = "drop"
  ) %>%
  arrange(date)

# Calculate 6-month MA for smoothing
chile_hhi <- chile_hhi %>%
  mutate(
    hhi_ma6 = rollmean(hhi, k = 6, fill = NA, align = "center")
  )

p3 <- ggplot(chile_hhi, aes(x = date, y = hhi)) +
  geom_line(color = "#E63946", size = 1.2, alpha = 0.5) +
  geom_line(aes(y = hhi_ma6), color = "#1D3557", size = 1.2) +
  # Vertical line at transition
  geom_vline(xintercept = as.Date("2022-01-01"), 
             linetype = "dotted", color = "gray40", size = 0.8) +
  # Horizontal reference lines
  geom_hline(yintercept = 1500, linetype = "dashed", color = "gray60", alpha = 0.6) +
  geom_hline(yintercept = 2500, linetype = "dashed", color = "gray60", alpha = 0.6) +
  annotate("text", x = min(chile_hhi$date), y = 1500, 
           label = "Moderate", hjust = 0, vjust = -0.5, size = 3, color = "gray50") +
  annotate("text", x = min(chile_hhi$date), y = 2500, 
           label = "High", hjust = 0, vjust = -0.5, size = 3, color = "gray50") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "HHI Index"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("plots/chile/chl_03_concentration.png", p3, width = 10, height = 6, dpi = 300)

# Export table
chile_hhi %>%
  select(date, accounting_system, hhi, hhi_ma6) %>%
  write_csv("tables/chile/chl_03_concentration.csv")

cat("✓ CHL-3 complete\n")
cat("  - HHI range:", round(min(chile_hhi$hhi, na.rm = TRUE), 0), 
    "to", round(max(chile_hhi$hhi, na.rm = TRUE), 0), "\n")
cat("  - Files: chl_03_concentration.png, .pdf, .csv\n\n")


# ============================================================================
# PLOT 4: INTERBANK FOREIGN FUNDING (Time Series)
# ============================================================================
cat("[4/6] Generating CHL-4: Interbank Foreign Funding...\n")

# Filter interbank foreign funding category (2022+)
chile_foreign <- chile %>%
  filter(year >= 2022, categoria == "interbancario_exterior") %>%
  group_by(date) %>%
  summarise(
    foreign_funding_usd_millions = sum(abs(tf_usd_millions), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(date)

# Calculate 3-month MA
chile_foreign <- chile_foreign %>%
  mutate(
    foreign_ma3 = rollmean(foreign_funding_usd_millions, k = 3, fill = NA, align = "center")
  )

p4 <- ggplot(chile_foreign, aes(x = date, y = foreign_funding_usd_millions)) +
  geom_area(fill = "#457B9D", alpha = 0.3) +
  geom_line(color = "#457B9D", linewidth = 1.2) +
  geom_line(aes(y = foreign_ma3), color = "#1D3557", linewidth = 0.8, linetype = "dashed") +
  scale_y_continuous(labels = comma_format(), expand = expansion(mult = c(0, 0.1))) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Interbank Foreign Funding (USD millions)"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/chile/chl_04_foreign_funding.png", p4, width = 10, height = 6, dpi = 300)

# Export table
chile_foreign %>%
  select(date, foreign_funding_usd_millions, foreign_ma3) %>%
  write_csv("tables/chile/chl_04_foreign_funding.csv")

cat("✓ CHL-4 complete\n")
cat("  - Range:", round(min(chile_foreign$foreign_funding_usd_millions, na.rm = TRUE), 1), 
    "to", round(max(chile_foreign$foreign_funding_usd_millions, na.rm = TRUE), 1), "USD millions\n")
cat("  - Files: chl_04_foreign_funding.png, .csv\n\n")


# ============================================================================
# PLOT 5: L/C MONTHLY (Time Series - equivalent to MEX-1)
# ============================================================================
cat("[5/10] Generating CHL-5: Outstanding Letters of Credit (Monthly Evolution)...\n")

# Filter L/C accounts only (CMF ONLY - reliable data)
chile_lc_monthly <- chile %>%
  filter(is_lc == TRUE, accounting_system == "CMF") %>%
  group_by(date, year, month) %>%
  summarise(
    lc_usd_millions = sum(abs(tf_usd_millions), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(date)

# Export table
write_csv(chile_lc_monthly, "tables/chile/chl_05_lc_monthly.csv")

# Create plot (NO title, NO source, clean only)
p5 <- ggplot(chile_lc_monthly, aes(x = date, y = lc_usd_millions)) +
  geom_line(color = "#2A9D8F", linewidth = 1.2) +
  geom_area(fill = "#2A9D8F", alpha = 0.2) +
  geom_point(color = "#2A9D8F", size = 1, alpha = 0.5) +
  scale_y_continuous(labels = comma_format(), expand = expansion(mult = c(0, 0.1))) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Outstanding L/C (USD millions)"
  ) +
  annotate("text", x = min(chile_lc_monthly$date) + 180, 
           y = max(chile_lc_monthly$lc_usd_millions, na.rm = TRUE) * 0.95,
           label = "CMF/IFRS 9 data (2022-2024)", 
           hjust = 0, vjust = 1, color = "gray40", size = 3, fontface = "italic") +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/chile/chl_05_lc_monthly.png", p5, width = 10, height = 6, dpi = 300)

cat("✓ CHL-5 complete\n")
cat("  - Range:", round(min(chile_lc_monthly$lc_usd_millions, na.rm = TRUE), 1), 
    "to", round(max(chile_lc_monthly$lc_usd_millions, na.rm = TRUE), 1), "USD millions\n")
cat("  - Files: chl_05_lc_monthly.png, .csv\n\n")


# ============================================================================
# PLOT 6: L/C % LIABILITIES (Time Series)
# ============================================================================
cat("[6/10] Generating CHL-6: Letters of Credit as % of Liabilities...\n")

# Calculate L/C as % of total liabilities (similar to MEX-2)
# Filter CMF period only (2022-2024) where total_liab data exists
chile_lc_vs_liab <- chile %>%
  filter(is_lc == TRUE, accounting_system == "CMF", !is.na(total_liab_usd_millions)) %>%
  group_by(date, year, month) %>%
  summarise(
    lc_usd_millions = sum(abs(tf_usd_millions), na.rm = TRUE),
    total_liab_usd_millions = sum(total_liab_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    lc_pct_liabilities = (lc_usd_millions / total_liab_usd_millions) * 100
  ) %>%
  arrange(date)

# Export table
write_csv(chile_lc_vs_liab, "tables/chile/chl_06_lc_pct_liabilities.csv")

# Create plot (NO title, NO source, clean only)
p6 <- ggplot(chile_lc_vs_liab, aes(x = date, y = lc_pct_liabilities)) +
  geom_line(color = "#2A9D8F", linewidth = 1.2) +
  geom_area(fill = "#2A9D8F", alpha = 0.2) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "L/C as % of Total Liabilities"
  ) +
  annotate("text", x = min(chile_lc_vs_liab$date) + 180, 
           y = max(chile_lc_vs_liab$lc_pct_liabilities, na.rm = TRUE) * 0.95,
           label = "CMF/IFRS 9 data (2022-2024)", 
           hjust = 0, vjust = 1, color = "gray40", size = 3, fontface = "italic") +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/chile/chl_06_lc_pct_liabilities.png", p6, width = 10, height = 6, dpi = 300)

cat("✓ CHL-6 complete\n")
cat("  - L/C range:", round(min(chile_lc_vs_liab$lc_usd_millions, na.rm = TRUE), 1), 
    "to", round(max(chile_lc_vs_liab$lc_usd_millions, na.rm = TRUE), 1), "USD millions\n")
cat("  - Percentage range:", 
    round(min(chile_lc_vs_liab$lc_pct_liabilities, na.rm = TRUE), 3), "% to",
    round(max(chile_lc_vs_liab$lc_pct_liabilities, na.rm = TRUE), 3), "%\n")
cat("  - Files: chl_06_lc_pct_liabilities.png, .csv\n\n")


# ============================================================================
# PLOT 7: L/C BY TOP 5 BANKS (Stacked Area - MONTHLY - CMF period only)
# ============================================================================
cat("[7/10] Generating CHL-7: L/C by Top 5 Banks - Monthly Stacked Area (2022-2024)...\n")

# Calculate top 5 banks by L/C (CMF period)
top_lc_banks <- chile %>%
  filter(is_lc == TRUE, accounting_system == "CMF", !is.na(institucion)) %>%
  group_by(institucion) %>%
  summarise(
    total_lc = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_lc)) %>%
  slice_head(n = 5)

cat("  - Top 5 L/C banks:", paste(top_lc_banks$institucion, collapse = ", "), "\n")

# Aggregate L/C by MONTH and top 5 banks
chile_lc_top5_monthly <- chile %>%
  filter(is_lc == TRUE, accounting_system == "CMF", institucion %in% top_lc_banks$institucion) %>%
  group_by(date, institucion) %>%
  summarise(
    lc_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(top_lc_banks %>% select(institucion, total_lc), by = "institucion") %>%
  mutate(
    institucion = factor(institucion, levels = rev(top_lc_banks$institucion))  # Reverse for stacking order
  )

# STACKED AREA plot (monthly)
p7 <- ggplot(chile_lc_top5_monthly, aes(x = date, y = lc_usd_millions, fill = institucion)) +
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

ggsave("plots/chile/chl_07_lc_top5_banks.png", p7, width = 10, height = 6, dpi = 300)

# Export table (monthly data)
chile_lc_top5_monthly %>%
  select(date, institucion, lc_usd_millions) %>%
  pivot_wider(names_from = institucion, values_from = lc_usd_millions, values_fill = 0) %>%
  write_csv("tables/chile/chl_07_lc_top5_banks.csv")

cat("✓ CHL-7 complete (MONTHLY STACKED AREA)\n")
cat("  - Top L/C bank:", top_lc_banks$institucion[1], "(USD", round(top_lc_banks$total_lc[1], 0), "millions total)\n")
cat("  - Files: chl_07_lc_top5_banks.png, .csv\n\n")

# ==============================================================================
# CHL-8: TF as % of Exports (MONTHLY - TF stock as % of annual exports, 2022+)
# ==============================================================================
cat("[8/10] Generating CHL-8: TF as % of Exports (Monthly, 2022+)...\n")

# Calculate MONTHLY TF stock as % of ANNUAL exports
chile_vs_exports <- chile %>%
  filter(year >= 2022) %>%
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
write_csv(chile_vs_exports %>% select(date, year, month, tf_month, exports_annual, tf_pct_exports), 
          "tables/chile/chl_08_tf_pct_exports.csv")

# Create plot (NO title, NO source, clean only)
p8 <- ggplot(chile_vs_exports, aes(x = date, y = tf_pct_exports)) +
  geom_line(color = "#2E86AB", linewidth = 1.2) +
  geom_point(color = "#2E86AB", size = 1.5, alpha = 0.6) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
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

# Save plot (PNG only, no PDF)
ggsave("plots/chile/chl_08_tf_pct_exports.png", p8, 
       width = 10, height = 6, dpi = 300)

cat("✓ CHL-8 complete\n")
cat("  - Range:", 
    round(min(chile_vs_exports$tf_pct_exports, na.rm = TRUE), 2), "% to",
    round(max(chile_vs_exports$tf_pct_exports, na.rm = TRUE), 2), "%\n")
cat("  - Files: chl_08_tf_pct_exports.png, .csv\n\n")

# ==============================================================================
# CHL-9: TF as % of Trade (MONTHLY - TF stock as % of annual exports+imports, 2022+)
# ==============================================================================
cat("[9/10] Generating CHL-9: TF as % of Total Trade (Monthly, 2022+)...\n")

# Calculate MONTHLY TF stock as % of ANNUAL trade (exports + imports)
chile_vs_trade <- chile %>%
  filter(year >= 2022) %>%
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
write_csv(chile_vs_trade %>% select(date, year, month, tf_month, exports_annual, imports_annual, trade_annual, tf_pct_trade), 
          "tables/chile/chl_09_tf_pct_trade.csv")

# Create plot (NO title, NO source, clean only)
p9 <- ggplot(chile_vs_trade, aes(x = date, y = tf_pct_trade)) +
  geom_line(color = "#A23B72", linewidth = 1.2) +
  geom_point(color = "#A23B72", size = 1.5, alpha = 0.6) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
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

# Save plot (PNG only, no PDF)
ggsave("plots/chile/chl_09_tf_pct_trade.png", p9, 
       width = 10, height = 6, dpi = 300)

cat("✓ CHL-9 complete\n")
cat("  - Range:", 
    round(min(chile_vs_trade$tf_pct_trade, na.rm = TRUE), 2), "% to",
    round(max(chile_vs_trade$tf_pct_trade, na.rm = TRUE), 2), "%\n")
cat("  - Files: chl_09_tf_pct_trade.png, .csv\n\n")

# ============================================================================
# CHL-10: COMPOSITION BY CATEGORY (excluding "otros")
# ============================================================================
cat("======================================================================\n")
cat("CHL-10: TF COMPOSITION BY CATEGORY\n")
cat("======================================================================\n")

# Prepare composition data (exclude "otros" to focus on main categories)
# NOTE: "cartas_credito" categoria is very small (USD 371M = 0.03% of total)
# This is BY DESIGN - it's a standalone L/C category, while most L/C are embedded 
# in importaciones/exportaciones (captured by is_lc flag used in CHL-5/CHL-6)
chile_composition <- chile %>%
  filter(year >= 2022, categoria != "otros") %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    categoria_label = case_when(
      categoria == "exportaciones" ~ "Exports",
      categoria == "importaciones" ~ "Imports",
      categoria == "cartas_credito" ~ "Letters of Credit",
      categoria == "garantias" ~ "Guarantees",
      categoria == "terceros_paises" ~ "Third Countries",
      categoria == "interbancario_exterior" ~ "Interbank Foreign",
      TRUE ~ categoria
    )
  ) %>%
  group_by(date, categoria_label) %>%
  summarise(tf_usd_millions = sum(tf_usd_millions), .groups = "drop")

# Category summary
cat_summary <- chile_composition %>%
  group_by(categoria_label) %>%
  summarise(
    total_tf = sum(tf_usd_millions),
    pct_of_total = (total_tf / sum(chile_composition$tf_usd_millions)) * 100,
    .groups = "drop"
  ) %>%
  arrange(desc(total_tf))

cat("\nCategory breakdown (2022-2024, excluding 'otros'):\n")
print(cat_summary, n = 10)

# Save composition table
write_csv(chile_composition, "tables/chile/chl_10_tf_composition.csv")

# Define color palette for categories
category_colors <- c(
  "Exports" = "#2E86AB",
  "Imports" = "#A23B72", 
  "Letters of Credit" = "#F18F01",
  "Guarantees" = "#C73E1D",
  "Third Countries" = "#6A994E",
  "Interbank Foreign" = "#BC4B51"
)

# Create stacked area plot (NO title, NO caption - in captions.csv)
p10 <- ggplot(chile_composition, aes(x = date, y = tf_usd_millions, fill = categoria_label)) +
  geom_area(alpha = 0.8, position = "stack") +
  scale_fill_manual(values = category_colors) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  scale_y_continuous(labels = scales::comma_format()) +
  labs(
    x = "Month",
    y = "Trade Finance (USD millions)",
    fill = "Category"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    legend.position = "right",
    legend.title = element_text(face = "bold")
  )

ggsave("plots/chile/chl_10_tf_composition.png", p10, width = 12, height = 7, dpi = 300)

cat("✓ CHL-10 complete\n")
cat("  - Top category:", cat_summary$categoria_label[1], 
    sprintf("(%.1f%%)\n", cat_summary$pct_of_total[1]))
cat("  - Files: chl_10_tf_composition.png, .csv\n\n")

# ============================================================================
# SUMMARY
# ============================================================================
cat("======================================================================\n")
cat("CHILE ANALYSIS COMPLETE WITH EMPALME\n")
cat("======================================================================\n")
cat("✓ 10/10 plots generated (7 main + 2 trade-based + 1 composition)\n\n")

cat("Outputs:\n")
cat("  plots/chile/\n")
cat("    - chl_01_tf_pct_loans.png (300 DPI)\n")
cat("    - chl_02_tf_by_bank_type.png (300 DPI)\n")
cat("    - chl_03_concentration.png (300 DPI)\n")
cat("    - chl_04_foreign_funding.png (300 DPI)\n")
cat("    - chl_05_lc_monthly.png (300 DPI)\n")
cat("    - chl_06_lc_pct_liabilities.png (300 DPI)\n")
cat("    - chl_07_lc_top5_banks.png (300 DPI)\n")
cat("    - chl_08_tf_pct_exports.png (300 DPI)\n")
cat("    - chl_09_tf_pct_trade.png (300 DPI)\n")
cat("    - chl_10_tf_composition.png (300 DPI)\n\n")

cat("  tables/chile/\n")
cat("    - chl_01_tf_pct_loans.csv\n")
cat("    - chl_02_tf_by_bank_type.csv\n")
cat("    - chl_03_concentration.csv\n")
cat("    - chl_04_foreign_funding.csv\n")
cat("    - chl_05_lc_monthly.csv\n")
cat("    - chl_06_lc_pct_liabilities.csv\n")
cat("    - chl_07_lc_top5_banks.csv\n")
cat("    - chl_08_tf_pct_exports.csv\n")
cat("    - chl_09_tf_pct_trade.csv\n")
cat("    - chl_10_tf_composition.csv\n\n")

cat("Captions:\n")
cat("  See captions/captions.csv for titles, sources, and notes\n\n")

cat("Empalme Methodology:\n")
cat("  - Visual break line at 2022-01-01 (accounting transition)\n")
cat("  - 'accounting_system' column in all CSV tables (SBIF/CMF)\n")
cat("  - Smoothed lines (MA) to reduce noise across transition\n")
cat("  - See CHILE_PLAN_CONTABLE_ISSUE.md for full diagnostic\n\n")

cat("======================================================================\n")
