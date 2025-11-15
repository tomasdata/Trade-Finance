# LATAM banks data -------------------------------------------------------------
library(tidyverse)
library(dplyr)
library(data.table)
library(stringr)
library(stringi)
library(kableExtra)
library(countrycode)
library(scales)
library(patchwork)
rm(list=ls())
# directories 
folder <- "G:/Mi unidad/Trade Finance"
data <- paste0(folder,"/Data/")
tables <- paste0(folder,"R/Tables/")
plots <- paste0(folder,"R/Plots/")
models <- paste0(folder,"R/Models/")

# Data ------------------
# Trade 
baci1 <- fread(paste0(data,"BACI_HS92_V202501/baci_trade_cty.csv"))
maping <- fread(paste0(data,"BACI_HS92_V202501/country_codes_V202501.csv"))

baci1 <- baci1 %>% left_join(maping %>% rename(country_exp=country_name,
                                               iso2_exp=country_iso2,
                                               iso3_exp=country_iso3),
                             by=c("exporter"="country_code")) %>% 
  left_join(maping %>% rename(country_imp=country_name,
                              iso2_imp=country_iso2,
                              iso3_imp=country_iso3),
            by=c("importer"="country_code"))

M_peru <- baci1 %>% filter(iso3_imp=="PER") %>%
  group_by(iso3_imp,year) %>% 
  summarise(M=sum(trade_value_usd,na.rm=T))

X_peru <- baci1 %>% filter(iso3_exp=="PER") %>% 
  group_by(iso3_exp,year) %>% 
  summarise(X=sum(trade_value_usd,na.rm=T))

M_chile <- baci1 %>% filter(iso3_imp=="CHL") %>%
  group_by(iso3_imp,year) %>% 
  summarise(M=sum(trade_value_usd,na.rm=T))

X_chile <- baci1 %>% filter(iso3_exp=="CHL") %>% 
  group_by(iso3_exp,year) %>% 
  summarise(X=sum(trade_value_usd,na.rm=T))

M_mexico <- baci1 %>% filter(iso3_imp=="MEX") %>%
  group_by(iso3_imp,year) %>% 
  summarise(M=sum(trade_value_usd,na.rm=T))

X_mexico <- baci1 %>% filter(iso3_exp=="MEX") %>% 
  group_by(iso3_exp,year) %>% 
  summarise(X=sum(trade_value_usd,na.rm=T))

M_brasil <- baci1 %>% filter(iso3_imp=="BRA") %>%
  group_by(iso3_imp,year) %>% 
  summarise(M=sum(trade_value_usd,na.rm=T))

X_brasil <- baci1 %>% filter(iso3_exp=="BRA") %>% 
  group_by(iso3_exp,year) %>% 
  summarise(X=sum(trade_value_usd,na.rm=T))

## Peru --------------------

