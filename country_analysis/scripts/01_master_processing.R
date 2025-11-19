# ==============================================================================
# 01_MASTER_PROCESSING.R
# Country Trade Finance Analysis - Master Data Processing Script
# ==============================================================================
# 
# Purpose: Load and process data from Mexico, Peru, Chile, and Brazil
#          Standardize formats, classify banks, create unified datasets
#
# Inputs:  data/mexico_full.csv, peru_full.csv, chile_full.csv, brasil_full.csv
# Outputs: data/processed/*.rds (processed data objects)
#
# Author:  Analysis Team
# Date:    November 2025
# ==============================================================================

# Load packages ----------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(scales)
})

cat("\n=======================================================\n")
cat("  MASTER DATA PROCESSING - COUNTRY TRADE FINANCE\n")
cat("=======================================================\n\n")

# Create output directory ------------------------------------------------------
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
  cat("✓ Created data/processed/ directory\n")
}

# ==============================================================================
# PART 1: MEXICO
# ==============================================================================
cat("\n[1/4] Processing MEXICO data...\n")

# Load Mexico data (ENHANCED with total liabilities and L/C %)
mexico_raw <- read_csv("data/mexico_full.csv", show_col_types = FALSE)
cat("  → Loaded:", nrow(mexico_raw), "observations\n")
cat("  → Period:", min(mexico_raw$year), "-", max(mexico_raw$year), "\n")
cat("  → Banks:", length(unique(mexico_raw$institucion)), "\n")

# Classify Mexican banks by type
mexico_foreign_banks <- c(
  "BANK OF AMERICA", "JP MORGAN", "MUFG", "CITI MEXICO", "MIZUHO",
  "ICBC", "BANK OF CHINA", "BARCLAYS", "SHINHAN", "SABADELL"
)

mexico_development_banks <- c(
  "BANCOMEXT", "BANOBRAS", "BANJERCITO", "NAFIN", "BABIEN", "HIPOTECARIA FED"
)

mexico_large_domestic <- c(
  "BANAMEX", "BBVA MEXICO", "SANTANDER", "BANORTE", "SCOTIABANK",
  "INBURSA", "BANREGIO", "BAJIO", "HSBC"  # HSBC is foreign-owned but major domestic player
)

mexico <- mexico_raw %>%
  mutate(
    # Standardize date
    date = ymd(paste0(year, "-", sprintf("%02d", month), "-01")),
    
    # Classify bank type (more detailed)
    bank_type = case_when(
      str_detect(toupper(institucion), paste(mexico_development_banks, collapse = "|")) ~ "Development",
      str_detect(toupper(institucion), paste(mexico_foreign_banks, collapse = "|")) ~ "Foreign",
      str_detect(toupper(institucion), paste(mexico_large_domestic, collapse = "|")) ~ "Large Domestic",
      TRUE ~ "Other Domestic"
    ),
    
    # Classify size category
    bank_size = case_when(
      bank_type == "Foreign" ~ "Foreign",
      bank_type == "Development" ~ "Development",
      str_detect(toupper(institucion), paste(mexico_large_domestic, collapse = "|")) ~ "Large",
      TRUE ~ "Medium/Small"
    ),
    
    # L/C metrics
    lc_usd_millions = amount_usd / 1e6,
    lc_mxn_billions = amount_mxn / 1e9,
    total_liab_usd_millions = total_liab_usd_millions  # Already in millions
    
    # NOTE: exports_usd_millions, imports_usd_millions already in mexico_full.csv
    # These are ANNUAL data from GMD (same value repeated all 12 months of each year)
  ) %>%
  select(
    date, year, month, year_month,
    cod_inst, institucion, bank_type, bank_size,
    lc_usd_millions, lc_mxn_billions, total_liab_usd_millions,
    exports_usd_millions, imports_usd_millions
  )

