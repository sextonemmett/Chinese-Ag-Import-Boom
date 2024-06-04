rm(list = ls())
library(tidyverse)

setwd('SET YOUR WD')

exporter_list = c("MAR", "ARG", "BFA", "BGD", "BOL", "BRA", "BWA", "CHL", "CHN", "CMR", "COL",
                  "CRI", "ECU", "EGY", "ETH", "GHA", "HKG", "IDN", "IND", "ISR", "JPN", "KEN",
                  "KHM", "KOR", "LAO", "LKA", "LSO", "MEX", "MMR", "MOZ", "MUS", "MWI", "MYS",
                  "NAM", "NGA", "NPL", "PAK", "PER", "PHL", "RWA", "SEN", "SGP", "THA", "TUN",
                  "TUR", "TWN", "TZA", "UGA", "VNM", "ZAF", "ZMB")

combined_1 = readRDS('./01_Data/R/R_Trade_and_tariffs/combined_1.rds')
combined_2 = readRDS('./01_Data/R/R_Trade_and_tariffs/combined_2.rds')
combined_3 = readRDS('./01_Data/R/R_Trade_and_tariffs/combined_3.rds')
combined_4 = readRDS('./01_Data/R/R_Trade_and_tariffs/combined_4.rds')
combined_5 = readRDS('./01_Data/R/R_Trade_and_tariffs/combined_5.rds')

combined_list = list(combined_1, combined_2, combined_3, combined_4, combined_5)
rm(combined_1, combined_2, combined_3, combined_4, combined_5)
gc()

### Aggregate exports to China ###
ex_list = list()

# Working in batches due to memory constraints
for (i in 1:5) {
  ex_data = combined_list[[i]] %>% 
    filter((i %in% exporter_list) & (j == 'CHN') & !is.na(v)) %>% 
    group_by(i, year) %>% 
    summarize(tot_ex_to_chn = sum(v)) %>% 
    ungroup()
  
  ex_list[[i]] = ex_data
}

tot_exports_to_chn = bind_rows(ex_list)

tot_exports_to_chn = tot_exports_to_chn %>% 
  group_by(i, year) %>% 
  summarize(tot_ex_to_chn = sum(tot_ex_to_chn)) %>% 
  ungroup()

saveRDS(tot_exports_to_chn, file = './01_Data/R/Total exports to China.rds')
gc()

### Total animal and food exports to China ###
ag_ex_list = list()

for (i in 1:5) {
  ag_ex_data = combined_list[[i]] %>% 
    # Filtering to product codes for animal and food
    filter((i %in% exporter_list) & (j == 'CHN') & !is.na(v) & str_detect(product, "^0[1-9]|^1[0-9]|^2[0-4]")) %>% 
    group_by(i, year) %>% 
    summarize(ag_ex_to_chn = sum(v)) %>% 
    ungroup()
  
  ag_ex_list[[i]] = ag_ex_data
}

ag_exports_to_chn = bind_rows(ag_ex_list)

ag_exports_to_chn = ag_exports_to_chn %>% 
  group_by(i, year) %>% 
  summarize(ag_ex_to_chn = sum(ag_ex_to_chn)) %>% 
  ungroup()

saveRDS(ag_exports_to_chn, file = './01_Data/R/Ag exports to China.rds')
gc()

### Product exports in 2001 ###
shr_list = list()

for (i in 1:5) {
  shr_data = combined_list[[i]] %>% 
    filter((i %in% exporter_list) & year == 2001 & !is.na(v)) %>% 
    select(i, year, v, product)
  
  shr_list[[i]] = shr_data
}

product_shares = bind_rows(shr_list)

product_shares = product_shares %>% 
  group_by(i, year, product) %>% 
  summarize(prod_ex_v = sum(v)) %>% 
  ungroup()

saveRDS(product_shares, file = './01_Data/R/Product shares of exports.rds')
gc()

### Country-product level: Chinese tariffs ### 
tariff_list = list()

for (i in 1:5) {
  tariff_data = combined_list[[i]] %>% 
    filter((i %in% exporter_list) & (j == 'CHN')) %>% 
    select(i, year, ADV, Component_ADV, product)
  
  tariff_list[[i]] = tariff_data
}

tariff_data = bind_rows(tariff_list)

saveRDS(tariff_data, file = './01_Data/R/Chinese import tariffs by year.rds')
gc()

### Product level: Chinese tariffs ### 
prod_tar_list = list()

for (i in 1:5) {
  prod_tar_data = combined_list[[i]] %>% 
    filter((j == 'CHN')) %>% 
    select(i, year, ADV, Component_ADV, product)
  
  prod_tar_list[[i]] = prod_tar_data
}

prod_tar_data = bind_rows(prod_tar_list)

saveRDS(prod_tar_data, file = './01_Data/R/All countries - Chinese import tariffs by year.rds')
gc()

