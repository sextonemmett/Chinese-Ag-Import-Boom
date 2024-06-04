rm(list = ls())
library(tidyverse)
library(plm)
library(ggplot2)

setwd('SET YOUR WD')

exporter_list = c("MAR", "ARG", "BFA", "BGD", "BOL", "BRA", "BWA", "CHL", "CHN", "CMR", "COL",
                  "CRI", "ECU", "EGY", "ETH", "GHA", "HKG", "IDN", "IND", "ISR", "JPN", "KEN",
                  "KHM", "KOR", "LAO", "LKA", "LSO", "MEX", "MMR", "MOZ", "MUS", "MWI", "MYS",
                  "NAM", "NGA", "NPL", "PAK", "PER", "PHL", "RWA", "SEN", "SGP", "THA", "TUN",
                  "TUR", "TWN", "TZA", "UGA", "VNM", "ZAF", "ZMB")

### Merge gravity, PWT, and trade and tariff features ###

# Load processed data
gravity = readRDS('./01_Data/R/Gravity.rds')
pwt = readRDS('./01_Data/R/PWT.rds')
tariffs = readRDS('./01_Data/R/Chinese import tariffs by year.rds')
prod_tariffs = readRDS('./01_Data/R/All countries - Chinese import tariffs by year.rds')
prod_exports = readRDS('./01_Data/R/Product shares of exports.rds')
tot_ex_to_chn = readRDS('./01_Data/R/Total exports to China.rds')
ag_ex_to_chn = readRDS('./01_Data/R/Ag exports to China.rds')
struc_trans = readRDS('./01_Data/R/Transformation.rds')

# Merge
df = inner_join(gravity, pwt, by = c('iso', 'year'))
df = inner_join(df, tot_ex_to_chn, by = c('iso' = 'i', 'year'))
df = inner_join(df, ag_ex_to_chn, by = c('iso' = 'i', 'year'))
df = inner_join(df, struc_trans, by = c('iso', 'year'))

avg_tar = prod_tariffs %>% 
  group_by(year, product) %>% 
    summarize(avg_adv = mean(ADV)) %>% 
  ungroup()

prod_exports = prod_exports %>% 
  filter(str_detect(product, "^0[1-9]|^1[0-9]|^2[0-4]")) %>% 
  filter(!str_detect(product, "^1201[0-9][0-9]"))

shift_shr = inner_join(prod_exports, tariffs, by = c('i', 'product'))
shift_shr = left_join(shift_shr, avg_tar, by = c('product', 'year.y' = 'year'))
shift_shr = left_join(shift_shr, gravity %>% select(year, iso, gdp), by = c('i'='iso', 'year.x' = 'year'))

# Define shift share instrument for exogenous tariff reduction measure
shift_shr = shift_shr %>% 
  mutate(prod_ex_shr_gdp = prod_ex_v/(gdp*1000)) %>% 
  mutate(prod_shift = prod_ex_shr_gdp*ADV,
         avg_prod_shift = prod_ex_shr_gdp*avg_adv) %>% 
  group_by(i, year.y) %>% 
    summarize(shift_share = sum(prod_shift),
              avg_shift_share = sum(avg_prod_shift)) %>% 
  ungroup() %>% 
  select(iso = i, year = year.y, shift_share, avg_shift_share) %>% 
  arrange(iso, year)
  
df_reg = inner_join(df, shift_shr, by = c('iso', 'year'))
df_reg = df_reg %>% 
  mutate(pct_ag_chn_gdp = ag_ex_to_chn/(gdp*1000)) %>% 
colSums(is.na(df_reg))

write.csv(df_reg, './01_Data/R/Regression df.csv')