cat("  → Classified banks:\n")
cat("     - Foreign:", sum(mexico$bank_type == "Foreign" & !duplicated(mexico$institucion)), "\n")
cat("     - Large Domestic:", sum(mexico$bank_type == "Large Domestic" & !duplicated(mexico$institucion)), "\n")
cat("     - Other Domestic:", sum(mexico$bank_type == "Other Domestic" & !duplicated(mexico$institucion)), "\n")

# Save
saveRDS(mexico, "data/processed/mexico_processed.rds")
cat("  ✓ Saved: data/processed/mexico_processed.rds\n")

# ==============================================================================
# PART 2: PERU
# ==============================================================================
cat("\n[2/4] Processing PERU data...\n")

# Load Peru data
peru_raw <- read_csv("data/peru_full.csv", show_col_types = FALSE)
cat("  → Loaded:", nrow(peru_raw), "observations\n")
cat("  → Period:", min(peru_raw$anio), "-", max(peru_raw$anio), "\n")

# Filter for foreign-trade credit
peru_tf <- peru_raw %>%
  filter(Concepto == "Comercio exterior")
cat("  → Foreign-trade credit obs:", nrow(peru_tf), "\n")

# Classify Peruvian banks
peru_foreign_banks <- c(
  "CITIBANK", "DEUTSCHE BANK", "BANK OF CHINA", "ICBC",
  "SCOTIABANK", "BBVA"  # Foreign-owned despite local names
)

peru_state_banks <- c(
  "BANCO DE LA NACION", "AGROBANCO", "BANCO CENTRAL"
)

peru_large_domestic <- c(
  "CREDITO", "BCP", "INTERBANK", "BANBIF", "CONTINENTAL"
)

peru <- peru_tf %>%
  mutate(
    # Standardize date
    date = ymd(paste0(anio, "-", sprintf("%02d", mes), "-01")),
    
    # Classify bank type
    bank_type = case_when(
      str_detect(toupper(institucion), paste(peru_foreign_banks, collapse = "|")) ~ "Foreign",
      str_detect(toupper(institucion), paste(peru_state_banks, collapse = "|")) ~ "State",
      str_detect(toupper(institucion), paste(peru_large_domestic, collapse = "|")) ~ "Large Domestic",
      str_detect(toupper(institucion), "MIBANCO|FALABELLA|RIPLEY") ~ "Consumer/Retail",
      TRUE ~ "Other Domestic"
    ),
    
    # Standardize size categories
    size_category = case_when(
      str_detect(size, "Corporate|Corporativ") ~ "Corporate",
      str_detect(size, "Grande|Large") ~ "Large",
      str_detect(size, "Median|Medium") ~ "Medium",
      str_detect(size, "Peque|Small") ~ "Small",
      str_detect(size, "Micro") ~ "Micro",
      TRUE ~ "Other"
    ),
    
    # Convert to USD millions
    tf_usd_millions = amount_usd / 1e6,
    total_credit_usd_millions = total_usd / 1e6,
    
    # Calculate share
    tf_share_pct = share * 100
    
    # NOTE: exports_usd_millions, imports_usd_millions already in peru_full.csv
  ) %>%
  select(
    date, year = anio, month = mes, year_month,
    institucion = institucion_std, bank_type,
    size_category,
    tf_usd_millions, total_credit_usd_millions, tf_share_pct,
    exports_usd_millions, imports_usd_millions
  )

cat("  → Classified banks:\n")
cat("     - Foreign:", sum(peru$bank_type == "Foreign" & !duplicated(peru$institucion)), "\n")
cat("     - State:", sum(peru$bank_type == "State" & !duplicated(peru$institucion)), "\n")
cat("     - Large Domestic:", sum(peru$bank_type == "Large Domestic" & !duplicated(peru$institucion)), "\n")
cat("     - Consumer/Retail:", sum(peru$bank_type == "Consumer/Retail" & !duplicated(peru$institucion)), "\n")
cat("  → Size categories:\n")
print(table(peru$size_category))

