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

open_zip_file <- function(thefile) {
  if(file.exists(paste(datadir, thefile, sep="/"))) {
    unzip(paste(datadir, thefile, sep="/"), exdir=datadir, list=TRUE) -> filelist
    unzip(paste(datadir, thefile, sep="/"), exdir=datadir)
    return(filelist$Name)
  } else {
    stop("File ", thefile, " cannot be found")
  }
}