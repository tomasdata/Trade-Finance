library(httr2)
library(jsonlite)
library(dplyr)
library(stringi)
library(stringr)
library(purrr)
library(tidyr)

folder <- ".."
data <- paste0(folder,"/data/")
tables <- paste0(folder,"/tables/")
plots <- paste0(folder,"/plots/")
models <- paste0(folder,"/models/")
# TEST -------------------------------------------------------------------------
BASE <- "https://api.cmfchile.cl/api-sbifv3/recursos_api"
KEY   <- "ec66dcd075d873e1134d1febc068847cce99d327"  

req <- request(sprintf("%s/balances/%d/%02d/instituciones", BASE, 2009, 12)) |>
  req_url_query(apikey = KEY, formato = "json") |>
  req_error(is_error = function(r) FALSE) |>
  req_perform()

cat("HTTP:", resp_status(req), "\n")
txt <- resp_body_string(req)
cat(substr(txt, 1, 200), "...\n")

if (resp_status(req) == 200) {
  js <- fromJSON(txt, simplifyDataFrame = TRUE)
  str(js, 1)
}



cod <- "001"  # Banco de Chile
url_bch <- sprintf("%s/balances/%d/instituciones/%s", BASE, 2009, cod)
url_bch
# "https://api.cmfchile.cl/api-sbifv3/recursos_api/balances/2009/instituciones/001"

req_bch <- request(url_bch) |>
  req_url_query(apikey = KEY, formato = "json") |>
  req_perform()

cat("HTTP:", resp_status(req_bch), "\n")
txt_bch <- resp_body_string(req_bch)
js <- fromJSON(txt_bch, simplifyDataFrame = TRUE)
cat(substr(txt_bch, 1, 200), "...\n")


js  <- jsonlite::fromJSON(txt_bch, simplifyVector = TRUE)
df  <- tibble::as_tibble(js$CodigosBalances)
dplyr::glimpse(df)

# End testing
YEARS <- 1998:2024
MONTH_FOR_INDEX <- 12     # mes para listar instituciones
PAUSE_BETWEEN   <- 0.15   # pausa entre requests (seg)

# ==================== HELPERS HTTP ====================
get_txt <- function(url, query = list(apikey = KEY, formato = "json"),
                    tries = 5, base_wait = 0.25) {
  last <- NULL
  for (i in seq_len(tries)) {
    resp <- request(url) |>
      req_url_query(!!!query) |>
      req_error(is_error = function(r) FALSE) |>
      req_perform()
    sc <- resp_status(resp)
    if (sc == 200) return(resp_body_string(resp))
    last <- sprintf("HTTP %s en %s", sc, url)
    # backoff exponencial con jitter
    wait <- base_wait * (2^(i - 1)) + runif(1, 0, 0.2)
    Sys.sleep(wait)
  }
  stop(last)
}

periodo_for_year <- function(y) {
  if (y <= 2007) return("periodo1")
  if (y == 2008) return("periodo2")
  return(NA_character_)        # 2009+ sin periodo
}

get_codes <- function(years, mode = c("intersect","union","atleast"), k = NULL) {
  mode <- match.arg(mode)
  idx <- purrr::map(years, ~{
    get_instituciones(.x, MONTH_FOR_INDEX) %>%
      mutate(Anho = .x) %>%
      select(Anho, CodigoInstitucion)
  }) |> list_rbind()
  
  if (mode == "union") {
    return(sort(unique(idx$CodigoInstitucion)))
  }
  if (mode == "intersect") {
    keep <- idx |> count(CodigoInstitucion) |>
      filter(n == length(unique(years))) |> pull(CodigoInstitucion)
    return(sort(keep))
  }
  # al menos k años (por defecto 80% del rango)
  if (mode == "atleast") {
    if (is.null(k)) k <- ceiling(0.8 * length(unique(years)))
    keep <- idx |> count(CodigoInstitucion) |>
      filter(n >= k) |> pull(CodigoInstitucion)
    return(sort(keep))
  }
}


# ==================== INSTITUCIONES (ÍNDICE) ====================
# Devuelve SIEMPRE: CodigoInstitucion, NombreInstitucion (este último puede ser NA en años antiguos)
get_instituciones <- function(year, month = MONTH_FOR_INDEX) {
  # 1) intento ruta por año/mes
  u1 <- sprintf("%s/balances/%d/%02d/instituciones", BASE, year, month)
  txt <- tryCatch(get_txt(u1), error = function(e) NULL)
  # 2) fallback por periodo
  if (is.null(txt)) {
    per <- periodo_for_year(year); stopifnot(!is.na(per))
    u2 <- sprintf("%s/balances/%s/%02d/instituciones", BASE, per, month)
    txt <- get_txt(u2)
  }
  
  js  <- jsonlite::fromJSON(txt, simplifyDataFrame = TRUE, flatten = TRUE)
  inst <- tibble::as_tibble(js$DescripcionesCodigosDeInstituciones)
  
  nm <- names(inst)
  # detectar columna de código (robusto)
  code_idx <- which(grepl("(cod(igo)?)(.*institucion|.*ifi)?$", nm, ignore.case = TRUE))
  stopifnot(length(code_idx) > 0)
  cod_col <- nm[code_idx[1]]
  # detectar nombre si existe; si no, NA
  name_idx <- which(grepl("^(nombre|descri).*", nm, ignore.case = TRUE))
  nom_col  <- if (length(name_idx) > 0) nm[name_idx[1]] else NA_character_
  
  inst %>%
    transmute(
      CodigoInstitucion = .data[[cod_col]] |> as.character(),
      NombreInstitucion = if (!is.na(nom_col)) .data[[nom_col]] |> as.character() else NA_character_
    ) %>%
    distinct()
}

