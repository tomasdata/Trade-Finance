# CMF Chile Data - Improved Script for Trade Finance Analysis
# ==============================================================================
# Este script extrae datos específicos de trade finance de la API CMF Chile
# Incluye conversión a USD y manejo mejorado de errores
# ==============================================================================

# Cargar librerías
library(httr2)
library(jsonlite)
library(dplyr)
library(stringi)
library(stringr)
library(purrr)
library(tidyr)
library(data.table)
library(lubridate)

# Configuración de rutas
folder <- ".."
data <- paste0(folder,"/data/")
tables <- paste0(folder,"/tables/")
plots <- paste0(folder,"/plots/")
models <- paste0(folder,"/models/")

# Configuración API
BASE <- "https://api.cmfchile.cl/api-sbifv3/recursos_api"
KEY   <- "ec66dcd075d873e1134d1febc068847cce99d327"

# ==============================================================================
# FUNCIONES MEJORADAS
# ==============================================================================

# Función robusta para obtener datos de API
get_txt <- function(url, query = list(apikey = KEY, formato = "json"),
                    tries = 5, base_wait = 0.25) {
  last <- NULL
  for (i in seq_len(tries)) {
    tryCatch({
      resp <- request(url) |>
        req_url_query(!!!query) |>
        req_error(is_error = function(r) FALSE) |>
        req_perform()
      
      sc <- resp_status(resp)
      if (sc == 200) return(resp_body_string(resp))
      last <- sprintf("HTTP %s en %s", sc, url)
    }, error = function(e) {
      last <- sprintf("Error: %s", e$message)
    })
    
    # Backoff exponencial con jitter
    wait <- base_wait * (2^(i - 1)) + runif(1, 0, 0.2)
    Sys.sleep(wait)
  }
  message("Falló después de ", tries, " intentos: ", last)
  return(NULL)
}

# Obtener tipo de cambio CLP/USD
get_exchange_rate <- function(year, month) {
  url <- sprintf("%s/dolar/%d/%02d?apikey=%s&formato=json", BASE, year, month, KEY)
  txt <- get_txt(url)
  if (!is.null(txt)) {
    data <- fromJSON(txt, simplifyDataFrame = TRUE)
    if (!is.null(data$Dolares) && nrow(data$Dolares) > 0) {
      # Usar el último valor del mes
      rate <- as.numeric(gsub("[$,]", "", data$Dolares$Valor[nrow(data$Dolares)]))
      return(rate)
    }
  }
  return(NA)
}

# Obtener instituciones de un año/mes específico
get_instituciones <- function(year, month = 12) {
  # Intentar ruta por año/mes
  u1 <- sprintf("%s/balances/%d/%02d/instituciones", BASE, year, month)
  txt <- tryCatch(get_txt(u1), error = function(e) NULL)
  
  # Fallback por periodo para años antiguos
  if (is.null(txt)) {
    per <- if (year <= 2007) "periodo1" else if (year == 2008) "periodo2" else NA
    if (!is.na(per)) {
      u2 <- sprintf("%s/balances/%s/%02d/instituciones", BASE, per, month)
      txt <- get_txt(u2)
    }
  }
  
  if (!is.null(txt)) {
    js <- jsonlite::fromJSON(txt, simplifyDataFrame = TRUE, flatten = TRUE)
    inst <- tibble::as_tibble(js$DescripcionesCodigosDeInstituciones)
    
    # Detectar columnas robustamente
    nm <- names(inst)
    code_idx <- which(grepl("(cod(igo)?)(.*institucion|.*ifi)?$", nm, ignore.case = TRUE))
    if (length(code_idx) > 0) {
      cod_col <- nm[code_idx[1]]
      name_idx <- which(grepl("^(nombre|descri).*", nm, ignore.case = TRUE))
      nom_col <- if (length(name_idx) > 0) nm[name_idx[1]] else NA_character_
      
      return(inst %>% 
        transmute(
          CodigoInstitucion = .data[[cod_col]] |> as.character(),
          NombreInstitucion = if (!is.na(nom_col)) .data[[nom_col]] |> as.character() else NA_character_
        ) %>% 
        distinct())
    }
  }
  return(tibble(CodigoInstitucion = character(), NombreInstitucion = character()))
}

