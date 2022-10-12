
library(lubridate)
library(dplyr)
library(leaflet)
library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(plotly)
library(hydroTSM)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- shinyUI(
  dashboardPage(
    skin = "red",
    
    dashboardHeader(title = "NYC Arrest Shiny App"),
    
    dashboardSidebar(
      sidebarMenu(
        menuItem("Home", tabName = "Home", icon = icon("home")),
        menuItem("Map", tabName = "Map", icon = icon("map")),
        menuItem("TimeSeries", tabName = "TimeSeries", icon = icon("chart-line")),
        menuItem("PieChart", tabName = "PieChart", icon = icon("chart-pie")),
        menuItem("RadarChart", tabName = "RadarChart", icon = icon("chart-simple")),
        menuItem("Appendix", tabName = "Appendix", icon = icon("info"))
      )
    ),
    
    dashboardBody(
      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"
      ),
      
      
      
      
      tabItems(
        
        tabItem(tabName = "Home", fluidPage(
          fluidRow(box(width = 15, title = "Introduction", status = "danger",
                       solidHeader = TRUE, h3("NYC Arrest and Public Safefy"),
                       h4("By Shuangxian Li,Yayuan Wang,Tomasz Wislicki,Louis Cheng"),
                       h5("Utilizing the arrest data provided by NYPD, this application aims to provide insight into the public security and police enforcement activities in New York from January 2011 to June 2022. The application includes one map, a time series plot, and pie charts to further break down the arrest activities into the perpetrators’ gender, age, race, and the location of the arrest event."),
                       h5("Users could refer to the 'How to Use The App' section to see more detailed instructions. Please enjoy the application :) "))),
          
          fluidRow(box(width = 15, title = "Targeted User", status = "danger", solidHeader=TRUE,
                       h5("NYC residents and tourists are able to use this app to understand public security and police enforcement activity."))),
          
          fluidRow(box(width = 15, title = "How to Use The App", status = "danger",
                       solidHeader = TRUE,
                       h5("The application is divided into 5 separate tabs"),
                       tags$div(tags$ul(
                         tags$li("The", strong("Home"), "tab: introduction."),
                         tags$li("The", strong("Map"), "tab: select year, race, gender, and age group to see the aggregated information on arrest activities; zoom in to check the location of each arrest event."),
                         tags$li("The", strong("TimeSeries"), "tab: select year, type, and borough to see how the number of arrest events changes over a year."),
                         tags$li("The", strong("PieChart"),"tab: select year, type, and borough to see the gender, race, and age composition of NYC arrest events."),
                         tags$li("The", strong("RadarChart"),"tab: select year to see the number of NYC arrest events for each type of arrest activities."),
                         tags$li("The", strong("Appendix"),"tab: appendix and data sources.")
                       ))
          ))
        )), # end of home 
        
        
        
        tabItem(tabName = "Map",                                                 # Map plot
                fluidPage(
                  fluidRow(
                    column(6,
                           selectInput(inputId = "map_year",
                                       label = "Choose a year",
                                       selected = 2022,
                                       choices = seq(min(PreDataTime$ARREST_YEAR),
                                                     max(PreDataTime$ARREST_YEAR))),
                           checkboxGroupInput("map_race", 
                                              label = "Perpetrator’s race",
                                              choices = SelectRace,
                                              selected = 'WHITE')
                    ),
                    column(6,
                           checkboxGroupInput("map_gender", 
                                              label = "Perpetrator’s gender",
                                              choices = SelectSex, 
                                              selected = 'M'),
                           checkboxGroupInput("map_age", 
                                              label = "Perpetrator’s age group",
                                              choices = c('<18','18-24','25-44', '45-64', '65+'),
                                              selected = '18-24')
                           
                    ),
                    column(12,
                           leafletOutput("mymap", height = '600px'))
                  )
                )
        ),      # end of Map
        
        tabItem(tabName = "TimeSeries",                                           # Time series
                fluidPage(
                  fluidRow(
                    column(6,
                           pickerInput(inputId = "line_year",
                                       label = "Choose a year",
                                       selected = 2022,
                                       choices = seq(min(PreDataTime$ARREST_YEAR),
                                                     max(PreDataTime$ARREST_YEAR)),
                                       options = list(
                                         `actions-box` = TRUE,
                                         size = 5
                                       ), 
                                       multiple = T)
                    ),
                    column(6,
                           pickerInput(inputId = "line_type",
                                       label ="choose a type",
                                       choices = unique(PreDataTime$OFNS_DESC),
                                       selected = "BURGLARY",
                                       options = list(
                                         `actions-box` = TRUE,
                                         size = 5
                                       ), 
                                       multiple = T
                           ),
                           pickerInput(inputId = "line_borough",
                                       label = "choose a borough",
                                       choices = SelectBoro,
                                       selected = "Q",
                                       options = list(
                                         `actions-box` = TRUE,
                                         size = 5
                                       ), 
                                       multiple = T
                           )
                    ),
                    column(12,
                           plotlyOutput(outputId = "ggplot",height = "600px"))
                  )
                )
        ),    # end of Time series
        
        
        tabItem(tabName = "PieChart",                                              # Pie chart
                fluidPage(
                  fluidRow(
                    column(6,
                           selectInput(inputId = "pie_year",
                                       label = "Choose a year",
                                       selected = 2022,
                                       choices = seq(min(PreDataPie$ARREST_YEAR),
                                                     max(PreDataPie$ARREST_YEAR)))
                    ),
                    column(6,
                           pickerInput(inputId = "pie_type",
                                       label ="choose a type",
                                       choices = unique(PreDataPie$OFNS_DESC),
                                       selected = "BURGLARY",
                                       options = list(
                                         `actions-box` = TRUE,
                                         size = 5
                                       ), 
                                       multiple = T
                           ),
                           pickerInput(inputId = "pie_borough",
                                       label = "choose a borough",
                                       choices = SelectBoro,
                                       selected = "Q",
                                       options = list(
                                         `actions-box` = TRUE,
                                         size = 5
                                       ), 
                                       multiple = T
                           )
                    ),
                  ),
                  column(12,
                         plotlyOutput("plot", height = '600px'))
                )
        ),        # End of Pie chart
        
        tabItem(tabName = "RadarChart",                                           # Radar Chart
                fluidPage(
                  fluidRow(
                    column(6,
                           selectInput(inputId = "radar_year",
                                       label = "Choose a year",
                                       selected = 2018,
                                       choices = seq(min(DataFreqOffense$ARREST_YEAR),
                                                     max(DataFreqOffense$ARREST_YEAR)))
                    ),
                    column(12,
                           plotlyOutput(outputId = "radar",height = "600px"))
                  )
                )
        ),  # End of Radar Chart
        
        tabItem(tabName = "Appendix", fluidPage(                             #Appendix
          HTML(
            "<h2> Data Sources </h2>
                <h4> <p><li>Arrest Data (2022): <a href='https://data.cityofnewyork.us/Public-Safety/NYPD-Arrest-Data-Year-to-Date-/uip8-fykc'>NYPD Arrest Data (Year to Date)</a></li></h4>
                
                <h4><li>Arrest Data (2006-2021) : <a href='https://data.cityofnewyork.us/Public-Safety/NYPD-Arrests-Data-Historic-/8h9b-rp9u' target='_blank'>NYPD Arrests Data (Historic)</a></li></h4>"
          ),
          
          titlePanel("Disclaimers "),
          
          HTML(
            " <p>This data is a breakdown of every arrest effected in NYC by the NYPD and is manually extracted every quarter. Therefore, there might exist little errors while documenting and processing the data.</p>",
            " <p>Moreover, notice that the data contains arrest information instead of the crimes, it only reflects the police enforcement activity in NYC but is unable to comprehensively illustrate the overall public safety and crime situation. Considering the dataset is maintained and updated quarterly, users are unable to obtain up-to-date information from the app. However, this app would still be a great tool to understand regional differences and changes in NYPD arrest activities in the past 10 years. 
 </p>"),
          
          titlePanel("Acknowledgement  "),
          
          HTML(
            " <p>This application is built using R shiny app.</p>",
            "<p>The following R packages were used in to build this RShiny application:</p>
                <li>Shiny</li>
                <li>Dyplr</li>
                <li>Plotly</li>
                <li>Leaflet</li>
                <li>Lubridate</li>
                <li>Tidyverse</li>
                <li>HydroTSM</li>"
          ),
          
          
          titlePanel("Contacts"),
          
          HTML(
            " <p>For more information please feel free to contact</p>",
            " <p>Shuangxian Li(sl4978@columbia.edu) </p>",
            " <p>Yayuan Wang(yw3548@columbia.edu)</p>",
            " <p>Tomasz Wislicki(tw2638@columbia.edu) </p>",
            " <p>Louis Cheng(yc3733@columbia.edu)</p>")
        )) # end of appendix
        
      )   # end of item
    ) # end of dashboardBody
  )  # end of dashboardPage
)   # end of shinyUI