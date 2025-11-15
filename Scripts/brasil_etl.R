#!/usr/bin/env Rscript
# Brasil trade finance ETL
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
})

message(">> Iniciando ETL de Brasil (PJ - Comércio exterior)")

# Resolve paths ---------------------------------------------------------------
args <- commandArgs(trailingOnly = FALSE)
file_flag <- "--file="
script_path <- sub(file_flag, "", args[grep(file_flag, args)])
if (length(script_path) == 0) {
  script_path <- "Scripts/brasil_etl.R"
}
script_dir <- dirname(normalizePath(script_path, winslash = "/", mustWork = FALSE))
repo_root <- normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = TRUE)

pre_root   <- file.path(repo_root, "pre-data")
brasil_dir <- file.path(pre_root, "Brasil")
data_dir   <- file.path(repo_root, "data")

raw_file   <- file.path(brasil_dir, "brasil_full.csv")
ptax_file  <- file.path(brasil_dir, "brl_usd_monthly_ptax.csv")
out_file   <- file.path(data_dir, "brasil_full.csv")

stopifnot(file.exists(raw_file), file.exists(ptax_file))

# Load raw data ---------------------------------------------------------------
message("   - Leyendo base cruda del BCB: ", raw_file)
brasil <- fread(raw_file)

# Normalize dates and keys
brasil[, data_base := as.Date(data_base)]
brasil[, year := as.integer(format(data_base, "%Y"))]
brasil[, month := as.integer(format(data_base, "%m"))]
brasil[, year_month := as.Date(sprintf("%04d-%02d-01", year, month))]

# Load PTAX monthly averages
message("   - Integrando PTAX mensual (BRL/USD)")
ptax <- fread(ptax_file)
ptax[, year_month := as.Date(year_month)]
setnames(ptax, old = c("ptax_avg_brl_per_usd"), new = c("ptax_brl_per_usd"))

brasil <- brasil %>%
  left_join(ptax, by = "year_month")

# Monetary columns (miles BRL -> BRL -> USD)
monetary_cols <- c(
  "a_vencer_ate_90_dias",
  "a_vencer_de_91_ate_360_dias",
  "a_vencer_de_361_ate_1080_dias",
  "a_vencer_de_1081_ate_1800_dias",
  "a_vencer_de_1801_ate_5400_dias",
  "a_vencer_acima_de_5400_dias",
  "vencido_acima_de_15_dias",
  "carteira_ativa",
  "carteira_inadimplida_arrastada",
  "ativo_problematico"
)

for (col in monetary_cols) {
  if (!col %in% names(brasil)) next
  brl_col <- paste0(col, "_brl")
  usd_col <- paste0(col, "_usd")
  brasil[[brl_col]] <- as.numeric(brasil[[col]]) * 1000
  brasil[[usd_col]] <- ifelse(
    !is.na(brasil$ptax_brl_per_usd) & brasil$ptax_brl_per_usd > 0,
    brasil[[brl_col]] / brasil$ptax_brl_per_usd,
    NA_real_
  )
}

# Trade enrichment via BACI ---------------------------------------------------
brasil <- brasil %>% mutate(X_exports = NA_real_, M_imports = NA_real_, trade = NA_real_)

trade_candidates <- c(
  file.path(data_dir, "BACI_HS92_V202501", "baci_trade_cty.csv"),
  file.path(pre_root, "BACI_HS92_V202501", "baci_trade_cty.csv"),
  file.path(pre_root, "baci_trade_cty.csv")
)
trade_file <- trade_candidates[file.exists(trade_candidates)][1]

country_candidates <- c(
  file.path(data_dir, "BACI_HS92_V202501", "country_codes_V202501.csv"),
  file.path(pre_root, "BACI_HS92_V202501", "country_codes_V202501.csv"),
  file.path(pre_root, "country_codes_V202501.csv")
)
country_file <- country_candidates[file.exists(country_candidates)][1]

if (!is.na(trade_file)) {
  message("   - Enriqueciendo con comercio BACI: ", trade_file)
  bra_code <- 76
  if (!is.na(country_file)) {
    codes <- fread(country_file)
    if ("country_iso3" %in% names(codes)) {
      code_row <- codes[toupper(country_iso3) %in% c("BRA", "BRASIL") |
                          country_name %like% "Brazil"]
      if (nrow(code_row) > 0 && "country_code" %in% names(code_row)) {
        bra_code <- code_row$country_code[1]
      }
    }
  }

  baci_dt <- fread(
    trade_file,
    select = c("exporter", "importer", "year", "trade_value_usd")
  )
  bra_exp <- baci_dt[exporter == bra_code, .(X_exports = sum(trade_value_usd, na.rm = TRUE)), by = year]
  bra_imp <- baci_dt[importer == bra_code, .(M_imports = sum(trade_value_usd, na.rm = TRUE)), by = year]
  bra_trade <- merge(bra_exp, bra_imp, by = "year", all = TRUE)
  bra_trade[, trade := X_exports + M_imports]

  brasil <- brasil %>%
    left_join(bra_trade, by = "year", suffix = c("", ".agg")) %>%
    mutate(
      X_exports = coalesce(X_exports.agg, X_exports),
      M_imports = coalesce(M_imports.agg, M_imports),
      trade = coalesce(trade.agg, trade)
    ) %>%
    select(-ends_with(".agg"))
} else {
  message("   - Archivo BACI no encontrado, columnas X/M/trade quedan en NA")
}

# Output ----------------------------------------------------------------------
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
setorder(brasil, data_base, uf, modalidade, ocupacao)
fwrite(brasil, out_file)

message(">> ETL finalizado: ", nrow(brasil), " filas -> ", out_file)
message("   Cobertura: ", as.character(min(brasil$data_base)), " a ", as.character(max(brasil$data_base)))
