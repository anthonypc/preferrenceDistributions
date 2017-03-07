## Hierachial Cluster Analysis
library(dplyr)
library(plyr)
library(ggplot2)
library(gplots)
library(MASS)
library(colorspace)
library(dendextend)
library(reshape2)
library(cluster) 
library(fpc)

## Function for exporting tables to CSVs. 
##Directory path other than work directory and extension needs to be defined 'x', 'y' is the table to be exported.
file_output <- function (x, y){
  path <- paste(work_dir, x, sep ="")
  write.table(y, file = path, sep = ",", row.names = FALSE)
}

## Get working directory path
setwd("C:/data/other-projects/data/firstPreferences/")
work_dir <- getwd()

## Import the pre-processed file produced from dataImport.R
## Load file.
load.file <- read.csv("20170129-electionPreferences.csv", stringsAsFactors = FALSE)

## File Check
head(load.file)
str(load.file)
dim(load.file)
names(load.file)

## Electorate level with first preferences
load.file$FromCandidatePartyAb <- ifelse(load.file$FromCandidatePartyAb == "", paste("FP", load.file$ToCandidatePartyAb, sep = " "), load.file$FromCandidatePartyAb)
preferenceHC.df <- aggregate(TransferCount ~ ToCandidatePartyAb + FromCandidatePartyAb + DivisionNm + electionYear + StateAb + FromCandidatePartyNm + ToCandidatePartyNm, data = load.file, sum)
preferenceHC.df <- ddply(preferenceHC.df, .(ToCandidatePartyAb, DivisionNm, electionYear), transform, percentVotesDisctTo = TransferCount/sum(TransferCount)*100)
preferenceHC.df <- ddply(preferenceHC.df, .(FromCandidatePartyAb, DivisionNm, electionYear), transform, percentVotesDisctFrom = TransferCount/sum(TransferCount)*100)

## Creating the frame for use in the analysis
preference2016HC.df <- preferenceHC.df[which(preferenceHC.df$electionYear==2016),]

## Minor parties to exclude
check2016ag.df <- aggregate(TransferCount ~ FromCandidatePartyAb, data = preference2016HC.df, sum)
exclude <- check2016ag.df[which(check2016ag.df$TransferCount < 10000),]$FromCandidatePartyAb
preference2016HC.df <- preference2016HC.df[!(preference2016HC.df$FromCandidatePartyAb %in% exclude),]

## Removing first preference columns
preference2016HC.df <- preference2016HC.df[!grepl("^FP ", preference2016HC.df$FromCandidatePartyAb), ]
preference2016HC.df[preference2016HC.df$ToCandidatePartyAb == "LNP",]$ToCandidatePartyAb <- "LP"
preference2016HC.df[preference2016HC.df$FromCandidatePartyAb == "LNP",]$FromCandidatePartyAb <- "LP"

preference2016HC.df$TransferCount <- as.numeric(preference2016HC.df$TransferCount)
preference2016HC.df$percentVotesDisctTo <- as.numeric(preference2016HC.df$percentVotesDisctTo)
preference2016HC.df$percentVotesDisctFrom <- as.numeric(preference2016HC.df$percentVotesDisctFrom)
preference2016HC.df[is.na(preference2016HC.df)] <- 0

preference2016HCag.df <- aggregate(percentVotesDisctFrom ~ ToCandidatePartyAb + FromCandidatePartyAb, data = preference2016HC.df, mean)

## Create the data frame for use with the correspondence analysis
preference2016HCdcast.df <- dcast(preference2016HCag.df, FromCandidatePartyAb ~ ToCandidatePartyAb, sum, value.var = "percentVotesDisctFrom")
rownames(preference2016HCdcast.df) <- paste0("From_", preference2016HCdcast.df$FromCandidatePartyAb)
colnames(preference2016HCdcast.df) <- paste0("To_", colnames(preference2016HCdcast.df))

preference2016KMdcast.df <- dcast(preference2016HCag.df, ToCandidatePartyAb ~ FromCandidatePartyAb, sum, value.var = "percentVotesDisctFrom")
rownames(preference2016KMdcast.df) <- paste0("TO_", preference2016KMdcast.df$ToCandidatePartyAb)
colnames(preference2016KMdcast.df) <- paste0("FROM_", colnames(preference2016KMdcast.df))

## Hierachial Clusting (Unsupervised learning)
x <- preference2016HCdcast.df[c(2,4,7,8)]
#x <- preference2016KMdcast.df[c(2:24)]

