library(vistime)
library(readxl)
library(data.table)

# Import Data
tilted.timeline <- data.table(read_excel("data/Tilted.xlsx", sheet = "timeline", col_names = TRUE))

tilted.groups <- data.table(read_excel("data/Tilted.xlsx", sheet = "groups", col_names = TRUE))


vistime(tilted.timeline,
        optimize_y = TRUE,
        linewidth = 15)
