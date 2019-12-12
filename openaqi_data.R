source("util_test.R")
library("ropenaq")
library("ggplot2")
library("dplyr")
library("viridis")
library("import")
library("lubridate")
from=seq(as.Date("2014-01-01"), length=72, by="1 month") 
to=seq(as.Date("2014-02-01"), length=72, by="1 month") -1
hourly=data.frame()
for(i in 1:72){
  #from ropenaqi package file util_test.R
  argsList=buildQuery(country = "AU", 
                      parameter = c("pm25"),
                      date_from = from[i],date_to = to[i], 
                      averaging_period =T,limit=10000)
  client <- crul::HttpClient$new(url = "https://api.openaq.org/v1/measurements")
  argsList <- Filter(Negate(is.null), argsList)
  res <- client$get(query = argsList)
  contentPage <- suppressMessages(res$parse())
  # parse the data
  output <- jsonlite::fromJSON(contentPage)
  df=output$results
  ddf=data.frame(df$location,df$parameter,df$value,df$unit,
                 df$country,df$city,"date"=df$date$utc,
                 "averagingPeriod"=df$averagingPeriod$value)
  hourly=rbind(hourly,ddf[which(ddf$averagingPeriod==1),])
}
write.csv(hourly,"hourlydata.csv")

