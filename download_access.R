library(rvest)
library(readxl)
library(tidyverse)
library(data.table)
library(knitr)
library(kableExtra)

downloads <- "Downloads"
datadir <- "Data"

IPEDSUrl <- ("https://nces.ed.gov/ipeds/use-the-data/download-access-database")
#years <- as.character(c(1961:2009))
#years <- c("2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021")
#years <- c(1980, 1984:2024)
source("allegheny_theme.R")
datadir <- "../IPEDS_public/AccessDBs"

download_zip_file <- function(i, the_df) {
  myhref <- the_df[i,]$url
  myurl <- paste("https://nces.ed.gov", myhref, sep="")
  filename <- trimws(the_df[i,]$file)
  destfile <- paste(datadir, "/", filename, ".zip", sep="")
  message("Downloading ", filename)
  if(!file.exists(destfile)) {
    download.file(myurl, destfile)
  }
  return(paste(filename, ".zip", sep=""))
}

the_table <- read_html(IPEDSUrl) %>% html_nodes("table")

all_links <- the_table %>% html_nodes("a")
access_df <- the_table %>% html_table()

url <- all_links %>% html_attr("href")
text <- all_links %>% html_text()

file_df <- data.frame("file"=text, "url"=url)

lapply(c(1:nrow(file_df)), download_zip_file, file_df)

saveRDS(file_df, file="../IPEDS_public/accessDB.RDS")
