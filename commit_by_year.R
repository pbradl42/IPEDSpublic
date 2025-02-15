library(rvest)
library(readxl)
library(tidyverse)
library(data.table)
library(knitr)
library(kableExtra)
library(here)


downloads <- "Downloads"
datadir <- "/raw_data/"

years <- c(1980, 1984:2023)

for(year in years) {
  add_cmd <- paste0("git add ", paste(here(), datadir, year, "*.zip", sep="/"))
  print(add_cmd)
  commit <- paste0("git commit -m \"Fixed SPSS, SAS and STATA files for ", year, "\"")
  print(commit)
  push <- "git push"
  print(push)
}

access_years <- c(2004:2023)
end_year <- as.numeric(substr(access_years, 2,4)) + 1
db_dates <- paste(access_years, end_year, sep="-")
table_dates <- paste(access_years, end_year, sep="")

access_dbs <- paste("IPEDS_", )