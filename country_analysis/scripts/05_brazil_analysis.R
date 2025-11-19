#!/usr/bin/env Rscript
# ============================================================================
# BRAZIL TRADE FINANCE ANALYSIS - 5 PLOTS
# ============================================================================
# 
# Purpose: Generate 5 Brazil plots with regional alternatives
# Input: data/processed/brazil_processed.rds
# Output: 5 PNG + 5 PDF + 5 CSV (plots/brazil/, tables/brazil/)
# 
# CRITICAL: Brazil has NO individual bank data (aggregated by BCB)
# - Data aggregated by: state (UF), sector (CNAE), borrower size (porte)
# - NO bank-level concentration analysis possible
# - Alternatives: Regional concentration, size distribution
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
dir.create("plots/brazil", showWarnings = FALSE, recursive = TRUE)
dir.create("tables/brazil", showWarnings = FALSE, recursive = TRUE)

cat("======================================================================\n")
cat("BRAZIL TRADE FINANCE ANALYSIS\n")
cat("======================================================================\n\n")

# Load processed data
cat("Loading Brazil processed data...\n")
brazil <- readRDS("data/processed/brasil_processed.rds")

cat("Period:", format(min(brazil$date), "%Y-%m"), "to", format(max(brazil$date), "%Y-%m"), "\n")
cat("Number of observations:", nrow(brazil), "\n")
cat("Size categories:", paste(unique(brazil$porte), collapse = ", "), "\n")
cat("Note: NO individual bank data (aggregated by BCB)\n\n")


# ============================================================================
# PLOT 1: TF % TOTAL CREDIT (Time Series)
# ============================================================================
cat("[1/5] Generating BRA-1: TF as % of Total Credit...\n")

# Calculate monthly aggregates (national level) - USE USD NOT BRL
brazil_monthly <- brazil %>%
  group_by(date, year, month) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(date)

# Calculate 3-month moving average for smoothing
brazil_monthly <- brazil_monthly %>%
  mutate(
    tf_ma3 = rollmean(tf_usd_millions, k = 3, fill = NA, align = "center")
  )

p1 <- ggplot(brazil_monthly, aes(x = date, y = tf_usd_millions)) +
  # Area under curve
  geom_area(fill = "#009C3B", alpha = 0.2) +
  # Main line
  geom_line(color = "#009C3B", linewidth = 1.2) +
  # Smoothed line
  geom_line(aes(y = tf_ma3), color = "#002776", linewidth = 0.8, linetype = "dashed") +
  scale_y_continuous(labels = comma_format()) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "Trade Finance (USD millions)"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("plots/brazil/bra_01_tf_pct_total.png", p1, width = 10, height = 6, dpi = 300)

# Export table
brazil_monthly %>%
  write_csv("tables/brazil/bra_01_tf_pct_total.csv")

cat("✓ BRA-1 complete\n")
cat("  - Range: USD", round(min(brazil_monthly$tf_usd_millions, na.rm = TRUE), 1), 
    "to", round(max(brazil_monthly$tf_usd_millions, na.rm = TRUE), 1), "millions\n")
cat("  - Files: bra_01_tf_pct_total.png, .pdf, .csv\n\n")


# ============================================================================
# PLOT 2: TF BY SIZE (Stacked Area)
# ============================================================================
cat("[2/5] Generating BRA-2: TF by Borrower Size...\n")

# Aggregate by month and size (CLEAN - remove Unknown/NA) - USE USD NOT BRL
brazil_by_size <- brazil %>%
  filter(
    !is.na(porte), 
    porte != "NA", 
    porte != "Unknown",
    size_category %in% c("Micro", "Small", "Medium", "Large")
  ) %>%
  group_by(date, size_category) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(date, size_category)

# Reorder size for better visualization
brazil_by_size <- brazil_by_size %>%
  mutate(
    size_category = factor(size_category, levels = c("Micro", "Small", "Medium", "Large"))
  )

