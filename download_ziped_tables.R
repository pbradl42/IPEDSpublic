library(rvest)
library(readxl)
library(tidyverse)
library(data.table)
library(knitr)
library(kableExtra)
library(here)


downloads <- "Downloads"
datadir <- "/raw_data/"

IPEDSUrl <- ("https://nces.ed.gov/ipeds/datacenter/DataFiles.aspx")
#years <- as.character(c(1961:2009))
#years <- c("2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021")
years <- c(1980, 1984:2023)

source("scrape_ipeds.R")


lapply(years, read_ipeds_table) -> thelist
names(thelist) <- years
lapply(c(1:length(thelist)), wrap_download_zip_file, thelist, years) -> thefiles

clean_up_data <- function(the_year) {
  all_files <- list.files(datadir, pattern=paste0(".*", the_year, ".*\\..*"))
  if(!dir.exists(paste0(here(), datadir, the_year))) {
    dir.create(path=paste0(here(), datadir, the_year))
  } 
  
 # move_file <- function(the_file, the_year) {
 #   file.rename(from=paste0(datadir, the_file), to=paste0(datadir, the_year, "/", the_file))
 # }
  
  #lapply(all_files, move_file, the_year)
}
lapply(years[[1]], clean_up_data) ## This was here to move files that hadn't been correctly placed in their 'year' dirs. It should be necessary anymore