## 2016 preference flow to major parties.
## Data sources
# http://www.aec.gov.au/Elections/federal_elections/Stats_CDRom.htm
# http://results.aec.gov.au/20499/Website/HouseDownloadsMenu-20499-Csv.htm

## Analysis and display
library(ggplot2)
library(reshape2)
library(plyr)

library(MASS)
library(ca)
library(FactoMineR)
library(factoextra)

library(smacof)

library(ggbiplot)
library(scales)
library(grid)

library(caret)

## PCA analysis chart function
## https://www.r-bloggers.com/computing-and-visualizing-pca-in-r/
## http://rstudio-pubs-static.s3.amazonaws.com/27823_dbc155ba66444eae9eb0a6bacb36824f.html
pcaCharts <- function(x) {
  x.var <- x$sdev ^ 2
  x.pvar <- x.var/sum(x.var)
  print("proportions of variance:")
  print(x.pvar)
  
  par(mfrow=c(2,2))
  plot(x.pvar,xlab="Principal component", ylab="Proportion of variance explained", ylim=c(0,1), type='b')
  plot(cumsum(x.pvar),xlab="Principal component", ylab="Cumulative Proportion of variance explained", ylim=c(0,1), type='b')
  screeplot(x)
  screeplot(x,type="l")
  par(mfrow=c(1,1))
}

## Function for exporting tables to CSVs. 
##Directory path other than work directory and extension needs to be defined 'x', 'y' is the table to be exported.
file_output <- function (x, y){
  path <- paste(work_dir, x, sep ="")
  write.table(y, file = path, sep = ",", row.names = FALSE)
}

## The summary statistcs by group.
summaryStatistics <- function(x) {
  c(min = min(x), max = max(x), 
    mean = mean(x), median = median(x), 
    std = sd(x))
}

## Setting date
date <- format(Sys.Date(), "%Y%m%d")

## Get working directory path
setwd("C:/data/other-projects/data/firstPreferences/")
work_dir <- getwd()

## Import the pre-processed file produced from dataImport.R
reImport.df <- read.csv("20170129-electionPreferences.csv", stringsAsFactors = FALSE)

## Select the appropriate columns.
preferencesWip.df <- reImport.df
preferencesWip.df$FromCandidatePartyAb <- ifelse(preferencesWip.df$FromCandidatePartyAb == "", paste("FP", preferencesWip.df$ToCandidatePartyAb, sep = " "), preferencesWip.df$FromCandidatePartyAb)
preferencesWip.df <- na.omit(preferencesWip.df)
preferencesWip.df[sapply(preferencesWip.df, is.character)] <- lapply(preferencesWip.df[sapply(preferencesWip.df, is.character)], as.factor)

## Removing first preference columns
preferencesWipExplore.df <- preferencesWip.df[-grep("FP ", preferencesWip.df$FromCandidatePartyAb),]

## Calculating percentages.
## State level
preferencesWipExploreNat.df <- ddply(preferencesWipExplore.df, .(StateAb, ToCandidatePartyAb, electionYear), transform, percentVotesStateTo = TransferCount/sum(TransferCount)*100)

preferencesWipExploreNat.df <- ddply(preferencesWipExplore.df, .(StateAb, FromCandidatePartyAb, electionYear), transform, percentVotesStateFrom = TransferCount/sum(TransferCount)*100)

## National level
preferencesWipExploreState.df <- ddply(preferencesWipExplore.df, .(FromCandidatePartyAb, electionYear), transform, percentVotesOverallFrom = TransferCount/sum(TransferCount)*100)

preferencesWipExploreState.df <- ddply(preferencesWipExplore.df, .(ToCandidatePartyAb, electionYear), transform, percentVotesOverallTo = TransferCount/sum(TransferCount)*100)

## Electorate level
preferencesWipExplore.df <- ddply(preferencesWipExplore.df, .(FromCandidatePartyAb, DivisionNm, electionYear), transform, percentVotesDisctFrom = TransferCount/sum(TransferCount)*100)

