#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
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

