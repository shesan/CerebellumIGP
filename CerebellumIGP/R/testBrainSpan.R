brainSpan <- function(geneInput) {
library(magrittr)
library(here)
library(dplyr)
library(ggplot2)
library(readr) #for fast table reading

#load functions
source(here("config.R"))

gene_of_interest <- geneInput
useRNAseq <- T
expression <- read_csv(here("data", "processed", "BrainSpan_RNASeq_TRUE_long_form.csv"), guess_max = 1000000)
expression %<>% filter(gene_symbol == gene_of_interest)

#two early datapoints are from the cerebellum and not cortex
as.data.frame(expression %>% select(age, region, AgeRank) %>% distinct() %>% arrange(AgeRank))

agePairs <- expression %>% select(AgeRank, AgeInMonths, donor = donor_id, age) %>% distinct() %>% arrange(AgeRank)
data.frame(agePairs)

if (useRNAseq) {
  yaxisLabel <- "log(Expression)"
} else {
  yaxisLabel <- "Expression"
}

#birth point rank 
birthPoint <- agePairs %>% filter( AgeInMonths > 0) %>% arrange(AgeInMonths) %>% head(1) %>% .$AgeRank - .5
agePairs %>% select(AgeRank)

dotplot1 <- ggplot(data = expression, aes(x=AgeRank, y=expression)) + geom_point() + theme_bw() +
  scale_x_discrete(limits=unique(agePairs$AgeRank), labels=agePairs %>% select(age) %>% distinct() %>% .$age) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  geom_vline(xintercept = birthPoint, color="grey", linetype = "longdash") +
  geom_line(stat="smooth", method="loess") + xlab("") +ylab(yaxisLabel) 

return(dotplot1)

}