# Save
saveRDS(peru, "data/processed/peru_processed.rds")
cat("  ✓ Saved: data/processed/peru_processed.rds\n")

# ==============================================================================
# PART 3: CHILE
# ==============================================================================
cat("\n[3/4] Processing CHILE data...\n")

# Load Chile data
chile_raw <- read_csv("data/chile_full.csv", show_col_types = FALSE)
cat("  → Loaded:", nrow(chile_raw), "observations\n")
cat("  → Period:", min(chile_raw$Anho), "-", max(chile_raw$Anho), "\n")

# ==============================================================================
# FIX: Chile 2022-2024 Trade Finance Categorization
# Issue: CMF changed accounting plan in 2022 (IFRS 9)
# Old codes (2015-2021): 7-9 digits, SBIF system
# New codes (2022-2024): 9 digits, CMF system
# Solution: Re-categorize accounts for 2022-2024 using new plan codes
# ==============================================================================

cat("  → Fixing Chile 2022-2024 trade finance categories...\n")

# Define TF accounts for OLD plan (2015-2021)
tf_old_asset_accounts <- c(
  # Credits for trade finance (SBIF plan)
  1270116, 1270117, 1270118,  # Export/Import/Third-party credits
  1270206, 1270207, 1270208,  # Export/Import/Third-party credits (alt)
  1302200,  # Trade finance credits general
  1302201, 1302202,  # Export credits and L/C
  1302241, 1302242   # Import credits and L/C
)

# Define TF accounts for NEW plan (2022-2024) - CMF/IFRS 9
# CRITICAL FIX: ONLY ASSET ACCOUNTS + REMOVE PARENT ACCOUNTS
tf_new_asset_accounts <- c(
  # Créditos comercio exterior (Activos SOLO) - SUBACCOUNTS ONLY
  # 145400200 REMOVED: Parent account that duplicates 201-204
  145400201, 145400202,  # Export financing (L/C + otros)
  145400203, 145400204,  # Import financing (L/C + otros)
  143200104, 143200106,  # Export + third-party
  143100104, 143100105, 143100106,  # Export/Import/Third-party (cat 1)
  
  # Garantías OTORGADAS (assets)
  190000204, 190000202,  # Guarantees given
  
  # Cartas de Crédito
  271000200,  # L/C stand-by
  
  # Activos con bancos del exterior (assets only)
  141000200, 141000400  # Assets with foreign banks
  
  # REMOVED ACCOUNTS (to prevent double-counting):
  # - 145400200: Parent account (= 201 + 202 + 203 + 204)
  # - 244500100, 244500101, 244500102: Funding (liabilities)
  # - 244250100, 244250101, 244250102: Funding category 2 (liabilities)
  # - 290000104, 290000102: Guarantees received (liabilities)
  # - 246000208, 246000304: Obligations to exporters (liabilities)
  # - 243000200, 243000400: Liabilities with foreign banks (liabilities)
  # - 272000000, 260000200: Provisions (negative entries)
)

