library(tidyverse)
mood_data <- readr::read_csv("data/mood_journal.csv")
summary(mood_data)


# Convert Date strings to datetime
#mood_data <- mood_data %>%
#  mutate(Date = parse_date(Date, "%m/%d/%Y") )

mood_data <- mood_data %>%
  mutate(Date = as.Date(Date, "%m/%d/%Y") )

head(mood_data)


# gathered_mood_data <- mood_data %>%
  gather(key="Type", value="Value", Mood, High, Low) %>%
  select(Date, Type, Value)


# date_labels behaving weirdly...
  
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
