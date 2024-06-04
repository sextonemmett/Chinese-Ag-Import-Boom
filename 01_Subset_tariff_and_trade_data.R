rm(list = ls())
library(tidyverse)

setwd('SET YOUR WD')

# Define the folder paths
# Tariff data comes from:
# Orefice, Gianluca; Fontagné, Lionel; Guimbard, Houssein (2024), 
# “Tariff-Based Product-Level Trade Elasticities”, Mendeley Data, V10, doi: 10.17632/wd52cwgw73.10. 
input_folder = "./01_Data/Trade and tariff data"
output_folder = "./01_Data/R/R_Trade_and_tariffs"

# Exporting countries for filtering
exporter_list = c("MAR", "ARG", "BFA", "BGD", "BOL", "BRA", "BWA", "CHL", "CHN", "CMR", "COL",
                   "CRI", "ECU", "EGY", "ETH", "GHA", "HKG", "IDN", "IND", "ISR", "JPN", "KEN",
                   "KHM", "KOR", "LAO", "LKA", "LSO", "MEX", "MMR", "MOZ", "MUS", "MWI", "MYS",
                   "NAM", "NGA", "NPL", "PAK", "PER", "PHL", "RWA", "SEN", "SGP", "THA", "TUN",
                   "TUR", "TWN", "TZA", "UGA", "VNM", "ZAF", "ZMB")

# Subset to China as importer or country from the exporter list and save RDS files for each product file
files = list.files(input_folder, full.names = TRUE, pattern = "\\.csv$")

counter = 0

# Loop through files and filter to bilateral trade flows I'm interested in
for (file in files) {
  
  counter = counter + 1
  print(paste0(counter, ": ", tools::file_path_sans_ext(basename(file))))
  
  data = read.csv(file, sep = ";")
  
  filtered_data = data %>%
    filter(i %in% exporter_list | j == "CHN")
  
  new_filename = paste0(output_folder, "/", tools::file_path_sans_ext(basename(file)), ".rds")
  saveRDS(filtered_data, new_filename)
}

rm(data, filtered_data)
gc()

cat("All files have been processed and saved.")

# Create a master trade and tariff file by combining the files in batches because of memory constraints
setwd('./01_Data/R/R_Trade_and_tariffs')
subset_files = list.files(pattern = "\\.rds$")

subset_1 = subset_files[1:1000] 
subset_2 = subset_files[1001:2000] 
subset_3 = subset_files[2001:3000] 
subset_4 = subset_files[3001:4000] 
subset_5 = subset_files[4001:5052] 

read_rds_and_add_product = function(filename) {

  product_code = sub(".*_([0-9]{6})\\.rds$", "\\1", filename)
  data = readRDS(filename)
  data$product = product_code
  data = data %>% select(i,j,year,v,q,ADV,Component_ADV,DISTW, product)

  return(data)
}

# Combine and save master dataframe in 5 parts, again because of memory constraints on my laptop
combined_1 = do.call(rbind, lapply(subset_1, read_rds_and_add_product))
gc()
saveRDS(combined_1, file = "./combined_1.rds")
rm(combined_1)
gc()

combined_2 = do.call(rbind, lapply(subset_2, read_rds_and_add_product))
gc()
saveRDS(combined_2, file = "./combined_2.rds")
rm(combined_2)
gc()

combined_3 = do.call(rbind, lapply(subset_3, read_rds_and_add_product))
gc()
saveRDS(combined_3, file = "./combined_3.rds")
rm(combined_3)
gc()

combined_4 = do.call(rbind, lapply(subset_4, read_rds_and_add_product))
gc()
saveRDS(combined_4, file = "./combined_4.rds")
rm(combined_4)
gc()

combined_5 = do.call(rbind, lapply(subset_5, read_rds_and_add_product))
gc()
saveRDS(combined_5, file = "./combined_5.rds")
rm(combined_5)
gc()

