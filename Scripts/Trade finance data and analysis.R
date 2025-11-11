# Trade finance data -----------------------------------------------------------
library(tidyverse)
library(data.table)
library(dtplyr)
library(WDI)
library(countrycode)
library(readxl)
library(httr)
library(comtradr)
library(readr)
library(viridis)
library(kableExtra)
library(zoo)
library(scales)
library(sf)
library(ggbreak)
library(lubridate)
library(cowplot)
library(ggrepel)
rm(list=ls())
select <- dplyr::select
#Directories -------------------------------------------------------------------
folder <- "G:/Mi unidad/Trade Finance"
data <- paste0(folder,"/Data/")
tables <- paste0(folder,"R/Tables/")
plots <- paste0(folder,"R/Plots/")
models <- paste0(folder,"R/Models/")
# Data -------------------------------------------------------------------------
## Correspondences -------------------------------------------------------------
# regions
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
    subregion=ifelse(is.na(subregion),paste0(region,"- No sub-region"),subregion)
  )
# income levels (https://datahelpdesk.worldbank.org/knowledgebase/articles/906519-world-bank-country-and-lending-groups)
class <- read_excel(paste0(data,"income levels.xlsx"), 
                    sheet = "Country Analytical History", 
                    skip = 5)
class.l <- class %>%
  pivot_longer(cols = 3:last_col(),
               names_to = "year",
               values_to = "value") %>% mutate(year=as.integer(year))
class.l[class.l == ".."] <- NA

class.l <- class.l %>% 
  group_by(orig) %>% 
  fill(value,.direction = 'updown') %>% ungroup() %>% 
  dplyr::select(iso3c=orig,
                income = value,
                year)

selected_countries <- regions %>% 
  filter(region=="Americas",subregion=="Latin America and the Caribbean") %>%
  select(iso2c) %>% unique %>% pull



## BACI CEPII -----------------------------------------------------------------------
# baci <- fread(paste0(data,"BACI_HS92_V202501/BACI_HS92_Y2000_V202501.csv"))
# base_dir <- file.path(data, "BACI_HS92_V202501")
# years    <- 2000:2025
# files    <- file.path(base_dir, sprintf("BACI_HS92_Y%04d_V202501.csv", years))
# files    <- files[file.exists(files)]
# 
# read_agg_one <- function(path) {
#   read_csv(
#     path,
#     col_types = cols(
#       t = col_integer(),
#       i = col_integer(),
#       j = col_integer(),
#       k = col_skip(),     # ingnore product
#       v = col_double(),
#       q = col_skip()      # ignorar quantity
#     ),
#     col_select = c(t, i, j, v),
#     progress = FALSE
#   ) %>%
#     group_by(t, i, j) %>%
#     summarise(trade_value_usd = sum(v, na.rm = TRUE), .groups = "drop")
# }
# 
# baci1 <- map_dfr(files, read_agg_one) %>%
#   group_by(t, i, j) %>%                                  
#   summarise(trade_value_usd = sum(trade_value_usd, na.rm = TRUE),
#             .groups = "drop") %>%
#   rename(year = t, exporter = i, importer = j)

#fwrite(baci1,paste0(data,"BACI_HS92_V202501/baci_trade_cty.csv"))
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

# values in thousands so we transform them to millions
baci_bilat <- baci1 %>%
  mutate(
    FOB = trade_value_usd/1000,
    exporter = country_exp,
    importer = country_imp,
  ) %>%
  select(year, exporter, importer, iso2_exp, iso2_imp, FOB) %>% 
  left_join(regions %>% select(iso2c, region_exp = region, subregion_exp = subregion),
            by = c("iso2_exp"="iso2c")) %>%
  left_join(regions %>% select(iso2c, region_imp = region, subregion_imp = subregion),
            by = c("iso2_imp"="iso2c"))


### Exploratory analysis ---------------------------------------------------------
bilat <- baci_bilat %>% 
  mutate(
    iso3_exp = countrycode(iso2_exp, "iso2c", "iso3c"),
    iso3_imp = countrycode(iso2_imp, "iso2c", "iso3c") 
  )
latam <- "Latin America and the Caribbean"


