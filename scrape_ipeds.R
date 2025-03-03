read_ipeds_table <- function(myyear) {
  myURL <- paste(IPEDSUrl, "?year=", myyear, sep="")
  message("Querying IPEDS for ", myyear)
  thepage <- read_html(myURL) %>%
    html_node(".idc_gridview") 
  if(!is.na(thepage)) {
    thetable <- thepage %>%
      html_table()
    write_csv(thetable, file=paste(datadir, "/", myyear, "_data_table.csv", sep=""))
    thelist <- thepage %>%  
      html_nodes("a")
   # junk <- c("Stata", "SPS", "SAS")
  #  match <- paste(paste(paste(junk, ".zip", sep=""), collapse="|"), "FLAGS", sep="|")
   # thelist <- thelist[grepl(match, thelist, ignore.case=TRUE)]
    return(thelist)
  } else {
    message("No page found for ", myyear)
    return(NA)
  }
}

read_year_data_table <- function(myyear) {
  read_csv(paste(datadir, "/", myyear, "_data_table.csv", sep=""))
}
download_zip_file <- function(thenode, theyear, force_reload=FALSE) {

  myhref <- thenode %>% html_attr("href")
  myname <- thenode %>% html_text()
  if(myname == "Dictionary") {
    myname <- gsub("data/", "", myhref)
    myname <- gsub(".zip", "", myname)
  } else if (myname %in% c("SPSS", "SAS", "STATA")) {
    myname <- gsub("data/", "", myhref)
    myname <- gsub(".zip", "", myname)
  } else if (grepl("Data_Stata", myhref)) {
    myname <- gsub("data/", "", myhref)
    myname <- gsub(".zip", "", myname)
  }
  myurl <- paste("https://nces.ed.gov/ipeds/datacenter/", myhref, sep="")
  destfile <- paste(datadir, "/", theyear, "/", myname, ".zip", sep="")
  if(!file.exists(destfile) | force_reload==TRUE) {
    download.file(myurl, destfile)
  }
  return(paste(myname, ".zip", sep=""))
}
wrap_download_zip_file <- function(i, the_node_list, years) {
  lapply(the_node_list[[i]], download_zip_file, years[[i]])
}

open_zip_file <- function(thefile, destdir=datadir) {
  if(file.exists(paste(datadir, thefile, sep="/"))) {
    unzip(paste(datadir, thefile, sep="/"), exdir=destdir, list=TRUE) -> filelist
    unzip(paste(datadir, thefile, sep="/"), exdir=destdir)
    return(filelist$Name)
  } else {
    stop("File ", thefile, " cannot be found")
  }
}

read_meta_data <- function(thefile) {
  if(file.exists(paste(scratch_dir, thefile, sep="/"))) {
    message(thefile)
    if(grepl("html$", thefile)) {
      message("File is html, skipping") 
      return(NA)
    } else {
      thefile_sheets <- excel_sheets(paste(scratch_dir, thefile, sep="/"))
      if(any(grepl("[V-v]arlist", thefile_sheets))) {
        sheet_name <- thefile_sheets[grepl("[V-v]arlist", thefile_sheets)]
        message(". reading ", sheet_name)
        varlist <- read_excel(paste(scratch_dir, thefile, sep="/"), sheet=sheet_name) %>%
          mutate(file = toupper(gsub(".xlsx", "", thefile))) %>% 
          mutate(year = parse_number(file))
      } else {
        varlist <- NA
      }
      if(any(grepl("[I-i]mputation values", thefile_sheets))) {
        sheet_name <- thefile_sheets[grepl("[I-i]mputation values", thefile_sheets)]
        message(". reading ", sheet_name)
        imputationvalues <- read_excel(paste(scratch_dir, thefile, sep="/"), sheet=sheet_name) %>%
          mutate(file = toupper(gsub(".xlsx", "", thefile))) %>%
          mutate(year = parse_number(file)) %>%
          filter(`Code values for item imputation variables Xvarname` != "CodeValue") %>%
          rename("CodeValue"=`Code values for item imputation variables Xvarname`) %>%
          rename("ValueLabel"=`...2`)
      } else {
        imputationvalues <- NA
      }
      if(any(grepl("[F-f]requencies", thefile_sheets))) {
        sheet_name <- thefile_sheets[grepl("[F-f]requencies", thefile_sheets)]
        if(length(sheet_name) > 1) {
          sheet_name <- sheet_name[!grepl("RV$", sheet_name)]
        }
        message(". reading ", sheet_name)
        frequencies <- read_excel(paste(scratch_dir, thefile, sep="/"), sheet=sheet_name) %>%
          mutate(file = toupper(gsub(".xlsx", "", thefile))) %>%
          mutate(year = parse_number(file)) %>%
          mutate(varname = ifelse(varname == "LOCk_OM", toupper(varname), varname))
      } else {
        frequencies <- NA
      }
      return(list("varlist"=varlist, "frequencies"=frequencies, "imputation_values"=imputationvalues))
    }
  } else {
    stop("File ", thefile, " does not exist")
  }
}