preferencesWipExplore.df <- ddply(preferencesWipExplore.df, .(ToCandidatePartyAb, DivisionNm, electionYear), transform, percentVotesDisctTo = TransferCount/sum(TransferCount)*100)

## Exploration of the data set
## Producing plots.
ggplot(preferencesWipExplore.df[which(preferencesWipExplore.df$StateAb=='QLD' & preferencesWipExplore.df$FromCandidatePartyAb=='ON'),], aes(x = DivisionNm, y = percentVotesDisctFrom, fill = ToCandidatePartyAb)) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + facet_grid(electionYear ~ .) + facet_grid(electionYear ~ .) + scale_fill_manual(values=c("#d73027", "#4575b4", "#74add1", "#fee090")) + ggtitle("QLD One Nation Party Two Candidate Preference Flows")

ggplot(preferencesWipExplore.df[which(preferencesWipExplore.df$StateAb=='QLD' & preferencesWipExplore.df$FromCandidatePartyAb=='GRN'),], aes(x = DivisionNm, y = percentVotesDisctFrom, fill = ToCandidatePartyAb)) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + facet_grid(electionYear ~ .) + facet_grid(electionYear ~ .) + scale_fill_manual(values=c("#b2182b","#6a51a3", "#d73027", "#4575b4", "#4575b4","#878787","#ffed00")) + ggtitle("QLD Green Party Two Candidate Preference Flows")

ggplot(preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='ON'),], aes(x = DivisionNm, y = percentVotesDisctFrom, fill = ToCandidatePartyAb)) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + facet_grid(electionYear ~ .) + facet_grid(electionYear ~ .) + scale_fill_manual(values=c("#b2182b","#999999", "#aaaaaa", "#6a51a3", "#4575b4", "#4575b4", "#4575b4","#1a9850","#ffed00")) + ggtitle("National One Nation Party Two Candidate Preference Flows")

ggplot(preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='GRN'),], aes(x = DivisionNm, y = percentVotesDisctFrom, fill = ToCandidatePartyAb)) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + facet_grid(electionYear ~ .) + facet_grid(electionYear ~ .) + scale_fill_manual(values=c("#b2182b","#999999", "#aaaaaa", "#6a51a3", "#d73027", "#4575b4","#4575b4","#4575b4", "#1a9850","#878787","#ffed00","#FF5800")) + ggtitle("National Green Party Two Candidate Preference Flows")

## Average APL share of preferences.
wipGRN.df <- aggregate(percentVotesDisctFrom ~ DivisionNm + electionYear, data = preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='GRN' & preferencesWipExplore.df$ToCandidatePartyAb=='ALP'),], sum)
tapply(wipGRN.df$percentVotesDisctFrom, wipGRN.df$electionYear, summaryStatistics)

ggplot(preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='ON'),], aes(x = DivisionNm, y = percentVotesDisctFrom, fill = ToCandidatePartyAb)) + geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0)) + facet_grid(electionYear ~ .) + facet_grid(electionYear ~ .) + scale_fill_manual(values=c("#b2182b","#999999", "#aaaaaa", "#6a51a3", "#4575b4","#4575b4","#4575b4", "#1a9850","#ffed00","#FF5800")) + ggtitle("One Nation Party Two Candidate Preference Flows")

## Average APL share of preferences.
wipONA.df <- aggregate(percentVotesDisctFrom ~ DivisionNm + electionYear, data = preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='ON' & preferencesWipExplore.df$ToCandidatePartyAb=='ALP'),], sum)
tapply(wipONA.df$percentVotesDisctFrom, wipONA.df$electionYear, summaryStatistics)

