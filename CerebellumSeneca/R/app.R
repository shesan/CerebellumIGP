library(shiny)
library(shinythemes) #*********

ui <- fluidPage(theme = shinytheme("spacelab"), #*********
                titlePanel("Cerebellum Gene Expression"),
                
                sidebarLayout(
                  sidebarPanel(
                    h3("Gene Input"), #*********
                    p(strong("Enter gene name (in UPPERCASE): ")), #********
                    textInput("geneInput", label = "", value = ""),
                    actionButton("runScript", "Submit"),
                    br(),
                    br(),
                    p(strong("Authors: "),"Shesan Govindasamy,
                      Queenie Tsang, and Gayathri Ravindra"),
                    p(strong("PI: "), "Leon French - CAMH"),
                    p(strong("Course: "), "BIF 806 - Independent
                      Group Project")
                    ),
                  mainPanel(
                    tabsetPanel(type = "tabs",
                                tabPanel("Allen - Six Adults", 
                                         splitLayout(
                                           imageOutput("plot"), width = 90, height = 100),
                                         plotOutput("legend", width = 100, height = 100)
                                ),
                                tabPanel("BrainSpan",
                                         plotOutput("plot2"))
                    )
                  )
                    ))

require("ggplot2")

server <- function(input, output, session) {
  
  ######################################Working
  output$plot <- renderImage({
    source("testAllenHBA_SVG.R")
    isolate ({
      allenHBA(input$geneInput)
    })
    if(input$runScript) {
      list(src=paste0("results/", input$geneInput, ".svg"),
           width = 500,
           height = 750)
    }
  }, deleteFile = TRUE)
  
  
  output$legend <- renderPlot({
    source("testLegend.r")
    input$runScript
    isolate({
      allenHBALegend(input$geneInput)
    })
    
  })
  
  
  output$plot2 <- renderPlot({
    source("testBrainSpan.R")
    input$runScript
    isolate({
      brainSpan(input$geneInput)
    })
  })
}

shinyApp(ui = ui, server = server)