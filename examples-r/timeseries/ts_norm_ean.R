# Exponential Adaptive Normalization

# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit) 

# Load a sample series

data(tsd)

library(ggplot2)
# Visualize original series
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Build sliding windows for supervised learning

sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
summary(ts[,10])

library(ggplot2)
# Visualize the target column (t0) after windowing
plot_ts(y=ts[,10]) + theme(text = element_text(size=16))

# Apply Exponential Adaptive Normalization

preproc <- ts_norm_ean(nw = 3)   # faster adaptation with smaller nw
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
summary(tst[,10])

# Inspect one normalized window (shape emphasized)
plot_ts(y=ts[1,]) + theme(text = element_text(size=16))
