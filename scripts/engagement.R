library(readxl)
library(tidyverse)
library(data.table)
library(circlize)

# Import data on gatherings and add 'type' column and change column names
neighbourhood <- data.table(read_excel("data/Engagement.xlsx", sheet = "neighbourhood", col_names = TRUE)) %>% 
  .[,type:=rep("neighbourhood")] %>% 
  rename(div = "Division", num = "Number", freq = "Annual frequency", part = "Number of participants") 
small <- data.table(read_excel("data/Engagement.xlsx", sheet = "small", col_names = TRUE)) %>% 
  .[,type:=rep("small")] %>%  
  rename(div = "Division", num = "Number", freq = "Annual frequency", part = "Number of participants")
store <- data.table(read_excel("data/Engagement.xlsx", sheet = "store", col_names = TRUE)) %>% 
  .[,type:=rep("store")] %>% 
  rename(div = "Division", num = "Number", freq = "Annual frequency", part = "Number of participants")
online <- data.table(read_excel("data/Engagement.xlsx", sheet = "online", col_names = TRUE)) %>% 
  .[,type:=rep("online")] %>% 
  .[,num:=rep(NA)] %>% 
  .[,part:=rep(NA)] %>% 
  rename(div = "Division", freq = "Annual frequency")
staff <- data.table(read_excel("data/Engagement.xlsx", sheet = "staff", col_names = TRUE)) %>% 
  rename(div = "Division", num = "Grassroots Organisations Activity Support Staff")

# Import data on rural-urban exchanges
events <- data.table(read_excel("data/RuralUrbanExchange.xlsx", sheet = "events", col_names = TRUE)) %>% 
  .[,type:=rep("event")] %>% 
  rename(div = "Division", freq = "Frequency", part = "Participants") 
visits <- data.table(read_excel("data/RuralUrbanExchange.xlsx", sheet = "visits", col_names = TRUE)) %>% 
  .[,type:=rep("visit")] %>% 
  rename(div = "Division", freq = "Frequency", part = "Participants") 
sharing <- data.table(read_excel("data/RuralUrbanExchange.xlsx", sheet = "sharing", col_names = TRUE)) %>% 
  .[,type:=rep("sharing")] %>% 
  rename(div = "Division", freq = "Frequency", part = "Participants") 
informal <- data.table(read_excel("data/RuralUrbanExchange.xlsx", sheet = "informal", col_names = TRUE)) %>% 
  .[,type:=rep("informal")] %>% 
  rename(div = "Division", freq = "Frequency", part = "Participants") 
store.experience <- data.table(read_excel("data/RuralUrbanExchange.xlsx", sheet = "storeExperience", col_names = TRUE)) %>% 
  .[,type:=rep("store_experience")] %>% 
  rename(div = "Division", freq = "Frequency", part = "Participants") 
tour.experience <- data.table(read_excel("data/RuralUrbanExchange.xlsx", sheet = "tourExperience", col_names = TRUE)) %>% 
  .[,type:=rep("tour_experience")] %>% 
  rename(div = "Division", freq = "Frequency", part = "Participants") 

# Join the data together into a single data.table
engagement <- neighbourhood %>% 
  rbind(small,store,online)
engagement[is.na(engagement), ] <- 0 

rural.urban <- events %>% 
  rbind(visits,sharing,informal,store.experience,tour.experience)
rural.urban[is.na(rural.urban), ] <- 0 
# Replace 'NA' with 0

staff[is.na(staff), ] <- 0 

total.groups <- engagement %>% .[,num] %>% sum()
total.meetings <- engagement %>% .[,freq] %>% sum()
total.attendances  <- engagement %>% .[,part] %>% sum() # i.e. number of attendances (which is more than the number of attendees)
total.activity.staff <- staff %>% .[,num] %>% sum()
total.exchanges <- rural.urban %>% .[,freq] %>% sum()
total.visitors <- rural.urban %>% .[,part] %>% sum() # i.e. more likely to be closer to total number of people as there will be less double counting of repeat visits than in the above number

total.grassroots.participants <- total.attendances + total.visitors
total.grassroots.interactions <- total.meetings + total.exchanges

remove(list=c("events","informal","neighbourhood","online","sharing","small","staff","store","store.experience","tour.experience","visits"))

# Visualise interactions

rural.urban.cord <- rural.urban %>% 
  .[part!=0,.(div,type,freq)]

engagement.cord <- engagement %>% 
  .[part!=0,.(div,type,freq)]

participation.cord <- rbind(rural.urban.cord,engagement.cord)

participation.cord.simple <- rbind(rural.urban[part!=0,.(total_part = sum(part)), by = div][,cat:="exchange"],
                                   engagement[part!=0,.(total_part = sum(part)), by = div][,cat:="engagement"]) %>% 
  .[,.(cat,div,total_part)] %>% 
  setorder(total_part)

remove(list=c("engagement.cord","rural.urban.cord","rural.urban","engagement","participation.cord"))

div.order <- participation.cord.simple %>% 
  .[,.(x = sum(total_part)), by = div] %>% 
  setorder(x) %>% 
  .[,div] %>% 
  c("exchange", "engagement")

grid.col <- data.table(div = div.order, col = "lightgrey") %>% 
  .[div == "engagement", col := "darkorange"] %>% 
  .[div == "exchange", col := "darkgreen"] %>% 
  .[div %like% "Seoul" | div %like% "Gyeonggi", col := "blue"] %>% 
  .[,col]

save(participation.cord.simple, div.order, grid.col, file = "participation.RData")

#chordDiagram(rural.urban.cord)

chordDiagram(participation.cord.simple, order = div.order, grid.col = grid.col, annotationTrack = "grid", 
             preAllocateTracks = list(track.height = mm_h(25)))

circos.track(track.index = 2, panel.fun = function(x, y) {
  xlim = get.cell.meta.data("xlim")
  xplot = get.cell.meta.data("xplot")
  ylim = get.cell.meta.data("ylim")
  si = get.cell.meta.data("sector.index")
  
  if(abs(xplot[2] - xplot[1]) < 10) {
    circos.axis(h = "top", labels.cex = 0.3, sector.index = si, track.index = 2)
  } else if(abs(xplot[2] - xplot[1]) > 30){
    circos.axis(h = "top", labels.cex = 0.8, sector.index = si, track.index = 2)
  } else {
    circos.axis(h = "top", labels.cex = 0.5, sector.index = si, track.index = 2)
  }
  
})

circos.track(track.index = 1, panel.fun = function(x, y) {
  xlim = get.cell.meta.data("xlim")
  xplot = get.cell.meta.data("xplot")
  ylim = get.cell.meta.data("ylim")
  sector.name = get.cell.meta.data("sector.index")
  
  if(abs(xplot[2] - xplot[1]) < 1) {
    circos.text(mean(xlim), ylim[1], sector.name, facing = "clockwise",
                niceFacing = TRUE, adj = c(0, 0.5), cex = 0.5)
  } else if(abs(xplot[2] - xplot[1]) > 30) {
    circos.text(mean(xlim), ylim[1], sector.name, facing = "bending.inside", 
                niceFacing = TRUE, adj = c(0.5, -1), cex = 1)
  } else {
    circos.text(mean(xlim), ylim[1], sector.name, facing = "clockwise",
                niceFacing = TRUE, adj = c(0, 0.5), cex = 1)
  }
}, bg.border = NA)
circos.clear()
