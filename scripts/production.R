library(readxl)
library(tidyverse)
library(data.table)
library(dplyr)
library(plotly)
library(ggplot2)
library(ggsankey)

# Import data
production.flow <- data.table(read_excel("data/ProductionByType.xlsx", col_names = TRUE)) %>% 
  .[, .(crop,production_type,supply_type,production_tons)]
  
production.flow1 <- production.flow[,.(production_type,crop,production_tons)] %>% 
  .[,.(production_tons = sum(production_tons)), by = .(production_type,crop)] %>% 
  rename(source = "production_type", target = "crop", value = "production_tons")


node.index1 <- data.frame(id=c("Organic", "Pesticide-free", "Low-pesticide", "Domestic"),
                          index=0:3)

node.index2 <- data.frame(id=c("Staple grains", "Misc grains", "Roots and Tubers", "Vegetables", "Fruit"),
                          index=4:8)

node.index3 <- data.frame(id=c("Contract", "Demand"),
                          index=9:10)

production.flow.nodes <- data.frame("name" = c(node.index1$id,node.index2$id,node.index3$id))

# Make a node.index a vector
node.index1.v <- node.index1$index
names(node.index1.v) <- node.index1$id

node.index2.v <- node.index2$index
names(node.index2.v) <- node.index2$id

node.index3.v <- node.index3$index
names(node.index3.v) <- node.index3$id

production.flow1.links <- production.flow1 %>% 
  mutate(., source = node.index1.v[source]) %>% 
  mutate(., source = unname(source)) %>% 
  mutate(., target = node.index2.v[target]) %>% 
  mutate(., target = unname(target))

production.flow2<- production.flow[,.(crop,supply_type,production_tons)] %>% 
  .[,.(production_tons = sum(production_tons)), by = .(supply_type,crop)] %>% 
  .[,.(crop,supply_type,production_tons)] %>% 
  rename(source = "crop", target = "supply_type", value = "production_tons")

production.flow2.links <- production.flow2 %>% 
  mutate(., source = node.index2.v[source]) %>% 
  mutate(., source = unname(source)) %>% 
  mutate(., target = node.index3.v[target]) %>% 
  mutate(., target = unname(target))

production.flow.links.complete <- rbind(production.flow1.links,production.flow2.links)

# Plotly interactive plot

production.fig <- plot_ly(
  type = "sankey",
  orientation = "h",
  
  node = list(
    label = production.flow.nodes$name,
    color = c("darkgreen", "green", "lightgreen", "aquamarine", "brown","darkorange","yellow","green", "red", "darkgrey","lightgrey"),
    pad = 15,
    thickness = 20,
    line = list(
      color = "black",
      width = 0.5
    )
  ),
  
  link = list(
    source = production.flow.links.complete$source,
    target = production.flow.links.complete$target,
    value =  production.flow.links.complete$value
  )
)

production.fig <- production.fig %>% layout(
  title = "",
  font = list(
    size = 12
  )
)

production.fig

# ggplot2 static plot??

save(production.flow.links.complete, production.fig, file="production.RData")