## Average LNP/LP share of preferences.
wipONL.df <- aggregate(percentVotesDisctFrom ~ DivisionNm + electionYear, data = preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='ON' & grepl("^LNP|^LNQ|^LP$", preferencesWipExplore.df$ToCandidatePartyAb)),], sum)
tapply(wipONL.df$percentVotesDisctFrom, wipONL.df$electionYear, summaryStatistics)

## Average LNP/LP share of preferences.
wipRL.df <- aggregate(percentVotesDisctFrom ~ DivisionNm + electionYear, data = preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='RUA' & grepl("^LNP|^LNQ|^LP$", preferencesWipExplore.df$ToCandidatePartyAb)),], sum)
tapply(wipRL.df$percentVotesDisctFrom, wipRL.df$electionYear, summaryStatistics)

## Average APL share of preferences.
wipRA.df <- aggregate(percentVotesDisctFrom ~ DivisionNm + electionYear, data = preferencesWipExplore.df[which(preferencesWipExplore.df$FromCandidatePartyAb=='RUA' & preferencesWipExplore.df$ToCandidatePartyAb=='ALP'),], sum)
tapply(wipRA.df$percentVotesDisctFrom, wipRA.df$electionYear, summaryStatistics)

preferencesWipExplore.df[which(grepl("^LNP|^LNQ|^LP$", preferencesWipExplore.df$FromCandidatePartyAb)),]
unique(preferencesWipExplore.df[which(grepl("LDP", preferencesWipExplore.df$FromCandidatePartyAb)),]$FromCandidatePartyNm)

## Electorate level with first preferences
preferencesWipMDS.df <- ddply(preferencesWip.df, .(ToCandidatePartyAb, DivisionNm, electionYear), transform, percentVotesDisctTo = TransferCount/sum(TransferCount)*100)
preferencesWipMDS.df <- ddply(preferencesWipMDS.df, .(FromCandidatePartyAb, DivisionNm, electionYear), transform, percentVotesDisctFrom = TransferCount/sum(TransferCount)*100)
preferencesWipExplore.mds <- preferencesWipMDS.df[c(1,3,7,8,13,14,18,21,22,23)]

preferencesWipExploreAg.mds <- aggregate(cbind(percentVotesDisctFrom, percentVotesDisctTo, TransferCount) ~ ToCandidatePartyAb + FromCandidatePartyAb + DivisionNm + electionYear + StateAb + FromCandidatePartyNm + ToCandidatePartyNm, data = preferencesWipExplore.mds, sum)

## Loading and preparing the data
preferences2016.df <- preferencesWipExploreAg.mds[which(preferencesWipExploreAg.mds$electionYear==2016),]
preferences2016.mds <- preferences2016.df[,c(1,2,8)]
check2016.df <- preferences2016.df[,c(1,2,10)]
check2016.mds <- aggregate(TransferCount ~ FromCandidatePartyAb, data = preferences2016.df, sum)

## Minor parties to exclude
exclude <- check2016.mds[which(check2016.mds$TransferCount < 10000),]$FromCandidatePartyAb
check2016.df <- check2016.df[!(check2016.df$FromCandidatePartyAb %in% exclude),]

## Creating the frame for use in the analysis
preferences2016.ca <- check2016.df[!grepl("^FP ", check2016.df$FromCandidatePartyAb), ]
preferences2016.ca[preferences2016.ca$ToCandidatePartyAb == "LNP",] <- "LP"
preferences2016.ca[preferences2016.ca$FromCandidatePartyAb == "LNP",] <- "LP"
preferences2016.ca$TransferCount <- as.numeric(preferences2016.ca$TransferCount)
preferences2016.ca[is.na(preferences2016.ca)] <- 0

preferences2016ag.ca <- aggregate(TransferCount ~ ToCandidatePartyAb + FromCandidatePartyAb, data = preferences2016.ca, mean)