# Re-categorize for 2022-2024
chile_raw <- chile_raw %>%
  mutate(
    # Preserve original categorization
    categoria_tf_orig = categoria_tf,
    
    # Create unified TF flag for both periods
    # NOTE: categoria_tf from ETL is ALL "otros" for 2015-2021, so we use account codes directly
    is_tf_account = case_when(
      # 2015-2021: Use old account codes directly
      Anho < 2022 & CodigoCuenta %in% tf_old_asset_accounts ~ TRUE,
      
      # 2022-2024: Use new account list
      Anho >= 2022 & CodigoCuenta %in% tf_new_asset_accounts ~ TRUE,
      
      # Default
      TRUE ~ FALSE
    ),
    
    # Enhanced categorization for 2022-2024
    categoria_tf_new = case_when(
      # Keep 2015-2021 original
      Anho < 2022 ~ categoria_tf,
      
      # Re-categorize 2022-2024
      Anho >= 2022 & CodigoCuenta == 145400200 ~ "comercio_exterior",
      Anho >= 2022 & CodigoCuenta %in% c(145400201, 145400202, 143200104, 143100104) ~ "exportaciones",
      Anho >= 2022 & CodigoCuenta %in% c(145400203, 145400204, 143100105) ~ "importaciones",
      Anho >= 2022 & CodigoCuenta %in% c(143200106, 143100106) ~ "terceros_paises",
      Anho >= 2022 & CodigoCuenta %in% c(244500100, 244500101, 244250100, 244250101) ~ "financiamiento_exportaciones",
      Anho >= 2022 & CodigoCuenta %in% c(244500102, 244250102) ~ "financiamiento_importaciones",
      Anho >= 2022 & CodigoCuenta %in% c(190000204, 190000202, 290000104, 290000102) ~ "garantias",
      Anho >= 2022 & CodigoCuenta == 271000200 ~ "cartas_credito",
      Anho >= 2022 & CodigoCuenta %in% c(246000208, 246000304) ~ "obligaciones",
      Anho >= 2022 & CodigoCuenta %in% c(141000200, 141000400, 243000200, 243000400) ~ "interbancario_exterior",
      Anho >= 2022 & CodigoCuenta %in% c(272000000, 260000200) ~ "provisiones",
      Anho >= 2022 & CodigoCuenta %in% tf_new_asset_accounts ~ "otros_tf",
      
      # Default
      TRUE ~ "otros"
    )
  )

# Summary of fix
tf_by_period <- chile_raw %>%
  filter(is_tf_account) %>%
  group_by(Anho) %>%
  summarise(
    obs = n(),
    bancos = n_distinct(NombreInstitucion),
    cuentas = n_distinct(CodigoCuenta),
    monto_total = sum(abs(MonedaTotal_num), na.rm = TRUE) / 1e12  # Trillones CLP
  )

cat("  → Chile TF accounts by period:\n")
print(as.data.frame(tf_by_period))

# ==============================================================================
# Extract TOTAL PASIVOS (Total Liabilities) for CHL-5 calculation
# Account code: 200000000 = TOTAL PASIVOS
# Available for 2022-2024 (CMF period)
# ==============================================================================
cat("  → Extracting total liabilities (account 200000000)...\n")

chile_total_liab <- chile_raw %>%
  filter(CodigoCuenta == 200000000) %>%
  mutate(
    date = ymd(paste0(Anho, "-", sprintf("%02d", Mes), "-01")),
    # Convert to USD millions (same logic as TF conversion)
    clp_usd_rate = case_when(
      Anho == 2015 ~ 654,
      Anho == 2016 ~ 677,
      Anho == 2017 ~ 649,
      Anho == 2018 ~ 641,
      Anho == 2019 ~ 703,
      Anho == 2020 ~ 792,
      Anho == 2021 ~ 758,
      Anho == 2022 ~ 870,
      Anho == 2023 ~ 855,
      Anho == 2024 ~ 945,
      TRUE ~ 800
    ),
    total_liab_usd_millions = MonedaTotal_num / clp_usd_rate / 1000000
  ) %>%
  select(
    date, year = Anho, month = Mes,
    codigo_inst = CodigoInstitucion, institucion = NombreInstitucion,
    codigo_cuenta = CodigoCuenta,
    total_liab_usd_millions
  )

cat("  → Total liabilities obs:", nrow(chile_total_liab), "\n")
cat("  → Period:", min(chile_total_liab$year), "-", max(chile_total_liab$year), "\n")

# Filter for trade finance using unified flag
chile_tf <- chile_raw %>%
  filter(is_tf_account)

cat("  → Trade finance obs:", nrow(chile_tf), "\n")
cat("  → Banks:", length(unique(chile_tf$NombreInstitucion)), "\n")

