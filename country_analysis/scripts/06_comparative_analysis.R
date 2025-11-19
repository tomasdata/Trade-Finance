#!/usr/bin/env Rscript
# ==============================================================================
# COMPARATIVE ANALYSIS - 4 COUNTRIES
# ==============================================================================
# Description: Cross-country comparative graphs for Chile, Peru, Mexico, Brazil
# Data: *_processed.rds from all 4 countries
# Output: plots/comparison/*.png, tables/comparison/*.csv
# Author: Tomás Fernández
# Date: November 2025
# ==============================================================================
#
# COMPARATIVE GRAPHS:
# COMP-1: Foreign-trade credit concentration (HHI) - Chile vs Peru
# COMP-2: L/C as % of total liabilities - Chile vs Mexico
# COMP-3: TF as % of total credit - All 4 countries (where available)
# COMP-4: TF by borrower size - Brazil vs Peru
#
# ==============================================================================

# Setup ------------------------------------------------------------------------
library(tidyverse)
library(scales)
library(viridis)

# Set paths
base_path <- "/Users/tomasfernandez/Documents/Tomas/Trade-Finance/country_analysis"
setwd(base_path)

# Create output directories
dir.create("plots/comparison", showWarnings = FALSE, recursive = TRUE)
dir.create("tables/comparison", showWarnings = FALSE, recursive = TRUE)

cat("\n")
cat("======================================================================\n")
cat("COMPARATIVE ANALYSIS - 4 COUNTRIES\n")
cat("======================================================================\n\n")

# Load data --------------------------------------------------------------------
cat("Loading processed data from all countries...\n")
mexico <- readRDS("data/processed/mexico_processed.rds")
peru <- readRDS("data/processed/peru_processed.rds")
chile <- readRDS("data/processed/chile_processed.rds")
brazil <- readRDS("data/processed/brasil_processed.rds")

cat("✓ Mexico:", nrow(mexico), "obs (", min(mexico$year), "-", max(mexico$year), ")\n")
cat("✓ Peru:", nrow(peru), "obs (", min(peru$year), "-", max(peru$year), ")\n")
cat("✓ Chile:", nrow(chile), "obs (", min(chile$year), "-", max(chile$year), ")\n")
cat("✓ Brazil:", nrow(brazil), "obs (", min(brazil$year), "-", max(brazil$year), ")\n\n")

# ==============================================================================
# COMP-1: FOREIGN-TRADE CREDIT CONCENTRATION (HHI) - CHILE VS PERU
# ==============================================================================
cat("[1/4] Generating COMP-1: Foreign-Trade Credit Concentration (HHI)...\n")
cat("  Comparing: Common period 2022-2024\n")

# Chile HHI (CMF period only, 2022-2024)
chile_hhi <- chile %>%
  filter(!is.na(institucion), year >= 2022, year <= 2024) %>%
  group_by(date) %>%
  mutate(total_tf = sum(tf_usd_millions, na.rm = TRUE)) %>%
  group_by(date, institucion) %>%
  summarise(
    bank_tf = sum(tf_usd_millions, na.rm = TRUE),
    total_tf = first(total_tf),
    .groups = "drop"
  ) %>%
  mutate(market_share = bank_tf / total_tf) %>%
  group_by(date) %>%
  summarise(
    hhi = sum(market_share^2, na.rm = TRUE) * 10000,
    .groups = "drop"
  ) %>%
  mutate(country = "Chile")

# Peru HHI (same period: 2022-2024)
peru_hhi <- peru %>%
  filter(!is.na(institucion), year >= 2022, year <= 2024) %>%
  group_by(date) %>%
  mutate(total_tf = sum(tf_usd_millions, na.rm = TRUE)) %>%
  group_by(date, institucion) %>%
  summarise(
    bank_tf = sum(tf_usd_millions, na.rm = TRUE),
    total_tf = first(total_tf),
    .groups = "drop"
  ) %>%
  mutate(market_share = bank_tf / total_tf) %>%
  group_by(date) %>%
  summarise(
    hhi = sum(market_share^2, na.rm = TRUE) * 10000,
    .groups = "drop"
  ) %>%
  mutate(country = "Peru")

