## 2016 preference flow to major parties.
## Data sources
# http://www.aec.gov.au/Elections/federal_elections/Stats_CDRom.htm
# http://results.aec.gov.au/20499/Website/HouseDownloadsMenu-20499-Csv.htm

## Analysis and display
library(ggplot2)
library(reshape2)
library(plyr)

## Function for exporting tables to CSVs. 
##Directory path other than work directory and extension needs to be defined 'x', 'y' is the table to be exported.
file_output <- function (x, y){
  path <- paste(work_dir, x, sep ="")
  write.table(y, file = path, sep = ",", row.names = FALSE)
}

## Setting date
date <- format(Sys.Date(), "%Y%m%d")

## Defining the year for each import.
x <- 2016

## Get working directory path
setwd(paste("C:/data/other-projects/data/firstPreferences/", x, "/preferences/", sep = ""))
electionYear <- x
work_dir <- getwd()

## Data preprocessing for analysis

## Collect the file list
fileListCSV <- list.files(, pattern=".csv$", full.names = TRUE)

## Create a data frame per each csv file.
for (i in 1:(length(fileListCSV)))
{
  listErrors[[i]] <- tryCatch({
    if (i == 1) {
      listRow <- list()
      listErrors <- list()
      outputList <- list()
      wip <- data.frame(NULL)
    }
    
    ## Collect the file name for recording
    name <- fileListCSV[i]
    wip <- read.csv(fileListCSV[i], header = TRUE, skip = 1, sep = ",", fill = TRUE, stringsAsFactors = FALSE, quote = "\"")
    
    ## Labeling rows with source.
    wip$fileName <-  gsub("\\./(.*)\\.csv", "\\1", fileListCSV[i])
    wip$electionYear <- electionYear
    assign(paste(gsub("\\./(.*)\\.csv", "\\1", fileListCSV[i]), ".df", sep = ""), data.frame(wip, check.rows = FALSE))
    
    ## Create a list of the output.
    outputList[[i]] <- assign(paste(gsub("\\./(.*)\\.csv", "\\1", fileListCSV[i]), ".df", sep = ""), data.frame(wip, check.rows = FALSE))
    
    listErrors[[i]] <- i
  }, error = function(e){
    fileListCSV[i]
  })
}

## Create the merged file
wipFinal.df <- do.call("rbind.fill", outputList)
assign(paste("outputList", x, ".df", sep = ""), data.frame(wipFinal.df))

outputListCombine.df <- rbind(outputList2010.df, outputList2013.df, outputList2016.df)

## File exports
# Exporting 
file_output(paste(date, "-electionPreferences.csv", sep = ""), outputListCombine.df)