# Classify Chilean banks
chile_foreign_banks <- c(
  "BRASIL", "CHINA", "SECURITY", "PARIS", "TOKYO"
)

chile_state_banks <- c(
  "ESTADO"
)

chile_large_domestic <- c(
  "CHILE", "CREDITO", "BCI", "SANTANDER", "ITAU", "SCOTIABANK"
)

chile <- chile_tf %>%
  mutate(
    # Standardize date
    date = ymd(paste0(Anho, "-", sprintf("%02d", Mes), "-01")),
    
    # Classify bank type (handle NA in NombreInstitucion for 2022-2024)
    bank_type = case_when(
      !is.na(NombreInstitucion) & str_detect(toupper(NombreInstitucion), paste(chile_foreign_banks, collapse = "|")) ~ "Foreign",
      !is.na(NombreInstitucion) & str_detect(toupper(NombreInstitucion), paste(chile_state_banks, collapse = "|")) ~ "State",
      !is.na(NombreInstitucion) & str_detect(toupper(NombreInstitucion), paste(chile_large_domestic, collapse = "|")) ~ "Large Domestic",
      !is.na(NombreInstitucion) ~ "Other Domestic",
      TRUE ~ "Unknown"  # For aggregated 2022-2024 data
    ),
    
    # Categorize account type (use new categorization for 2022-2024)
    account_type = case_when(
      # Use categoria_tf_new for classification
      categoria_tf_new == "exportaciones" ~ "Export Financing",
      categoria_tf_new == "importaciones" ~ "Import Financing",
      categoria_tf_new == "terceros_paises" ~ "Third-Party Trade",
      categoria_tf_new == "cartas_credito" ~ "Letters of Credit",
      categoria_tf_new %in% c("financiamiento_exportaciones", "financiamiento_importaciones") ~ "Foreign Funding",
      categoria_tf_new == "garantias" ~ "Guarantees",
      categoria_tf_new == "interbancario_exterior" ~ "Interbank Foreign",
      categoria_tf_new == "comercio_exterior" ~ "Trade Finance General",
      TRUE ~ "Other Trade Finance"
    ),
    
    # Convert to USD millions
    # MonedaTotal_num is in THOUSANDS of CLP
    # Using historical average CLP/USD rates (Banco Central de Chile):
    clp_usd_rate = case_when(
      Anho == 2015 ~ 654,
      Anho == 2016 ~ 677,
      Anho == 2017 ~ 649,
      Anho == 2018 ~ 641,
      Anho == 2019 ~ 703,
      Anho == 2020 ~ 792,
      Anho == 2021 ~ 758,
      Anho == 2022 ~ 870,
      Anho == 2023 ~ 855,
      Anho == 2024 ~ 945,
      TRUE ~ 800  # Fallback promedio
    ),
    # Convert: (thousands CLP) / (CLP per USD) / 1,000,000 = millions USD
    # Step 1: thousands CLP / rate = thousands USD
    # Step 2: thousands USD / 1,000,000 = millions USD
    tf_usd_millions = MonedaTotal_num / clp_usd_rate / 1000000,
    
    # Flag if L/C (update for new codes)
    is_lc = case_when(
      Anho < 2022 & CodigoCuenta %in% c(1302201, 1302241) ~ TRUE,
      Anho >= 2022 & CodigoCuenta %in% c(145400201, 145400203, 271000200) ~ TRUE,
      TRUE ~ FALSE
    ),
    
    # Add categoria for easier analysis
    categoria = categoria_tf_new
    
    # NOTE: exports_usd_millions, imports_usd_millions already in chile_full.csv (from GMD)
  ) %>%
  select(
    date, year = Anho, month = Mes,
    codigo_inst = CodigoInstitucion, institucion = NombreInstitucion,
    bank_type, 
    codigo_cuenta = CodigoCuenta, descripcion = DescripcionCuenta,
    account_type, categoria, is_lc,
    monto_clp_thousands = MonedaTotal_num,
    tf_usd_millions,
    exports_usd_millions, imports_usd_millions
  )

