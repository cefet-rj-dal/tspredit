#install.packages("tspredit")

# Loading the package
library(tspredit) 

# Series for study

data(tsd)

library(ggplot2)
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size=16))

# Sliding windows

sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)

# Sampling (train and test)

test_size <- 3
samp <- ts_sample(ts, test_size)

# First five rows of the train set
ts_head(samp$train, 5)

# Last five rows of the train set
ts_head(samp$train[-c(1:(nrow(samp$train)-5)),])

# Test data
ts_head(samp$test)
