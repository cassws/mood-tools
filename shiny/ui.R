library(shinythemes)

fluidPage(theme = shinytheme("readable"),
  headerPanel('Mood tools!'),
  sidebarPanel(
    hr(),
    textInput("mood_sheet_name", "Your journal name (in Drive)", "mood_journal"),
    actionButton("go", "Load data"),
    hr(),
    dateRangeInput("daterange1", "Date range:",
                   start = "2019-04-01",
                   end   = Sys.Date() + 1),
    hr()
  ),
  mainPanel(
    plotOutput('big_mood_plot', click='user_click', brush = 'user_brush', hover = 'user_hover'),
    h4('Changes in mood over time (overall, high, and low per day)'),
    textOutput("info")
  )
)

