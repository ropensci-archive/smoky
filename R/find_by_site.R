library(tidyverse)
library(here)
library(janitor)

nswgov <- read_csv(here::here("data", "nswgov_daily.csv")) %>%
  clean_names()

nswgov_long <- nswgov %>%
  select(1:27) %>%
  pivot_longer(names_to = "site", values_to = "aqi", 2:27)

my_site <- "sydney_central_east_raqi_24_hour_index"

mysite_data <- nswgov_long %>%
  filter(site == my_site)

