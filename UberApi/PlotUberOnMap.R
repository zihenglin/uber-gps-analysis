library(shiny)
library(leaflet)
library(data.table)
library(ggplot2)
library(stats)
library(dplyr)

uber.time <- data.table(read.csv('UberWaitingTime2016-04-18.csv'))
uber.price <- data.table(read.csv('UberPrice2016-04-18.csv'))  

uber.time <- uber.time[lat <= 37.791029 | lng >= -122.483492]
uber.time <- uber.time[lat <= 37.796469 | lng <= -122.392206]
uber.price <- uber.price[lat <= 37.791029 | lng >= -122.483492]
uber.price <- uber.price[lat <= 37.796469 | lng <= -122.392206]
latDelta <- diff(unique(uber.time$lat))[1] / 2
lngDelta <- diff(unique(uber.time$lng))[1] / 2



plotEstimationTime <- function(df) {
  pal <- colorNumeric(
    palette = c("green", "red"),
    domain = df$estimate
  )
  
  map <- leaflet() %>% 
    addTiles(group = "OSM") %>% 
    addRectangles(data = df,
                  lng1 = ~lng - lngDelta, 
                  lat1 = ~lat + latDelta,
                  lng2 = ~lng + lngDelta, 
                  lat2 = ~lat - latDelta,
                  fillColor = ~pal(estimate),
                  fillOpacity = 0.5,
                  weight = 0
    )
  map
}


plotSurgePrice <- function(df) {
  pal <- colorNumeric(
    palette = c("green", "red"),
    domain = df$surge_multiplier
  )
  map <- leaflet() %>% 
    addTiles(group = "OSM") %>% 
    addRectangles(data = df,
                lng1 = ~lng - lngDelta, 
                lat1 = ~lat + latDelta,
                lng2 = ~lng + lngDelta, 
                lat2 = ~lat - latDelta,
                fillColor = ~pal(surge_multiplier),
                fillOpacity = 0.5,
                weight = 0
  )
  map
}

# Waiting Time Estimation
uberx.time = uber.time[display_name == 'uberX']
uberblack.time = uber.time[display_name == 'UberBLACK']
ubertaxi.time = uber.time[display_name == 'uberTAXI']
plotEstimationTime(uberx.time)
plotEstimationTime(uberblack.time)
plotEstimationTime(ubertaxi.time)

# Pricing estimation 
uberx.price = uber.price[display_name == 'uberX']
uberblack.price = uber.price[display_name == 'UberBLACK']
plotSurgePrice(uberx.price)
plotSurgePrice(uberblack.price)

