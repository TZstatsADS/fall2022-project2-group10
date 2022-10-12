#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###############################Install Related Packages #######################
library(lubridate)
library(dplyr)
library(leaflet)
library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(plotly)
library(hydroTSM)
library(tidyverse)


# read two datasets
df1 <- read.csv('NYPD_Arrest_Data__Year_to_Date_.csv') # YTD Data
df2 <- read.csv("NYPD_Arrests_Data__Historic_.csv") # Historical data

## Combined Raw Datafile

df <- df1[,1:18] |> 
  rbind(df2[,1:18]) |> 
  select(ARREST_DATE, OFNS_DESC, LAW_CAT_CD, ARREST_BORO, ARREST_PRECINCT, JURISDICTION_CODE,
         AGE_GROUP, PERP_SEX, PERP_RACE, Latitude, Longitude) |> 
  dplyr::filter(OFNS_DESC != '(null)' | !is.na(ARREST_BORO)) |> 
  mutate(ARREST_DATE = as.Date(ARREST_DATE, "%m/%d/%Y"),
         ARREST_YEAR = year(ARREST_DATE))
df$PERP_RACE[df$PERP_RACE == "UNKNOWN"] <- "OTHER"

remove(df1, df2)


## Prepare data to summary

# PreDataTime: A New Database used in Time Serial plot

# PreDataPie: A New Database used in Pie plot

# DataFreqOffense: A New Database used in Radar Chart

PreDataTime <- df |> 
  mutate(ARREST_MONTH = month(ARREST_DATE)) |> 
  group_by(ARREST_YEAR, ARREST_MONTH, OFNS_DESC, ARREST_BORO) |> 
  count() |> 
  ungroup() |> 
  dplyr::filter(ARREST_YEAR >= 2011) |> 
  I()


PreDataPie <- df |> 
  group_by(ARREST_YEAR, OFNS_DESC, ARREST_BORO, PERP_SEX, PERP_RACE, AGE_GROUP) |> 
  count() |> 
  ungroup() |> 
  dplyr::filter(ARREST_YEAR >= 2011) |> 
  I()

PreDataSeason <- df |> 
  mutate(ARREST_SEASON = time2season(ARREST_DATE,out.fmt="seasons")) |>
  group_by(ARREST_YEAR, ARREST_SEASON, OFNS_DESC, ARREST_BORO) |> 
  count() |> 
  ungroup() |> 
  dplyr::filter(ARREST_YEAR >= 2011) |> 
  I()

DataFreqOffense <- df %>%
  group_by(ARREST_YEAR, OFNS_DESC) %>%
  tally() %>%
  spread(OFNS_DESC, n, fill = 0) %>% 
  select(-V1) %>% select(ARREST_YEAR,"BURGLARY", "CRIMINAL TRESPASS", "DANGEROUS DRUGS", "DANGEROUS WEAPONS", "DISORDERLY CONDUCT", "FELONY ASSAULT", "FORGERY", "FRAUDS", "GRAND LARCENY", "INTOXICATED & IMPAIRED DRIVING", "HARASSMENT", "MURDER & NON-NEGL. MANSLAUGHTER", "PETIT LARCENY", "SEX CRIMES")



