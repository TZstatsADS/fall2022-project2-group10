

setwd('../example 2013-2018/new_app/')

library(tidyverse)

# data load ---------------------------------------------------------------

DataArrestRaw <- read.csv('./NYPD_Arrest_Data__Year_to_Date_.csv')
DataHistorRaw <- read.csv('./NYPD_Arrests_Data__Historic_.csv')
DataArrest <- DataArrestRaw[,-19] |> 
    rbind(DataHistorRaw[-19]) |> 
    select(ARREST_DATE, OFNS_DESC, LAW_CAT_CD, ARREST_BORO, ARREST_PRECINCT, JURISDICTION_CODE,
           AGE_GROUP, PERP_SEX, PERP_RACE, Latitude, Longitude) |> 
    dplyr::filter(OFNS_DESC != '(null)') |> 
    mutate(ARREST_DATE = as.Date(ARREST_DATE, "%m/%d/%Y"),
           ARREST_YEAR = year(ARREST_DATE))

## Check range of Date
diff(range(DataArrest$ARREST_DATE))
length(unique(DataArrest$ARREST_DATE))

save(DataArrest, file = './CleanedData.RData')

# data summary ------------------------------------------------------------

## Prepare data to summary
head(DataArrest)
PreDataTime <- DataArrest |> 
    mutate(ARREST_MONTH = month(ARREST_DATE)) |> 
    group_by(ARREST_YEAR, ARREST_MONTH, OFNS_DESC, ARREST_BORO) |> 
    count() |> 
    ungroup() |> 
    dplyr::filter(ARREST_YEAR >= 2011) |> 
    # dplyr::filter(OFNS_DESC != "" & ARREST_BORO != "") |> 
    I()

## Check Unique Character
unique(PreDataTime$ARREST_YEAR)
unique(PreDataTime$OFNS_DESC)
unique(PreDataTime$ARREST_BORO)

PreDataPie <- DataArrest |> 
    group_by(ARREST_YEAR, OFNS_DESC, ARREST_BORO, PERP_SEX, PERP_RACE, AGE_GROUP) |> 
    count() |> 
    ungroup() |> 
    dplyr::filter(ARREST_YEAR >= 2011) |> 
    # dplyr::filter(OFNS_DESC != "" & ARREST_BORO != "" & 
    #                   AGE_GROUP %in% c("<18", "18-24", "25-44", "45-64", "65+") &
    #                   PERP_RACE != "UNKNOWN") |> 
    I()

## Check Unique Character
unique(PreDataPie$PERP_SEX)
unique(PreDataPie$PERP_RACE)
unique(PreDataPie$AGE_GROUP)

save(PreDataTime, PreDataPie, file = './AppData.RData')

# write xlsx --------------------------------------------------------------

library(openxlsx)
write.csv(DataArrest, file = './CleanedData.csv', quote = F)
write.csv(PreDataPie, file = './DataPiePlot.csv', quote = F)
write.csv(PreDataTime, file = './DataTimeSerial.csv', quote = F)