# Countries per year: counts of importers and exporters
countries_per_year <- bilat %>%
  group_by(year) %>%
  summarise(
    `# importers` = n_distinct(iso2_imp, na.rm = TRUE),
    `# exporters` = n_distinct(iso2_exp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year)

kbl(
  countries_per_year,
  format    = "latex",
  booktabs  = TRUE,
  linesep   = "",
  align=c("lcc"),
  escape    = FALSE,
  col.names = c("Year", "# importers", "# exporters")
) %>%
  kable_styling(latex_options = "hold_position")

# Importers ISO3 list per year
importers_year_list <- bilat %>%
  group_by(subregion_imp) %>% 
  summarise(
    `# importers` = n_distinct(importer, na.rm = TRUE),
    `Importers (ISO3)` = paste(sort(unique(importer)), collapse = ", "),
    .groups = "drop"
  ) %>% 
  arrange(subregion_imp)

kbl(
  importers_year_list,
  format    = "latex",
  booktabs  = TRUE,
  linesep   = "",
  align=c("lcl"),
  escape    = FALSE,
  col.names = c("Subregion", "# importers", "Importers")
) %>%
  kable_styling(latex_options = "hold_position") 

#  Exporters ISO3 list per year
exporters_year_list <- bilat %>%
  group_by(subregion_exp) %>% 
  summarise(
    `# exporters` = n_distinct(exporter, na.rm = TRUE),
    `Exporters (ISO3)` = paste(sort(unique(exporter)), collapse = ", "),
    .groups = "drop"
  ) %>%
  arrange(subregion_exp)

kbl(
  exporters_year_list,
  format    = "latex",
  booktabs  = TRUE,
  linesep   = "",
  align=c("lcl"),
  escape    = FALSE,
  col.names = c("Year", "# exporters", "Exporters")
) %>%
  kable_styling(latex_options = "hold_position") %>%
  column_spec(3, width = "12cm")


# 2) LATAM imports from world (incl. and excl. intra-LATAM
imp_all <- bilat %>%
  filter(subregion_imp == latam) %>%  # importer in LATAM
  group_by(year) %>%
  summarise(Imp_LATAM_all = sum(FOB, na.rm = TRUE), .groups = "drop")

imp_exrow <- bilat %>%
  filter(subregion_imp == latam, subregion_exp != latam) %>%  # excluding intra-LATAM
  group_by(year) %>%
  summarise(Imp_LATAM_exROW = sum(FOB, na.rm = TRUE), .groups = "drop")

# 3) LATAM exports to world (incl. and excl. intra-LATAM)
exp_all <- bilat %>%
  filter(subregion_exp == latam) %>%  # exporter in LATAM
  group_by(year) %>%
  summarise(Exp_LATAM_all = sum(FOB, na.rm = TRUE), .groups = "drop")

exp_exrow <- bilat %>%
  filter(subregion_exp == latam, subregion_imp != latam) %>%  # excluding intra-LATAM
  group_by(year) %>%
  summarise(Exp_LATAM_exROW = sum(FOB, na.rm = TRUE), .groups = "drop")

# 4) Build long df for plotting 
plot_df <- imp_all %>%
  left_join(imp_exrow, by = "year") %>%
  left_join(exp_all,  by = "year") %>%
  left_join(exp_exrow, by = "year") %>%
  pivot_longer(starts_with(c("Imp_","Exp_")), names_to = "series", values_to = "value") %>%
  mutate(
    flow  = if_else(grepl("^Imp_", series), "Imports", "Exports"),
    scope = if_else(grepl("_exROW$", series), "Excluding Latam", "Including Latam"),
    flow  = factor(flow,  levels = c("Imports","Exports")),
    scope = factor(scope, levels = c("Including Latam","Excluding Latam"))
  )

# 5) Figure — LATAM trade with the rest of the world (excl. intra-LATAM
ggplot(plot_df %>% filter(scope == "Excluding Latam"),
       aes(year, value, color = flow)) +
  geom_line(linewidth = 0.9) +
  scale_x_continuous(breaks = scales::pretty_breaks(10)) +
  scale_y_continuous(labels = scales::label_number(big.mark = " ")) +
  labs(
    #title = "LATAM trade with the rest of the world (excl. intra-LATAM)",
    x = NULL, y = "Millions of USD", color = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

# Country levle
# 6) Exports (exporter in LATAM
X_latam <- bilat %>%
  filter(subregion_exp == latam) %>%
  group_by(country_latam = exporter, iso2_latam = iso2_exp, year) %>%
  summarise(X = sum(FOB, na.rm = TRUE), .groups = "drop")

# 7) Imports (importer in LATAM
M_latam <- bilat %>%
  filter(subregion_imp == latam) %>%
  group_by(country_latam = importer, iso2_latam = iso2_imp, year) %>%
  summarise(M = sum(FOB, na.rm = TRUE), .groups = "drop")

# 8) Merge and build X+M
latam_panel <- full_join(X_latam, M_latam,
                         by = c("country_latam","iso2_latam","year")) %>%
  mutate(X = replace_na(X, 0),
         M = replace_na(M, 0),
         XM = X + M)

# 9) Compute Top-5 sets over the whole period
agg_total <- latam_panel %>%
  group_by(country_latam, iso2_latam) %>%
  summarise(X_tot = sum(X), M_tot = sum(M), XM_tot = sum(XM), .groups = "drop")

top5_X  <- agg_total %>% arrange(desc(X_tot))  %>% slice_head(n = 5) %>% pull(country_latam)
top5_M  <- agg_total %>% arrange(desc(M_tot))  %>% slice_head(n = 5) %>% pull(country_latam)
top5_XM <- agg_total %>% arrange(desc(XM_tot)) %>% slice_head(n = 5) %>% pull(country_latam)

top_countries <- c(top5_M,top5_X,top5_XM) %>% unique
# 10) Fixed color palette (ordered by XM_tot)
countries_order <- agg_total %>%
  arrange(desc(XM_tot)) %>%
  filter(country_latam %in% top_countries) %>% 
  pull(country_latam) %>% unique() 



pal_vals <- scales::hue_pal()(length(countries_order))
pal <- setNames(pal_vals, countries_order)

# 11) Helper to ensure identical look & feel
plot_top <- function(df_tot, top_vec, var, title) {
  df_tot %>%
    dplyr::filter(country_latam %in% top_vec) %>%
    dplyr::mutate(country_latam = factor(country_latam, levels = countries_order)) %>%
    ggplot(aes(year, .data[[var]], color = country_latam)) +
    geom_line(linewidth = 0.9) +
    scale_x_continuous(breaks = scales::pretty_breaks(10)) +
    scale_y_continuous(labels = scales::label_number(big.mark = " ")) +
    scale_color_manual(values = pal,
                       breaks = intersect(countries_order, top_vec), drop = FALSE) +
    labs(title = title, x = NULL, y = "Millions of USD", color = "Country") +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom")
}

# 12) Figures — Top 5 exporters/importers/X+M (LATAM)
p_X  <- plot_top(latam_panel, top5_X,  "X",  #"LATAM — Top 5 exporters"
                 "")
p_M  <- plot_top(latam_panel, top5_M,  "M",  #"LATAM — Top 5 importers"
                 "")
p_XM <- plot_top(latam_panel, top5_XM, "XM", #"LATAM — Top 5 by (Exports + Imports)"
                 "")

p_X
p_M
p_XM


# for a specific country.
# 13) Choose a target LATAM ISO2 
iso2_target <- "MX"

# 14) Export destinations of target country
destinations <- bilat %>%
  filter(iso2_exp == iso2_target) %>%
  group_by(partner = importer, year) %>%
  summarise(X_to_partner = sum(FOB, na.rm = TRUE), .groups = "drop")

top5_dest <- destinations %>%
  group_by(partner) %>%
  summarise(total = sum(X_to_partner), .groups = "drop") %>%
  arrange(desc(total)) %>%
  slice_head(n = 5) %>%
  pull(partner)

ggplot(destinations %>% filter(partner %in% top5_dest),
       aes(year, X_to_partner, color = partner)) +
  geom_line(linewidth = 0.9) +
  scale_x_continuous(breaks = scales::pretty_breaks(8)) +
  scale_y_continuous(labels = scales::label_number(big.mark = " ")) +
  labs(
    title = paste0("Top export destinations — ", iso2_target),
    x = NULL, y = "Millions of USD", color = "Destination"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

# 15) Import origins of target country
origins <- bilat %>%
  filter(iso2_imp == iso2_target) %>%
  group_by(partner = exporter, year) %>%
  summarise(M_from_partner = sum(FOB, na.rm = TRUE), .groups = "drop")

top5_orig <- origins %>%
  group_by(partner) %>%
  summarise(total = sum(M_from_partner), .groups = "drop") %>%
  arrange(desc(total)) %>%
  slice_head(n = 5) %>%
  pull(partner)

ggplot(origins %>% filter(partner %in% top5_orig),
       aes(year, M_from_partner, color = partner)) +
  geom_line(linewidth = 0.9) +
  scale_x_continuous(breaks = scales::pretty_breaks(8)) +
  scale_y_continuous(labels = scales::label_number(big.mark = " ")) +
  labs(
    title = paste0("Top import origins — ", iso2_target),
    x = NULL, y = "Millions of USD", color = "Origin"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")




## EXIM BANK US ----------------------------------------------------------------
# Excluding tax haven from https://www.imf.org/external/np/mae/oshore/2000/eng/back.htm#table1

ofc_imf2000_names_lac <- c(
  "Anguilla",
  "Antigua and Barbuda",
  "Aruba",
  "Bahamas",
  "Barbados",
  "Belize",
  "Bermuda",
  "British Virgin Islands",
  "Cayman Islands",
  "Dominica",
  "Grenada",
  "Montserrat",
  "Netherlands Antilles", 
  "Curaçao",
  "Sint Maarten",
  "Panama",
  "Saint Kitts and Nevis",
  "Saint Lucia",
  "Saint Vincent and the Grenadines",
  "Turks and Caicos Islands"
)

name_fix <- tibble::tibble(
  name_imf = c("Saint Kitts and Nevis",
               "Saint Lucia",
               "Saint Vincent and the Grenadines",
               "Turks and Caicos Islands",
               "British Virgin Islands",
               "Netherlands Antilles"),
  name_cc  = c("St. Kitts and Nevis",
               "St. Lucia",
               "St. Vincent and the Grenadines",
               "Turks and Caicos Islands",
               "Virgin Islands, British",
               "Netherlands Antilles")
)

names_cc <- dplyr::coalesce(
  dplyr::tibble(name_imf = ofc_imf2000_names_lac) %>%
    dplyr::left_join(name_fix, by = "name_imf") %>% 
    dplyr::pull(name_cc),
  ofc_imf2000_names_lac
)

ofc_iso2_imf <- countrycode::countrycode(names_cc, "country.name", "iso2c")


exim0 <- fread(paste0(data,"exim auth.csv")) %>% head(-2)
exim <-exim0 %>% mutate(iso2c = countrycode(
  as.character(Country),     
  origin    = "country.name",   
  destination = "iso2c"   
)) %>% 
  mutate(iso2c=ifelse(Country=="Micronesia","FM",iso2c)) %>% 
  left_join(regions,by="iso2c") %>% 
  filter(!Country %in% c("Multiple - Countries","Private Export Funding Corp.")) 

# Fix numeric variables
exim <- exim %>% 
  mutate(
    across(matches("Amount|Exposure"), 
           ~ as.numeric(gsub(",", "", .x))),
    across(matches("Amount|Exposure"), 
           ~ .x/1000000)
  ) 


# Exports of US
usa_imp <- bilat %>%
  filter(exporter == "USA") %>%
  group_by(importer,iso2_imp, year) %>%
  summarise(M_from_US = sum(FOB), .groups="drop")

### Exploratory analysis -------------------------------------------------------
exim_f <- exim %>% 
  mutate(across(where(is.character), as.factor)) 
summary(exim_f)

programs <- c("Guarantee", "Insurance", "Loan", "Working Capital")

program_colors <- setNames(hue_pal()(length(programs)), programs)


# by program
decision_summary <- exim %>% filter(Decision=="Approved") %>% 
  group_by(Program) %>%
  summarise(
    Ocurrence   = n(),
    TotalAmount = sum(`Approved/Declined Amount`, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  arrange(desc(TotalAmount)) %>%
  mutate(
    `% of total occ.`    = Ocurrence   / sum(Ocurrence)   * 100,
    `amount_share (%)`   = TotalAmount / sum(TotalAmount) * 100
  ) %>% 
  select(Program,Ocurrence,`% of total occ.`,TotalAmount,`amount_share (%)`)


kbl(
  head(decision_summary, 10),
  format    = "latex",
  align     = "lcccc",
  booktabs  = TRUE,
  linesep   = "",
  digits    = 1,
  escape    = FALSE,
  col.names = c(
    "Program",
    "Ocurrence",
    "\\shortstack{\\% of\\\\total occ.}",
    "\\shortstack{Total amount\\\\(millions of US$)}",
    "\\shortstack{\\% of\\\\total amount}"
  )
) %>%
  kable_styling(latex_options = "hold_position")


# by program in latam
decision_summary <- exim %>% filter(Decision=="Approved",iso2c %in% selected_countries) %>% 
  group_by(Program) %>%
  summarise(
    Ocurrence   = n(),
    TotalAmount = sum(`Approved/Declined Amount`, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  arrange(desc(TotalAmount)) %>%
  mutate(
    `% of total occ.`    = Ocurrence   / sum(Ocurrence)   * 100,
    `amount_share (%)`   = TotalAmount / sum(TotalAmount) * 100
  ) %>% 
  select(Program,Ocurrence,`% of total occ.`,TotalAmount,`amount_share (%)`)


kbl(
  head(decision_summary, 10),
  format    = "latex",
  align     = "lcccc",
  booktabs  = TRUE,
  linesep   = "",
  digits    = 1,
  escape    = FALSE,
  col.names = c(
    "Program",
    "Ocurrence",
    "\\shortstack{\\% of\\\\total occ.}",
    "\\shortstack{Total amount\\\\(millions of US$)}",
    "\\shortstack{\\% of\\\\total amount}"
  )
) %>%
  kable_styling(latex_options = "hold_position")

# By region
subregion_summary <- exim %>% filter(Decision=="Approved")%>%
  group_by(subregion) %>%
  summarise(
    Ocurrence    = n(),
    TotalAmount  = sum(`Approved/Declined Amount`, na.rm = TRUE)  ) %>%
  ungroup() %>%
  arrange(desc(TotalAmount)) %>%
  mutate(`% of total` = Ocurrence / sum(Ocurrence) * 100,
         amount_share = TotalAmount/sum(TotalAmount)*100) %>% 
  select(subregion,Ocurrence,`% of total`,TotalAmount,amount_share)

kbl(
  head(subregion_summary, 10),
  format    = "latex",
  align     = "lccc",
  booktabs  = TRUE,
  linesep   = "",
  digits    = 1,
  escape = F,
  col.names = c("Subregion", "Ocurrence",
                "\\shortstack{\\% of total\\ocurrence}}",
                "\\shortstack{Total amount \\(millions of US$)}", 
                "\\shortstack{\\% of\\total amount}")
) %>%
  kable_styling(latex_options = "hold_position")


# Plot by subregion and program
region_program_summary <- exim %>%
  filter(Decision == "Approved") %>%
  group_by(subregion, Program) %>%
  summarise(
    TotalAmount = sum(`Approved/Declined Amount`, na.rm = TRUE)
  ) %>%
  ungroup() 

top10 <- region_program_summary %>% 
  group_by(subregion) %>% 
  summarise(total = sum(TotalAmount, na.rm = TRUE)) %>% 
  slice_max(total, n = 10) %>% 
  pull(subregion)

region_program_summary %>% 
  filter(subregion %in% top10) %>% 
  mutate(highlight = subregion == "Latin America and the Caribbean") %>% 
  ggplot(aes(
    x    = fct_reorder(subregion, TotalAmount, .fun = sum, .desc = TRUE),
    y    = TotalAmount,
    fill = Program,
    alpha = highlight            
  )) +
  geom_col() +
  scale_fill_manual(values = program_colors)+
  scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.7), guide = FALSE) +
  labs(
    x    = "Subregion",
    y    = "Total amount (millions of US$)",
    fill = "Program"
  ) +
  theme_minimal() +
  theme(
    axis.text.x   = element_text(angle = 45, hjust = 1, size = 10),
    legend.position = "bottom"
  )



# Countries by subregion 
subregion_countries <- exim %>%
  group_by(subregion) %>%
  summarise(
    Countries = paste0(
      sort(unique(Country)),
      collapse = ", "    ),
    n=n_distinct(Country)
  ) %>%
  ungroup() %>% arrange(desc(n))

kbl(
  subregion_countries,
  format    = "latex",
  booktabs  = TRUE,
  linesep   = "",
  escape    = FALSE,
  col.names = c("Subregion", "Countries","Number of countries")
) %>%
  kable_styling(latex_options = "hold_position")



# By country in latam
country_latam_summary <- exim %>%
  filter(Decision == "Approved", iso2c %in% selected_countries) %>%
  group_by(Country) %>%
  summarise(
    Occurrence  = n(),
    TotalAmount = sum(`Approved/Declined Amount`, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  arrange(desc(TotalAmount)) %>%
  mutate(
    `% of total occ.`  = Occurrence / sum(Occurrence) * 100,
    `amount_share (%)` = TotalAmount / sum(TotalAmount) * 100
  ) %>% 
  select(Country,Occurrence, `% of total occ.`, TotalAmount,`amount_share (%)`)

kbl(
  head(country_latam_summary, 10),
  format    = "latex",
  align     = "lcccc",
  booktabs  = TRUE,
  linesep   = "",
  digits    = 1,
  escape    = FALSE,
  col.names = c(
    "Country",
    "Occurrence",
    "\\shortstack{\\% of total\\\\occurrence}",
    "\\shortstack{Total amount\\\\(US$ millions)}",
    "\\shortstack{\\% of\\\\total amount}"
  )
) %>%
  kable_styling(latex_options = "hold_position")


# Amount by program in LATAM (Time series)
plot_latam <- exim %>%
  filter(iso2c %in% selected_countries) %>%  
  group_by(`Fiscal Year`,Program) %>% 
  summarise(total_amount=sum(`Approved/Declined Amount`,
                             na.rm=T)) %>%
  mutate(`Fiscal Year` = as.integer(`Fiscal Year`))

latam_totals <- exim %>%
  filter(iso2c %in% selected_countries) %>%
  group_by(`Fiscal Year`) %>%
  summarise(latam_total = sum(`Approved/Declined Amount`, na.rm = TRUE))

world_total <- exim %>%
  group_by(`Fiscal Year`) %>%
  summarise(world_total = sum(`Approved/Declined Amount`, na.rm = TRUE))

share_df <- left_join(latam_totals, world_total, by = "Fiscal Year") %>%
  mutate(share = latam_total / world_total,
     `Fiscal Year` = as.integer(as.character(`Fiscal Year`)))

factor <- max(plot_latam$total_amount) / max(share_df$share)


ggplot() +
  geom_line(data = plot_latam,
            aes(x = `Fiscal Year`, y = total_amount, color = Program, group = Program),
            size = 1) +
  geom_point(data = plot_latam,
             aes(x = `Fiscal Year`, y = total_amount, color = Program),
             size = 2) +
  
  geom_line(
    data = share_df,
    aes(x = `Fiscal Year`, y = share * factor, linetype = "Share LATAM / World"),
    color = "black",
    alpha= 0.3,
    size  = 0.8
  ) +
  
  scale_color_manual(values = program_colors) +
  scale_linetype_manual(
    name   = "", 
    values = c("Share LATAM / World" = "dashed")
  ) +
  scale_x_continuous(breaks = sort(unique(plot_latam$`Fiscal Year`))) +
  scale_y_continuous(
    name    = "Total amount (millions of US$)",
    sec.axis = sec_axis(
      ~ . / factor,
      name   = "Share LATAM / World",
      labels = scales::percent_format(accuracy = 1)
    )
  ) +
  
  guides(
    color    = guide_legend(order = 1),
    linetype = guide_legend(order = 2)
  ) +

  labs(x = "Year", color = "Program") +
  theme_minimal()


# Summary statistics of amount variables in latam
exim %>%
  filter(Decision == "Approved",
         iso2c   %in% selected_countries) %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  group_by(variable) %>%
  summarise(
    Mean   = mean(value,   na.rm = TRUE),
    `Standard deviation`     = sd(value,     na.rm = TRUE),
    Min    = min(value,    na.rm = TRUE),
    median = median(value, na.rm = TRUE),
    max    = max(value,    na.rm = TRUE)
  )  %>% kbl(format    = "latex",
             align     = "lccccc",
             booktabs  = TRUE,
             linesep   = "",
             digits    = 1,
             escape    = FALSE,)


# Distribution by program
boxplots_df <- exim %>%
  filter(
    Decision == "Approved",
    `Approved/Declined Amount` > 0
  ) %>%
  mutate(
    box_region = if_else(
      subregion == "Latin America and the Caribbean",
      "Latin America & Caribbean",
      "Rest of the world"
    )
  )


ggplot(boxplots_df,
       aes(
         x    = fct_reorder(Program, `Approved/Declined Amount`, .fun = median),
         y    = `Approved/Declined Amount` * 1e6,
         fill = box_region
       )
) +
  geom_boxplot() +
  scale_y_log10(
    breaks = 10^(0:9),
    labels = comma
  ) +
  scale_fill_manual(values = c("Latin America & Caribbean" = "#1f78b4",
                               "Rest of the world" = "#33a02c")) +  
  labs(
    x = "Program",
    y = "Approved amount (US$)",
    fill = "Region"
  ) +
  theme_minimal(base_size = 14) +
  theme(legend.position = "bottom")


latam_program_term_summary <- exim %>%
  filter(
    Decision == "Approved",
    iso2c %in% selected_countries,
    !is.na(Term) & Term != "" 
  ) %>%
  group_by(Program, Term) %>%
  summarise(
    TotalAmount = sum(`Approved/Declined Amount`, na.rm = TRUE)
  ) %>%
  ungroup() 

ggplot(latam_program_term_summary, 
       aes(
         x = fct_reorder(Program, TotalAmount, .fun = sum, .desc = TRUE), 
         y = TotalAmount, 
         fill = Term
       )
) +
  geom_col() +
  scale_fill_brewer(palette = "Paired") +
  labs(
    title = "Approved amount in Latin America and the Caribbean by program and term",
    x = "Program",
    y = "Total approved amount (millions of US$)",
    fill = "Term" 
  ) +
  theme_minimal(base_size = 14) +
  theme(
    # axis.text.x = element_text(angle = 45, hjust = 1), # Rotate x-axis labels if they are long
    legend.position = "bottom"
  )



country_summary_map_data <- exim %>%
  filter(Decision == "Approved", iso2c %in% selected_countries) %>%
  group_by(iso3c) %>% 
  summarise(TotalAmount = sum(`Approved/Declined Amount`*1000000, na.rm = TRUE))

world_map <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")

world_map_exim <- world_map %>%
  left_join(country_summary_map_data, by = c("iso_a3_eh" = "iso3c"))

centroids <- st_centroid(world_map_exim) %>% filter(!is.na(TotalAmount)) %>% unique() %>% 
  arrange(desc(TotalAmount)) %>%
  slice(1:10)


ggplot(data = world_map_exim) +
  geom_sf(aes(fill = TotalAmount), color = "white", size = 0.2) +
  geom_label_repel(
    data = centroids,
    aes(
      geometry = geometry,
      label    = iso_a3
    ),
    stat               = "sf_coordinates",
    size               = 3,
    fill               = "white",    # fondo blanco
    color              = "black",    # texto negro
    label.padding      = unit(0.1, "lines"),
    label.size         = 0.2,
    min.segment.length = 0
  ) +
  coord_sf(xlim = c(-150, -30), ylim = c(-55, 35), expand = FALSE) +
  scale_fill_distiller(
    palette   = "YlGnBu",
    direction = 1,
    trans     = "log10",
    na.value  = "grey90",
    labels    = scales::comma
  ) +
  labs(
    #title = "Total approved amount in Latin America and the Caribbean",
    fill  = "Amount (US$)"
  ) +
  theme_void() +
  theme(legend.position = "right")

# Top lenders
top_lenders_amt <- exim %>%
  filter(Decision == "Approved",iso2c %in% selected_countries) %>%
  group_by(`Primary Exporter`) %>%
  summarise(TotalAmount = sum(`Approved/Declined Amount`, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(Share=TotalAmount/sum(TotalAmount,na.rm=T)*100) %>% 
  arrange(desc(TotalAmount)) %>%
  slice(1:10) %>%
  mutate(Rank = row_number())

#Top 10 Primary Borrowers 
top_borrowers_amt <- exim %>%
  filter(Decision == "Approved",iso2c %in% selected_countries) %>%
  group_by(`Primary Borrower`) %>%
  summarise(TotalAmount = sum(`Approved/Declined Amount`, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(Share=TotalAmount/sum(TotalAmount,na.rm=T)*100) %>% 
  arrange(desc(TotalAmount)) %>%
  slice(1:10) %>%
  mutate(Rank = row_number())


# Combined table
combined_amt <- top_lenders_amt %>%
  select(Rank, Exporter = `Primary Exporter`, Lender_USDm = TotalAmount,Share) %>%
  cbind(
    top_borrowers_amt %>%
      select(Rank,Borrower = `Primary Borrower`, Borrower_USDm = TotalAmount,Share)
  )

k_combined_amt <- kbl(
  combined_amt,
  format    = "latex",
  booktabs  = TRUE,
  linesep   = "",
  digits    = 1,
  col.names = c("Rank", "Primary exporter", "Amount financed (millions of US$)",
                "Share of the total (\\%)", "Rank",
                "Primary borrower", "Amount financed (millions of US$ )",
                "Share of the total (\\%)")
) %>%
  kable_styling(latex_options = "hold_position")

### Trade and TF --------------------------------------------------------------
exim_cty <- exim %>%
  filter(Decision=="Approved") %>%
  mutate(year = as.integer(`Fiscal Year`)) %>%    
  group_by(iso2c, year,subregion) %>%
  summarise(EXIM_amount = sum(`Approved/Declined Amount`), .groups="drop")

exim_panel <- exim_cty %>%
  left_join(usa_imp, by = c("iso2c" = "iso2_imp", "year")) %>% 
  mutate(
    exim_share_US    = EXIM_amount / M_from_US,
  ) %>% filter(subregion=="Latin America and the Caribbean")


# Top countries by share of TF over imports from US in the complete period
rank_df <- exim_panel %>%
  filter(!iso2c %in% ofc_iso2_imf) %>% 
  group_by(iso2c,importer) %>%
  summarise(EXIM = sum(EXIM_amount, na.rm = TRUE),
            M_us = sum(M_from_US,   na.rm = TRUE)) %>%
  filter(M_us > 0) %>%
  mutate(sh = EXIM / M_us) %>%
  slice_max(sh, n = 10) %>%
  arrange(sh)

ggplot(rank_df, aes(x = sh, y = reorder(importer, sh), size = M_us)) +
  geom_point(alpha = .7) +
  scale_x_continuous(labels = scales::percent) +
  scale_size_continuous(labels = label_number()) +
  labs(x = "Exim amount / Imports from US", 
       y = NULL, 
       size = "Imports from US \n(millions of US$)") +
  theme_minimal()


# 
pen_panel <- exim_panel %>%
  mutate(share = if_else(M_from_US > 0, EXIM_amount / M_from_US, NA_real_)) %>%
  group_by(iso2c) %>%
  filter(any(share > 0, na.rm = TRUE),!is.na(importer)) %>%  
  ungroup()

ggplot(pen_panel,
       aes(year, share, group = importer, color = importer)) +
  geom_line(linewidth = .8, alpha=.8) +
  geom_point() +
  facet_wrap(~importer, scales="free_y") +
  scale_y_continuous(labels=scales::percent) +
  labs(x=NULL, y="EXIM / Imports from US", color=NULL) +
  theme_minimal(base_size=12) + theme(legend.position="none")


ggplot(pen_panel, aes(year, fct_reorder(iso2c, -M_from_US, .fun=sum), fill = share)) +
  geom_tile() +
  scale_fill_viridis_c(labels=scales::percent) +
  labs(x=NULL, y=NULL, fill="EXIM amount / imports from US ") +
  theme_minimal()


# 
# latam_prog <- exim %>%
#   filter(Decision=="Approved", iso2c %in% selected_countries) %>%
#   mutate(year = as.integer(`Fiscal Year`)) %>%
#   group_by(iso2c, Program) %>%
#   summarise(amt = sum(`Approved/Declined Amount`, na.rm=TRUE), .groups="drop") %>%
#   group_by(iso2c) %>% mutate(share = amt/sum(amt)) %>% ungroup()
# 
# ggplot(latam_prog, aes(x = fct_reorder(iso2c, -amt, .fun=sum),
#                        y = share, fill = Program)) +
#   geom_col() +
#   scale_y_continuous(labels=scales::percent) +
#   labs(x=NULL, y="Program share in EXIM", fill="Program") +
#   theme_minimal() + theme(legend.position="bottom")


map_df <- exim_panel %>%
  group_by(iso2c) %>%
  summarise(share = sum(EXIM_amount,na.rm=TRUE)/sum(M_from_US,na.rm=TRUE)) %>%
  mutate(iso3c = countrycode(iso2c, "iso2c", "iso3c"))

world_map_exim2 <- world_map %>%
  left_join(map_df, by = c("iso_a3_eh" = "iso3c"))

labs_df <- sf::st_point_on_surface(world_map_exim2) %>%
  dplyr::filter(!is.na(share)) %>%
  sf::st_crop(xmin = -150, xmax = -30, ymin = -55, ymax = 35)

ggplot(world_map_exim2) +
  geom_sf(aes(fill = share), color = "white", size = .2) +
  geom_label_repel(
    data  = labs_df,
    aes(geometry = geometry,
        label = paste0(iso_a3, "\n", scales::percent(share, accuracy = 1))),
    stat               = "sf_coordinates",
    size               = 2,
    fill               = "white",
    color              = "black",
    label.padding      = grid::unit(0.1, "lines"),
    label.size         = 0.2,
    min.segment.length = 0
  ) +
  coord_sf(xlim = c(-150, -30), ylim = c(-55, 35), expand = FALSE) +
  scale_fill_viridis_c(labels = scales::percent, na.value = "grey90") +
  labs(fill = "EXIM amount / Imports from US") +
  theme_void() +
  theme(legend.position = "right")


rank_df <- exim_panel %>%
  filter(!iso2c %in% ofc_iso2_imf) %>% 
  summarise(EXIM = sum(EXIM_amount, na.rm = TRUE),
            M_US = sum(M_from_US,   na.rm = TRUE),
            .by = c(iso2c, importer)) %>%
  mutate(share = EXIM / M_US) %>%
  arrange(desc(share))

top5_iso2 <- rank_df %>% slice_head(n = 5) %>% pull(iso2c)

# --- annual time series for Top-5
ts_top5 <- exim_panel %>%
  filter(iso2c %in% top5_iso2) %>%
  mutate(share = if_else(M_from_US > 0, EXIM_amount / M_from_US, NA_real_),
         country = countrycode(iso2c, "iso2c", "country.name")) %>%
  arrange(country, year)

row_ts <- exim_panel %>% 
  mutate(in_top5 = iso2c %in% top5_iso2) %>% 
  group_by(year, in_top5) %>% 
  summarise(EXIM = sum(EXIM_amount, na.rm=TRUE),
            MUS  = sum(M_from_US,  na.rm=TRUE), .groups="drop") %>% 
  filter(!in_top5) %>% 
  transmute(year,
            country = "Rest of world",
            share   = if_else(MUS > 0, EXIM/MUS, NA_real_))

ts_top5_plus <- bind_rows(ts_top5, row_ts) %>% 
  mutate(country = forcats::fct_relevel(country, "Rest of world"))

ts_top5 <- ts_top5 %>%  dplyr::mutate(country = as.factor(country))

levs <- ts_top5 %>%  dplyr::distinct(country) %>%  dplyr::pull(country) %>%  as.character()
base_cols <- setNames(scales::hue_pal()(length(levs)), levs)

cols <- c(base_cols, "Rest of world" = "black")

ts_top5_plus <- dplyr::bind_rows(ts_top5, row_ts) %>% 
  dplyr::mutate(country = forcats::fct_relevel(country, "Rest of world", after = Inf))

ggplot(ts_top5_plus %>% filter(year<=2023), aes(year, share, color = country)) +
  geom_line(linewidth = 0.5) +
  geom_point(size = 1) +
  scale_color_manual(values = cols) +                 
  scale_x_continuous(breaks = scales::pretty_breaks(10)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_y_break(c(0.065, 0.25)) +                     
  labs(x = NULL,
       y = "EXIM approved amounts / Imports from U.S.",
       color = "Country",
       caption = "Note: Y axis with break between 6.5% and 25%") +
  theme_minimal() +
  theme(legend.position = "bottom")



## Bank of international settlemnt ---------------------------------------------
# Locational banking statistics
lbs0 <- fread(paste0(data,"Locational banking statistics.csv"))

lbs <- lbs0 %>%
  rename(
    rep_cty = L_REP_CTY,
    cp_cty  = L_CP_COUNTRY,
    sector  = L_CP_SECTOR,
    instr   = L_INSTR,
    position= L_POSITION,
    measure = Measure
  ) %>%
  filter(
    cp_cty %in% selected_countries,
    rep_cty != "5A",
    measure %in% c(
      "FX and break adjusted change (BIS calculated)",
      "Amounts outstanding / Stocks"
    )
  ) %>%
  select(rep_cty, cp_cty, sector,measure, instr, position, matches("^\\d{4}-Q[1-4]$")) %>%
  pivot_longer(matches("^\\d{4}-Q[1-4]$"), names_to="period", values_to="flow") %>%
  mutate(
    measure = case_when(
      measure == "FX and break adjusted change (BIS calculated)" ~ "chg",
      measure == "Amounts outstanding / Stocks"               ~ "stk"
    ),
    sector = recode(sector, A="As", N="Ns"),
    instr  = recode(instr, A="Ai", G="Gi")
  ) %>%
  pivot_wider(
    id_cols    = c(rep_cty, cp_cty, period),
    names_from = c(measure, sector, instr, position),
    values_from= flow,
    names_sep  = "_",
    values_fill= NA
  ) %>%
  rename(iso2c_i = rep_cty, iso2c_j = cp_cty)


### Exploratory analysis -------------------------------------------------------
regions_i <- regions
colnames(regions_i) <- paste0(colnames(regions_i),"_i")
regions_j <- regions
colnames(regions_j) <- paste0(colnames(regions_j),"_j")

lbs_exp <- lbs %>% left_join(regions_i) %>% left_join(regions_j) %>% 
  select(period,iso2c_i,iso2c_j,chg_Ns_Gi_C,stk_Ns_Gi_C,subregion_i,subregion_j,name_i,name_j) %>% 
  separate(col=period,sep="-",remove=F,into = c("Year","Quarter"))

summary(lbs_exp %>% mutate(across(where(is.character), as.factor)) )

negative_stocks <- lbs_exp %>% filter(stk_Ns_Gi_C < 0)
print("negative values):")
print(negative_stocks)

lbs_exp_clean <- lbs_exp %>%
  filter(stk_Ns_Gi_C >= 0) %>%
  mutate(date = yq(period))

total_stock_over_time <- lbs_exp_clean %>%
  group_by(date) %>%
  summarise(total_stock = sum(stk_Ns_Gi_C, na.rm = TRUE)) %>%
  ungroup()

ggplot(total_stock_over_time, aes(x = date, y = total_stock)) +
  geom_line(color = "blue") +
  geom_point(color = "darkblue", size = 0.8) +
  labs(
    x = "Date",
    y = "Total stock (millions of US$)"
  ) +
  scale_x_date(
    date_breaks = "24 months",       
    date_labels = "%Y-Q",         
    expand = expansion(add = c(0, 0)) 
  ) +
  scale_y_continuous(labels = scales::comma) +
  theme_minimal()


# Maps countries claims counterparts and reporting
latest_period <- max(lbs_exp$period[!is.na(lbs_exp$stk_Ns_Gi_C)])

world_map <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  select(iso_a2, geometry) %>%
  rename(iso2c = iso_a2)


stock_by_reporter <- lbs_exp %>%
  filter(Year %in% c(2024),Quarter=="Q4") %>%
  group_by(iso2c_i) %>%
  summarise(total_stock = sum(stk_Ns_Gi_C, na.rm = TRUE)) %>%
  rename(iso2c = iso2c_i)

map_data_reporter <- left_join(world_map, stock_by_reporter, by = "iso2c") 

ggplot(data = map_data_reporter) +
  geom_sf(aes(fill = total_stock )) + 
  scale_fill_viridis_c(
    option = "plasma", 
    na.value = "grey90",
    name = "Stock of claims \n(millions of US$)", 
    trans = "log10", 
    labels =  label_comma()
  ) +
  labs(
  #  title = "Claims by reporting country",
  #  subtitle = paste("Period:", latest_period)
  ) +
  theme_void()


stock_by_counterpart <- lbs_exp %>%
  filter(Year %in% c(2024),Quarter=="Q4") %>%
  group_by(iso2c_j,name_j) %>% 
  summarise(total_stock = sum(stk_Ns_Gi_C, na.rm = TRUE)) %>%
  rename(iso2c = iso2c_j) 

map_data_counterpart <- left_join(world_map, stock_by_counterpart, by = "iso2c")

top10 <- map_data_counterpart %>%
  filter(!is.na(total_stock)) %>%
  arrange(desc(total_stock)) %>%
  slice_head(n = 10)

centroids <- st_centroid(top10$geometry)
coords <- st_coordinates(centroids)
top10 <- top10 %>%
  mutate(long = coords[,1],
         lat  = coords[,2],
         label = paste0(name_j, "\n", comma(total_stock)))

ggplot(data = map_data_counterpart) +
  geom_sf(aes(fill = total_stock)) + 
  scale_fill_viridis_c(
    option    = "viridis", 
    na.value  = "grey90",
    name      = "Stock of liabilities \n(millions of US$)", 
    trans     = "log10",
    labels    = comma
  ) + 
  coord_sf(xlim = c(-150, -30), ylim = c(-55, 35), expand = FALSE) +
  geom_label_repel(
    data               = top10,
    aes(x = long, y = lat, label = label),
    size               = 3,
    fill               = "white",           
    color              = "black",          
    label.size         = 0.1,                
    label.padding      = unit(0.1, "lines"),
    segment.color      = "grey50",         
    min.segment.length = 0,
    fill               = alpha("white", 0.3),
    max.overlaps       = Inf
  ) +
  labs(
 #   title    = "Claims held against each counterparty country",
 #   subtitle = paste("Also known as liabilities of the counterparty country. Period:", latest_period),
  ) +
  theme_void()


# Table oof countries by group
reporting_countries <- lbs_exp %>%
  filter(!is.na(name_i)) %>%
  summarise(
    countries = paste(sort(unique(name_i)), collapse = ", "),
    count = n_distinct(name_i)
  ) %>%
  mutate(group = "Reporting Countries")

counterpart_countries <- lbs_exp %>%
  filter(!is.na(name_j)) %>%
  summarise(
    countries = paste(sort(unique(name_j)), collapse = ", "),
    count = n_distinct(name_j)
  ) %>%
  mutate(group = "Counterpart Countries")

summary_table <- bind_rows(reporting_countries, counterpart_countries) %>%
  select(group, countries,count)

kable(summary_table,
      format="latex",
      booktabs=T,
      escape=F,
      col.names = c("Group", "Countries", "Number of countries"))



# Relvant counrties by group
# Top reporters
top_reporters <- lbs_exp %>%
  filter(Year %in% c(2019,2020,2021,2022,2023,2024),Quarter=="Q4") %>% 
  select(-Quarter) %>% 
  group_by(name_i,Year) %>%
  summarise(total_stock = sum(stk_Ns_Gi_C, na.rm = TRUE)) %>% 
  ungroup() %>% 
  group_by(name_i) %>% 
  summarise(total_stock = mean(total_stock, na.rm = TRUE)) %>% 
  arrange(desc(total_stock)) %>%
  top_n(10, total_stock)

ggplot(top_reporters, aes(x = total_stock, y = reorder(name_i, total_stock))) +
  geom_col(fill = "skyblue") +
  geom_text(aes(label = scales::comma(round(total_stock))), hjust = -0.1) +
  labs(
 #   title = "Top 10 reporting countries by total stock of deposits and loans to non banking sector",
    x = "Stock (millions of US$)",
    y = "Reporting country"
  ) +
  theme_minimal() +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.15)),
    labels = label_comma() 
  )

# Top 10 Counterpart Countries 
top_counterparts <- lbs_exp %>%
  filter(Year %in% c(2019,2020,2021,2022,2023,2024),Quarter=="Q4") %>% 
  group_by(name_j,Year) %>%
  summarise(total_stock = sum(stk_Ns_Gi_C, na.rm = TRUE)) %>% 
  ungroup() %>% 
  group_by(name_j) %>% 
  summarise(total_stock = mean(total_stock, na.rm = TRUE)) %>% 
  arrange(desc(total_stock)) %>%
  top_n(10, total_stock)

ggplot(top_counterparts, aes(x = total_stock , y = reorder(name_j, total_stock))) +
  geom_col(fill = "salmon") +
  geom_text(aes(label = scales::comma(round(total_stock))), hjust = -0.1) +
  labs(
  #  title = "",
 #   subtitle = paste("Period:", latest_period),
    x = "Stock (millions of US$)",
    y = "Counterpart country"
  ) +
  theme_minimal() +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.15)),
    labels = label_comma() 
  )



# Plots
lbs_exp2 <- lbs_exp %>%
  mutate(
    qtr  = as.yearqtr(period, format = "%Y-Q%q"),
    date = as.Date(qtr)
  ) %>%
  filter(name_j != "Cayman Islands",Year>=2000)

top5 <- lbs_exp2 %>%
  group_by(name_j) %>%
  summarise(tot = sum(stk_Ns_Gi_C, na.rm = TRUE), .groups = "drop") %>%
  slice_max(tot, n = 5, with_ties = FALSE) %>%
  pull(name_j)

ts_top <- lbs_exp2 %>%
  filter(name_j %in% top5) %>%
  group_by(name_j, date) %>%
  summarise(total_stock = sum(stk_Ns_Gi_C, na.rm = TRUE), .groups = "drop")

ord <- ts_top %>% group_by(name_j) %>%
  summarise(last_val = total_stock[which.max(date)], .groups = "drop") %>%
  arrange(desc(last_val)) %>% pull(name_j)
ts_top <- ts_top %>% mutate(name_j = factor(name_j, levels = ord))

year_breaks <- ts_top %>%
  distinct(date) %>%
  mutate(y = year(date)) %>%
  group_by(y) %>%
  summarise(.break = min(date), .groups = "drop") %>%
  pull(.break)


ggplot(ts_top, aes(date, total_stock, color = name_j)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  scale_y_continuous(labels = label_comma()) +
  scale_x_date(breaks = year_breaks, labels = label_date("%Y")) +
  labs(x = NULL, y = "Stock (millions of US$)", color = "Counterpart") +
  theme_minimal() +
  theme(legend.position = "bottom")

### BIS and trade -----------------------------------------------------------------

trade_total_i <- dplyr::bind_rows(
  bilat %>% dplyr::transmute(iso2c_i = iso2_exp, year, X = FOB, M = 0),
  bilat %>% dplyr::transmute(iso2c_i = iso2_imp, year, X = 0,   M = FOB)
) %>%
  dplyr::summarise(
    X_total = sum(X, na.rm = TRUE),
    M_total = sum(M, na.rm = TRUE),
    .by = c(iso2c_i, year)
  ) %>%
  dplyr::mutate(XM_total = X_total + M_total) %>%
  dplyr::left_join(
    regions %>% dplyr::select(iso2c, region_i = region, subregion_i = subregion),
    by = c("iso2c_i" = "iso2c")
  )


lbs_bilat <- lbs_exp_clean %>%
  dplyr::mutate(year = as.integer(substr(period, 1, 4))) %>%
  filter(Quarter=="Q4") %>% 
  dplyr::summarise(
    claims_ij = first(stk_Ns_Gi_C, na.rm = TRUE),
    .by = c(iso2c_i, iso2c_j, year)
  ) %>%
  dplyr::left_join(
    regions %>% dplyr::select(iso2c, region_i = region, subregion_i = subregion),
    by = c("iso2c_i" = "iso2c")
  ) %>%
  dplyr::left_join(
    regions %>% dplyr::select(iso2c, region_j = region, subregion_j = subregion),
    by = c("iso2c_j" = "iso2c")
  ) 

claims_on_j_yr <- lbs_bilat %>%
  dplyr::filter(subregion_j == latam) %>%
  dplyr::summarise(claims_on_j = sum(claims_ij, na.rm = TRUE),
                   .by = c(iso2c_j, year))

# trade of j (X+M) by year
trade_j_yr <- trade_total_i %>%
  dplyr::transmute(iso2c_j = iso2c_i, year, XM_total)

# claims over j / trade of j
ratio_j_yr <- claims_on_j_yr %>%
  dplyr::left_join(trade_j_yr, by = c("iso2c_j","year")) %>%
  dplyr::mutate(ratio = dplyr::if_else(XM_total > 0, claims_on_j / XM_total, NA_real_))


top5_latam <- ratio_j_yr %>%
  group_by(iso2c_j) %>%
  summarise(ratio_total = mean(ratio, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(ratio_total)) %>%
  slice_head(n = 5) %>%
  left_join(regions %>% select(iso2c, name), by = c("iso2c_j" = "iso2c"))

ggplot(top5_latam,
       aes(x = ratio_total, y = reorder(name, ratio_total))) +
  geom_col(fill = "#2C7FB8") +
  geom_text(aes(label = scales::percent(ratio_total, accuracy = 0.1)),
            hjust = -0.1, size = 3) +
  scale_x_continuous(labels = scales::percent,
                     expand = expansion(mult = c(0, .15))) +
  labs(x = "Average of yearly (Claims / X+M)", y = NULL) +
  theme_minimal(base_size = 12)


ratio_ts_top5 <- ratio_j_yr %>%
  filter(iso2c_j %in% top5_latam$iso2c_j) %>%
  left_join(regions %>% select(iso2c, name), by = c("iso2c_j"="iso2c"))

ggplot(ratio_ts_top5,
       aes(x = year, y = ratio, color = name, group = name)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(breaks = scales::pretty_breaks(10)) +
  labs(x = NULL, y = "Claims on country / Total trade (X+M)", color = "Country") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")


# top
top5_imf <- ratio_j_yr %>%
  filter(!(iso2c_j %in% ofc_iso2_imf)) %>%
  left_join(regions %>% dplyr::select(iso2c, name),
                   by = c("iso2c_j" = "iso2c")) %>%
  group_by(iso2c_j, name) %>%
  summarise(ratio_total = mean(ratio, na.rm = TRUE), .groups = "drop") %>%
  arrange(dplyr::desc(ratio_total)) %>%
  slice_head(n = 5)

ggplot(top5_imf,
       aes(x = ratio_total, y = reorder(name, ratio_total))) +
  geom_col(fill = "#2C7FB8") +
  geom_text(aes(label = scales::percent(ratio_total, accuracy = 0.1)),
            hjust = -0.1, size = 3) +
  scale_x_continuous(labels = scales::percent,
                     expand = expansion(mult = c(0, .15))) +
  labs(subtitle = "Excluding offshore financial centers ",x = "Average of yearly (Claims / X+M)", y = NULL) +
  theme_minimal(base_size = 12)

ratio_ts_top_imf <- ratio_j_yr %>%
  dplyr::filter(iso2c_j %in% top5_imf$iso2c_j) %>%
  dplyr::left_join(regions %>% dplyr::select(iso2c, name),
                   by = c("iso2c_j" = "iso2c"))

ggplot(ratio_ts_top_imf %>% filter(year>=2000,year<=2023),
       aes(x = year, y = ratio, color = name, group = name)) +
  geom_line(linewidth = 1) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(breaks = scales::pretty_breaks(10)) +
  labs(x = NULL,
       y = "Claims on country / Total trade (X+M)",
       color = "Country") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")


## FFIEC 009 -------------------------------------------------------------------

### Trade finance column --------------------------------------------------------
files <- list.files(
  path       = file.path(data, "FFIEC 009"), 
  pattern    = "\\.(xls|xlsx)$", 
  full.names = TRUE
)


get_report_date <- function(fpath) {
  sh1 <- excel_sheets(fpath)[1]
  hdr <- read_excel(fpath, sheet = sh1, range = "A1:H12", col_names = FALSE)
  txt <- paste(as.character(unlist(hdr)), collapse = " ")
  rep_str <- str_extract(
    txt,
    "(?i)(period\\s*:\\s*|as\\s*of\\s*)\\s*(January|February|March|April|May|June|July|August|September|October|November|December)\\s+\\d{1,2},?\\s+\\d{4}"
  )
  rep_str <- str_replace(rep_str, "(?i)^(period\\s*:\\s*|as\\s*of\\s*)", "")
  suppressWarnings(mdy(rep_str))
}


read_tf <- function(fpath) {
  sheets <- excel_sheets(fpath)
  sh <- sheets[str_detect(sheets, "All Banks - Table 1")]
  rep_date <- get_report_date(fpath)
  
  df <- read_excel(
    path  = fpath,
    sheet = sh,
    skip  = 7,           
    n_max = Inf           
  ) %>% 
    dplyr::select(
      Country = 1,
      D_UR = matches("^Country\\s*Risk\\s*Claims"),
      UnusedCommitments = matches("^Unused\\s*Commitments$"),
      Guarantees = matches("^Guarantees\\b.*Excluding\\s*Credit\\s*Derivatives\\s*Sold"),
      TradeFinance = matches("^Trade\\s*Finance$")
    ) %>%
    filter(!is.na(Country), Country != "Total") %>% 
    mutate(
      File = basename(fpath),
      Sheet = sh,
      D_UR=as.numeric(D_UR),
      date   = rep_date,
      year   = year(date),
      quarter = quarter(date),
      quarter_id = paste0(year, "Q", quarter)
    )
  
  
  df <- df %>% 
    rename(Country = 1,tf=`TradeFinance`) %>% 
    filter(!is.na(Country) & Country != "Total") 
  
  return(df)
}

all_tf0 <- map_dfr(files, read_tf)

all_tf <- all_tf0 %>% select(-File,-Sheet) %>% 
  mutate(
    Country = Country |>
      as.character() |>
      str_squish() |>
      str_to_lower() |>
      str_to_title(locale = "en"),
    iso3c = countrycode(Country, origin = "country.name", destination = "iso3c", warn = TRUE),
    iso2c= countrycode(Country, origin = "country.name", destination = "iso2c", warn = TRUE),
    iso3c=ifelse(Country=="OTHER LAT. AM. & CAR.","AA",iso3c),
    iso2c=ifelse(Country=="OTHER LAT. AM. & CAR.","AA",iso2c)
  ) %>% filter(Country!="G-10 And Luxembourg",!is.na(iso2c)) %>% 
  left_join(regions) 
  
ffiec_tf <- all_tf %>% 
  filter(iso2c!="AA") %>%
  mutate(
    TF_share_allin = tf / (D_UR + UnusedCommitments + Guarantees), 
    TF_share_onbal = tf / D_UR                                      
  )


ffiec_tf %>%
  group_by(subregion, Country) %>%
  summarise(
    periods = n_distinct(date[!is.na(tf) |
                                !is.na(tf) |
                                !is.na(tf) |
                                !is.na(tf)]),
    .groups = "drop"
  ) %>%
  arrange(subregion, Country) %>%
  group_by(subregion) %>%
  summarise(
    Countries = paste(Country, collapse = ", "),
    n = n_distinct(Country),
    .groups = "drop"
  ) %>% kbl(format="latex",booktabs = T,escape=F,col.names = c("Subregion"," Countries","\\shortstack{Number of\\\\countries}"))



# # Share of trade finance with respect to total claims.
# sub_tfshare_cum <- ffiec_tf %>% filter(subregion==lac_name) %>% 
#   group_by(Country) %>%
#   summarise(
#     TF = sum(tf, na.rm=TRUE),
#     D  = sum(D_UR, na.rm=TRUE),
#     UC = sum(UnusedCommitments, na.rm=TRUE),
#     G  = sum(Guarantees, na.rm=TRUE),
#     .groups="drop"
#   ) %>%
#   mutate(share_allin = TF / (D + UC + G))
# 
# ggplot(sub_tfshare_cum,
#        aes(x=reorder(Country, share_allin), y=share_allin)) +
#   geom_col(width=0.7, fill="#2B8CBE") +
#   coord_flip() +
#   scale_y_continuous(labels=scales::percent_format(accuracy=1)) +
#   labs(x=NULL, y="Cumulative TF share (all-in)",
#        title="Trade finance share by subregion (2015-06-30 to 2024-12-31)") +
#   theme_minimal()


### time series by subregion --------------------------------------------------
lac_name <- "Latin America and the Caribbean"
lac_color <- "#2B8CBE"

sub_ts <- ffiec_tf %>%
  filter(!iso2c %in% c("AA")) %>%
  group_by(subregion, date) %>%
  summarise(tf = sum(tf, na.rm = TRUE), .groups = "drop")


avg_q4 <- ffiec_tf %>% filter(quarter == 4) %>%
  group_by(subregion, date) %>% summarise(tf = sum(tf, na.rm = TRUE), .groups = "drop") %>%
  group_by(subregion) %>% summarise(tf = mean(tf, na.rm = TRUE), .groups = "drop")

top5_sub <- avg_q4 %>% arrange(desc(tf)) %>% slice_head(n = 5) %>% pull(subregion)
top5_sub <- union(top5_sub, lac_name)

cols <- setNames(hue_pal()(length(top5_sub)), top5_sub)
cols[names(cols) == lac_name] <- lac_color


sub_ts_top5 <- sub_ts %>%
  filter(subregion %in% top5_sub) %>%
  mutate(subregion = factor(subregion, levels = top5_sub))

lac_ts <- ffiec_tf %>%
  filter(subregion == lac_name) %>%
  group_by(date) %>%
  summarise(tf = sum(tf, na.rm = TRUE), .groups = "drop") %>%
  mutate(subregion = factor(lac_name, levels = top5_sub))

ggplot() +
  geom_line(data = sub_ts_top5,
            aes(date, tf, color = subregion),
            linewidth = 0.9, alpha = 0.25) +
  geom_line(data = lac_ts,
            aes(date, tf, color = subregion),
            linewidth = 1.1, alpha = 1) +
  scale_color_manual(values = cols, name = NULL) +
  scale_y_continuous(labels = label_number(),n.breaks = 8)+
  labs(x = NULL, y = "Millions of USD",
       title = "") +
  theme_minimal()+
  theme(legend.position = "bottom")


# bars
lac_name  <- "Latin America and the Caribbean"
lac_color <- "#2B8CBE"

annual_tf <- ffiec_tf %>%
  group_by(year, subregion) %>%
  summarise(TF = sum(tf, na.rm = TRUE), .groups = "drop")

sub_order <- annual_tf %>%
  group_by(subregion) %>%
  summarise(TF_tot = sum(TF, na.rm=TRUE), .groups="drop") %>%
  arrange(desc(TF_tot)) %>% pull(subregion)

annual_tf <- annual_tf %>% mutate(subregion = fct_relevel(subregion, sub_order))

subs   <- levels(annual_tf$subregion)
pal    <- setNames(hue_pal()(length(subs)), subs)
pal[names(pal) == lac_name] <- lac_color
alphas <- setNames(rep(0.7, length(subs)), subs)
alphas[names(alphas) == lac_name] <- 1


label_data <- annual_tf %>%
  arrange(year, fct_rev(subregion)) %>%
  group_by(year) %>%
  mutate(
    label_y_pos = cumsum(TF) - 0.5 * TF,
    percentage = TF / sum(TF, na.rm = TRUE)
  ) %>%
  ungroup() %>%
  group_by(year) %>%
  mutate(rank = rank(desc(TF), ties.method = "first")) %>%
  ungroup() %>%
  mutate(
    label_text = if_else(
      rank <= 3,
      percent(percentage, accuracy = 1),
      NA_character_
    )
  )


ggplot(annual_tf, aes(x = factor(year), y = TF,
                      fill = subregion, alpha = subregion)) +
  geom_col() +
  geom_text(
    data = label_data,
    aes(y = label_y_pos, label = label_text),
    color = "white", 
    size = 3.5,
    fontface = "bold"
  ) +
  scale_fill_manual(values = pal, name = NULL) +
  scale_alpha_manual(values = alphas, guide = "none") +
  scale_y_continuous(labels = label_number()) +
  labs(x = NULL, y = "Millions of USD") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")




# Bars by quarter

q_levels <- ffiec_tf %>%
  arrange(date) %>% distinct(quarter_id) %>% pull()

quarter_tf <- ffiec_tf %>%
  mutate(quarter_id = factor(quarter_id, levels = q_levels)) %>%
  group_by(quarter_id, subregion) %>%
  summarise(TF = sum(tf, na.rm = TRUE), .groups = "drop") %>%
  mutate(subregion = fct_relevel(subregion, sub_order))

ggplot(quarter_tf, aes(x = quarter_id, y = TF,
                       fill = subregion, alpha = subregion)) +
  geom_col() +
  scale_fill_manual(values = pal, name = NULL) +
  scale_alpha_manual(values = alphas, guide = "none") +
  labs(x = NULL, y = "Millions of USD",
   #    title = "Trade finance by subregion — quarterly totals (stacked)"
   ) +
  scale_y_continuous(labels = label_number())+
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        axis.text.x = element_text(angle = 90, vjust = 0.5))

### by subregion in LATAM.
agg_cb_period <- ffiec_tf %>%
  group_by(subregion) %>%
  summarise(
    tf = sum(tf, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(c(tf), names_to = "basis", values_to = "value") %>%
  mutate(
    basis   = recode(basis, "tf" = "Trade finance claims"),
    subregion = factor(subregion)
  )

ggplot(agg_cb_period,
       aes(x = value, y = fct_reorder(subregion, value))) +
  geom_col(width = 0.7, fill = "#2B8CBE") +  
  scale_x_continuous(labels = label_number(accuracy = 1,big.mark = " "),
                     n.breaks = 7,
                     expand = expansion(mult = c(0, 0.02))) +
  labs(
    x = "Millions of USD",
    y = NULL,
    # title = paste0("Trade finance to LATAM — ", range_txt)
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.y = element_text(size = 9),
    panel.grid.major.y = element_blank()
  )


### by country in LATAM.
agg_cb_period <- ffiec_tf %>%
  filter(subregion==lac_name,quarter==4) %>% 
  group_by(Country) %>%
  summarise(
    tf = mean(tf, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(c(tf), names_to = "basis", values_to = "value") %>%
  mutate(
    basis   = recode(basis, "tf" = "Trade finance claims"),
    Country = factor(Country)
  )

ggplot(agg_cb_period,
       aes(x = value, y = fct_reorder(Country, value))) +
  geom_col(width = 0.7, fill = "#2B8CBE") +  
  scale_x_continuous(labels = label_number(accuracy = 1,big.mark = " "),
                     n.breaks = 7,
                     expand = expansion(mult = c(0, 0.02))) +
  labs(
    x = "Millions of USD",
    y = NULL,
    # title = paste0("Trade finance to LATAM — ", range_txt)
  ) +
  theme_minimal(base_size = 14) +
  theme(
    axis.text.y = element_text(size = 9),
    panel.grid.major.y = element_blank()
  )


sub_ts <- ffiec_tf %>%
  filter(subregion==lac_name) %>%
  group_by(Country, date) %>%
  summarise(tf = sum(tf, na.rm = TRUE), .groups = "drop")

top5_sub <- sub_ts %>%
  group_by(Country) %>%
  summarise(tot = sum(tf, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(tot)) %>% slice_head(n = 5) %>% pull(Country)
top5_sub <- union(top5_sub, lac_name)

cols <- setNames(hue_pal()(length(top5_sub)), top5_sub)
cols[names(cols) == lac_name] <- lac_color


sub_ts_top5 <- sub_ts %>%
  filter(Country %in% top5_sub) %>%
  mutate(Country = factor(Country, levels = top5_sub))

lac_ts <- ffiec_tf %>%
  filter(Country == lac_name) %>%
  group_by(date) %>%
  summarise(tf = sum(tf, na.rm = TRUE), .groups = "drop") %>%
  mutate(Country = factor(lac_name, levels = top5_sub))

ggplot() +
  geom_line(data = sub_ts_top5,
            aes(date, tf, color = Country),
            linewidth = 0.9, alpha = 1) +
  geom_line(data = lac_ts,
            aes(date, tf, color = Country),
            linewidth = 1.1, alpha = 1) +
  scale_color_manual(values = cols, name = NULL) +
  scale_y_continuous(labels = label_number(),n.breaks = 8)+
  labs(x = NULL, y = "Millions of USD",
       title = "") +
  theme_minimal()+
  theme(legend.position = "bottom")


### FFIEC 009 and trade -----------------------------------------------------------------

trade_tot <- bind_rows(
  bilat %>% transmute(country = exporter, iso2 = iso2_exp, year, XM = FOB),
  bilat %>% transmute(country = importer, iso2 = iso2_imp, year, XM = FOB)
) %>%
  summarise(XM = sum(XM, na.rm = TRUE), .by = c(country, iso2, year))

ffiec_cty <- ffiec_tf %>%
  group_by(iso2c, year) %>%
  slice_max(date, n = 1, with_ties = FALSE) %>%  
  summarise(TF = first(tf), .groups = "drop")

ffiec_ratio_total <- ffiec_cty %>%
  dplyr::left_join(trade_tot, by = c("iso2c"="iso2","year")) %>%
  dplyr::mutate(tf_share_total = dplyr::if_else(XM > 0, TF / XM, NA_real_))

denominator <- "imports_usa"
den_base <- if (denominator == "imports_usa") {
  usa_imp %>%                                 
    transmute(iso2c = iso2_imp, year, XM = M_from_US)
} else {
  trade_tot %>%                                
    transmute(iso2c = iso2, year, XM)
}


# Build ratio and keep LATAM
ratio_cty_year <- ffiec_cty %>%
  inner_join(den_base, by = c("iso2c", "year")) %>%          # align keys
  mutate(tf_share = dplyr::if_else(XM > 0, TF / XM, NA_real_)) %>%
  inner_join(regions %>% dplyr::select(iso2c, subregion), by = "iso2c") %>%
  dplyr::filter(subregion == lac_name)


ratio_full <- ratio_cty_year %>%
  group_by(iso2c) %>%
  summarise(ratio_full = mean(tf_share, na.rm = TRUE), .groups = "drop") %>%
  mutate(iso3c = countrycode(iso2c, "iso2c", "iso3c"))

map_df <- ratio_cty_year %>%
  group_by(iso2c) %>%
  summarise(share = mean(tf_share, na.rm = TRUE), .groups = "drop") %>%
  mutate(iso3c = countrycode(iso2c, "iso2c", "iso3c"))

world_map_ffiec <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  select(iso_a3, iso_a3_eh, geometry) %>%
  left_join(map_df, by = c("iso_a3_eh" = "iso3c")) %>%
  filter(!sf::st_is_empty(geometry)) %>%
  sf::st_make_valid()

# Safe centroids for labels; keep only rows with non-missing share; crop to Americas
labs_df <- sf::st_point_on_surface(world_map_ffiec) %>%
  dplyr::filter(!is.na(share)) %>%
  sf::st_crop(xmin = -150, xmax = -30, ymin = -55, ymax = 35)

# Draw map with legend and labels
ggplot(world_map_ffiec) +
  geom_sf(aes(fill = share), color = "white", linewidth = .2) +
  geom_label_repel(
    data  = labs_df,
    aes(geometry = geometry,
        label = paste0(iso_a3, "\n", scales::percent(share, accuracy = 1))),
    stat               = "sf_coordinates",
    size               = 2,
    fill               = "white",
    color              = "black",
    label.padding      = grid::unit(0.1, "lines"),
    label.size         = 0.2,
    min.segment.length = 0
  ) +
  coord_sf(xlim = c(-150, -30), ylim = c(-55, 35), expand = FALSE) +
  scale_fill_viridis_c(
    labels = scales::percent,
    na.value = "grey90",
    name = if (denominator == "imports_usa") "TF / Imports from U.S." else "TF / (X+M)"
  ) +
  guides(fill = guide_colorbar(title.position = "top")) +
  theme_void() +
  theme(legend.position = "right")


# Top 5 countries by cumulative ratio and their time series
top5_iso2 <- ratio_full %>% filter(!iso2c %in% ofc_iso2_imf) %>% 
  arrange(desc(ratio_full)) %>%
  slice_head(n = 5) %>%
  pull(iso2c)

ts_top5 <- ratio_cty_year %>%
  filter(iso2c %in% top5_iso2,) %>%
  mutate(country = countrycode(iso2c, "iso2c", "country.name")) %>%
  arrange(country, year)

p_ts <- ggplot(ts_top5, aes(x = year, y = tf_share, color = country)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.6) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  labs(
    x = NULL,
    y = if (denominator == "imports_usa") "TF / Imports from U.S." else "TF / (X+M)",
 #   title = "Top 5 LATAM by avg. TF over imports from US"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
p_ts



# plot by subregion
# Compute tf by year and trade by year
tf_q4_sub_yr <- ffiec_tf %>%
  filter(quarter == 4) %>%
  group_by(subregion, year) %>%
  summarise(tf_q4 = sum(tf, na.rm = TRUE), .groups = "drop")

# 2) XM subregion year
xm_sub_yr <- den_base %>%
  inner_join(regions %>% select(iso2c, subregion), by = "iso2c") %>%
  group_by(subregion, year) %>%
  summarise(XM = sum(XM, na.rm = TRUE), .groups = "drop")

#yearly ratio
sub_ratio_yr <- tf_q4_sub_yr %>%
  inner_join(xm_sub_yr, by = c("subregion","year")) %>%
  mutate(tf_share = if_else(XM > 0, tf_q4 / XM, NA_real_))

# Top 5 by the average share in the sample.
top5_sub <- sub_ratio_yr %>%
  group_by(subregion) %>%
  summarise(avg_share = mean(tf_share, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(avg_share)) %>% slice_head(n = 5) %>% pull(subregion) %>%
  union(lac_name)

sub_ratio_top5 <- sub_ratio_yr %>%
  filter(subregion %in% top5_sub) %>%
  mutate(subregion = factor(subregion, levels = top5_sub))


# Split: no-LAC vs LAC
sub_others <- sub_ratio_top5 %>% filter(subregion != lac_name)
sub_lac    <- sub_ratio_top5 %>% filter(subregion == lac_name)


south_name <- "Southern Asia"
sub_south  <- dplyr::filter(sub_ratio_top5, subregion == south_name)

pal_names <- union(top5_sub, south_name)            # asegura que esté "Southern Asia"
cols <- setNames(hue_pal()(length(pal_names)), pal_names)
cols[names(cols) == lac_name] <- lac_color         # color especial para LAC

p_main <- ggplot() +
  geom_line(data = dplyr::filter(sub_others, subregion != south_name),
            aes(year, tf_share, color = subregion, group = subregion),
            linewidth = 0.9, alpha = 0.25) +
  geom_line(data = dplyr::filter(sub_lac, subregion != south_name),
            aes(year, tf_share, color = subregion, group = subregion),
            linewidth = 1.1, alpha = 1) +
  scale_color_manual(values = cols, name = NULL) +
  scale_y_continuous(labels = scales::percent, limits = c(0, 0.13)) +   
  labs(x = NULL, y = if (denominator == "imports_usa") "TF / Imports from U.S." else "TF / (X+M)") +
  theme_minimal() + theme(legend.position = "bottom")

p_inset <- ggplot(sub_south, aes(year, tf_share)) +
  geom_line(linewidth = 0.9, color = cols[[south_name]], alpha = 0.25) +
  scale_y_continuous(labels = scales::percent) +
  labs(x = NULL, y = NULL, title = south_name) +
  theme_minimal(base_size = 8) +
  theme(legend.position = "none",
        plot.title = element_text(size = 8, hjust = 0.5, margin = margin(b=2)))


ggdraw(p_main) +
  draw_plot(p_inset, x = 0.62, y = 0.65, width = 0.35, height = 0.35)  


# plot top 5 subregions with axis modified

south_name <- "Southern Asia"
pal_names  <- union(top5_sub, south_name)

cols <- setNames(hue_pal()(length(pal_names)), pal_names)
cols[names(cols) == lac_name] <- lac_color  # color especial para LAC

plot_df <- sub_ratio_top5 %>%
  filter(subregion %in% pal_names) %>%
  mutate(is_lac = subregion == lac_name)

#  transformation for the axis. from 10% will go faster.
piecewise_trans <- function(cut = 0.10, s = 0.001){
  trans_new("piecewise",
            transform = function(y) ifelse(y <= cut, y, cut + s*(y - cut)),
            inverse   = function(y) ifelse(y <= cut, y, cut + (y - cut)/s)
  )
}

p_main <- ggplot(plot_df,
                 aes(year, tf_share, color = subregion, group = subregion)) +
  geom_line(aes(linewidth = is_lac, alpha = is_lac)) +
  geom_point(aes(size = is_lac, alpha = is_lac)) +
  scale_color_manual(values = cols, name = NULL) +
  scale_alpha_manual(values = c(`FALSE` = 0.35, `TRUE` = 1), guide = "none") +
  scale_linewidth_manual(values = c(`FALSE` = 0.9,  `TRUE` = 1.2), guide = "none") +
  scale_size_manual(values = c(`FALSE` = 1.3, `TRUE` = 1.8), guide = "none") +
  scale_y_continuous(
    trans  = piecewise_trans(cut = 0.10, s = 0.1),
    breaks = c(0, .02, .05, .10, .25, .50),
    labels = percent_format(accuracy = 1),
    expand = expansion(mult = c(0.02, 0.04))
  ) +
  labs(
    x = NULL,
    y = if (denominator == "imports_usa") "TF / Imports from U.S." else "TF / (X+M)",
    caption = "Note: Y-axis compressed above 10%"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

p_main




# plot top 5 latam shares.
ratio_cty_year <- ffiec_tf %>%
  filter(quarter == 4, subregion == lac_name,!iso2c %in% ofc_iso2_imf) %>%
  select(iso2c, Country, year, tf) %>%
  inner_join(den_base, by = c("iso2c","year")) %>%
  mutate(tf_share = if_else(XM > 0, tf / XM, NA_real_))

top5 <- ratio_cty_year %>%
  group_by(Country) %>%
  summarise(avg_share = mean(tf_share, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(avg_share)) %>%
  slice_head(n = 5) %>%
  pull(Country)

ts_top5 <- ratio_cty_year %>%
  filter(Country %in% top5) %>%
  mutate(Country = factor(Country, levels = top5))

cols <- setNames(hue_pal()(length(top5)), top5)

ggplot(ts_top5, aes(year, tf_share, color = Country, group = Country)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.6) +
  scale_color_manual(values = cols, name = NULL) +
  scale_y_continuous(labels = percent) +
  labs(x = NULL,
       y = if (denominator == "imports_usa") "TF / Imports from U.S." else "TF(Q4) / (X+M)") +
  theme_minimal() +
  theme(legend.position = "bottom")