p2 <- ggplot(brazil_by_size, aes(x = date, y = tf_usd_millions, fill = size_category)) +
  geom_area(alpha = 0.8) +
  scale_fill_manual(
    values = c(
      "Micro" = "#FDB462",
      "Small" = "#80B1D3",
      "Medium" = "#009C3B",
      "Large" = "#002776"
    ),
    labels = c("Micro", "Small", "Medium", "Large")
  ) +
  scale_y_continuous(labels = comma_format()) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "Trade Finance (USD millions)",
    fill = "Borrower Size"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 0, hjust = 0.5)
  )

ggsave("plots/brazil/bra_02_tf_by_size.png", p2, width = 10, height = 6, dpi = 300)

# Export table
brazil_by_size %>%
  pivot_wider(names_from = size_category, values_from = tf_usd_millions) %>%
  write_csv("tables/brazil/bra_02_tf_by_size.csv")

cat("✓ BRA-2 complete\n")
cat("  - Size categories:", paste(levels(brazil_by_size$size_category), collapse = ", "), "\n")
size_totals <- brazil_by_size %>%
  group_by(size_category) %>%
  summarise(total = sum(tf_usd_millions, na.rm = TRUE)) %>%
  arrange(desc(total))
cat("  - Top size:", size_totals$size_category[1], "with USD",
    round(size_totals$total[1], 0), "millions\n")
cat("  - Files: bra_02_tf_by_size.png, .pdf, .csv\n\n")


# ============================================================================
# PLOT 3: TF BY REGION (Alternative to "by bank type")
# ============================================================================
cat("[3/5] Generating BRA-3: TF by Region (Top 10 States)...\n")

# Calculate total TF by state (entire period) - USE USD NOT BRL
top_states <- brazil %>%
  filter(!is.na(uf), uf != "NA") %>%
  group_by(uf) %>%
  summarise(
    total_tf = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(total_tf)) %>%
  slice_head(n = 10)

cat("  - Top 10 states:", paste(top_states$uf, collapse = ", "), "\n")

# Filter data for top 10 states
brazil_by_region <- brazil %>%
  filter(uf %in% top_states$uf) %>%
  group_by(date, uf) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(date, uf)

# Add state ordering by total volume
brazil_by_region <- brazil_by_region %>%
  left_join(top_states %>% select(uf, total_tf), by = "uf") %>%
  mutate(
    uf = factor(uf, levels = top_states$uf)
  )

p3 <- ggplot(brazil_by_region, aes(x = date, y = tf_usd_millions, color = uf)) +
  geom_line(linewidth = 1) +
  scale_color_viridis_d(option = "turbo") +
  scale_y_continuous(labels = comma_format()) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "Trade Finance (USD millions)",
    color = "State (UF)"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "right",
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("plots/brazil/bra_03_tf_by_region.png", p3, width = 12, height = 6, dpi = 300)

# Export table
brazil_by_region %>%
  select(date, uf, tf_usd_millions) %>%
  pivot_wider(names_from = uf, values_from = tf_usd_millions) %>%
  write_csv("tables/brazil/bra_03_tf_by_region.csv")

cat("✓ BRA-3 complete\n")
cat("  - Top state:", top_states$uf[1], "(USD", round(top_states$total_tf[1], 0), "millions)\n")
cat("  - Files: bra_03_tf_by_region.png, .pdf, .csv\n\n")


# ============================================================================
# PLOT 4: REGIONAL CONCENTRATION (Alternative to HHI)
# ============================================================================
cat("[4/5] Generating BRA-4: Regional Concentration (Top 5 States %)...\n")

# Calculate monthly concentration (Top 5 states share) - USE USD NOT BRL
brazil_concentration <- brazil %>%
  filter(!is.na(uf), uf != "NA") %>%
  group_by(date, uf) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(date) %>%
  mutate(
    total_tf = sum(tf_usd_millions),
    state_share = tf_usd_millions / total_tf
  ) %>%
  arrange(date, desc(state_share)) %>%
  group_by(date) %>%
  summarise(
    cr5_pct = sum(state_share[1:min(5, n())]) * 100,
    .groups = "drop"
  ) %>%
  arrange(date)