# Merge total liabilities data (available for 2022-2024 only)
cat("  → Merging total liabilities by bank-date...\n")
chile <- chile %>%
  left_join(
    chile_total_liab %>% select(date, codigo_inst, total_liab_usd_millions),
    by = c("date", "codigo_inst")
  )

cat("  → Classified banks:\n")
cat("     - Foreign:", sum(chile$bank_type == "Foreign" & !duplicated(chile$institucion)), "\n")
cat("     - State:", sum(chile$bank_type == "State" & !duplicated(chile$institucion)), "\n")
cat("     - Large Domestic:", sum(chile$bank_type == "Large Domestic" & !duplicated(chile$institucion)), "\n")
cat("  → Account types:\n")
print(table(chile$account_type))

# Save
saveRDS(chile, "data/processed/chile_processed.rds")
cat("  ✓ Saved: data/processed/chile_processed.rds\n")

# ==============================================================================
# PART 4: BRAZIL
# ==============================================================================
cat("\n[4/4] Processing BRAZIL data...\n")

# Load Brazil data (sample for now due to size)
brasil_raw <- read_csv("data/brasil_full.csv", show_col_types = FALSE)
cat("  → Loaded:", nrow(brasil_raw), "observations\n")
cat("  → Period:", min(brasil_raw$year), "-", max(brasil_raw$year), "\n")

# Note: Brazil data already filtered for "PJ - Comércio exterior"
brasil <- brasil_raw %>%
  mutate(
    # Standardize date
    date = ymd(paste0(year, "-", sprintf("%02d", month), "-01")),
    
    # Standardize size categories (for comparison with Peru)
    size_category = case_when(
      str_detect(porte, "Grande") ~ "Large",
      str_detect(porte, "Médio") ~ "Medium",
      str_detect(porte, "Pequeno") ~ "Small",
      str_detect(porte, "Micro") ~ "Micro",
      TRUE ~ "Unknown"
    ),
    
    # Simplify sector names
    sector_short = case_when(
      str_detect(cnae_secao, "Indústrias de transformação") ~ "Manufacturing",
      str_detect(cnae_secao, "Comércio") ~ "Wholesale/Retail",
      str_detect(cnae_secao, "Agricultura") ~ "Agriculture",
      str_detect(cnae_secao, "Transporte") ~ "Transport/Logistics",
      str_detect(cnae_secao, "Administrat") ~ "Admin Services",
      str_detect(cnae_secao, "Profission") ~ "Professional Services",
      str_detect(cnae_secao, "extrativas") ~ "Mining",
      str_detect(cnae_secao, "Construção") ~ "Construction",
      str_detect(cnae_secao, "Informação") ~ "IT/Communication",
      str_detect(cnae_secao, "Finan") ~ "Financial Services",
      TRUE ~ "Other"
    ),
    
    # Region classification
    region = case_when(
      uf %in% c("SP", "RJ", "MG", "ES") ~ "Southeast",
      uf %in% c("RS", "SC", "PR") ~ "South",
      uf %in% c("BA", "SE", "AL", "PE", "PB", "RN", "CE", "PI", "MA") ~ "Northeast",
      uf %in% c("GO", "MT", "MS", "DF") ~ "Center-West",
      TRUE ~ "North"
    ),
    
    # Interest rate type
    rate_type = case_when(
      str_detect(indexador, "Pós") ~ "Post-fixed",
      str_detect(indexador, "Pre") ~ "Pre-fixed",
      str_detect(indexador, "Flu") ~ "Floating",
      str_detect(indexador, "preços") ~ "Price Index",
      TRUE ~ "Other"
    ),
    
    # Convert to USD millions (FIXED: carteira was in BRL units, divide by 1e9 then convert)
    # Original carteira values are in BRL cents or similar unit → need /1e9 not /1e6
    tf_usd_millions = carteira_ativa_usd / 1e9,  # FIX: Was /1e6 → inflated by 1000x
    tf_brl_millions = carteira_ativa_brl / 1e9,  # FIX: Was /1e6 → inflated by 1000x
    
    # NOTE: exports_usd_millions, imports_usd_millions already in brasil_full.csv
    
    # NPL rate
    npl_rate = ifelse(carteira_ativa > 0, 
                     carteira_inadimplida_arrastada / carteira_ativa * 100, 
                     NA)
  ) %>%
  select(
    date, year, month, year_month,
    uf, region, 
    cnae_secao, sector_short,
    porte, size_category,
    indexador, rate_type,
    numero_de_operacoes,
    tf_usd_millions, tf_brl_millions,
    a_vencer_ate_90_dias_usd, a_vencer_de_91_ate_360_dias_usd,
    exports_usd_millions, imports_usd_millions,
    npl_rate
  )