# Obtener balances específicos de trade finance
get_tf_balances <- function(year, cod, tf_codes) {
  # Intentar ruta por año
  u1 <- sprintf("%s/balances/%d/instituciones/%s", BASE, year, cod)
  txt <- tryCatch(get_txt(u1), error = function(e) NULL)
  
  # Fallback por periodo
  if (is.null(txt)) {
    per <- if (year <= 2007) "periodo1" else if (year == 2008) "periodo2" else NA
    if (!is.na(per)) {
      u2 <- sprintf("%s/balances/%s/instituciones/%s", BASE, per, cod)
      txt <- get_txt(u2)
    }
  }
  
  if (!is.null(txt)) {
    js <- jsonlite::fromJSON(txt, simplifyDataFrame = TRUE)
    df <- tibble::as_tibble(js$CodigosBalances)
    
    if (!"CodigoInstitucion" %in% names(df)) df$CodigoInstitucion <- cod
    
    # Filtrar solo cuentas de trade finance
    df_tf <- df %>% filter(CodigoCuenta %in% tf_codes)
    
    return(df_tf)
  }
  return(NULL)
}

# ==============================================================================
# CUENTAS DE TRADE FINANCE IDENTIFICADAS
# ==============================================================================

# Cuentas principales de trade finance encontradas en la API
tf_codes <- c(
  # Financiamientos de comercio exterior
  "244250100", "244250101", "244250102",  # Financiamientos con bancos del país
  "244500100", "244500101", "244500102",  # Financiamientos con bancos del exterior
  
  # Créditos interbancarios de comercio exterior
  "143100104", "143100105", "143100106",  # Con bancos del país
  "143200104", "143200105", "143200106",  # Con bancos del exterior
  
  # Créditos de comercio exterior (cartera comercial)
  "145400200",                           # Créditos de comercio exterior
  "145400201", "145400202",              # Exportaciones chilenas
  "145400203", "145400204",              # Importaciones chilenas  
  "145400205", "145400290",              # Terceros países y otros
  
  # Variantes de presentación
  "813200600", "814200600", "821200600", # Cartera comercial - diferentes formatos
  
  # Créditos contingentes
  "831200000"                            # Créditos contingentes
)

# ==============================================================================
# EXTRACCIÓN DE DATOS
# ==============================================================================

# Años a procesar (rango más manejable para prueba)
YEARS <- 2020:2024
MONTH_FOR_INDEX <- 12
PAUSE_BETWEEN <- 0.15

message("Iniciando extracción de datos CMF Trade Finance para años ", min(YEARS), "-", max(YEARS))

# Obtener instituciones recientes como referencia
ref_year <- 2024
ref_names <- get_instituciones(ref_year, MONTH_FOR_INDEX) %>% 
  select(CodigoInstitucion, NombreInstitucion) %>% 
  distinct()

# Encontrar códigos comunes (instituciones presentes en todos los años)
message("Identificando instituciones comunes...")
codes_by_year <- map_dfr(YEARS, function(y) {
  inst <- get_instituciones(y, MONTH_FOR_INDEX)
  tibble(Anho = y, CodigoInstitucion = inst$CodigoInstitucion)
})

codes_intersection <- codes_by_year %>% 
  count(CodigoInstitucion, name = "n_years") %>% 
  filter(n_years == length(YEARS)) %>% 
  pull(CodigoInstitucion)

message("Instituciones presentes en todos los años: ", length(codes_intersection))

# Extraer datos de trade finance
all_data <- list()

for (y in YEARS) {
  message("Procesando año ", y, " (", length(codes_intersection), " instituciones)")
  
  year_data <- list()
  
  for (i in seq_along(codes_intersection)) {
    cod <- codes_intersection[i]
    
    # Obtener balances de trade finance
    balances <- get_tf_balances(y, cod, tf_codes)
    
    if (!is.null(balances) && nrow(balances) > 0) {
      # Agregar información de institución
      balances <- balances %>% 
        left_join(ref_names, by = "CodigoInstitucion") %>% 
        mutate(Anho = y, Mes = MONTH_FOR_INDEX)
      
      year_data[[i]] <- balances
    }
    
    Sys.sleep(PAUSE_BETWEEN)
  }
  
  if (length(year_data) > 0) {
    all_data[[as.character(y)]] <- bind_rows(year_data)
    message("  -> ", nrow(all_data[[as.character(y)]]), " registros obtenidos")
  }
}