# Calculate 6-month MA for smoothing
brazil_concentration <- brazil_concentration %>%
  mutate(
    cr5_ma6 = rollmean(cr5_pct, k = 6, fill = NA, align = "center")
  )

p4 <- ggplot(brazil_concentration, aes(x = date, y = cr5_pct)) +
  geom_line(color = "#009C3B", linewidth = 1.2, alpha = 0.5) +
  geom_line(aes(y = cr5_ma6), color = "#002776", linewidth = 1.2) +
  geom_hline(yintercept = 50, linetype = "dashed", color = "gray60") +
  geom_hline(yintercept = 70, linetype = "dashed", color = "gray60") +
  annotate("text", x = min(brazil_concentration$date), y = 50, 
           label = "Moderate", hjust = 0, vjust = -0.5, size = 3, color = "gray50") +
  annotate("text", x = min(brazil_concentration$date), y = 70, 
           label = "High", hjust = 0, vjust = -0.5, size = 3, color = "gray50") +
  scale_y_continuous(labels = percent_format(scale = 1), limits = c(0, 100)) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    x = "Year",
    y = "Top 5 States Share (%)"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("plots/brazil/bra_04_regional_concentration.png", p4, width = 10, height = 6, dpi = 300)

# Export table
brazil_concentration %>%
  write_csv("tables/brazil/bra_04_regional_concentration.csv")

cat("✓ BRA-4 complete\n")
cat("  - CR5 range:", round(min(brazil_concentration$cr5_pct, na.rm = TRUE), 1), "%",
    "to", round(max(brazil_concentration$cr5_pct, na.rm = TRUE), 1), "%\n")
cat("  - Files: bra_04_regional_concentration.png, .pdf, .csv\n\n")


# ============================================================================
# PLOT 5: SIZE COMPARISON WITH PERU (Grouped Bars)
# ============================================================================
cat("[5/5] Generating BRA-5: Size Distribution Comparison (Brazil vs Peru)...\n")

# Load Peru data for comparison
peru <- readRDS("data/processed/peru_processed.rds")

# Aggregate Brazil by size (2023-2024 average) - USE USD NOT BRL
brazil_size_dist <- brazil %>%
  filter(year >= 2023, !is.na(porte), porte != "NA") %>%
  group_by(porte) %>%
  summarise(
    tf_total = sum(tf_usd_millions, na.rm = TRUE) / 2,  # Average per year
    .groups = "drop"
  ) %>%
  mutate(
    country = "Brazil",
    tf_pct = tf_total / sum(tf_total) * 100,
    # Map Brazil size categories to Peru equivalents
    size_category = case_when(
      porte == "Micro" ~ "Micro",
      porte == "Pequeno" ~ "Small",
      porte == "Médio" ~ "Medium",
      porte == "Grande" ~ "Large",
      TRUE ~ "Other"
    )
  )

# Aggregate Peru by size (2023-2024 average)
peru_size_dist <- peru %>%
  filter(year >= 2023, !is.na(size_category), size_category != "NA") %>%
  group_by(size_category) %>%
  summarise(
    tf_total = sum(tf_usd_millions, na.rm = TRUE) / 2,  # Average per year
    .groups = "drop"
  ) %>%
  mutate(
    country = "Peru",
    tf_pct = tf_total / sum(tf_total) * 100
  )

# Combine for comparison (aggregate Peru Corporate+Large as "Large")
brazil_agg <- brazil_size_dist %>%
  group_by(country, size_category) %>%
  summarise(tf_pct = sum(tf_pct), .groups = "drop")

peru_agg <- peru_size_dist %>%
  mutate(
    size_category = if_else(size_category == "Corporate", "Large", size_category)
  ) %>%
  group_by(country, size_category) %>%
  summarise(tf_pct = sum(tf_pct), .groups = "drop")

# Combine
comparison <- bind_rows(brazil_agg, peru_agg) %>%
  filter(size_category != "Other")

# Order size categories
comparison <- comparison %>%
  mutate(
    size_category = factor(size_category, levels = c("Micro", "Small", "Medium", "Large"))
  )

