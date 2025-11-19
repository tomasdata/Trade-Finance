# ==============================================================================
# MEXICO TRADE FINANCE ANALYSIS - SIMPLIFIED
# ==============================================================================
# Description: Generate 2 plots (L/C analysis - MONTHLY frequency)
# Data: mexico_processed.rds (2,204 obs, 2022-2025, 53 banks)
# Output: plots/mexico/*.png, plots/mexico/*.pdf, tables/mexico/*.csv
# ==============================================================================

library(tidyverse)
library(scales)
library(viridis)

# Set paths
base_path <- "/Users/tomasfernandez/Documents/Tomas/Trade-Finance/country_analysis"
setwd(base_path)

# Create output directories
dir.create("plots/mexico", showWarnings = FALSE, recursive = TRUE)
dir.create("tables/mexico", showWarnings = FALSE, recursive = TRUE)

# Load data
cat("Loading Mexico processed data...\n")
mexico <- readRDS("data/processed/mexico_processed.rds")

cat("\nData structure:\n")
cat("Period:", min(mexico$date), "to", max(mexico$date), "\n")
cat("Number of banks:", n_distinct(mexico$institucion), "\n")
cat("Number of observations:", nrow(mexico), "\n\n")

# ==============================================================================
# MEX-1: Outstanding L/C (Monthly Evolution)
# ==============================================================================
cat("[1/2] Generating MEX-1: Outstanding L/C (Monthly)...\n")

mexico_monthly <- mexico %>%
  group_by(date, year, month) %>%
  summarise(
    lc_usd_millions = sum(lc_usd_millions, na.rm = TRUE),
    n_banks = n_distinct(institucion),
    .groups = "drop"
  )

write_csv(mexico_monthly, "tables/mexico/mex_01_lc_monthly.csv")

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

ggsave("plots/mexico/mex_01_lc_monthly.png", p1, width = 10, height = 6, dpi = 300)
ggsave("plots/mexico/mex_01_lc_monthly.pdf", p1, width = 10, height = 6)

cat("✓ MEX-1 complete\n")
cat("  - Range: USD", round(min(mexico_monthly$lc_usd_millions), 0), "to",
    round(max(mexico_monthly$lc_usd_millions), 0), "millions\n")
cat("  - Files: mex_01_lc_monthly.png, .pdf, .csv\n\n")

# ==============================================================================
# MEX-2: Outstanding L/C by Bank Type (MONTHLY - Stacked Area)
# ==============================================================================
cat("[2/4] Generating MEX-2: L/C by Bank Type (Monthly)...\n")

# Simplify bank classification
mexico <- mexico %>%
  mutate(
    bank_type_simple = case_when(
      bank_type == "Foreign" ~ "Foreign",
      bank_type == "Development" ~ "Development",
      bank_type == "Large Domestic" ~ "Large Domestic",
      TRUE ~ "Other Domestic"
    )
  )

mexico_by_type <- mexico %>%
  group_by(bank_type_simple, date, year, month) %>%
  summarise(
    lc_usd_millions = sum(lc_usd_millions, na.rm = TRUE),
    n_banks = n_distinct(institucion),
    .groups = "drop"
  )

write_csv(mexico_by_type, "tables/mexico/mex_02_lc_by_bank_type.csv")

p2 <- ggplot(mexico_by_type, aes(x = date, y = lc_usd_millions, fill = bank_type_simple)) +
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
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    panel.grid.minor = element_blank(),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("plots/mexico/mex_02_lc_by_bank_type.png", p2, width = 10, height = 6, dpi = 300)
ggsave("plots/mexico/mex_02_lc_by_bank_type.pdf", p2, width = 10, height = 6)

cat("✓ MEX-2 complete\n")
cat("  - Bank types:", paste(unique(mexico_by_type$bank_type_simple), collapse = ", "), "\n")
cat("  - Files: mex_02_lc_by_bank_type.png, .pdf, .csv\n\n")

# Summary
cat(rep("=", 70), "\n", sep = "")
cat("MEXICO ANALYSIS COMPLETE\n")
cat(rep("=", 70), "\n", sep = "")
cat("\n✓ 2/2 plots generated (MONTHLY frequency maintained)\n")
cat("\nOutputs:\n")
cat("  plots/mexico/\n")
cat("    - mex_01_lc_monthly.png\n")
cat("    - mex_01_lc_monthly.pdf\n")
cat("    - mex_02_lc_by_bank_type.png\n")
cat("    - mex_02_lc_by_bank_type.pdf\n\n")
