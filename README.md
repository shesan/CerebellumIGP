# Cerebellar spatiotemporal gene expression mapper

by Shesan Govindasamy, Queenie Tsang, and Gayathri Ravindra. Supervised by Leon French, with additional assistance from Derek Howard.

Our R Shiny app produces a total of two products that we can discuss in further detail. These products are indicated by the tabs of our app with each in reference to a dataset we have used to plot gene expression. The first image generated using our program is a SVG sagittal view image using Allen Human Brain Atlas. The Allen HBA dataset consists of temporal gene expression data from six adult brain samples.
This image highlights the cerebrum and cerebellum regions of the brain with only the cerebellum regions highlighted after running the app. The program takes in input of genes present in the dataset which include TTR, BRCA1, or TP53 for example. The image generated includes a legend which corresponds to levels of expression for the gene of interest. Regions highlighted in yellow would have higher expression for the gene while regions highlighted in purple would have lower expression. The legend also indicates expression values in terms of a numeric scale.



![image](https://user-images.githubusercontent.com/1896013/120113601-315ec580-c149-11eb-8f4b-83652a0c5a1d.png)
Fig1. Allen Human Brain Atlas tab results. The A-value displays the SVG file of the mapped expression values from the pre-processed Allen Human Brain Atlas data results.
The B-value displays the expression level gradient as a legend, the colors refers to the SVG map to show the levels of expressions.



In terms of interpreting this data, there are a few methods that this SVG image could be further used for. Our initial design kept neuroscientists and researchers in mind because they were the target audience for our web application. Thus, we predict one will be able to quickly characterize expression patterns using the figure to identify genes with coordinated behavior or it can serve as a reference to cell activity of genes. For instance, generating the SVG for multiple genes, a similar pattern of expression may be observed which could suggest a link between genes. With regard to cell activity, we know that cells are the direct result of gene expression. Therefore, we can compare expression levels of genes in the cerebellum to deviant cell activity to check for possible correlation in the values.
The second product developed using R Shiny was the line plot generated through the use of the BrainSpan dataset. BrainSpan consists of spatial gene expression data for developing human brains (fetal stage to early adulthood). This graph maps the log of the expression level for a particular gene (y-axis) as a function of time (x-axis). Looking at the overall pattern of the line plotted, one can determine points in development with high expression of the gene (regions with peaks) and areas with low expression (regions with troughs). This plot essentially provides a method for identifying expression patterns for genes on a time basis which can provide insight to the relationship that exists between these genes and age-related diseases.



![image](https://user-images.githubusercontent.com/1896013/120113615-46d3ef80-c149-11eb-8e05-18ca734380e9.png)
Fig2. BrainSpan tab results. The A-value shows the generated ggplot of the age correlation to log2Expression levels from the pre-processed BrainSpan results. Generation of the plot takes time and is dependent on your computational power, allow some time to let it plot.


To learn how to use the application, refer to the Cerebellar Spatiotemporal Gene Expression Mapper Technical Documentation.
