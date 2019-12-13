#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(readr))
suppressPackageStartupMessages(library(readxl))
suppressPackageStartupMessages(library(here))
suppressPackageStartupMessages(library(janitor))
suppressPackageStartupMessages(library(lubridate))



nswgov <- read_csv(here::here("data", "nswgov_daily.csv")) %>%
    clean_names()

nswgov$date <- dmy(nswgov$date)

nswgov_long <- nswgov %>%
    select(1:27) %>%
    gather(key = "site", value = "aqi", 2:27)

nswgov_long$site <- gsub("_raqi_24_hour_index","",nswgov_long$site)
nswgov_long$site <- gsub("_"," ",nswgov_long$site)
nswgov_long$site <- stringr::str_to_title(nswgov_long$site, locale = "en")
regions <- distinct(nswgov_long, site)

nswgov_long <- nswgov_long%>%
    mutate(level = case_when(
        aqi %in% c(0:33) ~ "Very Good",
        aqi %in% c(34:66) ~ "Good",
        aqi %in% c(67:99) ~ "Fair",
        aqi %in% c(100:149) ~ "Poor",
        aqi %in% c(150:200) ~ "Very Poor",
        aqi %in% c(201:max(aqi,na.rm=T)) ~ "Hazardous"
    ))

todaydate <- today()
yesterdaydate <- today()-2




# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
 
    selectInput('var',label = 'Is it smoky in:',choices = regions),
        # Show a plot of the generated distribution
    htmlOutput(outputId = "regions"),
    htmlOutput(outputId = "quality")
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    yesterdaydata <- reactive({nswgov_long%>%
            filter(date == yesterdaydate, site == input$var)
    })
    
    output$regions<-renderText({
        paste("You have selected", input$var, "the AQI yesterday was", yesterdaydata()$aqi)
    })
    output$quality<-renderText({
        paste("The air quality was", "<font color=\"#FF0000\"><b>",  yesterdaydata()$level,"</b></font>")
    }) 
    
    
}

# Run the application 
shinyApp(ui = ui, server = server)