# files <- list.files(
#   path       = file.path(data, "Peru banks"),
#   pattern    = "\\.(XLS|xlsx)$",
#   full.names = TRUE
# )
# 
# month_map <- c(
#   "en"=1,
#   "fe"=2,
#   "ma"=3,
#   "ab"=4,
#   "my"=5,
#   "jn"=6,
#   "jl"=7,
#   "ag"=8,
#   "se"=9,
#   "oc"=10,
#   "no"=11,
#   "di"=12
# )
# 
# parse_month_year <- function(fname) {
#   base <- tolower(basename(fname))
#   yy <- str_extract(base, "(19|20)\\d{2}")
#   anho <- if (!is.na(yy)) as.integer(yy) else NA_integer_
#   tok <- str_match(base, "([a-z]{1,10})(?=(19|20)\\d{2})")[,2]
#   mes_num <- month_map[[tok]]
#   c(anho,mes_num)
# }
# 
# 
# 
# peru <- data.frame()
# for (i in 1:length(files)){
# 
#   norm <- function(x) str_squish(tolower(stri_trans_general(as.character(x), "Latin-ASCII")))
# 
#   tmp  <- readxl::read_excel(files[[i]], col_names = FALSE)
#   mat_n   <- tmp[,1]
#   target1  <- ("Total Créditos Directos                          (En Miles S/.)") # amount in thousands
#   target2 <- ("Total Créditos Directos                          (En Miles S/)")
#   row_idx <- which(mat_n[[1]] %in% c(target1, target2))[1]
#   if (length(row_idx) == 0) row_idx <- NA_integer_
#   totals <- tmp[c(row_idx),]
# 
#   hdr <- which(apply(tmp, 1, function(r)
#     any(str_detect(norm(r), "^concepto(?:\\b|\\s|/|:)?$"))
#   ))[1]
#   stopifnot(!is.na(hdr))
# 
#   df_raw <- readxl::read_excel(files[[i]], skip = hdr - 1, col_names = TRUE)
# 
#   # 2) Verification
#   if (!str_detect(norm(names(df_raw)[1]), "^concepto\\b")) {
#     df_raw <- readxl::read_excel(files[[i]], skip = hdr, col_names = T)
#     header <- as.character(unlist(tmp[hdr, ]))
#     header[is.na(header)] <- paste0("V", which(is.na(header)))
#   }
# 
#   primera_col <- stringr::str_squish(tolower(as.character(df_raw[[1]])))
#   idx_ult_otros <- tail(which(stringr::str_detect(primera_col, "^créditos de consumo\\b")), 1)
#   stopifnot(length(idx_ult_otros) == 1)
# 
#   df <-  df_raw %>% dplyr::slice(1:(idx_ult_otros-1))
# 
#   title_index <- c(1,10,19,28,37)
# 
#   df <- df %>%
#     mutate(titulo = if_else(row_number() %in% title_index,
#                             as.character(.[[1]]), NA_character_)) %>%
#     fill(titulo, .direction = "down") %>%
#     slice(-title_index)   %>% na.omit
# 
#   info <- parse_month_year(files[[i]])
#   names(totals) <- names(df)
#   totals <- totals[,-c(1,ncol(totals))]
# 
#   df <- df %>%
#     pivot_longer(cols = c(2:(ncol(df)-1)),
#                  names_to = "institucion",
#                  values_to = "share",
#                  values_transform = list(share = ~ as.numeric(.x))
#     ) %>%
#     filter(institucion!="TOTAL BANCA MÚLTIPLE") %>%
#     mutate(año = info[[1]], mes = info[[2]], my = paste0(año,"-",mes))
# 
#   totals_long <- totals %>%
#     pivot_longer(
#       cols = everything(),
#       names_to = "institucion",
#       values_to = "total"
#     ) %>%
#     mutate(total = readr::parse_number(as.character(total)))
# 
#   df <- df %>%
#     left_join(totals_long, by = "institucion") %>%
#     mutate(
#       amount = share/100  * total
#     )
# 
#   peru <- bind_rows(peru,df)
# 
# }
# 
# peru <- peru %>%
#   mutate(
#     size = titulo %>%
#       str_replace_all("\\*", "") %>%
#       str_to_lower() %>%
#       str_squish() %>%
#       str_replace("^cr[eé]ditos?\\s+(a\\s+)?", "") %>%
#       str_replace_all("microempresas?$", "Micro") %>%
#       str_replace_all("grandes empresas?$", "Large") %>%
#       str_replace_all("medianas empresas?$", "Medium") %>%
#       str_replace_all("pequeñ[ao]s? empresas?$", "Small") %>%
#       str_replace_all("corporativos?$", "Corporate") %>%
#       str_replace_all("\\sempresas?$", "") %>%
#       str_squish(),
# size = factor(size,
#               levels = c("Corporate","Large","Medium","Small","Micro"),
#               ordered = TRUE)
#   ) %>% select(-titulo)
# 
# 
# 
# 
# 
# inst_norm <- function(x){
#   x %>%
#     str_squish() %>%
#     str_replace_all("\\(.*?\\)", "") %>%   # saca "(con sucursales...)"
#     str_remove_all("\\*+") %>%             # saca asteriscos
#     str_replace_all("[\\s/\\-]*\\d+$", "") %>% # saca sufijos tipo "2" o "2/"
#     stri_trans_general("Latin-ASCII") %>%  # sin acentos
#     str_to_lower() %>%
#     str_squish()
# }
# 
# 
# peru <- peru %>%
#   mutate(
#     inst_clean = inst_norm(institucion),
#     institucion_std = case_when(
#       # Cambios de nombre: ultimo nombre del banco
#       inst_clean %in% c("b. financiero", "b. pichincha") ~ "B. Pichincha",
#       inst_clean %in% c("b. azteca peru", "alfin banco", "alfin banco2/") ~ "Alfin Banco",
#       inst_clean %in% c("hsbc bank peru", "b. gnb") ~ "B. GNB",
#       inst_clean %in% c("b. continental", "b. bbva peru") ~ "B. BBVA Perú",
#       inst_clean %in% c("b. de comercio", "bancom") ~ "Bancom (Banco de Comercio)",
#       
#       # resto
#       inst_clean == "b. de credito del peru"        ~ "Banco de Crédito del Perú",
#       inst_clean == "b. interamericano de finanzas" ~ "BanBif (Banco Interamericano de Finanzas)",
#       inst_clean == "scotiabank peru"              ~ "Scotiabank Perú",
#       inst_clean == "citibank"                     ~ "Citibank",
#       inst_clean == "interbank"                    ~ "Interbank",
#       inst_clean == "mibanco"                      ~ "Mibanco",
#       inst_clean == "b. falabella peru"            ~ "B. Falabella Perú",
#       inst_clean == "b. santander peru"            ~ "B. Santander Perú",
#       inst_clean == "b. ripley"                    ~ "B. Ripley",
#       inst_clean == "deutsche bank peru"           ~ "Deutsche Bank Perú",
#       inst_clean == "b. cencosud"                  ~ "B. Cencosud",
#       inst_clean == "b. icbc"                      ~ "B. ICBC",
#       inst_clean == "bank of china"                ~ "Bank of China",
#       inst_clean == "b. bci peru"                  ~ "B. BCI Perú"
#       )
#   )
# 
# 
# 
# 
# 
# 
# fwrite(peru,paste0(data,"peru_full.csv"))

