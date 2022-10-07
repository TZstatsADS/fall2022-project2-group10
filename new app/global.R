library(shiny)
library(leaflet)
library(leaflet.extras)
library(googleVis)
library(shinydashboard)
library(tidyverse)
library(dplyr)
library(shinyWidgets)
library(ggplot2)
library(lubridate)
library(plotly)

load("AppData.RData")
load("CleanedData.RData")

################################################ Global for Time series
SelectBoro <- unique(PreDataPie$ARREST_BORO)
names(SelectBoro) <- c("Brooklyn", "Manhattan", "Queens", "Bronx", "StatenIsland")
SelectBoro

SelectSex <- c('Male' = 'M', 'Female' = "F")
SelectSex