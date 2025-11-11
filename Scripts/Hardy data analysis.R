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
library(haven)
library(scales)
library(sf)
library(lubridate)
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


# Hardy firm level data --------------------------------------------------------

hfl <- read_dta(paste0(data, "BryanHardy_JMP_FirmData_forMP.dta"))


# Hardy bank level data --------------------------------------------------------

hbl <- read_dta(paste0(data, "BryanHardy_JMP_LoanData_forMP.dta"))


# CCT data ---------------------------------------------------------------------
cct <- read_dta(paste0(data, "HardySaffie_CCT_Data.dta"))






