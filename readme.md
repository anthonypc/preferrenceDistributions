# Analysing Australian Preference Distribution

The following files were used to analysis preference flows in the 2016 Australian federal election and how this places parties relative to each other. Preference data was used for this as it is both easily accessible through the [AEC website](http://www.aec.gov.au/Elections/federal_elections/Stats_CDRom.htm "Official election statistics") and how a person fills out a ballot is fairly certain indication of their preferences.

## dataImport

This file imports the downloaded csv files from a folder where they are saved and produces an interim working file.

## prefernceProcess

This file transforms and filters the data initially processed by dataImport.r and produces exploratory plots and tables. The file also includes PCA and produces a Correspondence Analysis based on the data.