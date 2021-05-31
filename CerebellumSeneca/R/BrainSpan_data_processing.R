library(magrittr)
library(here)
library(dplyr)
library(ggplot2)
library(reshape2)
library(readr) #for fast table reading

#load functions
source(here("R", "BrainSpan_functions.R"))
source(here("config.R"))


useRNAseq <- T

if (useRNAseq) { 
  pathToBrainSpanExpression <- BRAINSPAN_LOCATION_RNASEQ 
} else { 
  pathToBrainSpanExpression <- BRAINSPAN_LOCATION_EXONARRAY 
}
#load expression (slow)
expression <- loadBrainSpanExpression(pathToBrainSpanExpression, doRankTransform = FALSE)
sampleMetaData <- getExpressionColumnData(pathToBrainSpanExpression)
sampleMetaData$uniqueID <- rownames(sampleMetaData)

expression$gene_symbol <- rownames(expression)
expression <- as_tibble(expression) %>% select(gene_symbol, everything())

sampleMetaData <- as_tibble(sampleMetaData)
#filter for cerebellum
sampleMetaData %<>% filter(grepl("cerebell", structure_name))
expression %<>% select_(.dots = c("gene_symbol", quote(sampleMetaData$uniqueID)))
sampleMetaData$AgeRank <- convertToRanksForAge(sampleMetaData$AgeInMonths)

if (useRNAseq) {
  expression %<>% mutate_if(is.double, funs(log(. + 1)))
} else {
}

expression_long_form <- as_tibble(melt(expression)) %>% rename(uniqueID = variable, expression = value)
expression_long_form <- inner_join(sampleMetaData, expression_long_form) 

#add in entrezID
rowLabels <- read_csv(paste0(pathToBrainSpanExpression, "rows_metadata.csv")) %>% select(gene_symbol, entrez_id) %>% distinct()
#pick the first entrez_id if there are conflicts
rowLabels %<>% group_by(gene_symbol) %>% summarize(entrez_id = first(entrez_id))
expression_long_form <- inner_join(expression_long_form, rowLabels, by="gene_symbol") %>% select(gene_symbol, age, region = structure_name, entrez_id, everything())

#write out
write_csv(expression_long_form, here("data", "processed", paste0("BrainSpan_RNASeq_", useRNAseq,"_long_form.csv")))