# ==================== BALANCES POR BANCO-AÑO ====================
# Devuelve tibble con el nodo CodigosBalances (+ CodigoInstitucion asegurada)
get_balances_inst_year <- function(year, cod) {
  # 1) ruta por año
  u1 <- sprintf("%s/balances/%d/instituciones/%s", BASE, year, cod)
  txt <- tryCatch(get_txt(u1), error = function(e) NULL)
  # 2) fallback por periodo
  if (is.null(txt)) {
    per <- periodo_for_year(year); stopifnot(!is.na(per))
    u2  <- sprintf("%s/balances/%s/instituciones/%s", BASE, per, cod)
    txt <- get_txt(u2)
  }
  js <- jsonlite::fromJSON(txt, simplifyDataFrame = TRUE)
  df <- tibble::as_tibble(js$CodigosBalances)
  
  # Asegura que no venga una columna espuria con el mismo nombre
  df <- df %>% select(-any_of("NombreInstitucion"))
  
  if (!"CodigoInstitucion" %in% names(df)) df$CodigoInstitucion <- cod
  df
}

# ==================== DICCIONARIO DE NOMBRES ====================
# Usamos un año reciente como “fuente de verdad” para nombres (ajústalo si prefieres).
ref_year   <- 2024
ref_names  <- get_instituciones(ref_year, MONTH_FOR_INDEX) %>%
  select(CodigoInstitucion, NombreInstitucion) %>%
  distinct()

# ==================== CÓDIGOS COMUNES (INTERSECCIÓN) ====================
message("Construyendo intersección de códigos en ", min(YEARS), "–", max(YEARS), " ...")

codes_by_year <- purrr::map(YEARS, ~{
  tibble(Anho = .x) %>%
    mutate(inst = list(get_instituciones(.x, MONTH_FOR_INDEX)))
}) %>%
  list_rbind() %>%            # o purrr::list_rbind
  tidyr::unnest(inst) %>%
  select(Anho, CodigoInstitucion)

codes_intersection <- codes_by_year %>%
  count(CodigoInstitucion, name = "n_years") %>%
  filter(n_years == length(YEARS)) %>%
  pull(CodigoInstitucion)

message("Códigos presentes en TODOS los años: ", length(codes_intersection))

# (Opcional) ver cuáles son:
 print(sort(codes_intersection))

# ==================== DESCARGA: TODOS LOS AÑOS x CÓDIGOS COMUNES ====================
 get_balances_years_common <- function(years = YEARS,
                                       codes_common = NULL,
                                       pause_between = PAUSE_BETWEEN,
                                       mode = "intersect", k = NULL) {
   # Determina el set de instituciones una sola vez (si no se pasa desde afuera)
   if (is.null(codes_common)) {
     codes_common <- get_codes(years, mode = mode, k = k)
   }
   
   out_list <- purrr::map(years, function(y) {
     message(">>> Año ", y, " (", length(codes_common), " instituciones)")
     res_y <- purrr::map_dfr(codes_common, function(cod) {
       out <- tryCatch(get_balances_inst_year(y, cod),
                       error = function(e) { message("   Falló año=", y, " cod=", cod, " -> ", e$message); NULL })
       Sys.sleep(pause_between); out
     })
     
     inst_y <- tryCatch(get_instituciones(y, MONTH_FOR_INDEX),
                        error = function(e) tibble(CodigoInstitucion=character(), NombreInstitucion=character()))
     
     res_y %>%
       left_join(inst_y %>% select(CodigoInstitucion, NombreInstitucion_inst = NombreInstitucion),
                 by = "CodigoInstitucion") %>%
       left_join(ref_names %>% rename(NombreInstitucion_ref = NombreInstitucion),
                 by = "CodigoInstitucion") %>%
       mutate(
         NombreInstitucion = coalesce(NombreInstitucion_inst, NombreInstitucion_ref),
         Anho = suppressWarnings(as.integer(Anho)),
         Mes  = suppressWarnings(as.integer(Mes))
       ) %>%
       select(-NombreInstitucion_inst, -NombreInstitucion_ref) %>%
       relocate(CodigoInstitucion, NombreInstitucion, .before = 1)
   })
   
   stats::setNames(out_list, years)
 }
 
# ============== EJECUTAR DESCARGA ==============
 lst <- get_balances_years_common(years = 1998:2024, mode = "union", pause_between = 0.15)
 
 panel <- bind_rows(lst)

# Vista rápida
glimpse(panel)

fwrite(panel,paste0(data,"cmf_data.csv"))
