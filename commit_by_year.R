library(rvest)
library(readxl)
library(tidyverse)
library(data.table)
library(knitr)
library(kableExtra)
library(here)


downloads <- "Downloads"
datadir <- "raw_data"

years <- c(1980, 1984:2023)

years <- c(1984:2023)
for(year in years) {
  add_cmd <- paste0("git add ", paste(here(), datadir, year, "*.zip", sep="/"))
  system(add_cmd)
  commit <- paste0("git commit -m \"Fixed SPSS, SAS and STATA files for ", year, "\"")
  system(commit)
  push <- "git push"
  system(push)
}

access_years <- c(2004:2023)
end_year <- as.numeric(substr(access_years, 2,4)) + 1
end_year <- sapply(end_year, function(x) ifelse(nchar(x)==1, paste0("0", x), x))

filenames <- data.frame("year"=access_years, "end_year"=end_year)
filenames <- filenames %>%
  mutate(db_dates = paste(access_years, end_year, sep="-")) %>%
  mutate(table_dates = paste(access_years, end_year, sep=""))

move_access_db <- function(i, filenames_df) {
  year <- filenames_df[i,]$year
  source_dir <- "AccessDBs"
  dest_dir <- paste("raw_data", year, sep="/")
  the_db_filename <- paste0("IPEDS_", filenames_df[i,]$db_dates, "_Final.zip")
  the_table_filename <- paste0("IPEDS", filenames_df[i,]$table_dates, "Tablesdoc.xlsx")
  if(file.exists(paste(source_dir, the_db_filename, sep="/")) & !file.exists(paste(dest_dir, the_db_filename, sep="/"))) {
    file.rename(from=paste(source_dir, the_db_filename, sep="/"), to=paste(dest_dir, the_db_filename, sep="/"))
  }
  if(file.exists(paste(source_dir, the_table_filename, sep="/")) & !file.exists(paste(dest_dir, the_table_filename, sep="/"))) {
    file.rename(from=paste(source_dir, the_table_filename, sep="/"), to=paste(dest_dir, the_table_filename, sep="/"))
  }
}

lapply(c(1:nrow(filenames)), move_access_db, filenames)