# Numeric scaling 
# When working with percentages not relevant
#numCol <- sapply(x, is.numeric)
#x[numCol] <- lapply(x[numCol], scale)

# Determine number of clusters
kmx.df <- x
wss <- (nrow(kmx.df)-1)*sum(apply(x,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(kmx.df, 
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")

# K-Means Cluster Analysis
fit <- kmeans(kmx.df, 3)
# get cluster means 
aggregate(kmx.df,by=list(fit$cluster),FUN=mean)
# append cluster assignment
kmx.df <- data.frame(kmx.df, fit$cluster)

# Cluster Plot against 1st 2 principal components

# vary parameters for most readable graph
clusplot(kmx.df, fit$cluster, color=TRUE, shade=TRUE, 
         labels=2, lines=0)

# Centroid Plot against 1st 2 discriminant functions
plotcluster(kmx.df, fit$cluster)

hcx.df <- x
## Hierachial Clustering
hc.complete <- hclust(dist(hcx.df, method = "euclidean"), method = "complete")
hc.average <- hclust(dist(hcx.df, method = "euclidean"), method = "average")
hc.single <- hclust(dist(hcx.df, method = "euclidean"), method = "single")
hc.ward <- hclust(dist(hcx.df, method = "euclidean"), method = "ward.D")

plot(hc.complete, main = "Complete linkage", xlab = "", sub = "", cex = .9)
rect.hclust(hc.complete, k = 3, border="red")

plot(hc.average , main = "Average linkage", xlab = "", sub = "", cex = .9)
rect.hclust(hc.average, k = 3, border="red")

plot(hc.single , main = "Single linkage", xlab = "", sub = "", cex = .9)
rect.hclust(hc.single, k = 3, border="red")

plot(hc.ward , main = "Ward linkage", xlab = "", sub = "", cex = .9)
rect.hclust(hc.ward, k = 3, border="red")

cluster.complete <- cutree(hc.complete, 3)
table(cluster.complete)
cluster.average <- cutree(hc.average, 3)
table(cluster.average)
cluster.single <- cutree(hc.single, 3)
table(cluster.single)
cluster.ward <- cutree(hc.ward, 3)
table(cluster.ward)

export.df <- preference2016HCdcast.df
export.df$tag <- cutree(hc.ward, 4)

## Summary of variables
lapply(hcx.df, function(x) {
  if (is.numeric(x)) return(summary(x))
  if (is.factor(x)) return(table(x))
})

## https://cran.r-project.org/web/packages/dendextend/vignettes/Cluster_Analysis.html
dend <- as.dendrogram(hc.ward)
dend <- rotate(dend, 1:367)
dend <- color_branches(dend, k=6)
dend <- hang.dendrogram(dend,hang_height=0.1)

plot(dend, 
     main = "Clustered Claiments", 
     horiz =  TRUE,  nodePar = list(cex = .7))

## Preparing the data to be converted to a matrix.
# Define the function for the conversion
#factorNumeric <- function(x){as.numeric(levels(x))[x]}
factorNumeric <- function(x){as.numeric(factor(x))}
# Perform the conversion
facCol <- sapply(hcx.df, is.factor)
hcx.df[,facCol] <- lapply(hcx.df[,facCol], factorNumeric)

# Numeric scaling of the factors
hcx.df[facCol] <- lapply(hcx.df[facCol], scale)

labels_colors(dend) <-
  rainbow_hcl(6)[sort_levels_values(
    as.numeric(export.df$tag)[order.dendrogram(dend)]
  )]

# Heatmap graph
some_col_func <- function(n) rev(colorspace::heat_hcl(n, c = c(200, 60), l = c(60, 200), power = c(2, .2)))
gplots::heatmap.2(as.matrix(hcx.df), 
                  main = "Heatmap for the data set",
                  srtCol = 20,
                  dendrogram = "row",
                  Rowv = dend,
                  labRow = rownames(hcx.df),
                  Colv = "NA", # this to make sure the columns are not ordered
                  trace="none",          
                  #margins =c(5,0.1),      
                  key.xlab = "Scaled Value",
                  denscol = "grey",
                  density.info = "density",
                  #RowSideColors = rev(labels_colors(dend)),    
                  col = some_col_func
)

## Compare
cluster.stats(d, fit1$cluster, hc.ward$cluster)