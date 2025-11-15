#!/usr/bin/env Rscript
# Mexico letters of credit ETL
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
})

message(">> Iniciando ETL de México (cartas de crédito)")

# Resolve paths ---------------------------------------------------------------
args <- commandArgs(trailingOnly = FALSE)
file_flag <- "--file="
script_path <- sub(file_flag, "", args[grep(file_flag, args)])
if (length(script_path) == 0) {
  script_path <- "Scripts/mexico_lc_etl.R"
}
script_dir <- dirname(normalizePath(script_path, winslash = "/", mustWork = FALSE))
repo_root <- normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = TRUE)

pre_root <- file.path(repo_root, "pre-data")
pre_dir  <- file.path(pre_root, "Mexico")
data_dir <- file.path(repo_root, "data")

raw_file <- file.path(pre_dir, "040_R12A_1219_133.csv")
tc_file <- file.path(pre_dir, "mxnusd.csv")
out_file <- file.path(data_dir, "mexico_full.csv")

stopifnot(file.exists(raw_file), file.exists(tc_file))

# Helper: last non-NA
last_non_na <- function(x) {
  vals <- x[!is.na(x)]
  if (length(vals) == 0) NA_real_ else tail(vals, 1)
}

# Institution dictionary ------------------------------------------------------
inst_map <- c(
  "40133" = "ACTINVER",
  "40062" = "AFIRME",
  "90721" = "ALBO",
  "90706" = "ARCUS FI",
  "90659" = "ASP INTEGRA OPC",
  "40127" = "AZTECA",
  "37166" = "BABIEN",
  "40030" = "BAJIO",
  "40002" = "BANAMEX",
  "40154" = "BANCO COVALTO",
  "37006" = "BANCOMEXT",
  "40137" = "BANCOPPEL",
  "40160" = "BANCO S3",
  "40152" = "BANCREA",
  "37019" = "BANJERCITO",
  "40147" = "BANKAOOL",
  "40106" = "BANK OF AMERICA",
  "40159" = "BANK OF CHINA",
  "37009" = "BANOBRAS",
  "40072" = "BANORTE",
  "40058" = "BANREGIO",
  "40060" = "BANSI",
  "2001"  = "BANXICO",
  "40129" = "BARCLAYS",
  "40145" = "BBASE",
  "40012" = "BBVA MEXICO",
  "40112" = "BMONEX",
  "90677" = "CAJA POP MEXICA",
  "90683" = "CAJA TELEFONIST",
  "90715" = "CASHI CUENTA",
  "90630" = "CB INTERCAM",
  "90631" = "CI BOLSA",
  "40124" = "CITI MEXICO",
  "90901" = "CLS",
  "90903" = "CODI VALIDA",
  "40130" = "COMPARTAMOS",
  "40140" = "CONSUBANCO",
  "90725" = "COOPDESARROLLO",
  "90652" = "CREDICAPITAL",
  "90688" = "CREDICLUB",
  "90680" = "CRISTOBAL COLON",
  "90723" = "CUENCA",
  "90729" = "DEP Y PAG DIG",
  "40151" = "DONDE",
  "90616" = "FINAMEX",
  "90634" = "FINCOMUN",
  "90734" = "FINCO PAY",
  "90699" = "FONDEADORA",
  "90685" = "FONDO (FIRA)",
  "90601" = "GBM",
  "40167" = "HEY BANCO",
  "37168" = "HIPOTECARIA FED",
  "40021" = "HSBC",
  "40155" = "ICBC",
  "40036" = "INBURSA",
  "90902" = "INDEVAL",
  "40150" = "INMOBILIARIO",
  "40136" = "INTERCAM BANCO",
  "40059" = "INVEX",
  "40110" = "JP MORGAN",
  "40128" = "KAPITAL",
  "90661" = "KLAR",
  "90653" = "KUSPIT",
  "90670" = "LIBERTAD",
  "90602" = "MASARI",
  "90722" = "MERCADO PAGO W",
  "90720" = "MEXPAGO",
  "40042" = "MIFEL",
  "40158" = "MIZUHO BANK",
  "90600" = "MONEXCB",
  "40108" = "MUFG",
  "40132" = "MULTIVA BANCO",
  "37135" = "NAFIN",
  "90638" = "NU MEXICO",
  "90710" = "NVIO",
  "40148" = "PAGATODO",
  "90732" = "PEIBO",
  "90620" = "PROFUTURO",
  "40156" = "SABADELL",
  "40014" = "SANTANDER",
  "40044" = "SCOTIABANK",
  "40157" = "SHINHAN",
  "90728" = "SPIN BY OXXO",
  "90646" = "STP",
  "90703" = "TESORED",
  "90684" = "TRANSFER",
  "40138" = "UALA",
  "90656" = "UNAGRA",
  "90617" = "VALMEX",
  "90605" = "VALUE",
  "90608" = "VECTOR",
  "40113" = "VE POR MAS",
  "40141" = "VOLKSWAGEN"
)

