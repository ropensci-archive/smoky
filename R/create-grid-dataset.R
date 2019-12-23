# Helper packages
library(dplyr)       # for data manipulation
library(ggplot2)     # for data visualization
library(janitor)
library(lubridate)
library(here)
library(tidyverse)



# Read CSV into R
data <- read_csv(here("data", "nswgov_daily.csv"))
                 
# Clean columns
data<- clean_names(data)
# Rename value column
data <- data %>% rename(aqi = sydney_central_east_raqi_24_hour_index) 
# Reduce columns
data_reduced <- select(data,"date","aqi")
#Format as date
data_reduced$date <- as.Date(data_reduced$date, format = "%d/%m/%Y")
#Calculate date stuff
data_reduced$month_of_year <- month(data_reduced$date)
data_reduced$year <- year(data_reduced$date)
data_reduced$day_of_month <- day(data_reduced$date)

# Calculate summary table of percentiles
percentiles <- data_reduced %>%
  group_by(month_of_year) %>%
  summarise(P95 = quantile(aqi, probs = 0.95, na.rm = TRUE),
            P5 = quantile(aqi, probs = 0.05, na.rm = TRUE),
            P20 = quantile(aqi, probs = 0.2, na.rm = TRUE),
            P40 = quantile(aqi, probs = 0.4, na.rm = TRUE),
            P60 = quantile(aqi, probs = 0.6, na.rm = TRUE),
            P80 = quantile(aqi, probs = 0.8, na.rm = TRUE))

# Join percentiles back on
data_joined<-merge(x=data_reduced,y=percentiles,by="month_of_year",all=TRUE)

# Calculate smokiness relative to historical
data_joined <- data_joined %>% 
  mutate(smokiness = case_when(
    .$aqi > .$P95 ~ "7",
    .$aqi <= .$P95 & .$aqi > .$P80 ~ "6",
    .$aqi <= .$P80 & .$aqi > .$P60 ~ "5",
    .$aqi <= .$P60 & .$aqi > .$P40 ~ "4",
    .$aqi <= .$P40 & .$aqi > .$P20 ~ "3",
    .$aqi <= .$P20 & .$aqi > .$P5 ~ "2",
    .$aqi <= .$P5 ~ "1",
    TRUE ~ "other"
  )
  )

data_joined %>% write_csv(here("data", "aqi_percentile_joined.csv"))
          