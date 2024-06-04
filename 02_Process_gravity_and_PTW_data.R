rm(list = ls())
library(tidyverse)
library(readxl)

setwd('SET YOUR WD')

# Subset large gravity trade equation file
# Gravity trade data is from CEPII: http://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=8
gravity_raw = read_csv('./01_Data/Gravity.csv')

exporter_list = c("MAR", "ARG", "BFA", "BGD", "BOL", "BRA", "BWA", "CHL", "CHN", "CMR", "COL",
                  "CRI", "ECU", "EGY", "ETH", "GHA", "HKG", "IDN", "IND", "ISR", "JPN", "KEN",
                  "KHM", "KOR", "LAO", "LKA", "LSO", "MEX", "MMR", "MOZ", "MUS", "MWI", "MYS",
                  "NAM", "NGA", "NPL", "PAK", "PER", "PHL", "RWA", "SEN", "SGP", "THA", "TUN",
                  "TUR", "TWN", "TZA", "UGA", "VNM", "ZAF", "ZMB")

gravity_df = gravity_raw %>% 
  filter((iso3_o %in% exporter_list) & iso3_d == 'CHN' & country_exists_o == 1) %>% 
  select(year, iso = iso3_o, distance = dist, population = pop_o, contig=contig, gdp = gdp_o) %>% 
  filter(year > 2000)

saveRDS(gravity_df, file = './01_Data/R/Gravity.rds')
grav = readRDS('./01_Data/R/Gravity.rds')

# Subset PWT: https://www.rug.nl/ggdc/productivity/pwt/?lang=en
pwt_raw = read_excel('./01_Data/PWT.xlsx', sheet = 'Data')

pwt = pwt_raw %>% 
  filter(countrycode %in% exporter_list & year > 2000) %>% 
  mutate(cap_to_gdp = rnna/rgdpna) %>% 
  select(year, iso = countrycode, emp, hum_cap = hc, cap_to_gdp, ctfp)

saveRDS(pwt, file = './01_Data/R/PWT.rds')
