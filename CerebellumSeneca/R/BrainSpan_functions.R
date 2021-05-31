#read in expression data (exon array expression)
loadBrainSpanExpression <- function(pathToBrainSpanExpression, doRankTransform=TRUE) {
  rowLabels <- read.table(paste0(pathToBrainSpanExpression, "rows_metadata.csv"),header=T,row.names=1,sep=",",stringsAsFactors = F)$gene_symbol
  print("Loading expression, please wait")
  expression <- read_csv(paste0(pathToBrainSpanExpression, "expression_matrix.csv"),col_names=F, progress=T)
  expression <- as.data.frame(expression)
  rownames(expression) <- expression[,1] #probably not needed
  expression[,1] <- NULL
  
  dupRowLabels <- rowLabels[duplicated(rowLabels)]
  correlations <- c()
  dupedIndices <- c()
  if (doRankTransform) {
    expression <- apply(expression,2,rank) #use ranked expression
  }
  
  for(rowLabel in dupRowLabels) {
    locations <- which(rowLabels == rowLabel)
    #most are pefectly correlated except one gene (r = 0.69)
    correlations <- c(correlations, cor(as.numeric(expression[locations[1],]),as.numeric(expression[locations[2],])))
    dupedIndices <- c(dupedIndices, locations[2:length(locations)]) #some have more than one
  }
  rowsBefore <- nrow(expression)
  expression <- expression[-dupedIndices,]
  rowLabels <- rowLabels[-dupedIndices]
  rownames(expression) <- rowLabels #unqiue gene symbols as row names
  print(paste("Duplicate gene symbol rows removed:" ,rowsBefore-nrow(expression)))
  
  columnData <- getExpressionColumnData(pathToBrainSpanExpression)
  colnames(expression) <- rownames(columnData)
  expression
}

#get the meta data associated with the brainspan expression samples
getExpressionColumnData <- function(pathToBrainSpanExpression) {
  #now set the column names using donor and region name
  columnData <- read.table(paste0(pathToBrainSpanExpression, "columns_metadata.csv"),header=T,row.names=1,sep=",",stringsAsFactors = F)
  #update the name of a single region if we are using an old expression dataset (508 samples)
  sum(columnData$structure_name=="posterior (caudal) superior temporal cortex (area TAc)") #count of regions
  columnData[columnData$structure_name=="posterior (caudal) superior temporal cortex (area TAc)", "structure_name"] <- "posterior (caudal) superior temporal cortex (area 22c)"
  
  rownames(columnData) <- paste(columnData$donor_name, "region", columnData$structure_name,sep=".")
  #create age in Months column
  convertAgeToMonths <- function(ageString) {
    ageDigit <- as.numeric(gsub(" .*", "", ageString))
    ageUnit <- gsub(".* ", "", ageString)
    if (ageUnit == "pcw") age <- (ageDigit-70)/12
    if (ageUnit == "yrs") age <- ageDigit*12
    if (ageUnit == "mos") age <- ageDigit
    age
  }
  columnData$AgeInMonths <- sapply(columnData$age, convertAgeToMonths)
  columnData
}


#convert age in months to ranked age values - gives ties the same rank
convertToRanksForAge <- function(ageVariable) {
  monthsToRankedAge <- c(rank(unique(ageVariable)))
  names(monthsToRankedAge) <- unique(ageVariable)
  ageVariableRanked <- monthsToRankedAge[as.character(ageVariable)]
  ageVariableRanked
}