# Load CNBV data --------------------------------------------------------------
message("   - Leyendo archivo CNBV: ", raw_file)
cnbv_raw <- fread(
  raw_file,
  colClasses = list(
    character = c("sector", "periodo", "institucion", "concepto"),
    numeric   = "importe_pesos"
  )
)

tf_code <- "202401504003"
message("   - Filtrando concepto TF ", tf_code)
cnbv_tf <- cnbv_raw[concepto == tf_code]
if (nrow(cnbv_tf) == 0) {
  stop("No se encontraron registros para el concepto ", tf_code)
}

cnbv_tf[, year := as.integer(substr(periodo, 1, 4))]
cnbv_tf[, month := as.integer(substr(periodo, 5, 6))]
cnbv_tf[, year_month := sprintf("%04d-%02d", year, month)]
cnbv_tf[, cod_inst_raw := as.character(institucion)]
cnbv_tf[, cod_inst := gsub("^0+", "", cod_inst_raw)]
cnbv_tf[cod_inst == "", cod_inst := cod_inst_raw]
cnbv_tf <- cnbv_tf[cod_inst != "5"]
cnbv_tf[, amount_mxn := as.numeric(importe_pesos)]

agg_tf <- cnbv_tf[, .(
  amount_mxn = sum(amount_mxn, na.rm = TRUE)
), by = .(year, month, year_month, cod_inst)]

setorder(agg_tf, year, month, cod_inst)
agg_tf[, cod_inst := as.character(cod_inst)]

# Tipo de cambio --------------------------------------------------------------
message("   - Procesando tipo de cambio diario")
tc_daily <- fread(
  tc_file,
  sep = ";",
  dec = ",",
  na.strings = c("N/E", "", "NA")
)
setnames(tc_daily, make.names(names(tc_daily)))
tc_daily <- tc_daily %>%
  mutate(
    fecha = as.Date(fecha, format = "%d/%m/%Y"),
    tc = as.numeric(para.solventar.obligaciones),
    year = as.integer(format(fecha, "%Y")),
    month = as.integer(format(fecha, "%m"))
  ) %>%
  filter(!is.na(year), !is.na(month))

tc_monthly <- tc_daily %>%
  group_by(year, month) %>%
  summarise(tipo_cambio = last_non_na(tc), .groups = "drop")

# Merge -----------------------------------------------------------------------
message("   - Integrando tipo de cambio y diccionario de bancos")
mexico_full <- agg_tf %>%
  left_join(tc_monthly, by = c("year", "month")) %>%
  mutate(
    tipo_cambio = as.numeric(tipo_cambio),
    amount_usd = if_else(!is.na(tipo_cambio) & tipo_cambio > 0,
                         amount_mxn / tipo_cambio, NA_real_),
    amount_usd_thousands = amount_usd / 1e3
  ) %>%
  mutate(
    institucion = inst_map[cod_inst],
    institucion = if_else(is.na(institucion), cod_inst, institucion)
  )

# Trade enrichment (optional) -------------------------------------------------
mexico_full <- mexico_full %>%
  mutate(X_exports = NA_real_, M_imports = NA_real_, trade = NA_real_)

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
  mex_code <- 484
  if (!is.na(country_file)) {
    codes <- fread(country_file)
    if ("country_iso3" %in% names(codes)) {
      code_row <- codes[toupper(country_iso3) %in% c("MEX", "MEXICO") |
                          country_name %like% "Mexico"]
      if (nrow(code_row) > 0 && "country_code" %in% names(code_row)) {
        mex_code <- code_row$country_code[1]
      }
    }
  }

  baci_dt <- fread(
    trade_file,
    select = c("exporter", "importer", "year", "trade_value_usd")
  )
  mex_exp <- baci_dt[exporter == mex_code, .(X_exports = sum(trade_value_usd, na.rm = TRUE)), by = year]
  mex_imp <- baci_dt[importer == mex_code, .(M_imports = sum(trade_value_usd, na.rm = TRUE)), by = year]
  mex_trade <- merge(mex_exp, mex_imp, by = "year", all = TRUE)
  mex_trade[, trade := X_exports + M_imports]
  mexico_full <- mexico_full %>%
    left_join(mex_trade, by = "year", suffix = c("", ".agg")) %>%
    mutate(
      X_exports = coalesce(X_exports.agg, X_exports),
      M_imports = coalesce(M_imports.agg, M_imports),
      trade = coalesce(trade.agg, trade)
    ) %>%
    select(-ends_with(".agg"))
} else {
  message("   - Archivo BACI no encontrado, se omite trade (columnas quedan en NA)")
}

# Output ----------------------------------------------------------------------
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
mexico_full <- mexico_full %>%
  arrange(year, month, cod_inst)

fwrite(mexico_full, out_file)

message(">> ETL finalizado: ", nrow(mexico_full), " filas -> ", out_file)
message("   Cobertura: ", min(mexico_full$year_month), " a ", max(mexico_full$year_month))