penusd <- fread(file.path(data, "PEN_USD.csv"), skip = 2, header = FALSE)
setnames(penusd, c("mes_raw","tc"))
# map dates
abbr_es <- c("Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic")

penusd <- penusd %>%
  mutate(
    mes_abr = substr(mes_raw, 1, 3),
    yy      = as.integer(substr(mes_raw, 4, 5)),
    year    = ifelse(yy >= 70, 1900 + yy, 2000 + yy),     
    month   = match(mes_abr, abbr_es),
    fecha   = as.Date(sprintf("%04d-%02d-01", year, month)),
    tc=as.numeric(tc)
  ) %>%
  select(fecha, year, month, tc)


peru <- fread(paste0(data,"peru_full.csv"))

peru <- peru %>%
  mutate(
    Concepto = recode(Concepto,
                      "Arrendamiento financiero y Lease-back**" = "Arrendamiento financiero y Lease-back",
                      "Otros 1/" = "Otros",
                      .default = Concepto,     # lo no listado se mantiene
                      .missing = Concepto
    )
  )

peru_tf <- peru %>% 
 # mutate(amount=amount/1000) %>% # in millions of soles  
  filter(Concepto %in% c("Comercio exterior")) %>% 
  left_join(X_peru,by=c("año"="year")) %>% 
  left_join(M_peru,by=c("año"="year")) %>% 
  left_join(penusd,by=c("año"="year","mes"="month")) %>%
  mutate(amount_usd=amount/tc,
         X_M=X+M)
  

### Exploratory analysis ------------------------


tab_cov <- peru_tf %>%
  mutate(period = make_date(año, mes, 1)) %>%
  group_by(institucion_std) %>%
  summarise(`Periods available (months)` = n_distinct(period), .groups = "drop") %>%
  arrange(desc(`Periods available (months)`))

kbl(tab_cov, format = "latex", booktabs = TRUE,
    col.names = c("Institution","Periods available (months)")) %>%
  kable_styling(latex_options = c("hold_position"))

