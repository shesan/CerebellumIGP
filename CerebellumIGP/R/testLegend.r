allenHBALegend <- function(geneInput) {
  library(grid)
  library(cowplot)
  library(ggplot2)
  library(Cairo)
  library(rsvg)
  library(readr)
  library(dplyr)
  library(magrittr)
  library(here)
  library(XML)
  library(viridis)
  source(here("config.R"))
  
  #todo, find slice[s] that contain all the structure_name_left_right_stripped structures
  
  expression <- read_csv(here("data", "processed", "Allen_HBA_long_form.csv"))
  gene_of_interest <- geneInput
  n_of_colors = 200
  expression %<>% filter(gene_symbol == gene_of_interest)
  expression %<>% mutate(expression_scaled = (expression - min(expression)) / (max(expression) - min(expression)))
  expression %<>% mutate(expression_scaled = round(expression_scaled * n_of_colors))
  
  #add color
  color_scale = viridis(n_of_colors+1, alpha = 1)
  expression %<>% mutate(color = color_scale[expression_scaled+1])
  #to get more svg templates run/look at Derek's code at: https://github.com/derekhoward/molecular_AN/blob/master/svg_download.py
  svg <- htmlParse(here("data","allen_HBA_small_files", "2382_112364227.svg"))
  
  #style_of_node  <- "stroke:black;fill:#6d6e70"
  #structure_id_of_node <- 4722
  
  change_colors <- function(node) {
    style_of_node <- xmlAttrs(node)["style"]
    structure_id_of_node <- xmlAttrs(node)["structure_id"]
    match_rows <- expression %>% filter(structure_id == structure_id_of_node) 
    if (nrow(match_rows) > 0) {
      xmlAttrs(node)["style"] <- gsub(pattern="fill:#......", replacement=paste0("fill:", match_rows[1,"color"]), x= style_of_node)
    } else {
      #set to missing value color - #808080?
      xmlAttrs(node)["style"] <- gsub(pattern="fill:#......", replacement="fill:#D0D0D0", x = style_of_node)
    }
  }
  
  xpathSApply(svg, "//path", change_colors)
  
  for_legend <- expression %>% select(color,  Expression = expression, expression_scaled) 
  for_legend 
  
  for_legend_plot <- ggplot(data = for_legend, mapping = aes(x = Expression, y = expression_scaled,fill = Expression)) + 
    geom_tile() + scale_fill_viridis() 
  
  legend <- cowplot::get_legend(for_legend_plot)
  grid.newpage()
  grid.draw(legend)
  legendout <- grid.draw(legend)
  return(legendout)
}


#https://stackoverflow.com/questions/39093777/renderimage-and-svg-in-shiny-app might be useful for rendering it in a shiny app
