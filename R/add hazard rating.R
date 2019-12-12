library(tidyverse)
library(here)

#read percentile data data

aqi <- read_csv(here("data", "aqi_percentile_joined.csv"))

# add categories from epa
# very good, moderate, poor, very poor, hazardous

aqi_cat <- aqi %>%
        mutate(category = case_when(between(aqi, 0, 33) ~ "Very Good", 
                             between(aqi, 34, 66) ~ "Good", 
                            between(aqi, 67, 99) ~ "Fair", 
                            between(aqi, 100, 149) ~ "Foor",
                            between(aqi, 150, 200) ~ "Very Poor",
                            (aqi > 200 ~ "Hazardous")))

aqi_cat %>% write_csv(here("data", "aqi_percentile_hazard_categories.csv"))     
     