# foreign trade credit over total credit.

peru_m <- peru %>%
  mutate(fecha = make_date(año, mes, 1)) %>%
  left_join(penusd %>% select(fecha, tc), by = "fecha") %>%
  mutate(kUSD = (amount) / tc)

comp_m <- peru_m %>%
  group_by(fecha, Concepto) %>%
  summarise(kUSD = sum(kUSD, na.rm=TRUE), .groups="drop") %>%
  group_by(fecha) %>%
  mutate(share = kUSD / sum(kUSD)) %>%
  ungroup()

to_en <- c(
  "Comercio exterior"                          = "Foreign trade",
  "Préstamos"                                  = "Loans",
  "Descuentos"                                 = "Discounted bills",
  "Factoring"                                  = "Factoring",
  "Tarjetas de crédito"                        = "Credit cards",
  "Arrendamiento financiero y Lease-back"      = "Financial leasing & lease-back",
  "Otros"                                      = "Other loans"
)
ft_share <- comp_m %>%
  group_by(fecha) %>%
  summarise(share_ft = kUSD[Concepto=="Comercio exterior"] / sum(kUSD), .groups="drop")

plot_df <- comp_m %>%
  mutate(Concept = recode(Concepto, !!!to_en))

ylim_max <- max(plot_df$kUSD, na.rm = TRUE)

# 2) Gráfico
ggplot() +
  # otras modalidades (translúcidas)
  geom_area(
    data = dplyr::filter(plot_df, Concept != "Foreign trade"),
    aes(fecha, kUSD, fill = Concept),
    alpha = 0.6
  ) +
  # Foreign trade (opaca)
  geom_area(
    data = dplyr::filter(plot_df, Concept == "Foreign trade"),
    aes(fecha, kUSD, fill = Concept),
    alpha = 1
  ) +
  # línea de share con eje secundario
  geom_line(
    data = ft_share,
    aes(fecha, share_ft * ylim_max),
    linewidth = 0.8,
    inherit.aes = FALSE
  ) +
  scale_y_continuous(
    labels = scales::label_number(big.mark = " "),
    sec.axis = sec_axis(~ . / ylim_max, labels = scales::percent,
                        name = "Foreign trade share (relative to all types)")
  ) +
  labs(x = NULL, y = "Stock (thousand of USD)", fill = "Modality",
       title = "Business direct credit by loan type — Foreign trade highlighted") +
  theme_minimal(12) +
  theme(legend.position = "bottom")


# Plot tf by firm size

tf_m_size <- peru_tf %>%
  mutate(fecha = make_date(año, mes, 1)) %>%
  group_by(año, size, fecha) %>%
  summarise(tf = sum(amount_usd, na.rm = TRUE), .groups = "drop")

tf_y_size <- tf_m_size %>%
  group_by(año, size) %>%
  summarise(tf_avg = mean(tf, na.rm = TRUE), n_meses = n_distinct(month(fecha)), .groups = "drop")

ggplot(tf_y_size, aes(x = año, y = tf_avg, color = size, group = size)) +
  geom_line(linewidth = 0.9) +
  labs(x = "Año", y = "Foreign trade credit (thousands of USD)", color = "Firm size",
       title = "Foreign trade credit (yearly average) — by firm size") +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  scale_y_continuous(labels = label_number(accuracy = 1, big.mark = " ")) +
  theme_minimal(base_size = 12)


# Plot tf as share of trade
# amounts by size
tf_m_size <- peru_tf %>%
  mutate(fecha = make_date(año, mes, 1)) %>%
  group_by(año, mes, size) %>%
  summarise(tf_kusd = sum(amount_usd, na.rm = TRUE), .groups = "drop")

# Avg of the monthly stocks
tf_y_size <- tf_m_size %>%
  group_by(año, size) %>%
  summarise(tf_kusd_avg = mean(tf_kusd, na.rm = TRUE),
            n_meses = n_distinct(mes), .groups = "drop")

