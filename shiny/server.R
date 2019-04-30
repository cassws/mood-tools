library(tidyverse)
library(googledrive)
library(googlesheets4)
library(ggthemr)

function(input, output, session) {
  
  ggthemr('flat dark', layout= 'clean', type='outer')
  
  interaction_type <- "none"
  
  observeEvent(input$user_click, print("click"))
  observeEvent(input$user_brush, print("brush"))
  observeEvent(input$user_hover, print("hover"))

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

output$info <- renderPrint({
  out <- nearPoints(mood_data_to_plot$data, input$user_hover, xvar = "Date", yvar = "Mood", threshold = 10, maxpoints = 1, addDist = TRUE)
  if(nrow(out) > 0) out$Notes
})

  
}

