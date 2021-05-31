#call install.packages("readr...etc") to install these
library(readr)
library(dplyr)
library(magrittr)
library(data.tree)
library(reshape2)
library(jsonlite)
library(here)
source(here("config.R"))

ALLEN_HBA_LOCATION

jsonOntology <- fromJSON(here("data", "allen_HBA_small_files", "ontology.json"), simplifyDataFrame = FALSE)

ontologyTree <- as.Node(jsonOntology, mode = "explicit")

#grab the cerebellum and subregions
cerebellum <- FindNode(ontologyTree, "cerebellum")

cerebellum_subregion_list <- cerebellum$Get("id")
cerebellum_subregions <- as_tibble(cbind(names(cerebellum_subregion_list), cerebellum_subregion_list)) %>% rename(name=V1, id = cerebellum_subregion_list)
cerebellum_subregions

folderPattern <- "normalized_microarray.*"
sampleFilename <- "SampleAnnot.csv"
probeFilename <- "Probes.csv"
expressionFilename <- "MicroarrayExpression.csv"

allsampleAnnot = NULL
allExpression = NULL

probeInfo <- read_csv(here("data", "allen_HBA_small_files", "rows_metadata_from_fetal4.csv"))
probeInfo %<>% rename(probe_id = probeset_id, probe_name = probeset_name)

for (donorFolder in list.files(ALLEN_HBA_LOCATION, pattern = folderPattern)) {
  sampleAnnot <- read_csv(paste0(ALLEN_HBA_LOCATION,"/",donorFolder,"/",sampleFilename))
  
  #check if donor has target region
  expressionMatrix <- read_csv(paste0(ALLEN_HBA_LOCATION,"/",donorFolder, "/",expressionFilename), col_names=F) 
  
  expressionMatrix %<>% rename(probe_id = X1)
  dim(expressionMatrix)
  
  strip_left_right <- function(structure_name) {
    tokens <- trimws(unlist(strsplit(structure_name, ",")))
    tokens <- tokens[tokens != "left"]
    tokens <- tokens[tokens != "right"]
    cleaned_name <- paste(tokens, collapse = ", ")
    cleaned_name
  }
  sampleAnnot %<>% rowwise() %>% mutate(structure_name_left_right_stripped = strip_left_right(structure_name))
  sampleAnnot %<>% mutate(donorID = donorFolder)
  sampleAnnot %<>% mutate(uniqueID = paste("ID", structure_id, slab_num, well_id, polygon_id, donorID, sep=".")) %>% select(uniqueID, everything())

  colnames(expressionMatrix) <- c("probe_id", sampleAnnot$uniqueID)
  
  expressionMatrix <- inner_join(probeInfo %>% select(probe_id, probe_name), expressionMatrix) %>% select(-probe_id)
  
  #bind cols of expression matrix
  allExpression <- bind_cols(allExpression, expressionMatrix)
  
  #bind rows of sample annot
  allsampleAnnot <- bind_rows(allsampleAnnot, sampleAnnot)
}

#filter for the cerebellum
allsampleAnnot %<>% filter(structure_id %in% cerebellum_subregions$id)
#print out some statistics on sample counts
allsampleAnnot %>% group_by(structure_name) %>% summarize(n=n()) %>% arrange(-n)
allsampleAnnot %>% group_by(structure_name_left_right_stripped) %>% summarize(n=n()) %>% arrange(-n)

#filter expression for the cerebellum
allExpression %<>% select_(.dots = c("probe_name",allsampleAnnot$uniqueID))

#filter probes without proper names
probeInfo %<>% filter(!grepl("A_", gene_symbol)) %>% filter(!grepl("CUST_", gene_symbol)) 
probeInfo %<>% filter(gene_symbol != "na")

#convert to long form
allExpressionLong <- as_tibble(melt(allExpression))
#merge in information about probes
allExpressionLong <- inner_join(probeInfo %>% select(probe_name, entrez_id, gene_symbol), allExpressionLong)
allExpressionLong %<>% rename(uniqueID = variable)
#merge in information about donors
allExpressionLong <- inner_join(allsampleAnnot %>% select(uniqueID, structure_id, structure_name, structure_name_left_right_stripped, donorID), allExpressionLong)

#summarize probes to genes, might be slow 
allExpressionLong %<>% group_by(uniqueID, gene_symbol) %>% 
  summarize(structure_name = first(structure_name), structure_id = first(structure_id), structure_name_left_right_stripped = first(structure_name_left_right_stripped), 
            donorID = first(donorID), entrez_id = first(entrez_id), expression = mean(value)
  )

#Some regions have few donors - might be dangerous to average across donors
as.data.frame(allExpressionLong %>% select(donorID, structure_name_left_right_stripped) %>% distinct() %>% group_by(structure_name_left_right_stripped) %>% 
  summarize(n=length(unique(donorID))) %>% arrange(-n))

left_right_mapping <- allExpressionLong %>% ungroup() %>% select(structure_name, structure_id, structure_name_left_right_stripped) %>% distinct()

#average to structure_name_left_right_stripped
allExpressionLong %<>% group_by(structure_name_left_right_stripped, gene_symbol) %>% 
  summarize(entrez_id = first(entrez_id), expression = mean(expression))

allExpressionLong <- full_join( left_right_mapping, allExpressionLong)  %>% arrange(structure_name_left_right_stripped,expression)
#then expand to both sides to help with the SVG files (so a left region is averaged across left and right)

as.data.frame(allExpressionLong %>% filter(gene_symbol == "A1CF"))

#write out
write_csv(allExpressionLong, here("data", "processed", "Allen_HBA_long_form.csv"))
