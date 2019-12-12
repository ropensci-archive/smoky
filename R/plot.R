library(tidyverse)
library(here)
library(janitor)

nswgov <- read_csv(here::here("data", "nswgov_daily.csv")) %>%
  clean_names()

nswgov_long <- nswgov %>%
  select(1:27) %>%
  pivot_longer(names_to = "site", values_to = "aqi", 2:27) %>%
  mutate(date = as.Date(dmy(date)),
         year = year(date))

my_site <- "sydney_central_east_raqi_24_hour_index"

today <- Sys.Date()
today_day <- day(today)
today_month <- month(today)
today_year <- year(today)

target_year <- 2014:2019
get_year <- function(target_year) {
  target_date <- as.Date(paste(target_year, today_month, today_day, sep = "-"))
  mysite_data <- nswgov_long %>%
    filter(site == my_site,
           year == target_year,
           date <= (target_date + 7),
           date >= (target_date - 7))
  return(mysite_data)
}
all <- target_year %>% purrr::map_dfr(get_year)