# Define server logic required to draw a histogram
server <- shinyServer(function(input, output, session) {
  #### Time Series Graph
  output$ggplot<-renderPlotly({
    Year <- input$line_year
    type <- input$line_type
    borough <- input$line_borough
    
    PreDataTime |> 
      dplyr::filter(ARREST_YEAR %in% Year &
                      OFNS_DESC %in% type &
                      ARREST_BORO %in% borough) |> 
      group_by(ARREST_MONTH, ARREST_YEAR) |> 
      dplyr::summarise(n = sum(n, na.rm = T),
                       .groups = 'drop') |> 
      mutate(ARREST_YEAR = as.character(ARREST_YEAR)) |> 
      plot_ly(x = ~ARREST_MONTH, 
              y = ~n,
              color = ~ARREST_YEAR,
              type = "scatter",
              mode = "lines+markers",
              marker = list(size = 10,
                            line = list(width = 2))) |> 
      layout(showlegend = TRUE,
             xaxis = list(title = list(text = "Month",
                                       font = list(size = 12,
                                                   color = 'black')),
                          dtick = 1,
                          tick0 = 1),
             yaxis = list(title = list(text = "Count",
                                       font = list(size = 12,
                                                   color = 'black'))),
             title = list(text = paste('In', Year,
                                       'the number of', type,
                                       'happened in', names(which(SelectBoro == borough)),
                                       sep = ' '),
                          font = list(size = 14,
                                      color = 'black')))
  })
  
  ######## Pie Chart Page
  output$plot <- renderPlotly({
    Year <- input$pie_year
    type <- input$pie_type
    borough <- input$pie_borough
    # browser()
    
    DataPlot <- PreDataPie |> 
      dplyr::filter(ARREST_YEAR == Year &
                      OFNS_DESC %in% type &
                      ARREST_BORO %in% borough)
    DataPlotSex <- DataPlot |> 
      group_by(PERP_SEX) |> 
      summarise(n = sum(n, na.rm = T)) |> 
      rename(group = "PERP_SEX") |> 
      mutate(group = case_when(group == 'F' ~ 'Female',
                               group == 'M' ~ 'Male',
                               TRUE ~ 'Other'))
    DataPlotRace <- DataPlot |> 
      group_by(PERP_RACE) |> 
      summarise(n = sum(n, na.rm = T)) |> 
      rename(group = "PERP_RACE")
    DataPlotAge <- DataPlot |> 
      group_by(AGE_GROUP) |> 
      summarise(n = sum(n, na.rm = T)) |> 
      rename(group = "AGE_GROUP")
    
    plot_ly() |> 
      add_pie(data = DataPlotSex, labels = ~group, values = ~n,
              textinfo = 'label+percent',
              name = "Sex",
              title = "Sex",                                              #Perpetrator Sex Distribution Chart
              marker = list(colors=colors,
                            line = list(color = '#FFFFFF', width = 1)),
              domain = list(x = c(0, 0.4), y = c(0.4, 1))) |> 
      add_pie(data = DataPlotRace, labels = ~group, values = ~ n,
              textinfo = 'label+percent',
              name = "Race",
              showlegend = T,
              title = "Race",                                             #Perpetrator Race Distribution Chart
              marker = list(#colors=colors,
                line = list(color = '#FFFFFF', width = 1)),
              domain = list(x = c(0.25, 0.75), y = c(0, 0.6))) |> 
      add_pie(data = DataPlotAge, labels = ~group, values = ~ n,
              textinfo = 'label+percent',
              name = "Age",
              title = "Age",                                                #Perpetrator  Distribution Chart
              marker = list(#colors=colors,
                line = list(color = '#FFFFFF', width = 1)),
              domain = list(x = c(0.6, 1), y = c(0.4, 1))) %>%
      layout(title = "Pie Chart Summary of Perpetrator Data", showlegend = F,
             #grid=list(rows=1, columns=3),
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  })
  
  ## Radar Chart
  
  output$radar <- renderPlotly({
    year <- filter(DataFreqOffense, ARREST_YEAR == input$radar_year)
    
    r <- map_dbl(year[, 2:15], ~.x)
    nms <- names(r)
    
    #code to plot the radar
    fig <- plot_ly(
      type = 'scatterpolar',
      r = r,
      theta = nms,
      fill = 'toself',
      mode = 'markers'
    ) 
    fig <- fig %>%
      layout(
        polar = list(
          radialaxis = list(
            visible = T,
            range = c(0,max(r))
          )
        ),
        showlegend = F
      )
  })
  
  ######## Map Page
  output$mymap <- renderLeaflet({
    Year <- input$map_year
    gender <- input$map_gender
    age <- input$map_age
    race <- input$map_race
    df |> 
      dplyr::filter(ARREST_YEAR == Year &
                      AGE_GROUP %in% age &
                      PERP_SEX %in% gender &
                      PERP_RACE %in% race) |> 
      leaflet() |> 
      addTiles() |> 
      addCircleMarkers(lng = ~Longitude, lat = ~Latitude, clusterOptions = markerClusterOptions())
  })
})


