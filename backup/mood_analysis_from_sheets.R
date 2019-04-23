# second version, fetches from google sheets instead of a local .csv

library(tidyverse)
library(googledrive)
library(googlesheets4)

# install.packages("devtools")
# devtools::install_github("tidyverse/googlesheets4")

# library(googledrive)
# drive_find(n_max = 50)
# mood_data <- readr::read_csv("data/mood_journal.csv")

data_sheet_handle <-drive_get("mood_journal")

mood_data <- read_sheet(data_sheet_handle)

summary(mood_data)

# Convert Date strings to datetime
mood_data <- mood_data %>%
  mutate(Date = as.Date(Date))

head(mood_data)


ggplot(data = mood_data) +
  theme_bw() +  
  scale_x_date() + 
  geom_ribbon(aes(x = Date, ymin = Low, ymax = High), fill = "grey85") +
  geom_point(mapping = aes(x = Date, y = Mood)) +
  geom_line(mapping = aes(x = Date, y = Mood)) +
  geom_hline(yintercept=3, linetype="dashed", 
             color = "blue", size=0.5) +
  expand_limits(y=1)

mood_data <- mood_data %>%
  mutate(Any_Exercise = (Exercise > 0))

ggplot(data = mood_data) +
  geom_boxplot(aes(y = Mood, fill=Any_Exercise)) +
  expand_limits(y=1)