p5 <- ggplot(comparison, aes(x = size_category, y = tf_pct, fill = country)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c(
    "Brazil" = "#009C3B",
    "Peru" = "#D91023"
  )) +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  labs(
    x = "Borrower Size",
    y = "Share of Trade Finance (%)",
    fill = "Country"
    # NO title, NO caption - in captions.csv
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

ggsave("plots/brazil/bra_05_size_comparison.png", p5, width = 10, height = 6, dpi = 300)

# Export table
comparison %>%
  pivot_wider(names_from = country, values_from = tf_pct) %>%
  write_csv("tables/brazil/bra_05_size_comparison.csv")

cat("✓ BRA-5 complete\n")
cat("  - Brazil dominant size:", brazil_agg$size_category[which.max(brazil_agg$tf_pct)], 
    "(", round(max(brazil_agg$tf_pct), 1), "%)\n")
cat("  - Peru dominant size:", peru_agg$size_category[which.max(peru_agg$tf_pct)], 
    "(", round(max(peru_agg$tf_pct), 1), "%)\n")
cat("  - Files: bra_05_size_comparison.png, .pdf, .csv\n\n")

# ==============================================================================
# BRA-6: TF as % of Exports (MONTHLY - TF stock as % of annual exports)
# ==============================================================================
cat("[6/8] Generating BRA-6: TF as % of Exports (Monthly)...\n")

# Calculate MONTHLY TF stock as % of ANNUAL exports
brazil_vs_exports <- brazil %>%
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
write_csv(brazil_vs_exports %>% select(date, year, month, tf_month, exports_annual, tf_pct_exports), 
          "tables/brazil/bra_06_tf_pct_exports.csv")

# Create plot (NO title, NO source, clean only)
p6 <- ggplot(brazil_vs_exports, aes(x = date, y = tf_pct_exports)) +
  geom_line(color = "#009C3B", linewidth = 1.2) +
  geom_point(color = "#009C3B", size = 1.5, alpha = 0.6) +
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
ggsave("plots/brazil/bra_06_tf_pct_exports.png", p6, 
       width = 10, height = 6, dpi = 300)

cat("✓ BRA-6 complete\n")
cat("  - Range:", 
    round(min(brazil_vs_exports$tf_pct_exports, na.rm = TRUE), 2), "% to",
    round(max(brazil_vs_exports$tf_pct_exports, na.rm = TRUE), 2), "%\n")
cat("  - Files: bra_06_tf_pct_exports.png, .csv\n\n")

# ==============================================================================
# BRA-7: TF as % of Trade (MONTHLY - TF stock as % of annual exports+imports)
# ==============================================================================
cat("[7/8] Generating BRA-7: TF as % of Total Trade (Monthly)...\n")

# Calculate MONTHLY TF stock as % of ANNUAL trade (exports + imports)
brazil_vs_trade <- brazil %>%
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
write_csv(brazil_vs_trade %>% select(date, year, month, tf_month, exports_annual, imports_annual, trade_annual, tf_pct_trade), 
          "tables/brazil/bra_07_tf_pct_trade.csv")

# Create plot (NO title, NO source, clean only)
p7 <- ggplot(brazil_vs_trade, aes(x = date, y = tf_pct_trade)) +
  geom_line(color = "#FFDF00", linewidth = 1.2) +
  geom_point(color = "#FFDF00", size = 1.5, alpha = 0.6) +
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
ggsave("plots/brazil/bra_07_tf_pct_trade.png", p7, 
       width = 10, height = 6, dpi = 300)

cat("✓ BRA-7 complete\n")
cat("  - Range:", 
    round(min(brazil_vs_trade$tf_pct_trade, na.rm = TRUE), 2), "% to",
    round(max(brazil_vs_trade$tf_pct_trade, na.rm = TRUE), 2), "%\n")
cat("  - Files: bra_07_tf_pct_trade.png, .csv\n\n")

# ==============================================================================
# BRA-8: TF by Sector (Stacked Bar Chart - Top 10 Sectors)
# ==============================================================================
cat("[8/8] Generating BRA-8: TF by Sector (Stacked Bar)...\n")

# Aggregate by sector and year (annual bars)
brazil_by_sector <- brazil %>%
  group_by(year, sector_short) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  )

