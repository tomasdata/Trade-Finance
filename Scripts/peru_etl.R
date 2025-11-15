#!/usr/bin/env Rscript
# Peru trade finance ETL
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
})

message(">> Iniciando ETL de Perú (SBS comercio exterior)")

# Paths -----------------------------------------------------------------------
args <- commandArgs(trailingOnly = FALSE)
file_flag <- "--file="
script_path <- sub(file_flag, "", args[grep(file_flag, args)])
if (length(script_path) == 0) {
  script_path <- "Scripts/peru_etl.R"
}
script_dir <- dirname(normalizePath(script_path, winslash = "/", mustWork = FALSE))
repo_root  <- normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = TRUE)

pre_root  <- file.path(repo_root, "pre-data")
peru_dir  <- file.path(pre_root, "Peru")
data_dir  <- file.path(repo_root, "data")

raw_file   <- file.path(peru_dir, "peru_full.csv")
fx_files   <- list.files(peru_dir, pattern = "Mensuales.*\\.csv$", full.names = TRUE)
fx_file    <- if (length(fx_files) > 0) fx_files[1] else NA_character_
out_file   <- file.path(data_dir, "peru_full.csv")

stopifnot(file.exists(raw_file))
if (is.na(fx_file) || !file.exists(fx_file)) {
  stop("No se encontró el archivo de tipo de cambio mensual en pre-data/Peru/")
}

# Leer SBS raw ----------------------------------------------------------------
message("   - Leyendo base cruda SBS: ", raw_file)
peru_raw <- fread(raw_file)
setnames(peru_raw, old = "año", new = "anio")

peru_raw[, anio := as.integer(anio)]
peru_raw[, mes := as.integer(mes)]
peru_raw[, year_month := as.Date(sprintf("%04d-%02d-01", anio, mes))]

# Tipo de cambio (BCRP PN01215PM) ---------------------------------------------
message("   - Procesando tipo de cambio mensual (BCRP PN01215PM)")
fx <- fread(
  fx_file,
  skip = 2,
  col.names = c("periodo", "tc_compra", "tc_venta")
)

month_map <- c(
  "Ene" = 1, "Feb" = 2, "Mar" = 3, "Abr" = 4,
  "May" = 5, "Jun" = 6, "Jul" = 7, "Ago" = 8,
  "Sep" = 9, "Oct" = 10, "Nov" = 11, "Dic" = 12
)

fx[, month := month_map[substr(periodo, 1, 3)]]
fx[, year_two := suppressWarnings(as.integer(substring(periodo, 4)))]
fx[, year := ifelse(year_two >= 90, 1900 + year_two, 2000 + year_two)]
fx[, year_month := as.Date(sprintf("%04d-%02d-01", year, month))]
fx <- fx[!is.na(year_month)]
fx <- fx[, .(year, month, tipo_cambio_venta = tc_venta, tipo_cambio_compra = tc_compra)]

# Merge tipo de cambio --------------------------------------------------------
peru <- peru_raw %>%
  left_join(fx, by = c("anio" = "year", "mes" = "month"))

# Conversión monetaria (miles de PEN -> PEN -> USD) ---------------------------
message("   - Calculando montos en PEN y USD usando TC venta")
peru <- peru %>%
  mutate(
    total_pen = total * 1000,
    amount_pen = amount * 1000,
    total_usd = if_else(!is.na(tipo_cambio_venta) & tipo_cambio_venta > 0,
                        total_pen / tipo_cambio_venta, NA_real_),
    amount_usd = if_else(!is.na(tipo_cambio_venta) & tipo_cambio_venta > 0,
                         amount_pen / tipo_cambio_venta, NA_real_)
  )

# Comercio exterior (BACI) ----------------------------------------------------
peru <- peru %>% mutate(X_exports = NA_real_, M_imports = NA_real_, trade = NA_real_)

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
  per_code <- 604
  if (!is.na(country_file)) {
    codes <- fread(country_file)
    if ("country_iso3" %in% names(codes)) {
      code_row <- codes[toupper(country_iso3) %in% c("PER", "PERU") |
                          country_name %like% "Peru"]
      if (nrow(code_row) > 0 && "country_code" %in% names(code_row)) {
        per_code <- code_row$country_code[1]
      }
    }
  }

  baci_dt <- fread(
    trade_file,
    select = c("exporter", "importer", "year", "trade_value_usd")
  )
  per_exp <- baci_dt[exporter == per_code,
                     .(X_exports = sum(trade_value_usd, na.rm = TRUE)), by = year]
  per_imp <- baci_dt[importer == per_code,
                     .(M_imports = sum(trade_value_usd, na.rm = TRUE)), by = year]
  per_trade <- merge(per_exp, per_imp, by = "year", all = TRUE)
  per_trade[, trade := X_exports + M_imports]

  peru <- peru %>%
    left_join(per_trade, by = c("anio" = "year"), suffix = c("", ".agg")) %>%
    mutate(
      X_exports = coalesce(X_exports.agg, X_exports),
      M_imports = coalesce(M_imports.agg, M_imports),
      trade = coalesce(trade.agg, trade)
    ) %>%
    select(-ends_with(".agg"))
} else {
  message("   - Archivo BACI no encontrado, columnas X/M/trade quedan en NA")
}

# Salida ----------------------------------------------------------------------
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
setorder(peru, anio, mes, institucion_std, Concepto)
fwrite(peru, out_file)

message(">> ETL finalizado: ", nrow(peru), " filas -> ", out_file)
message("   Cobertura: ", min(peru$year_month), " a ", max(peru$year_month))