xmy <- peru_tf %>% group_by(año) %>% summarise(X_M = first(X_M), .groups = "drop")

ratio_y_size <- tf_y_size %>%
  left_join(xmy, by = "año") %>%
  mutate(ratio = (tf_kusd_avg) / X_M)

ggplot(ratio_y_size, aes(año, ratio, color = size, group = size)) +
  geom_line(linewidth = 0.9) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = pretty_breaks()) +
  labs(x = "Año", y = "TF / (X+M)", color = "Firm size",
       title = "Foreign trade credit as a share of trade — yearly averages") +
  theme_minimal(base_size = 12)


sizes_big <- c("Corporate","Large","Medium")
sizes_small <- c("Small","Micro")
p_big <- ratio_y_size %>%
  filter(size %in% sizes_big) %>%
  mutate(size = factor(size, levels = sizes_big)) %>%
  ggplot(aes(año, ratio*100, color = size, group = size)) +
  geom_line(linewidth = 0.9) + 
  # scale_y_continuous(labels = scales::percent_format(accuracy = 0.01))
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(x = NULL,
       y = "Foreign trade credit / Total trade \n(%)", color = "Firm size",
       # title = "Foreign trade credit as a share of trade — yearly averages", 
       subtitle = "Corporate, Large, Medium") + 
  theme_minimal(12) 
  p_small <- ratio_y_size %>% 
    filter(size %in% sizes_small) %>% 
    mutate(size = factor(size, levels = sizes_small)) %>%
    ggplot(aes(año, ratio*100, color = size, group = size)) +
    geom_line(linewidth = 0.9) + # scale_y_continuous(labels = scales::percent_format(accuracy = 0.01)) 
    scale_x_continuous(breaks = scales::pretty_breaks()) +
    labs(x = "año", y = "Foreign trade credit / Total trade \n(%)", color = "", subtitle = "Small, Micro") + 
    theme_minimal(12) 
  
  (p_big / p_small) +
  plot_layout(heights = c(2, 1), guides = "collect") & theme(legend.position = "bottom")


# plot all banks credit for foreign trade.
tf_m_sys <- peru_tf %>%
  group_by(año, mes) %>%
  summarise(tf_kusd = sum(amount_usd, na.rm = TRUE), .groups = "drop")

ratio_y_sys <- tf_m_sys %>%
  group_by(año) %>%
  summarise(tf_kusd_avg = mean(tf_kusd, na.rm = TRUE), .groups = "drop") %>%
  left_join(xmy, by = "año") %>%
  mutate(ratio = (tf_kusd_avg ) / X_M) %>% filter(año<=2023)

ggplot(ratio_y_sys, aes(año, ratio)) +
  geom_line(linewidth = 0.9) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = pretty_breaks()) +
  labs(x = "Year", y = "Foreign trade credit / Total trade \n(%)",
      # title = "Foreign trade credit as a share of trade — All banks"
      ) +
  theme_minimal(base_size = 12)



tf_y_bank <- peru_tf %>%
  mutate(fecha = make_date(año, mes, 1)) %>%
  group_by(año, mes, institucion_std) %>%
  summarise(tf_kusd = sum(amount_usd, na.rm = TRUE), .groups = "drop") %>%
  group_by(año, institucion_std) %>%
  summarise(tf_kusd_avg = mean(tf_kusd, na.rm = TRUE),
            n_meses = n_distinct(mes), .groups = "drop") %>%
  left_join(peru_tf %>% distinct(año, X_M),
            by = "año") %>%
  mutate(ratio = tf_kusd_avg / X_M) %>%  filter(año<=2023)

last <- max(tf_y_bank$año, na.rm = TRUE)
top5 <- tf_y_bank %>%
  filter(año == last) %>%
  slice_max(ratio, n = 5) %>%
  pull(institucion_std)


