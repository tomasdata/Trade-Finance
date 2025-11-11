# CMF Chile Data - Script Consistente con otros países LATAM
# ==============================================================================
# Genera datos de Chile con estructura consistente a Perú y Brasil
# Enfocado específicamente en Trade Finance
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

# Configuración API
BASE <- "https://api.cmfchile.cl/api-sbifv3/recursos_api"
KEY   <- "ec66dcd075d873e1134d1febc068847cce99d327"

# ==============================================================================
# FUNCIONES
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
    
    wait <- base_wait * (2^(i - 1)) + runif(1, 0, 0.2)
    Sys.sleep(wait)
  }
  return(NULL)
}

# Obtener tipo de cambio CLP/USD
get_exchange_rate <- function(year, month) {
  url <- sprintf("%s/dolar/%d/%02d?apikey=%s&formato=json", BASE, year, month, KEY)
  txt <- get_txt(url)
  if (!is.null(txt)) {
    data <- fromJSON(txt, simplifyDataFrame = TRUE)
    if (!is.null(data$Dolares) && nrow(data$Dolares) > 0) {
      rate <- as.numeric(gsub("[$,]", "", data$Dolares$Valor[nrow(data$Dolares)]))
      return(rate)
    }
  }
  return(700)  # Default aproximado si falla
}

# Obtener instituciones de un año/mes específico
get_instituciones <- function(year, month = 12) {
  u1 <- sprintf("%s/balances/%d/%02d/instituciones", BASE, year, month)
  txt <- tryCatch(get_txt(u1), error = function(e) NULL)
  
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
  u1 <- sprintf("%s/balances/%d/instituciones/%s", BASE, year, cod)
  txt <- tryCatch(get_txt(u1), error = function(e) NULL)
  
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
    df_tf <- df %>% filter(CodigoCuenta %in% tf_codes)
    return(df_tf)
  }
  return(NULL)
}

# ==============================================================================
# MAPEO DE CUENTAS TF A CATEGORÍAS CONSISTENTES
# ==============================================================================

# Cuentas principales de trade finance con mapeo a categorías consistentes
tf_categories <- list(
  "comercio_exterior" = c(
    "145400200",  # Créditos de comercio exterior
    "813200600",  # Créditos de comercio exterior (cartera comercial)
    "814200600",  # Créditos de comercio exterior (cartera comercial)
    "821200600"   # Créditos de comercio exterior (cartera comercial)
  ),
  "exportaciones" = c(
    "145400201",  # Acreditivos negociados a plazo de exportaciones chilenas
    "145400202",  # Otros créditos para exportaciones chilenas
    "143100104",  # Créditos comercio exterior exportaciones chilenas (bancos país)
    "143200104",  # Créditos comercio exterior exportaciones chilenas (bancos exterior)
    "244250101",  # Financiamientos para exportaciones chilenas (bancos país)
    "244500101"   # Financiamientos para exportaciones chilenas (bancos exterior)
  ),
  "importaciones" = c(
    "145400203",  # Acreditivos negociados a plazo de importaciones chilenas
    "145400204",  # Otros créditos para importaciones chilenas
    "143100105",  # Créditos comercio exterior importaciones chilenas (bancos país)
    "143200105",  # Créditos comercio exterior importaciones chilenas (bancos exterior)
    "244250102",  # Financiamientos para importaciones chilenas (bancos país)
    "244500102"   # Financiamientos para importaciones chilenas (bancos exterior)
  ),
  "financiamiento_exterior" = c(
    "244250100",  # Financiamientos de comercio exterior (bancos país)
    "244500100",  # Financiamientos de comercio exterior (bancos exterior)
    "244500000"   # Financiamientos de comercio exterior (bancos exterior)
  ),
  "contingentes" = c(
    "831200000"   # Créditos contingentes
  )
)

# Función para categorizar cuenta
categorizar_cuenta <- function(codigo) {
  for (categoria in names(tf_categories)) {
    if (codigo %in% tf_categories[[categoria]]) {
      return(categoria)
    }
  }
  return("otros_tf")
}

# ==============================================================================
# EXTRACCIÓN Y PROCESAMIENTO
# ==============================================================================

# Parámetros
YEARS <- 2015:2024  # Rango más manejable y reciente
MONTH_FOR_INDEX <- 12
PAUSE_BETWEEN <- 0.1

message("Generando datos consistentes de Chile Trade Finance (", min(YEARS), "-", max(YEARS), ")")

# Obtener instituciones recientes
ref_names <- get_instituciones(2024, MONTH_FOR_INDEX) %>% 
  select(CodigoInstitucion, NombreInstitucion) %>% 
  distinct()

# Encontrar instituciones comunes
message("Identificando instituciones comunes...")
codes_by_year <- map_dfr(YEARS, function(y) {
  inst <- get_instituciones(y, MONTH_FOR_INDEX)
  tibble(Anho = y, CodigoInstitucion = inst$CodigoInstitucion)
})

codes_intersection <- codes_by_year %>% 
  count(CodigoInstitucion, name = "n_years") %>% 
  filter(n_years >= 3) %>%  # Al menos 3 años para ser consistente
  pull(CodigoInstitucion)

