library(readxl)
library(tidyverse)
library(data.table)
#library(ggplot2)
#library(smplot2)
#library(networkD3)
library(dplyr)
#library(PantaRhei) # try this for Sankey diagram
library(plotly)

# Set options

# Multipliers for Conversion from KRW
krw <- 1 #units 1,000,000 = million KRW
euro <- 0.000669165 * 1000000 # units 1,000 = euros
usd <- 0.000721814 * 1000 # units 1,000 = k usd
gbp <- 0.000557775 * 1000 # units 1,000 = k gbp

# choose currency
currency <- euro

# columns listed by type
value.cols <- c("local", "fed", "prod", "life_coop", "business_fed", "hansalim_fed")
category.cols <- "div"

# Import Data
value.flow <- data.table(read_excel("data/ValueFlow.xlsx", sheet = "flow", col_names = TRUE)) %>% 
  rename(div = "Division", local = "Local Goods", fed = "Federation Goods", prod = "Producer Share", life_coop = "Life Coop Share", business_fed = "Business Federation Share", hansalim_fed = "Hansalim Federation Share") %>% 
  .[, (value.cols) := lapply(.SD, function(x) x * currency), .SDcols = value.cols]



#value.flow.nodes <- data.frame("name" = c(value.flow$div,"Local Goods","Federation Goods","Producer Share","Life Coop Share","Business Federation Share","Hansalim Federation Share"))

value.flow.nodes <- data.frame("name" = c("Local Goods","Federation Goods",value.flow$div,"Producer Share","Life Coop Share","Business Federation Share","Hansalim Federation Share"))

node.index1 <- data.frame(id=c("local", "fed"),
                          index=0:1)

node.index2 <- data.frame(id=c("prod", "life_coop", "business_fed","hansalim_fed"),
                          index=29:32)



# Make a node.index a vector
node.index1.v <- node.index1$index
names(node.index1.v) <- node.index1$id

node.index2.v <- node.index2$index
names(node.index2.v) <- node.index2$id

value.flow.links1 <- value.flow %>% 
  .[,div:=2:28] %>% 
  .[,c(1,2,3)] %>% 
  melt(id.vars="div",
       measure.vars=c("local","fed"),
       variable.name="shares",
       value.name="value") %>% 
  rename(target="div",source="shares") %>% 
  .[,.(source,target,value)] %>% 
  mutate(., source = node.index1.v[source]) %>% 
  mutate(., source = unname(source))

value.flow.links2 <- value.flow %>%
  .[,div:=2:28] %>% 
  .[,c(1,4,5,6,7)] %>% 
  melt(id.vars="div",
       measure.vars=c("prod", "life_coop", "business_fed","hansalim_fed"),
       variable.name="shares",
       value.name="value") %>% 
  rename(source="div",target="shares") %>% 
  mutate(., target = node.index2.v[target]) %>% 
  mutate(., target = unname(target))

value.flow.links.complete <- rbind(value.flow.links1,value.flow.links2)

value.flow.fig <- plot_ly(
  type = "sankey",
  orientation = "h",

  node = list(
    label = value.flow.nodes$name,
    color = c("darkgreen", "lightgreen", rep("grey",27),"darkblue","blue","lightblue","pink"),
    pad = 15,
    thickness = 20,
    line = list(
      color = "black",
      width = 0.5
    )
  ),
  
  link = list(
    source = value.flow.links.complete$source,
    target = value.flow.links.complete$target,
    value =  value.flow.links.complete$value
  )
)

save(value.flow.links.complete, value.flow.nodes, value.flow.fig, file="valueflow.RData")

value.flow.fig <- value.flow.fig %>% layout(
  title = "",
  font = list(
    size = 12
  )
)

value.flow.fig



# 
#budget <- data.table(read_excel("data/FederationSpending.xlsx", sheet = "income-expenses", col_names = TRUE)) %>% 
#  rename(category = "Category", class = "Class", type = "Type", item = "Item")

#life.coop.income <- data.table(read_excel("data/LifeCoopsIncome.xlsx", sheet = "2023", col_names = TRUE)) %>% 
#  rename(div = "Division", local_mil_won = "Local Goods (mil won)", fed_mil_won = "Federation Goods (mil won)", local = "Local Goods", fed = "Federation Goods")



#value.flow.links.complete <- as.data.frame(value.flow.links.complete)
#names(value.flow.links.complete) = c("source", "target", "value")

#sankeyNetwork(Links = value.flow.links.complete, Nodes = value.flow.nodes.test, Source = "source",
#              Target = "target", Value = "value", NodeID = "name",
#              units = "", fontSize = 12, nodeWidth = 30)

#ggplot(data = life.coop.income, mapping = aes(x = div, y = fed_mil_won, color = div)) +
#  sm_bar() +
#  ggtitle("Life Coop Supply Value (Income)")
