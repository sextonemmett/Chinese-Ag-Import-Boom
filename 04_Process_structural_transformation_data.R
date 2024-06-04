rm(list = ls())
library(tidyverse)
library(readxl)

setwd('SET YOUR WD')

# Load structural transformation outcome variables
# Groningen Growth and Development Centre; UNU-WIDER, 2023, 
# "Economic Transformation Database, February 2021 release", https://doi.org/10.34894/LCH4CA, DataverseNL, V2.
struc_trans = read_xlsx('./01_Data/Economic Transformation.xlsx', sheet = 'Data')
      
struc_trans = struc_trans %>% 
  mutate(agr_pct = Agriculture/Total,
         manuf_pct = Manufacturing/Total) %>% 
  select(iso = cnt, var, year, agr_pct, manuf_pct, flag_war = `War flag`) %>% 
  filter(var %in% c('VA', 'EMP')) %>% 
  pivot_wider(id_cols = c('iso', 'year'), names_from = var, values_from = c('agr_pct', 'manuf_pct', 'flag_war')) %>% 
  select(-flag_war_VA) %>% 
  rename(flag_war = flag_war_EMP)

saveRDS(struc_trans, './01_Data/R/Transformation.rds')