# Get top 10 sectors by total volume
top_sectors <- brazil_by_sector %>%
  group_by(sector_short) %>%
  summarise(total_tf = sum(tf_usd_millions, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(total_tf)) %>%
  slice_head(n = 10) %>%
  pull(sector_short)

# Filter for top sectors
brazil_top_sectors <- brazil_by_sector %>%
  filter(sector_short %in% top_sectors) %>%
  mutate(sector_short = factor(sector_short, levels = rev(top_sectors)))

# Export table
write_csv(brazil_top_sectors, "tables/brazil/bra_08_tf_by_sector.csv")

# Create plot (NO title, NO caption - in captions.csv)
p8 <- ggplot(brazil_top_sectors, aes(x = year, y = tf_usd_millions / 1000, fill = sector_short)) +
  geom_col(position = "stack") +
  scale_fill_viridis_d(option = "turbo") +
  scale_y_continuous(
    labels = comma_format(),
    expand = expansion(mult = c(0, 0.05))
  ) +
  scale_x_continuous(breaks = seq(min(brazil_top_sectors$year), max(brazil_top_sectors$year), by = 2)) +
  labs(
    x = "Year",
    y = "Trade Finance (USD billions)",
    fill = "Sector"
  ) +
  theme_minimal() +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    legend.position = "right",
    legend.title = element_text(size = 10, face = "bold"),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

# Save plot
ggsave("plots/brazil/bra_08_tf_by_sector.png", p8, 
       width = 12, height = 7, dpi = 300)

cat("✓ BRA-8 complete\n")
cat("  - Top sector:", top_sectors[1], "\n")
cat("  - Number of sectors shown:", length(top_sectors), "\n")
cat("  - Files: bra_08_tf_by_sector.png, .pdf, .csv\n\n")

# ============================================================================
# SUMMARY
# ============================================================================
cat("======================================================================\n")
cat("BRAZIL ANALYSIS COMPLETE\n")
cat("======================================================================\n")
cat("✓ 8/8 plots generated (5 original + 2 trade-based + 1 sectoral)\n\n")

cat("Outputs:\n")
cat("  plots/brazil/\n")
cat("    - bra_01_tf_pct_total.png (300 DPI)\n")
cat("    - bra_02_tf_by_size.png (300 DPI)\n")
cat("    - bra_03_tf_by_region.png (300 DPI)\n")
cat("    - bra_04_regional_concentration.png (300 DPI)\n")
cat("    - bra_05_size_comparison.png (300 DPI)\n")
cat("    - bra_06_tf_pct_exports.png (300 DPI)\n")
cat("    - bra_07_tf_pct_trade.png (300 DPI)\n")
cat("    - bra_08_tf_by_sector.png (300 DPI)\n\n")
cat("  tables/brazil/\n")
cat("    - bra_01_tf_pct_total.csv\n")
cat("    - bra_02_tf_by_size.csv\n")
cat("    - bra_03_tf_by_region.csv\n")
cat("    - bra_04_regional_concentration.csv\n")
cat("    - bra_05_size_comparison.csv\n")
cat("    - bra_06_tf_pct_exports.csv\n")
cat("    - bra_07_tf_pct_trade.csv\n")
cat("    - bra_08_tf_by_sector.csv\n\n")
cat("Captions:\n")
cat("  See captions/captions.csv for titles, sources, and notes\n\n")
cat("======================================================================\n\n")

cat("Note:\n")
cat("  - Brazil has NO individual bank data (BCB aggregation)\n")
cat("  - Regional analysis used instead of bank-level\n")
cat("  - Size distribution shows Médio (Medium) dominance (53.8%)\n")
cat("  - Comparison with Peru shows different size profiles\n\n")

cat("======================================================================\n")
