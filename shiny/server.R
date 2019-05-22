library(tidyverse)
library(googledrive)
library(googlesheets4)
library(ggthemr)
library(GGally)

# for date formatting
library(scales)
# library(ggwordcloud)

function(input, output, session) {
  
  ggthemr('flat dark', layout= 'minimal', type='outer')
  
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
mood_data_to_plot <- reactiveValues(data=setNames(data.frame(matrix(ncol = 4, nrow = 0)), c("Date", "Mood", "High", "Low")), natureIndicator = "Mood")
    
observeEvent(input$go, {
  data_sheet_handle <-drive_get("mood_journal")
  
  mood_data <- read_sheet(data_sheet_handle)
  
  mood_data <- mood_data %>%
    mutate(Date = as.Date(Date)) %>%
    mutate(Any_Exercise = (Exercise > 0)) %>%
    mutate(Mood_Range = High - Low) %>%
    select(Date, Mood, High, Low, Mood_Range, Exercise, Sleep, Nature, Walk, Internet, Any_Exercise, Notes, Grateful)
  
  
  
  
  mood_data_full$data <- mood_data
  mood_data_to_plot$data <- mood_data
})

observeEvent(input$avg, {
  mood_data_to_plot$data <- mood_data_to_plot$data %>%
    mutate(Mood = (High + Low)/2)
})

observeEvent(input$walk_nature_indicator, {
  mood_data_to_plot$natureIndicator <- input$walk_nature_indicator
})


output$big_mood_plot <- renderPlot({
  print("is this still running?")
  print(mood_data_to_plot$data)
  ggplot(data = mood_data_to_plot$data) +
    scale_x_date(labels = date_format('%a %m-%e'), breaks='1 week') + 
    ylim(1, 5) +
    theme(text = element_text(size=16)) +
    geom_ribbon(aes(x = Date, ymin = Low, ymax = High), alpha=0.45) +
    geom_point(mapping = aes(x = Date, y = Mood), size = 5, color = 'white', alpha = 0.3) +
    geom_line(mapping = aes(x = Date, y = Mood), colour = 'white', size=1.5) +
    geom_hline(yintercept=3, 
               alpha = 0.9, size=1) +
    expand_limits(y=1)
}, execOnResize = TRUE)

output$a_new_plot <- renderPlot({
  ggcorr(mood_data_to_plot$data) +
    theme(text = element_text(size=16))
}, bg="transparent")

output$walk_and_nature <- renderPlot({
  boxplot_data <- mood_data_to_plot$data %>%
    mutate (Walk_and_Nature = paste(Walk, "Walk,", Nature, "Nature"))
  
  
  ggplot(boxplot_data, aes_string(x = "Walk_and_Nature", y = mood_data_to_plot$natureIndicator)) +
    theme(text = element_text(size=16), 
          axis.text.x = element_text(angle = 30, hjust = 1)) +
    geom_boxplot()
  
})

# output$gratitude_plot <- renderPlot({
#   set.seed(42)
#   
#   word_data <- mood_data_to_plot$data %>%
#     mutate(Grateful =  strsplit(gsub('[[:punct:] ]+',' ',Grateful), ' '))
#   
#   ggplot(word_data, aes(label = Grateful)) +
#     geom_text_wordcloud()
# 
# })
output$info <- renderPrint({
  out <- nearPoints(mood_data_to_plot$data, input$user_hover, xvar = "Date", yvar = "Mood", threshold = 15, maxpoints = 1, addDist = TRUE)
  if(nrow(out) > 0) paste(out$Notes,
                          '<br ><br >Sleep: ', out$Sleep, 'hours<br>Nature: ', out$Nature, '<br>Walk: ', out$Walk, '<br>Exercise:', out$Exercise, 'minutes<br>Internet: ', out$Internet, 'minutes')
})

  
}

