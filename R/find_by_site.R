library(readr)

Sys.Date() - 1

my_site <- "sydney_central_east_raqi_24_hour_index"

mysite_data <- nswgov_long %>%
  filter(site == "sydney_central_east_raqi_24_hour_index")

