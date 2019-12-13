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
library(glue)
library(ggplot2)
library(plotly)



# Read CSV into R
nswgov <- read_csv(here::here("data", "nswgov_daily.csv")) %>%
    clean_names()
percentile <- read_csv(here::here("data", "aqi_percentile_month.csv")) %>%
    clean_names()

nswgov$date <- dmy(nswgov$date)

nswgov_long <- nswgov %>%
    select(1:27) %>%
    gather(key = "site", value = "aqi", 2:27)

nswgov_long$site <- gsub("_raqi_24_hour_index","",nswgov_long$site)
nswgov_long$site <- gsub("_"," ",nswgov_long$site)
nswgov_long$site <- stringr::str_to_title(nswgov_long$site, locale = "en")
regions <- distinct(nswgov_long, site)

percentile$month_lab <- month.abb[percentile$month]
percentile$day_of_month <-day(percentile$date)

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
    htmlOutput(outputId = "quality"),
    
    plotOutput("gridplot"),
    img(src="aqui_nsw.gif", contentType ='image/gif')   
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    yesterdaydata <- reactive({nswgov_long%>%
            filter(date == yesterdaydate, site == input$var)
    })
    
    output$regions<-renderText({
        glue("In  ", input$var, " the AQI yesterday was ", yesterdaydata()$aqi)
    })
    output$quality<-renderText({
        glue("The air quality was ", case_when(yesterdaydata()$level == "Hazardous" ~"<font color=\"#FF0000\"><b>",
                                               yesterdaydata()$level == "Very Poor" ~"<font color=\"#FF0000\"><b>",
                                               yesterdaydata()$level == "Poor" ~"<font color=\"#808080\"><b>",
                                               yesterdaydata()$level == "Fair" ~"<font color=\"#808080\"><b>",
                                               yesterdaydata()$level == "Good" ~"<font color=\"#008000\"><b>",
                                               yesterdaydata()$level == "Very Good" ~"<font color=\"#008000\"><b>"),  
              yesterdaydata()$level,"</b></font>")
    }) 
    
    output$gridplot <- renderPlot({ggplot(percentile %>% filter(year == "2019", aqi != "NA"), aes(x = day_of_month, y = reorder(month_lab,-month), fill = percent)) +
        geom_tile(color = "white", size = 0.35) +
        geom_text(aes(label = aqi),size=2) +
        scale_fill_gradient(low="white", high="red") +
        ggtitle("Sydney City Air Quality Index for 2019") + 
        xlab("Day of Month") +
        ylab("Month") + 
        labs(fill = "AQI Percentile") +
        scale_x_continuous("Day of Month", labels = as.character(percentile$day_of_month), breaks = percentile$day_of_month)
        })
    
   
}

# Run the application 
shinyApp(ui = ui, server = server)
