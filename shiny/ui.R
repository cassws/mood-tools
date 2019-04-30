library(shinythemes)

fluidPage(theme = shinytheme("readable"),
  headerPanel('Mood tools!'),
  sidebarPanel(
    textInput("mood_sheet_name", "Your journal name (in Drive)", "mood_journal"),
    actionButton("go", "Load data"),
    hr(),
    dateRangeInput("daterange1", "Date range:",
                   start = "2019-04-01",
                   end   = Sys.Date() + 1),
    hr()
  ),
  mainPanel(
    br(),
    h4('Changes in mood over time (overall, high, and low per day)'),
    plotOutput('big_mood_plot', click='user_click', brush = 'user_brush', hover = 'user_hover'),
    br(),
    textOutput("info"),
    
    hr(),
    h4('Correlation matrix for mood data'),
    plotOutput('a_new_plot'),
    br()
  )
)

