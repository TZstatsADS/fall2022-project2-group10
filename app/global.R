

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

# df1 <- read.csv("NYPD_Arrest_Data__Year_to_Date_.csv")            # year to date data
# df2 <- read.csv("NYPD_Arrests_Data__Historic_.csv")               # historical data

df <- read.csv("DataSet.csv")            # year to date data


df$ARREST_DATE <- as.Date(df$ARREST_DATE)
df$ARREST_YEAR <- year(df$ARREST_DATE)

## Prepare data to summary

#PreDataTime: A New Database used in Time Serial plot

#PreDataPie: A New Database used in Pie plot



PreDataTime <- df |> 
  mutate(ARREST_MONTH = month(ARREST_DATE)) |> 
  group_by(ARREST_YEAR, ARREST_MONTH, OFNS_DESC, ARREST_BORO) |> 
  count() |> 
  ungroup() |> 
  dplyr::filter(ARREST_YEAR >= 2016) |> 
  I()


PreDataPie <- df |> 
  group_by(ARREST_YEAR, OFNS_DESC, ARREST_BORO, PERP_SEX, PERP_RACE, AGE_GROUP) |> 
  count() |> 
  ungroup() |> 
  dplyr::filter(ARREST_YEAR >= 2016) |> 
  I()

PreDataSeason <- df |> 
  mutate(ARREST_SEASON = time2season(ARREST_DATE,out.fmt="seasons")) |>
  group_by(ARREST_YEAR, ARREST_SEASON, OFNS_DESC, ARREST_BORO) |> 
  count() |> 
  ungroup() |> 
  dplyr::filter(ARREST_YEAR >= 2016) |> 
  I()

DataFreqOffense <- df %>%
  group_by(ARREST_YEAR, OFNS_DESC) %>%
  tally() %>%
  spread(OFNS_DESC, n, fill = 0) %>% 
  select(-V1) %>% select(ARREST_YEAR,"BURGLARY", "CRIMINAL TRESPASS", "DANGEROUS DRUGS", "DANGEROUS WEAPONS", "DISORDERLY CONDUCT", "FELONY ASSAULT", "FORGERY", "FRAUDS", "GRAND LARCENY", "INTOXICATED & IMPAIRED DRIVING", "HARASSMENT", "MURDER & NON-NEGL. MANSLAUGHTER", "PETIT LARCENY", "SEX CRIMES")



## Value used in Shiny App UI

SelectBoro <- unique(PreDataPie$ARREST_BORO)
names(SelectBoro) <- c("Brooklyn", "Manhattan", "Queens", "Bronx", "StatenIsland")


SelectSex <- c('Male' = 'M', 'Female' = "F")

SelectRace <- c('White' = 'WHITE', 'White Hispanic' = 'WHITE HISPANIC',
                'Black' = 'BLACK', 'Black Hispanic' = 'BLACK HISPANIC',
                'Asian / Pacific Islander' = 'ASIAN / PACIFIC ISLANDER',
                'American Indian/Alaskan Native' = 'AMERICAN INDIAN/ALASKAN NATIVE',
                'Other' = 'OTHER')