# Combine
concentration_comp <- bind_rows(chile_hhi, peru_hhi)

# Export table
write_csv(concentration_comp, "tables/comparison/comp_01_concentration_hhi.csv")

# Create plot (NO title, NO caption)
p1 <- ggplot(concentration_comp, aes(x = date, y = hhi, color = country)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 1500, linetype = "dashed", color = "gray60", alpha = 0.6) +
  geom_hline(yintercept = 2500, linetype = "dashed", color = "gray60", alpha = 0.6) +
  annotate("text", x = min(concentration_comp$date), y = 1500,
           label = "Moderate", hjust = 0, vjust = -0.5, size = 3, color = "gray50") +
  annotate("text", x = min(concentration_comp$date), y = 2500,
           label = "High", hjust = 0, vjust = -0.5, size = 3, color = "gray50") +
  scale_color_manual(values = c("Chile" = "#E63946", "Peru" = "#C1121F")) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  scale_y_continuous(limits = c(0, 2500)) +
  labs(
    x = "Month",
    y = "HHI Index",
    color = "Country"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("plots/comparison/comp_01_concentration_hhi.png", p1,
       width = 10, height = 6, dpi = 300)

cat("✓ COMP-1 complete\n")
cat("  - Chile HHI range:", round(min(chile_hhi$hhi), 0), "to",
    round(max(chile_hhi$hhi), 0), "\n")
cat("  - Peru HHI range:", round(min(peru_hhi$hhi), 0), "to",
    round(max(peru_hhi$hhi), 0), "\n")
cat("  - Files: comp_01_concentration_hhi.png, .csv\n\n")

# ==============================================================================
# COMP-2: L/C AS % OF TOTAL LIABILITIES - CHILE VS MEXICO
# ==============================================================================
cat("[2/4] Generating COMP-2: L/C as % of Total Liabilities...\n")
cat("  Comparing: Common period 2022-2024\n")

# Mexico: L/C as % of liabilities (2022-2024 only)
mexico_lc_liab <- mexico %>%
  filter(!is.na(total_liab_usd_millions), year >= 2022, year <= 2024) %>%
  group_by(date, year, month) %>%
  summarise(
    lc_usd_millions = sum(lc_usd_millions, na.rm = TRUE),
    total_liab_usd_millions = sum(total_liab_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    lc_pct_liabilities = (lc_usd_millions / total_liab_usd_millions) * 100,
    country = "Mexico"
  )

# Chile: L/C as % of liabilities (CMF period: 2022-2024)
chile_lc_liab <- chile %>%
  filter(is_lc == TRUE, year >= 2022, year <= 2024, !is.na(total_liab_usd_millions)) %>%
  group_by(date, year, month) %>%
  summarise(
    lc_usd_millions = sum(abs(tf_usd_millions), na.rm = TRUE),
    total_liab_usd_millions = sum(total_liab_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    lc_pct_liabilities = (lc_usd_millions / total_liab_usd_millions) * 100,
    country = "Chile"
  )

# Combine
lc_liab_comp <- bind_rows(
  mexico_lc_liab %>% select(date, country, lc_pct_liabilities),
  chile_lc_liab %>% select(date, country, lc_pct_liabilities)
)

# Export table
write_csv(lc_liab_comp, "tables/comparison/comp_02_lc_pct_liabilities.csv")

# Create plot (NO title, NO caption)
p2 <- ggplot(lc_liab_comp, aes(x = date, y = lc_pct_liabilities, color = country)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 1, alpha = 0.5) +
  scale_color_manual(values = c("Chile" = "#2A9D8F", "Mexico" = "#A23B72")) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "L/C as % of Total Liabilities",
    color = "Country"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("plots/comparison/comp_02_lc_pct_liabilities.png", p2,
       width = 10, height = 6, dpi = 300)

cat("✓ COMP-2 complete\n")
cat("  - Mexico range:", round(min(mexico_lc_liab$lc_pct_liabilities, na.rm = TRUE), 3),
    "% to", round(max(mexico_lc_liab$lc_pct_liabilities, na.rm = TRUE), 3), "%\n")
cat("  - Chile range:", round(min(chile_lc_liab$lc_pct_liabilities, na.rm = TRUE), 3),
    "% to", round(max(chile_lc_liab$lc_pct_liabilities, na.rm = TRUE), 3), "%\n")
cat("  - Files: comp_02_lc_pct_liabilities.png, .csv\n\n")

# ==============================================================================
# COMP-3: TF AS % OF EXPORTS - COMMON PERIOD 2022-2024
# ==============================================================================
cat("[3/4] Generating COMP-3: TF as % of Annual Exports...\n")
cat("  Comparing: Common period 2022-2024 for all countries\n")

# Peru: TF as % of exports (2022-2024)
peru_tf_exports <- peru %>%
  filter(year >= 2022, year <= 2024) %>%
  group_by(year, month) %>%
  summarise(
    tf_month = sum(tf_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    tf_pct_exports = (tf_month / exports_annual) * 100,
    country = "Peru"
  )

# Brazil: TF as % of exports (2022-2024)
brazil_tf_exports <- brazil %>%
  filter(year >= 2022, year <= 2024) %>%
  group_by(year, month) %>%
  summarise(
    tf_month = sum(tf_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    tf_pct_exports = (tf_month / exports_annual) * 100,
    country = "Brazil"
  )

# Chile: TF as % of exports (2022-2024)
chile_tf_exports <- chile %>%
  filter(year >= 2022, year <= 2024) %>%
  group_by(year, month) %>%
  summarise(
    tf_month = sum(tf_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    tf_pct_exports = (tf_month / exports_annual) * 100,
    country = "Chile"
  )

# Mexico: L/C as % of exports (2022-2024 only, note: L/C only, not full TF)
mexico_lc_exports <- mexico %>%
  filter(year >= 2022, year <= 2024) %>%
  group_by(year, month) %>%
  summarise(
    lc_month = sum(lc_usd_millions, na.rm = TRUE),
    exports_annual = first(exports_usd_millions),
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", sprintf("%02d", month), "-01")),
    tf_pct_exports = (lc_month / exports_annual) * 100,
    country = "Mexico (L/C only)"
  )

# Combine all
tf_exports_comp <- bind_rows(
  peru_tf_exports %>% select(date, country, tf_pct_exports),
  brazil_tf_exports %>% select(date, country, tf_pct_exports),
  chile_tf_exports %>% select(date, country, tf_pct_exports),
  mexico_lc_exports %>% select(date, country, tf_pct_exports)
)

# Export table
write_csv(tf_exports_comp, "tables/comparison/comp_03_tf_pct_exports.csv")

# Create plot (NO title, NO caption)
p3 <- ggplot(tf_exports_comp, aes(x = date, y = tf_pct_exports, color = country)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 1, alpha = 0.5) +
  scale_color_manual(values = c(
    "Peru" = "#C1121F",
    "Brazil" = "#009C3B",
    "Chile" = "#E63946",
    "Mexico (L/C only)" = "#A23B72"
  )) +
  scale_y_continuous(
    labels = percent_format(scale = 1),
    expand = expansion(mult = c(0.05, 0.1))
  ) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  labs(
    x = "Month",
    y = "Monthly TF Stock as % of Annual Exports",
    color = "Country"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("plots/comparison/comp_03_tf_pct_exports.png", p3,
       width = 12, height = 7, dpi = 300)

cat("✓ COMP-3 complete\n")
cat("  - Peru range:", round(min(peru_tf_exports$tf_pct_exports, na.rm = TRUE), 2),
    "% to", round(max(peru_tf_exports$tf_pct_exports, na.rm = TRUE), 2), "%\n")
cat("  - Brazil range:", round(min(brazil_tf_exports$tf_pct_exports, na.rm = TRUE), 2),
    "% to", round(max(brazil_tf_exports$tf_pct_exports, na.rm = TRUE), 2), "%\n")
cat("  - Chile range:", round(min(chile_tf_exports$tf_pct_exports, na.rm = TRUE), 2),
    "% to", round(max(chile_tf_exports$tf_pct_exports, na.rm = TRUE), 2), "%\n")
cat("  - Mexico (L/C) range:", round(min(mexico_lc_exports$tf_pct_exports, na.rm = TRUE), 3),
    "% to", round(max(mexico_lc_exports$tf_pct_exports, na.rm = TRUE), 3), "%\n")
cat("  - Files: comp_03_tf_pct_exports.png, .csv\n\n")

# ==============================================================================
# COMP-4: TF BY BORROWER SIZE - BRAZIL VS PERU (ALL AVAILABLE YEARS)
# ==============================================================================
cat("[4/4] Generating COMP-4: TF by Borrower Size (Brazil vs Peru)...\n")
cat("  Comparing: Monthly time series, all available years\n")

# Brazil: Monthly by size category (all years)
brazil_size_monthly <- brazil %>%
  filter(!is.na(porte), porte != "NA") %>%
  mutate(
    size_category = case_when(
      porte == "Micro" ~ "Micro",
      porte == "Pequeno" ~ "Small",
      porte == "Médio" ~ "Medium",
      porte == "Grande" ~ "Large",
      TRUE ~ "Other"
    )
  ) %>%
  filter(size_category != "Other") %>%
  group_by(date, size_category) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(country = "Brazil")

# Peru: Monthly by size category (all years)
peru_size_monthly <- peru %>%
  filter(!is.na(size_category), size_category != "NA") %>%
  mutate(
    # Aggregate Corporate + Large for Peru
    size_category = if_else(size_category == "Corporate", "Large", size_category)
  ) %>%
  filter(size_category %in% c("Micro", "Small", "Medium", "Large")) %>%
  group_by(date, size_category) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(country = "Peru")

# Combine and calculate percentages
size_comp_monthly <- bind_rows(brazil_size_monthly, peru_size_monthly) %>%
  group_by(date, country) %>%
  mutate(
    tf_total = sum(tf_usd_millions, na.rm = TRUE),
    tf_pct = (tf_usd_millions / tf_total) * 100,
    size_category = factor(size_category, levels = c("Micro", "Small", "Medium", "Large"))
  ) %>%
  ungroup()

# Also create annual average for static comparison (2012-2024, all years)
brazil_size_annual <- brazil %>%
  filter(!is.na(porte), porte != "NA") %>%
  mutate(
    size_category = case_when(
      porte == "Micro" ~ "Micro",
      porte == "Pequeno" ~ "Small",
      porte == "Médio" ~ "Medium",
      porte == "Grande" ~ "Large",
      TRUE ~ "Other"
    )
  ) %>%
  filter(size_category != "Other") %>%
  group_by(year, size_category) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(country = "Brazil")

peru_size_annual <- peru %>%
  filter(!is.na(size_category), size_category != "NA") %>%
  mutate(
    size_category = if_else(size_category == "Corporate", "Large", size_category)
  ) %>%
  filter(size_category %in% c("Micro", "Small", "Medium", "Large")) %>%
  group_by(year, size_category) %>%
  summarise(
    tf_usd_millions = sum(tf_usd_millions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(country = "Peru")

size_comp_annual <- bind_rows(brazil_size_annual, peru_size_annual) %>%
  group_by(year, country) %>%
  mutate(
    tf_total = sum(tf_usd_millions, na.rm = TRUE),
    tf_pct = (tf_usd_millions / tf_total) * 100,
    size_category = factor(size_category, levels = c("Micro", "Small", "Medium", "Large"))
  ) %>%
  ungroup()

# Export tables
write_csv(size_comp_monthly, "tables/comparison/comp_04_tf_by_size_monthly.csv")
write_csv(size_comp_annual, "tables/comparison/comp_04_tf_by_size_annual.csv")

# Create 3 plots:
# Plot A: Annual stacked bars showing absolute volume evolution
p4a <- ggplot(size_comp_annual, aes(x = year, y = tf_usd_millions / 1000, fill = size_category)) +
  geom_col(position = "stack", alpha = 0.8) +
  scale_fill_viridis_d(option = "plasma", begin = 0.2, end = 0.8) +
  scale_y_continuous(labels = comma_format()) +
  scale_x_continuous(breaks = seq(2010, 2024, by = 2)) +
  facet_wrap(~country, ncol = 1, scales = "free_y") +
  labs(
    x = "Year",
    y = "Trade Finance (USD billions)",
    fill = "Borrower Size"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    strip.text = element_text(size = 11, face = "bold")
  )

# Plot B: Annual 100% stacked bars (percentage composition)
p4b <- ggplot(size_comp_annual, aes(x = year, y = tf_pct, fill = size_category)) +
  geom_col(position = "fill", alpha = 0.8) +
  scale_fill_viridis_d(option = "plasma", begin = 0.2, end = 0.8) +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_continuous(breaks = seq(2010, 2024, by = 2)) +
  facet_wrap(~country, ncol = 1) +
  labs(
    x = "Year",
    y = "Share of Total TF (%)",
    fill = "Borrower Size"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    strip.text = element_text(size = 11, face = "bold")
  )

# Plot C: Side-by-side comparison (faceted by size, showing both countries)
p4c <- ggplot(size_comp_annual, aes(x = year, y = tf_pct, color = country, group = country)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 1.5, alpha = 0.6) +
  scale_color_manual(values = c("Brazil" = "#009C3B", "Peru" = "#C1121F")) +
  scale_y_continuous(labels = percent_format(scale = 1)) +
  scale_x_continuous(breaks = seq(2010, 2024, by = 2)) +
  facet_wrap(~size_category, ncol = 2, scales = "free_y") +
  labs(
    x = "Year",
    y = "Share of Total TF (%)",
    color = "Country"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.title = element_text(size = 11, face = "bold"),
    axis.text = element_text(size = 9),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    strip.text = element_text(size = 10, face = "bold")
  )

# Save all three plots
ggsave("plots/comparison/comp_04a_tf_by_size_volume.png", p4a,
       width = 12, height = 8, dpi = 300)
ggsave("plots/comparison/comp_04b_tf_by_size_pct.png", p4b,
       width = 12, height = 8, dpi = 300)
ggsave("plots/comparison/comp_04c_tf_by_size_trends.png", p4c,
       width = 12, height = 8, dpi = 300)

# Calculate summary statistics
brazil_2024 <- size_comp_annual %>% filter(country == "Brazil", year == 2024)
peru_2024 <- size_comp_annual %>% filter(country == "Peru", year == 2024)

cat("✓ COMP-4 complete\n")
cat("  - Brazil 2024 dominant size:",
    brazil_2024 %>% filter(tf_pct == max(tf_pct)) %>% pull(size_category) %>% as.character(),
    "(", round(max(brazil_2024$tf_pct), 1), "%)\n")
cat("  - Peru 2024 dominant size:",
    peru_2024 %>% filter(tf_pct == max(tf_pct)) %>% pull(size_category) %>% as.character(),
    "(", round(max(peru_2024$tf_pct), 1), "%)\n")
cat("  - Files: comp_04a_tf_by_size_volume.png, comp_04b_tf_by_size_pct.png, comp_04c_tf_by_size_trends.png, .csv\n\n")

# Summary ----------------------------------------------------------------------
cat(rep("=", 70), "\n", sep = "")
cat("COMPARATIVE ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n✓ 4/4 comparative analyses generated\n")
cat("\nOutputs:\n")
cat("  plots/comparison/\n")
cat("    - comp_01_concentration_hhi.png (Chile vs Peru, 2022-2024, 300 DPI)\n")
cat("    - comp_02_lc_pct_liabilities.png (Chile vs Mexico, 2022-2024, 300 DPI)\n")
cat("    - comp_03_tf_pct_exports.png (4 countries, 2022-2024, 300 DPI)\n")
cat("    - comp_04a_tf_by_size_volume.png (Brazil vs Peru, annual stacks, 300 DPI)\n")
cat("    - comp_04b_tf_by_size_pct.png (Brazil vs Peru, 100% stacks, 300 DPI)\n")
cat("    - comp_04c_tf_by_size_trends.png (Brazil vs Peru, trends by size, 300 DPI)\n")
cat("\n  tables/comparison/\n")
cat("    - comp_01_concentration_hhi.csv\n")
cat("    - comp_02_lc_pct_liabilities.csv\n")
cat("    - comp_03_tf_pct_exports.csv\n")
cat("    - comp_04_tf_by_size_monthly.csv\n")
cat("    - comp_04_tf_by_size_annual.csv\n")
cat(rep("=", 70), "\n", sep = "")
