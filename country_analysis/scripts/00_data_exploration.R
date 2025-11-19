################################################################################
# Country Trade Finance Analysis - Data Exploration
# Purpose: Understand structure of all 4 country datasets
# Countries: Mexico, Peru, Chile, Brazil
# Date: November 19, 2025
################################################################################

library(tidyverse)

cat("\n")
cat("================================================================================\n")
cat("  COUNTRY TRADE FINANCE DATA - INITIAL EXPLORATION\n")
cat("  Countries: Mexico, Peru, Chile, Brazil\n")
cat("================================================================================\n\n")

# Set working directory
setwd("../data")

################################################################################
# 1. MEXICO
################################################################################

cat("=== MEXICO ===\n\n")

mexico <- read_csv("mexico_full.csv", show_col_types = FALSE)

cat("Dimensions:", nrow(mexico), "rows x", ncol(mexico), "columns\n\n")
cat("Columns:\n")
print(names(mexico))

cat("\n\nFirst 10 rows:\n")
print(head(mexico, 10))

cat("\n\nUnique institutions:\n")
print(unique(mexico$institucion))

cat("\n\nTime period:\n")
cat("Years:", paste(unique(mexico$year), collapse = ", "), "\n")
cat("Date range:", min(mexico$year_month, na.rm = TRUE), "to", max(mexico$year_month, na.rm = TRUE), "\n")

cat("\n\nTrade types:\n")
print(table(mexico$trade))

cat("\n\nSummary statistics:\n")
print(summary(mexico %>% select(where(is.numeric))))

################################################################################
# 2. PERU
################################################################################

cat("\n\n")
cat("=== PERU ===\n\n")

peru <- read_csv("peru_full.csv", show_col_types = FALSE)

cat("Dimensions:", nrow(peru), "rows x", ncol(peru), "columns\n\n")
cat("Columns:\n")
print(names(peru))

cat("\n\nFirst 10 rows:\n")
print(head(peru, 10))

cat("\n\nConceptos (credit types):\n")
print(table(peru$Concepto))

cat("\n\nUnique institutions (first 20):\n")
print(head(unique(peru$institucion_std), 20))

cat("\n\nBorrower sizes:\n")
print(table(peru$size))

cat("\n\nTime period:\n")
cat("Years:", paste(unique(peru$anio), collapse = ", "), "\n")

cat("\n\nTrade types:\n")
print(table(peru$trade))

################################################################################
# 3. CHILE
################################################################################

cat("\n\n")
cat("=== CHILE ===\n\n")

# Chile has many columns, read sample first
chile_sample <- read_csv("chile_full.csv", n_max = 1000, show_col_types = FALSE)

cat("Dimensions (sample):", nrow(chile_sample), "rows x", ncol(chile_sample), "columns\n\n")
cat("Columns (first 20):\n")
print(head(names(chile_sample), 20))

cat("\n\nFirst 5 rows (selected columns):\n")
print(head(chile_sample %>% 
           select(CodigoInstitucion, NombreInstitucion, 
                  DescripcionCuenta, Anho, Mes, MonedaTotal), 5))

cat("\n\nUnique institutions (first 20):\n")
print(head(unique(chile_sample$NombreInstitucion), 20))

cat("\n\nAccount types (sample of unique):\n")
print(head(unique(chile_sample$DescripcionCuenta), 30))

cat("\n\nTime period (from sample):\n")
cat("Years:", paste(unique(chile_sample$Anho), collapse = ", "), "\n")

################################################################################
# 4. BRAZIL
################################################################################

cat("\n\n")
cat("=== BRAZIL ===\n\n")

# Brazil is large, read sample
brazil_sample <- read_csv("brasil_full.csv", n_max = 1000, show_col_types = FALSE)

cat("Dimensions (sample):", nrow(brazil_sample), "rows x", ncol(brazil_sample), "columns\n\n")
cat("Columns:\n")
print(names(brazil_sample))

cat("\n\nFirst 5 rows (selected columns):\n")
print(head(brazil_sample %>% 
           select(data_base, uf, tcb, cliente, porte, modalidade, origem), 5))

cat("\n\nBorrower sizes (porte):\n")
print(table(brazil_sample$porte))

cat("\n\nModalities (credit types):\n")
print(table(brazil_sample$modalidade))

cat("\n\nOrigin (bank types):\n")
print(table(brazil_sample$origem))

cat("\n\nClient types:\n")
print(table(brazil_sample$cliente))

################################################################################
# 5. COMPARATIVE SUMMARY
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("  COMPARATIVE SUMMARY\n")
cat("================================================================================\n\n")

summary_df <- tibble(
  Country = c("Mexico", "Peru", "Chile", "Brazil"),
  Rows = c(
    nrow(mexico),
    nrow(peru),
    "~762,688",
    "~838,167"
  ),
  Columns = c(
    ncol(mexico),
    ncol(peru),
    ncol(chile_sample),
    ncol(brazil_sample)
  ),
  Key_Variables = c(
    "L/C liabilities, bank type, exports/imports",
    "Foreign-trade credit, borrower size, bank type",
    "Foreign-trade loans, bank type, currency types",
    "Credit by size, modality, origin, sector"
  ),
  Time_Period = c(
    paste(range(mexico$year), collapse = "-"),
    paste(range(peru$anio), collapse = "-"),
    "2004-2024 (approx)",
    "2011-2024 (approx)"
  )
)

print(summary_df)

cat("\n\n=== KEY FINDINGS ===\n\n")

cat("MEXICO:\n")
cat("  - Focus: Letters of Credit (L/C) as liabilities\n")
cat("  - Trade distinction: Exports vs Imports\n")
cat("  - ", length(unique(mexico$institucion)), " institutions\n")
cat("  - Variables in USD thousands\n\n")

cat("PERU:\n")
cat("  - Focus: Foreign-trade credit (various concepts)\n")
cat("  - Borrower sizes available\n")
cat("  - Bank types: ", paste(head(unique(peru$institucion_std), 5), collapse = ", "), "...\n")
cat("  - Both PEN and USD amounts\n\n")

cat("CHILE:\n")
cat("  - Comprehensive banking data\n")
cat("  - Multiple currency types (CLP, USD, Reajustable)\n")
cat("  - Detailed account descriptions\n")
cat("  - Need to identify foreign-trade specific accounts\n\n")

cat("BRAZIL:\n")
cat("  - Granular: by state (UF), sector (CNAE), client type\n")
cat("  - Borrower sizes (porte): ", paste(unique(brazil_sample$porte), collapse = ", "), "\n")
cat("  - Modalities include foreign-trade operations\n")
cat("  - Origin: National vs Foreign banks\n\n")

cat("=== NEXT STEPS ===\n\n")
cat("1. Identify trade finance variables in each dataset\n")
cat("2. Standardize bank type classifications\n")
cat("3. Create time series for each requested metric\n")
cat("4. Calculate concentration indices (HHI, CR4)\n")
cat("5. Generate comparable metrics across countries\n\n")

cat("================================================================================\n")
cat("  EXPLORATION COMPLETE\n")
cat("================================================================================\n\n")
