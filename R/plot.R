library(tidyverse)
library(here)
library(janitor)

nswgov <- read_csv(here::here("data", "nswgov_daily.csv")) %>%
  clean_names()

nswgov_long <- nswgov %>%
  select(1:27) %>%
  pivot_longer(names_to = "site", values_to = "aqi", 2:27) %>%
  mutate(date = as.Date(dmy(date)),
         year = year(date),
         day = day(date),
         month = month(day),
         day_month = paste(day, month, sep = "-"))

my_site <- "sydney_central_east_raqi_24_hour_index"

today <- Sys.Date() - 10
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


all_summarised <- all %>%
  group_by(day_month) %>%
  summarise(aqi = median(aqi, na.rm = TRUE))


library(ggplot2)

ggplot(data = all, aes(x = aqi)) +
  geom_density(fill = "grey") +
  geom_vline(data = filter(all, date == today - 1), aes(xintercept = aqi), color = "red") +
  geom_vline(aes(xintercept = quantile(aqi, prob = 25/100)), linetype = "dashed") +
  geom_vline(aes(xintercept = quantile(aqi, prob = 50/100)), linetype = "dashed") +
  geom_vline(aes(xintercept = quantile(aqi, prob = 75/100)), linetype = "dashed") +
  theme_bw(base_size = 20) +
  theme(panel.background = element_rect(fill = "transparent", colour = NA),
        panel.grid.minor = element_blank(), panel.grid.major = element_blank(),
        plot.background = element_rect(fill = "transparent", colour = NA),
        panel.border = element_blank(),
        plot.title = element_text(face = "bold",
                                  color = '#333333', size = 18, hjust = 0.5),
        axis.text.x = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold",
                                    size = 16),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  labs(title = paste("Distribution of air quality data for this time of year from 2014 onwards"))
