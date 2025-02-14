library(knitr)
library(tidyverse)
library(kableExtra)
library(here)

downloads <- "Downloads"
datadir <- ""


years <- c(1980, 1984:2023)
move_file <- function(the_file, the_year) {
  file.rename(from=paste0(the_file), to=paste0(the_year, "/", the_file))
}

get_file_list_from_csv <- function(the_year) {
  the_csv <- paste(the_year, "_data_table.csv", sep="")
  read_csv(paste(here(), the_csv, sep="/")) %>%
    clean_colnames()
}
create_file_name <- function(the_stem) {
  the_file <- paste(the_stem, ".zip", sep="")
  return(the_file)  
}
create_path <- function(the_stem) {
  the_file <- create_file_name(the_stem)
  path <- paste(here(), the_file, sep="/")
  return(path)
}

find_file <- function(the_stem, the_year) {
    if(file.exists(create_path(the_stem))) {
      message(create_file_name(the_stem), " found in Data, moving...")
      move_file(create_file_name(the_stem), the_year)
      return(paste(create_file_name(the_stem), sep="/"))
    } else {
      if(file.exists(paste(here(), the_year, create_file_name(the_stem), sep="/"))) {
        message(create_file_name(the_stem), " already found year archive!")
        return(paste(create_file_name(the_stem), sep="/"))
      } else {
        message(the_stem, " not found!")
        return(NA)
      }
    }
}
dict_files <- function(the_stem, the_year) {
  the_stem_dict <- paste0(the_stem, "_Dict")
  find_file(the_stem_dict, the_year)
}
program_files <- function(program_type, the_stem, the_year) {
  
  if(program_type == "SPSS") { 
    program_type <- "SPS" 
  } else if (program_type == "STATA") { 
    program_type <- "Stata" 
  }
  filename <- paste0(the_stem, "_", program_type)
  the_file <- find_file(filename, the_year)
  if(!is.na(the_file)) {
    to_return <- paste0("<a href=\"", the_file, "\">", program_type, "</a>")
  } else {
    to_return <- program_type
  }
  return(to_return)
}

create_programs_cell <- function(i, file_df) {
  programs <- str_split(file_df[i,]$programs, ",")
  the_stem <- file_df[i,]$data_file
  the_year <- unique(file_df[i,]$year)
  to_return <- sapply(trimws(programs[[1]]), program_files, the_stem, the_year)
  return(paste(to_return, collapse="|"))
}

set_title <- function(the_year) {
  tx  <- readLines(paste(here(), "header.yml", sep="/"))
  tx2  <- gsub(pattern = "year_archive", replace = the_year, x = tx)
#      tx2  <- gsub(pattern = "Departmental", replace = paste("Departmental", target_active, sep="_"), x = tx2)
  writeLines(tx2, con=paste(here(), "year.qmd", sep="/"))
  rest <- readLines(paste(here(), "year_template.qmd", sep="/"))
  write(rest,file=paste(here(), "year.qmd", sep="/"),append=TRUE)
}

clean_up_data <- function(the_year) {
  if(!is.numeric(the_year)) { the_year <- the_year[[1]]}
  file_df <- get_file_list_from_csv(the_year)
  if(!is.data.frame(file_df)) {stop("something has gone wrong!")}
 # if(!dir.exists(paste(here(), "Data", the_year, sep="/"))) {
 #   dir.create(path=paste(here(), "Data", the_year, sep="/"))
 # } 
  file_df$url <- sapply(file_df$data_file, find_file, the_year)
  file_df$staturl <- sapply(file_df$stata_data_file, find_file, the_year)
  file_df$programs <- sapply(c(1:nrow(file_df)), create_programs_cell, file_df)
  file_df$dict <- sapply(file_df$data_file, dict_files, the_year)
  saveRDS(file_df, file="year_file.RDS")
  
  set_title(the_year)
  
  quarto::quarto_render(input=paste(here(), "year_template.qmd", sep="/"), output_format="html", output_file="index.html")
  file.rename("index.html", paste(here(), the_year, "index.html", sep="/"))

  if(dir.exists(paste(here(), the_year, sep="/"))) {
   file.rename(paste(here(), the_year, sep="/"), paste(here(), the_year, sep="/"))
  }
  return(file_df)
  #lapply(all_files, move_file, the_year)
}

lapply(years, clean_up_data) -> the_files_list