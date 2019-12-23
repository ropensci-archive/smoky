# this is lizzies code that creates the grid plot from aqi percentile month data

# Helper packages
library(ggplot2)
library(plotly)
library(lubridate)
library(tidyverse)

# Read CSV into R
data <- read_csv(here::here("data", "aqi_percentile_month.csv"))
data$month_lab <- month.abb[data$month]
data$day_of_month <-day(data$date)

#Create Plot
ggplot(data %>% filter(year == "2019", aqi != "NA"), aes(x = day_of_month, y = reorder(month_lab,-month), fill = percent)) +
  geom_tile(color = "white", size = 0.5) +
  geom_text(aes(label = aqi),size=2) +
  scale_fill_gradient(low="white", high="red") +
  ggtitle("Sydney City Air Quality Index for 2019") + 
  xlab("Day of Month") +
  ylab("Month") + 
  labs(fill = "AQI Percentile") +
  theme(legend.position="bottom") +
  scale_x_continuous("Day of Month", labels = as.character(data$day_of_month), breaks = data$day_of_month)

ggsave("grid_plot.png")