## Create the data frame for use with the correspondence analysis
correspondencePref.df <- dcast(preferences2016ag.ca, FromCandidatePartyAb ~ ToCandidatePartyAb, sum, value.var = "TransferCount")
rownames(correspondencePref.df) <- paste0("From_", correspondencePref.df$FromCandidatePartyAb)
colnames(correspondencePref.df) <- paste0("To_", colnames(correspondencePref.df))
rowNum <- dim(correspondencePref.df)[1]
colNum <- dim(correspondencePref.df)[2]
correspondencePref.df <- correspondencePref.df[c(1:rowNum),c(2:colNum)]

## PCA Analysis of the data.
# log transform 
correspondencePrefLog.df <- log(correspondencePref.df[,c(1,3,6,7)])
parties.df <- rownames(correspondencePrefLog.df)

## Replacing infinite values with zero
correspondencePrefLog.df <- do.call(data.frame,lapply(correspondencePrefLog.df, function(x) replace(x, is.infinite(x),0)))

# apply PCA - scale. = TRUE is highly 
# advisable, but default is FALSE. 
correspondencePrefLog.pca <- prcomp(correspondencePrefLog.df,
                                    retx = TRUE,
                                    center = TRUE,
                                    scale. = TRUE) 

# print method
print(correspondencePrefLog.pca)

# plot method
plot(correspondencePrefLog.pca, type = "l")

# summary method
summary(correspondencePrefLog.pca)

# Predict PCs
predict(correspondencePrefLog.pca, 
        newdata = tail(correspondencePrefLog.df, 10))

## Stock plots
pcaCharts(correspondencePrefLog.pca)
biplot(correspondencePrefLog.pca, scale = 0, cex = .7)

#library(devtools)
#install_github("ggbiplot", "vqv")

g <- ggbiplot(correspondencePrefLog.pca, obs.scale = 1, var.scale = 1, labels = row.names(correspondencePref.df),
              ellipse = TRUE, 
              circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')
print(g)

trans = preProcess(correspondencePref.df, 
                   method=c("BoxCox", "center", 
                            "scale", "pca"))
PC = predict(trans, correspondencePref.df)

# Retained PCs
head(PC, 3)

## Column cut down.
suppressRow <- grep("From_FP.*", rownames(correspondencePref.df))
suppressCol <- c(2,4,5,8,9)
#correspondencePref.df <- correspondencePref.df[c(1,3,5,6,7,8,9,10)]

## setting values for fit
chisq <- chisq.test(correspondencePref.df)
n <- sum(correspondencePref.df)
chisq

## Total inertia value
chisq$statistic/n

# Removing columns with all zero.
correspondencePref.df <- correspondencePref.df[, !apply(is.na(correspondencePref.df) | correspondencePref.df == 0, 2, all)]
correspondencePref.df <- correspondencePref.df[ rowSums(correspondencePref.df[c(1,5)])!=0, ] 

## Principal intertias table/contingency table
# Performing the analysis using two different packages to ensure that all the data required as per SPSS examples is generated.
#survey.ca <- ca(correspondencePref.df, nd=2, suprow = suppress)
#survey.cac <- CA(correspondencePref.df, ncp = 2, graph = TRUE, row.sup = suppress)
survey.ca <- ca(correspondencePref.df, nd = 3, supcol = suppressCol)
survey.cac <- CA(correspondencePref.df, ncp = 3, graph = TRUE, col.sup = suppressCol)
survey.ca
## Summary statistics. dim contribution figures are not actual percent. Use figures produced later in the process.
base::summary(survey.ca)

## Three dimension plot
plot3d.ca(survey.ca)

## Contribution figures for effect per row/col
# Displayed as percent
survey.cac$row$contrib
survey.cac$col$contrib

## Plot combinations of dimensions.
fviz_ca_biplot(survey.ca, axes = c(1,2), geom="text", arrow = c(FALSE, TRUE))
fviz_ca_biplot(survey.ca, axes = c(1,3), geom="text", arrow = c(FALSE, TRUE))
