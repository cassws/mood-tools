library(tidyverse)
library(googledrive)
library(googlesheets4)
library(ggthemr)

function(input, output, session) {
  
  ggthemr('flat dark', layout= 'clean', type='outer')

  # install.packages("devtools")
  # devtools::install_github("tidyverse/googlesheets4")
  
  # library(googledrive)
  # drive_find(n_max = 50)
  # mood_data <- readr::read_csv("data/mood_journal.csv")
  

  
#complete record of mood data (as opposed to data for plotting)
mood_data_full <- reactiveValues(data=setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("Date", "Mood", "High", "Low")))

#stores full or subset of data to generate plots
mood_data_to_plot <- reactiveValues(data=setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("Date", "Mood", "High", "Low")))
    
observeEvent(input$go, {
  data_sheet_handle <-drive_get("mood_journal")
  
  mood_data <- read_sheet(data_sheet_handle)
  
  mood_data <- mood_data %>%
    mutate(Date = as.Date(Date))
  
  mood_data <- mood_data %>%
    mutate(Any_Exercise = (Exercise > 0))
  
  
  mood_data_full$data <- mood_data
  mood_data_to_plot$data <- mood_data
})
  
  
  # Combine the selected variables into a new data frame
#  selectedData <- reactive({
#    iris[, c(input$xcol, input$ycol)]
#    iris[, c("Sepal.Length", "Sepal.Width")]
#    
#      })
  
#  clusters <- reactive({
#    kmeans(selectedData(), input$clusters)
#  })
  
  
#output$bigmoodplot <- renderPlot(outPlot)

output$big_mood_plot <- renderPlot({
  print("is this still running?")
  print(mood_data_to_plot$data)
  ggplot(data = mood_data_to_plot$data) +
    scale_x_date() + 
    theme(text = element_text(size=16)) +
    geom_ribbon(aes(x = Date, ymin = Low, ymax = High), alpha=0.45) +
    geom_point(mapping = aes(x = Date, y = Mood), size = 5, color = 'white', alpha = 0.3) +
    geom_line(mapping = aes(x = Date, y = Mood), colour = 'white', size=1.5) +
    geom_hline(yintercept=3, 
               alpha = 0.9, size=1) +
    expand_limits(y=1)
}, execOnResize = TRUE)

#  output$plot1 <- renderPlot({
#    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
#              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
#    
#    par(mar = c(5.1, 4.1, 0, 1))
#    plot(selectedData(),
#         col = clusters()$cluster,
#         pch = 20, cex = 3)
#    points(clusters()$centers, pch = 4, cex = 4, lwd = 4)
#  })
  
}

