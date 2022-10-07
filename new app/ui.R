library(shiny)
library(shinyWidgets)

shinyUI(
    dashboardPage(
        skin = "red",
        
        dashboardHeader(title = "NYC Arrest Data"),
        
        dashboardSidebar(
            sidebarMenu(
                menuItem("Map", tabName = "Map", icon = icon("map")),
                menuItem("TimeSeries", tabName = "TimeSeries", icon = icon("chart-line")),
                menuItem("PieChart", tabName = "PieChart", icon = icon("chart-pie")),
                menuItem("More Info", tabName = "MoreInfo", icon = icon("info"))
            )
        ),
        
        dashboardBody(
            tags$style(type="text/css",
                       ".shiny-output-error { visibility: hidden; }",
                       ".shiny-output-error:before { visibility: hidden; }"
            ),
            tabItems(
                tabItem(tabName = "Map", 
                        fluidPage(
                            fluidRow(
                                column(6,
                                       selectInput(inputId = "map_year",
                                                   label = "Choose a year",
                                                   selected = 2022,
                                                   choices = seq(min(PreDataTime$ARREST_YEAR),
                                                                 max(PreDataTime$ARREST_YEAR)))
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
                ),
                tabItem(tabName = "TimeSeries",
                        fluidPage(
                            fluidRow(
                                column(6,
                                       selectInput(inputId = "line_year",
                                                   label = "Choose a year",
                                                   selected = 2022,
                                                   choices = seq(min(PreDataTime$ARREST_YEAR),
                                                                 max(PreDataTime$ARREST_YEAR)))
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
                ),
                tabItem(tabName = "PieChart",
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
                )
            )
        )
    )
)