cat("  → Size categories:\n")
print(table(brasil$size_category))
cat("  → Regions:\n")
print(table(brasil$region))
cat("  → Top sectors:\n")
print(head(sort(table(brasil$sector_short), decreasing = TRUE), 10))

# Save
saveRDS(brasil, "data/processed/brasil_processed.rds")
cat("  ✓ Saved: data/processed/brasil_processed.rds\n")

# ==============================================================================
# PART 5: SUMMARY STATISTICS
# ==============================================================================
cat("\n=======================================================\n")
cat("  SUMMARY STATISTICS\n")
cat("=======================================================\n\n")

cat("MEXICO:\n")
cat("  Observations:", nrow(mexico), "\n")
cat("  Period:", format(min(mexico$date), "%b %Y"), "-", 
    format(max(mexico$date), "%b %Y"), "\n")
cat("  Banks:", length(unique(mexico$institucion)), "\n")
cat("  Total L/C (USD millions):", 
    format(sum(mexico$lc_usd_millions, na.rm = TRUE), big.mark = ",", nsmall = 0), "\n")

cat("\nPERU:\n")
cat("  Observations:", nrow(peru), "\n")
cat("  Period:", format(min(peru$date), "%b %Y"), "-", 
    format(max(peru$date), "%b %Y"), "\n")
cat("  Banks:", length(unique(peru$institucion)), "\n")
cat("  Total TF Credit (USD millions):", 
    format(sum(peru$tf_usd_millions, na.rm = TRUE), big.mark = ",", nsmall = 0), "\n")
cat("  Size categories:", paste(unique(peru$size_category), collapse = ", "), "\n")

cat("\nCHILE:\n")
cat("  Observations:", nrow(chile), "\n")
cat("  Period:", format(min(chile$date), "%b %Y"), "-", 
    format(max(chile$date), "%b %Y"), "\n")
cat("  Banks:", length(unique(chile$institucion)), "\n")
cat("  TF Accounts:", length(unique(chile$codigo_cuenta)), "\n")

cat("\nBRAZIL:\n")
cat("  Observations:", nrow(brasil), "\n")
cat("  Period:", format(min(brasil$date), "%b %Y"), "-", 
    format(max(brasil$date), "%b %Y"), "\n")
cat("  States:", length(unique(brasil$uf)), "\n")
cat("  Sectors:", length(unique(brasil$sector_short)), "\n")
cat("  Total TF Credit (USD millions):", 
    format(sum(brasil$tf_usd_millions, na.rm = TRUE), big.mark = ",", nsmall = 0), "\n")

cat("\n=======================================================\n")
cat("  PROCESSING COMPLETE!\n")
cat("=======================================================\n")
cat("\nProcessed data saved in: data/processed/\n")
cat("  - mexico_processed.rds\n")
cat("  - peru_processed.rds\n")
cat("  - chile_processed.rds\n")
cat("  - brasil_processed.rds\n\n")

cat("Ready for country-specific analysis scripts!\n\n")
