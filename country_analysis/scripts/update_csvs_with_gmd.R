#!/usr/bin/env Rscript
# ============================================================================
# UPDATE COUNTRY CSVs WITH GMD DATA ONLY
# ============================================================================
# Purpose: Replace BACI trade data with GMD-only (avoid discontinuities)
# Author: Tomás Fernández
# Date: November 2025
# ============================================================================

library(tidyverse)

cat("\n")
cat("═══════════════════════════════════════════════════════════════\n")
cat("  UPDATING COUNTRY CSVs WITH GMD DATA (NO BACI)\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

# Load GMD data
cat("[1/5] Loading GMD data...\n")
gmd <- read_csv("data/GMD.csv", show_col_types = FALSE) %>%
  filter(countryname %in% c("Mexico", "Peru", "Chile", "Brazil")) %>%
  select(country = countryname, year, 
         exports_usd_millions = exports_USD, 
         imports_usd_millions = imports_USD,
         gdp_usd_billions = nGDP_USD) %>%
  mutate(gdp_usd_billions = gdp_usd_billions / 1000)  # Convert millions to billions

cat("  → GMD loaded:", nrow(gmd), "country-year observations\n")
cat("  → Countries:", unique(gmd$country) %>% paste(collapse = ", "), "\n")
cat("  → Years:", min(gmd$year, na.rm=TRUE), "-", max(gmd$year, na.rm=TRUE), "\n\n")

# ============================================================================
# MEXICO
# ============================================================================
cat("[2/5] Processing MEXICO...\n")
mexico <- read_csv("data/mexico_full.csv", show_col_types = FALSE)

# Remove old trade columns if they exist
mexico <- mexico %>%
  select(-any_of(c("X_exports", "M_imports", "trade", 
                   "exports_usd_millions", "imports_usd_millions", 
                   "gdp_usd_billions")))

# Add GMD data
mexico <- mexico %>%
  left_join(gmd %>% filter(country == "Mexico") %>% select(-country),
            by = "year")

cat("  → Updated:", nrow(mexico), "observations\n")
cat("  → Trade data rows:", sum(!is.na(mexico$exports_usd_millions)), "\n")
cat("  → GDP data rows:", sum(!is.na(mexico$gdp_usd_billions)), "\n")

write_csv(mexico, "data/mexico_full.csv")
cat("  ✓ Saved: data/mexico_full.csv\n\n")

# ============================================================================
# PERU
# ============================================================================
cat("[3/5] Processing PERU...\n")
peru <- read_csv("data/peru_full.csv", show_col_types = FALSE)

# Remove old trade columns
peru <- peru %>%
  select(-any_of(c("X_exports", "M_imports", "trade",
                   "exports_usd_millions", "imports_usd_millions",
                   "gdp_usd_billions")))

# Add GMD data (Peru uses "anio" not "year")
peru <- peru %>%
  left_join(gmd %>% filter(country == "Peru") %>% select(-country),
            by = c("anio" = "year"))

cat("  → Updated:", nrow(peru), "observations\n")
cat("  → Trade data rows:", sum(!is.na(peru$exports_usd_millions)), "\n")
cat("  → GDP data rows:", sum(!is.na(peru$gdp_usd_billions)), "\n")

write_csv(peru, "data/peru_full.csv")
cat("  ✓ Saved: data/peru_full.csv\n\n")

# ============================================================================
# CHILE
# ============================================================================
cat("[4/5] Processing CHILE...\n")
chile <- read_csv("data/chile_full.csv", show_col_types = FALSE)

# Remove old trade columns
chile <- chile %>%
  select(-any_of(c("X_exports", "M_imports", "trade",
                   "exports_usd_millions", "imports_usd_millions",
                   "gdp_usd_billions")))

# Add GMD data (Chile uses "Anho" not "year")
chile <- chile %>%
  left_join(gmd %>% filter(country == "Chile") %>% select(-country),
            by = c("Anho" = "year"))

cat("  → Updated:", nrow(chile), "observations\n")
cat("  → Trade data rows:", sum(!is.na(chile$exports_usd_millions)), "\n")
cat("  → GDP data rows:", sum(!is.na(chile$gdp_usd_billions)), "\n")

write_csv(chile, "data/chile_full.csv")
cat("  ✓ Saved: data/chile_full.csv\n\n")

# ============================================================================
# BRAZIL
# ============================================================================
cat("[5/5] Processing BRAZIL...\n")
brasil <- read_csv("data/brasil_full.csv", show_col_types = FALSE)

# Remove old trade columns
brasil <- brasil %>%
  select(-any_of(c("X_exports", "M_imports", "trade",
                   "exports_usd_millions", "imports_usd_millions",
                   "gdp_usd_billions")))

# Add GMD data
brasil <- brasil %>%
  left_join(gmd %>% filter(country == "Brazil") %>% select(-country),
            by = "year")

cat("  → Updated:", nrow(brasil), "observations\n")
cat("  → Trade data rows:", sum(!is.na(brasil$exports_usd_millions)), "\n")
cat("  → GDP data rows:", sum(!is.na(brasil$gdp_usd_billions)), "\n")

write_csv(brasil, "data/brasil_full.csv")
cat("  ✓ Saved: data/brasil_full.csv\n\n")

# ============================================================================
# SUMMARY
# ============================================================================
cat("═══════════════════════════════════════════════════════════════\n")
cat("  SUMMARY: ALL 4 COUNTRIES UPDATED WITH GMD DATA\n")
cat("═══════════════════════════════════════════════════════════════\n\n")

cat("✅ Mexico:  GMD trade data (2022-2024), annual GDP\n")
cat("✅ Peru:    GMD trade data (2010-2024), annual GDP\n")
cat("✅ Chile:   GMD trade data (2015-2024), annual GDP\n")
cat("✅ Brazil:  GMD trade data (2012-2024), annual GDP\n\n")

cat("🎯 Methodology: GMD ONLY (no BACI mix)\n")
cat("   - Consistent BOP methodology across all years\n")
cat("   - No discontinuities from source mixing\n")
cat("   - GDP as annual variable (no interpolation)\n\n")

cat("📝 Next: Re-run scripts/01_master_processing.R\n\n")