# ==============================================================================
# PROCESAMIENTO Y CONVERSIÓN A USD
# ==============================================================================

if (length(all_data) > 0) {
  # Combinar todos los años
  tf_panel <- bind_rows(all_data)
  
  message("Total de registros obtenidos: ", nrow(tf_panel))
  
  # Obtener tipos de cambio
  message("Obteniendo tipos de cambio CLP/USD...")
  
  exchange_rates <- tf_panel %>% 
    distinct(Anho, Mes) %>% 
    mutate(rate = map2_dbl(Anho, Mes, get_exchange_rate)) %>% 
    filter(!is.na(rate))
  
  # Unir con tipos de cambio
  tf_panel_usd <- tf_panel %>% 
    left_join(exchange_rates, by = c("Anho", "Mes")) %>% 
    mutate(
      # Convertir montos a USD
      MonedaChilenaNoReajustable_USD = as.numeric(MonedaChilenaNoReajustable) / rate,
      MonedaReajustablePorIPC_USD = as.numeric(MonedaReajustablePorIPC) / rate,
      MonedaReajustablePorTipoDeCambio_USD = as.numeric(MonedaReajustablePorTipoDeCambio) / rate,
      MonedaTotal_USD = as.numeric(MonedaTotal) / rate,
      
      # Mantener montos originales en USD
      MonedaExtranjera_USD = as.numeric(MonedaExtranjera)
    ) %>% 
    select(
      CodigoInstitucion, NombreInstitucion, Anho, Mes, CodigoCuenta, DescripcionCuenta,
      MonedaChilenaNoReajustable, MonedaChilenaNoReajustable_USD,
      MonedaReajustablePorIPC, MonedaReajustablePorIPC_USD,
      MonedaReajustablePorTipoDeCambio, MonedaReajustablePorTipoDeCambio_USD,
      MonedaExtranjera, MonedaExtranjera_USD,
      MonedaTotal, MonedaTotal_USD,
      rate
    )
  
  # Guardar datos
  fwrite(tf_panel_usd, paste0(data, "cmf_tradefinance_enhanced.csv"))
  
  # Resumen por tipo de cuenta
  resumen_cuentas <- tf_panel_usd %>% 
    group_by(CodigoCuenta, DescripcionCuenta) %>% 
    summarise(
      total_usd = sum(MonedaTotal_USD, na.rm = TRUE),
      total_clp = sum(MonedaChilenaNoReajustable, na.rm = TRUE),
      n_obs = n(),
      .groups = "drop"
    ) %>% 
    arrange(desc(total_usd))
  
  fwrite(resumen_cuentas, paste0(data, "cmf_resumen_cuentas.csv"))
  
  # Resumen por institución
  resumen_bancos <- tf_panel_usd %>% 
    group_by(CodigoInstitucion, NombreInstitucion) %>% 
    summarise(
      total_usd = sum(MonedaTotal_USD, na.rm = TRUE),
      total_clp = sum(MonedaChilenaNoReajustable, na.rm = TRUE),
      n_cuentas = n_distinct(CodigoCuenta),
      .groups = "drop"
    ) %>% 
    arrange(desc(total_usd))
  
  fwrite(resumen_bancos, paste0(data, "cmf_resumen_bancos.csv"))
  
  message("Proceso completado exitosamente!")
  message("Archivos guardados:")
  message("  - cmf_tradefinance_enhanced.csv")
  message("  - cmf_resumen_cuentas.csv") 
  message("  - cmf_resumen_bancos.csv")
  
  # Mostrar resumen
  cat("\n=== RESUMEN DE DATOS EXTRAÍDOS ===\n")
  cat("Período:", min(YEARS), "-", max(YEARS), "\n")
  cat("Instituciones:", length(codes_intersection), "\n")
  cat("Cuentas TF:", length(tf_codes), "\n")
  cat("Registros totales:", nrow(tf_panel_usd), "\n")
  cat("Total Trade Finance (USD):", scales::comma(sum(tf_panel_usd$MonedaTotal_USD, na.rm = TRUE)), "\n")
  
} else {
  message("No se pudieron obtener datos. Verificar conexión API.")
}