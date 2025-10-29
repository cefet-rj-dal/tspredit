#install.packages("tspredit")

# Loading the package
library(tspredit) 

# Series for study

data(tsd)

# Series visualization
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Sliding windows

sw_size <- 5
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)

# Projection (X, y)

io <- ts_projection(ts)

# Input data (X)
ts_head(io$input)

# Output data (y)
ts_head(io$output)