tf_y_bank %>%
  filter(institucion_std %in% top5) %>%
  ggplot(aes(x = año, y = ratio, color = institucion_std, group = institucion_std)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  labs(x = "Year", y = "Foreign trade credit / Total trade \n(%)", color = "Bank",
       #title = "2023 Top-5 banks by trade-finance stock as share of trade (TF/(X+M))"
       ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")


# Concentration of TF (Do a few banks concentrate the most of the market?)
tf_conc <- peru %>%
  filter(Concepto == "Comercio exterior") %>%
  mutate(fecha = lubridate::make_date(año, mes, 1)) %>%
  group_by(fecha, institucion_std) %>%
  summarise(tf_miles = sum(amount, na.rm = TRUE), .groups = "drop") %>%
  group_by(fecha) %>%
  mutate(w = tf_miles / sum(tf_miles)) %>%       # participation
  arrange(desc(w), .by_group = TRUE) %>%
  mutate(rank = row_number()) %>%
  summarise(
    CR3 = sum(w[rank <= 3], na.rm = TRUE),
    CR5 = sum(w[rank <= 5], na.rm = TRUE),
    n_banks = n(),
    .groups = "drop"
  )

tf_conc %>%
  ggplot(aes(fecha)) +
  geom_line(aes(y = CR3, color = "Top 3 banks"), linewidth = 0.9) +
  geom_line(aes(y = CR5, color = "Top 5 banks"), linewidth = 0.9) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    x = NULL,
    y = "Share of foreign trade credit",
    color = "Group",
   # title = "Share of trade-finance held by top 3 vs top 5 banks (monthly)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

## ## Brasil -----------------
# files <- list.files(
#   path       = file.path(data, "Brasil credits"),
#   pattern    = "\\.(csv)$",
#   full.names = TRUE
# )
#  
# brasil <- rbindlist(
#   lapply(files, function(f) {
#     fread(f)[modalidade == "PJ - Comércio exterior"]
#   }),
#   use.names = TRUE,
#   fill = TRUE
# )
# 
# fwrite(brasil,paste0(data,"brasil_full.csv"))
brasil <- fread(paste0(data,"brasil_full.csv"))

### Exploratory analysis ------------------------------------

 
 
 
## Mexico ------------------
mexico <- fread(paste0(data,"Mexico/040_R12A_1219_133.csv"))

conceptos_tf <- c("202401504003") # Cartas de credito

mexico <- mexico %>% filter(concepto %in% conceptos_tf)

mxnusd <- readxl::read_excel(paste0(data, "/mxnusd.xls"),skip=6)
mxnusd <- mxnusd %>% mutate(date=as.Date(Fecha, format="%d/%m/%Y"),
                            year=year(date),
                            month=month(date),
                            year_month=paste0(year,"-",month)) %>% 
  filter(!is.na(Fecha)) %>% 
  select(-Fecha,-Determinación,-`Publicación\nDOF`,tc=`Para solventar\nobligaciones`) %>% 
  arrange(date) %>% 
  group_by(year,month,year_month) %>% 
  summarise(tc=last(tc))

mexico$year <- as.integer(substr(mexico$periodo, 1, 4))
mexico$month  <- as.integer(substr(mexico$periodo, 5, 6))

mexico1 <- mexico %>% left_join(mxnusd,by=c("year","month")) %>% 
  left_join(X_mexico,by=c("year"="year")) %>% 
  left_join(M_mexico,by=c("year"="year")) %>% 
  mutate(amount_usd=importe_pesos/tc,
         amount_usdk=amount_usd/1000)

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
mexico1 <- mexico1 %>% rename(cod_inst=institucion) %>% filter(cod_inst!=5)
mexico1$institucion <- inst_map[as.character(mexico1$cod_inst)]

# Concentracion de mercado en LC --
lc_by_bank_month <- mexico1 %>%
  group_by(year_month, cod_inst, institucion) %>%
  summarise(
    lc_usd = sum(amount_usd, na.rm = TRUE),
    .groups = "drop"
  )

conc_ts <- lc_by_bank_month %>%
  group_by(year_month) %>%
  mutate(
    total_lc = sum(lc_usd, na.rm = TRUE)
  ) %>%
  arrange(year_month, desc(lc_usd)) %>%
  mutate(rank = row_number()) %>%
  summarise(
    top5_share = sum(lc_usd[rank <= 5]) / unique(total_lc),
    hhi = sum((lc_usd / unique(total_lc))^2),
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year_month, "-01"))
  )

