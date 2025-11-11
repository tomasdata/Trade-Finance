#!/usr/bin/env Rscript
# Chile CMF ETL
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(stringr)
})

message(">> Iniciando ETL de Chile (CMF balances)")

# Resolve paths ---------------------------------------------------------------
args <- commandArgs(trailingOnly = FALSE)
file_flag <- "--file="
script_path <- sub(file_flag, "", args[grep(file_flag, args)])
if (length(script_path) == 0) {
  script_path <- "Scripts/chile_etl.R"
}
script_dir <- dirname(normalizePath(script_path, winslash = "/", mustWork = FALSE))
repo_root  <- normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = TRUE)

pre_root  <- file.path(repo_root, "pre-data")
chile_dir <- file.path(pre_root, "Chile")
data_dir  <- file.path(repo_root, "data")

raw_file  <- file.path(chile_dir, "chile_full.csv")
out_file  <- file.path(data_dir, "chile_full.csv")

stopifnot(file.exists(raw_file))

# Helper ----------------------------------------------------------------------
parse_monetary <- function(x) {
  as.numeric(str_replace_all(x, "\\.", "") %>% str_replace(",", "."))
}

# Load raw data ---------------------------------------------------------------
message("   - Leyendo base cruda CMF: ", raw_file)
chile_raw <- fread(raw_file, colClasses = "character")
numeric_cols <- c(
  "MonedaChilenaNoReajustable",
  "MonedaExtranjera",
  "MonedaReajustable",
  "MonedaTotal",
  "MonedaReajustablePorIPC",
  "MonedaReajustablePorTipoDeCambio"
)

for (col in numeric_cols) {
  new_col <- paste0(col, "_num")
  chile_raw[[new_col]] <- parse_monetary(chile_raw[[col]])
}

chile <- chile_raw %>%
  mutate(
    Anho = as.integer(Anho),
    Mes  = as.integer(Mes),
    year_month = as.Date(sprintf("%04d-%02d-01", Anho, Mes))
  ) %>%
  filter(Anho >= 2015)

# Account dictionary ----------------------------------------------------------
categorize_account <- function(code) {
  code <- as.integer(code)
  case_when(
    code %in% c(200000000, 510000000, 100000000, 140000000,
                500000000, 505000000, 145000000) ~ "control",
    code %in% c(145400200, 145400101, 145400102) ~ "comercio_exterior",
    code %in% c(145400201, 145400202, 145400105, 145400205) ~ "exportaciones",
    code %in% c(145400203, 145400204, 145400290) ~ "importaciones",
    code %in% c(143100104, 143100105, 143100106,
                143200104, 143200105, 143200106) ~ "interbancario_exterior",
    code %in% c(244250100, 244500100, 244500200, 244000000, 244500000) ~ "financiamiento_exterior",
    code %in% c(813200600, 814200600, 821200600, 831200000) ~ "contingentes",
    TRUE ~ "otros"
  )
}

chile <- chile %>%
  mutate(
    categoria_tf = categorize_account(CodigoCuenta),
    es_control = categoria_tf == "control"
  )

# Shares within category ------------------------------------------------------
chile <- chile %>%
  group_by(year_month, categoria_tf) %>%
  mutate(
    total_categoria_usd = sum(MonedaExtranjera_num, na.rm = TRUE),
    share_categoria = if_else(
      total_categoria_usd > 0,
      MonedaExtranjera_num / total_categoria_usd,
      NA_real_
    )
  ) %>%
  ungroup()

# Export ----------------------------------------------------------------------
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
setorder(chile, year_month, CodigoInstitucion, CodigoCuenta)
fwrite(chile, out_file)

message(">> ETL finalizado: ", nrow(chile), " filas -> ", out_file)
message("   Cobertura: ", min(chile$year_month), " a ", max(chile$year_month))