message("Instituciones con datos consistentes: ", length(codes_intersection))

# Extraer datos
all_data <- list()

for (y in YEARS) {
  message("Procesando año ", y)
  
  year_data <- list()
  
  for (i in seq_along(codes_intersection)) {
    cod <- codes_intersection[i]
    
    # Obtener todos los códigos TF
    all_tf_codes <- unlist(tf_categories)
    balances <- get_tf_balances(y, cod, all_tf_codes)
    
    if (!is.null(balances) && nrow(balances) > 0) {
      # Agregar información y procesar
      balances <- balances %>% 
        left_join(ref_names, by = "CodigoInstitucion") %>% 
        mutate(
          Anho = y, 
          Mes = MONTH_FOR_INDEX,
          # Convertir montos a números (limpiar formato chileno)
          MonedaChilenaNoReajustable = as.numeric(gsub("[,$]", "", MonedaChilenaNoReajustable)),
          MonedaExtranjera = as.numeric(gsub("[,$]", "", MonedaExtranjera)),
          MonedaTotal = as.numeric(gsub("[,$]", "", MonedaTotal))
        ) %>% 
        filter(!is.na(MonedaTotal) & MonedaTotal > 0)  # Solo valores positivos
      
      year_data[[i]] <- balances
    }
    
    Sys.sleep(PAUSE_BETWEEN)
  }
  
  if (length(year_data) > 0) {
    all_data[[as.character(y)]] <- bind_rows(year_data)
  }
}

# Procesamiento final a formato consistente
if (length(all_data) > 0) {
  tf_panel <- bind_rows(all_data)
  
  message("Total registros crudos: ", nrow(tf_panel))
  
  # Obtener tipos de cambio
  message("Obteniendo tipos de cambio...")
  exchange_rates <- tf_panel %>% 
    distinct(Anho, Mes) %>% 
    mutate(rate = map2_dbl(Anho, Mes, get_exchange_rate))
  
  # Transformar a formato consistente con otros países
  chile_consistent <- tf_panel %>% 
    left_join(exchange_rates, by = c("Anho", "Mes")) %>% 
    mutate(
      # Categorizar cuentas
      Concepto = categorizar_cuenta(CodigoCuenta),
      
      # Nombre de institución estandarizado
      institucion = NombreInstitucion,
      
      # Período mensual
      my = paste0(Anho, "-", Mes),
      
      # Montos en CLP y USD
      amount_clp = MonedaTotal,
      amount_usd = MonedaTotal / rate,
      
      # Total del banco (para calcular share)
      total_banco_tf = MonedaTotal,
      
      # Share (será calculado por período)
      share = 0
    ) %>% 
    select(
      Concepto, institucion, share, Anho = year, Mes = month, my, 
      total = total_banco_tf, amount = amount_usd, 
      # Campos adicionales para Chile
      CodigoInstitucion, CodigoCuenta, DescripcionCuenta, 
      amount_clp, rate
    )
  
  # Calcular shares por período y concepto
  chile_consistent <- chile_consistent %>% 
    group_by(Anho, Mes, Concepto) %>% 
    mutate(
      total_periodo = sum(amount, na.rm = TRUE),
      share = amount / total_periodo
    ) %>% 
    ungroup() %>% 
    filter(!is.na(share) & share > 0)
  
  # Agregar campos de consistencia
  chile_consistent <- chile_consistent %>% 
    mutate(
      size = case_when(
        Concepto == "comercio_exterior" ~ "Corporate",
        Concepto == "exportaciones" ~ "Large", 
        Concepto == "importaciones" ~ "Medium",
        Concepto == "financiamiento_exterior" ~ "Small",
        TRUE ~ "Micro"
      ),
      inst_clean = tolower(gsub("[^a-zA-Z0-9\\s]", "", institucion)),
      institucion_std = institucion  # Mantener nombre original
    ) %>% 
    select(
      Concepto, institucion, share, year = Anho, month = Mes, my,
      total, amount, size, inst_clean, institucion_std
    )
  
  # Guardar datos consistentes
  fwrite(chile_consistent, paste0(data, "chile_full.csv"))
  
  # Generar resumen
  resumen <- chile_consistent %>% 
    group_by(Concepto, year) %>% 
    summarise(
      total_amount = sum(amount, na.rm = TRUE),
      n_instituciones = n_distinct(institucion),
      .groups = "drop"
    ) %>% 
    arrange(Concepto, year)
  
  fwrite(resumen, paste0(data, "chile_resumen.csv"))
  
  message("Proceso completado!")
  message("Registros generados: ", nrow(chile_consistent))
  message("Período: ", min(chile_consistent$year), "-", max(chile_consistent$year))
  message("Conceptos: ", paste(unique(chile_consistent$Concepto), collapse = ", "))
  message("Instituciones: ", n_distinct(chile_consistent$institucion))
  
  # Mostrar ejemplo de datos generados
  cat("\n=== EJEMPLO DE DATOS GENERADOS ===\n")
  print(head(chile_consistent, 3))
  
} else {
  message("No se pudieron obtener datos. Verificar conexión API.")
}