# a) Top 5 share en el tiempo
ggplot(conc_ts, aes(x = date, y = top5_share)) +
  geom_line(size = 1) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    x = NULL,
    y = "Top 5 share of LC market",
    title = "Concentration of letters of credit\nTop 5 banks' share over time"
  ) +
  theme_minimal()




### Exploratory analysis ------------------------------------

# letra de credito serie de tiempo ---
last_date <- max(mexico1$year_month, na.rm = TRUE)

# top 5 banks
top5_codes <- mexico1 %>%
  filter(year_month == last_date) %>%
  group_by(cod_inst, institucion) %>%
  summarise(
    lc_usd_k = sum(amount_usdk, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(lc_usd_k)) %>%
  slice(1:5) %>%
  pull(cod_inst)


tf_all_groups <- mexico1 %>%
  mutate(
    grupo = ifelse(cod_inst %in% top5_codes, institucion, "Others"),
    grupo = ifelse(is.na(grupo), "Others", grupo)
  )

# Agregar por mes y grupo
ts_lc <- tf_all_groups %>%
  group_by(year_month, grupo) %>%
  summarise(
    lc_usd_k = sum(amount_usdk, na.rm = TRUE),
    .groups = "drop"
  ) %>% ungroup

ts_lc <- ts_lc %>%
  mutate(
    date = as.Date(paste0(year_month, "-01"))
  )


# Gráfico de series: Top 5 individuales + Others
ggplot(ts_lc, aes(x = date, y = lc_usd_k, color = grupo, group = grupo)) +
  geom_line(size=1.1) +
  labs(
    x = NULL,
    y = "Letters of credit outstanding\n(thousands of USD)",
    color = "Bank / group",
    title = "Mexican banks’ letters of credit over time\nTop 5 (last period) vs Others"
  ) +
  scale_y_continuous(labels = label_number(big.mark = " ")) +
  scale_x_date(breaks = scales::pretty_breaks(n=10)) +
  theme_minimal()+
  theme(legend.position = "bottom")



# barras apiladas por banco relativo a trade. --


tf_22_23 <- mexico1 %>%
  filter(year %in% c(2022, 2023),
         cod_inst != 5)

# trade anual
trade_by_year <- tf_22_23 %>%
  group_by(year) %>%
  summarise(
    X = first(X),
    M = first(M),
    trade = X + M,
    .groups = "drop"
  )

# avg cartas de credito
bank_avg <- tf_22_23 %>%
  group_by(year, cod_inst, institucion) %>%
  summarise(
    lc_usd_avg = mean(amount_usdk, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(trade_by_year, by = "year") %>%
  mutate(
    share_trade = lc_usd_avg / trade*100 
  )

# Top 5 bancos 2023
top5_codes <- bank_avg %>%
  group_by(cod_inst, institucion) %>%
  summarise(lc_usd_avg_all = mean(lc_usd_avg, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(lc_usd_avg_all)) %>%
  slice(1:5) %>%
  pull(cod_inst)

# Construir grupos: Top5 (siempre mismos códigos) vs Others
plot_df <- bank_avg %>%
  mutate(
    grupo = ifelse(cod_inst %in% top5_codes, institucion, "Others")
  ) %>%
  group_by(year, grupo) %>%
  summarise(
    share_trade = sum(share_trade),  
    .groups = "drop"
  )

# Orden de leyenda: Top5 según ranking 2023 + Others
orden_top5 <- bank_avg %>%
  filter(year == 2023, cod_inst %in% top5_codes) %>%
  arrange(desc(share_trade)) %>%
  pull(institucion) %>%
  unique()

plot_df <- plot_df %>%
  mutate(
    grupo = factor(grupo,
                   levels = c(orden_top5, "Others"))
  )

# barras apiladas 2022 vs 2023
ggplot(plot_df,
       aes(x = factor(year),
           y = share_trade,
           fill = grupo)) +
  geom_col() +
  scale_y_continuous(
    #labels = percent_format(accuracy = 0.01)
  ) +
  labs(
    x = NULL,
    y = "Letters of Credit/Total trade \n(%)",
    fill = "Banco",
    title = "Letters of credit liabilities in Mexico banks relative to total trade"
  ) +
  theme_minimal()


## Chile -------------------
chile <- fread(paste0(data,"cmf_data.csv"))
  
# Trade finance variables only:
  cuentas_tf <- c(
#   ACTIVOS: Interbancarios con bancos del país
    "143100104", # Activo interbancario (bancos del país): Créditos comercio exterior — exportaciones chilenas
    "143100105", # Activo interbancario (bancos del país): Créditos comercio exterior — importaciones chilenas
    "143100106", # Activo interbancario (bancos del país): Créditos comercio exterior — entre terceros países
    
    #  ACTIVOS: Interbancarios con bancos del exterior 
    "143200104", # Activo interbancario (bancos del exterior): Créditos comercio exterior — exportaciones chilenas
    "143200105", # Activo interbancario (bancos del exterior): Créditos comercio exterior — importaciones chilenas
    "143200106", # Activo interbancario (bancos del exterior): Créditos comercio exterior — entre terceros países
    
    # Activos: Colocaciones comercialees Prestamos comerciales:
    "145400200", # creditos de comercio exterior
    "145400201",#Acreditivos negociados a plazo de exportaciones chilenas
    "145400202", # Otros créditos para exportaciones chilenas  
    "145400203", # Acreditivos negociados a plazo de importaciones chilenas    
    "145400204", # Otros créditos para importaciones chilenas   
    "145400205", #Acreditivos negociados a plazo de operaciones entre terceros países         
    "145400290", #Otros créditos para operaciones entre terceros países    

    # ACTIVOS: Colocaciones a clientes (cartera comercial) 
    "813200600", # Créditos de comercio exterior (cartera comercial) – versión de cuenta según bloque de evaluación
    "814200600", # Créditos de comercio exterior (cartera comercial) – otra variante de presentación/reglamentaria
    "821200600", # Créditos de comercio exterior (cartera comercial) – agregado equivalente en otro formato
    
    #  PASIVOS: Obligaciones con bancos del país
    "244250100", # Financiamientos de comercio exterior
    "244250101", # Pasivo con bancos del país: Financiamientos de comercio exterior — exportaciones chilenas
    "244250102", # Pasivo con bancos del país: Financiamientos de comercio exterior — importaciones chilenas
    "244250103", # Pasivo con bancos del país: Obligaciones por operaciones entre terceros países
    
    #  PASIVOS: Obligaciones con bancos del exterior (fondeo trade) 
    "244500000", # Financiamientos de comercio exterior
    "244500101", # Pasivo con bancos del exterior: Financiamientos de comercio exterior — exportaciones chilenas
    "244500102", # Pasivo con bancos del exterior: Financiamientos de comercio exterior — importaciones chilenas
    "244500103", # Pasivo con bancos del exterior: Obligaciones por operaciones entre terceros países
    # Información complementaria mensual 
    "831200000" # Creditos contingentes 
    
    
  )  
chile_tf <- chile %>%
  filter(CodigoCuenta %in% cuentas_tf)

### Exploratory analysis ------------------------------------

## Trade exploratory analysis -----------------------------------------
regions <- fread(paste0(data, "country_correspondence.csv")) %>% 
  select(
    name,
    iso3c     = `alpha-3`,
    region,
    subregion = `sub-region`
  ) %>% 
  mutate(
    iso2c = countrycode(iso3c,
                        origin      = "iso3c",
                        destination = "iso2c",
                        warn        = TRUE),
    subregion=ifelse(is.na(subregion),paste0(region,"- No sub-region"),subregion))
    

baci2 <- baci1 %>%
  left_join(regions %>% select(iso3c, region_exp = region, subregion_exp = subregion),
            by = c("iso3_exp"="iso3c")) %>%
  left_join(regions %>% select(iso3c, region_imp = region, subregion_imp = subregion),
            by = c("iso3_imp"="iso3c"))