read_data_file <- function(thefile, the_dir=datadir) {
  message(thefile)
  if(grepl("zip$", thefile)) {
    file_for_match <- gsub(".zip", "", thefile)
    open_zip_file(thefile) -> thefilecsv
  } else if (grepl("csv$", thefile)) {
    file_for_match <- gsub(".csv", "", thefile)
    thefilecsv <- thefile
  }
  if(length(thefilecsv) > 1) {
    thefilecsv <- thefilecsv[!grepl("_rv", thefilecsv)]
  }
  ## Read file, add year
  thedata <- read_csv(paste(the_dir, thefilecsv, sep="/")) %>%
    mutate(year = parse_number(thefile))  
  
  thevars_byyear <- thevars %>%
    filter(year == parse_number(thefile))
  imputated <- thevars_byyear[toupper(thevars_byyear$imputationvar) %in% colnames(thedata),] %>%
    mutate(imputationvar = toupper(imputationvar))
  if(nrow(imputated) > 0) {
    imputation_table <- imputationvaluesdf %>%
      filter(file==file_for_match)
    imputed_replace <- lapply(imputated$imputationvar, join_imputation, imputation_table, thedata)
    do.call(cbind, imputed_replace) -> to_replace
    theroot <- thedata %>% select(!imputated$imputationvar) 
    thedata <- cbind(theroot, to_replace)
  }
  thedata <- thedata[!duplicated(thedata),]
  return(thedata)
}
join_imputation <- function(imputationvar, imputationtable, thedata) {
  thedata %>%
    rename("CodeValue"=imputationvar) %>%
    left_join(imputationtable, by="CodeValue") %>%
    select(!"CodeValue") %>%
    rename({{imputationvar}}:="ValueLabel") %>%
    select({{imputationvar}})
}
look_for_rv <- function(filename, file_list) {
  if(gsub("\\.", "_rv.", filename) %in% file_list) {
    return(gsub("\\.", "_rv.", filename))
  } else {
    return(filename)
  }
}
get_vars_by_file <- function(filetype, myvars) {
  ## Figure out which vars are in this type of file.
  relevant_vars <- myvars %>% filter(grepl(paste0("^\\^", filetype), file))
  ## Figure out the files
  unlist(datafiles_open) -> datafiles_open_vector
  relevant_files <- datafiles_open_vector[grepl(paste0("^", filetype), datafiles_open_vector, ignore.case=TRUE)]
  ## Take the revised files if they exist
  relevant_files <- sapply(relevant_files, look_for_rv, relevant_files) %>% unique()
  ## read the files
  the_data_list <- lapply(relevant_files, read_data_file, scratch_dir)
  ## bind and select the variables
  full_df <- rbindlist(the_data_list, fill=TRUE) %>%
    select(unique(relevant_vars$varname), year)
  ## return (and write out a csv)
  write_csv(full_df, paste0("full_", filetype, ".csv"))
  return(full_df)
}