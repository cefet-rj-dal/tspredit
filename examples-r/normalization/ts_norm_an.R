# Exponential Adaptive Normalization

# Installing the package (if needed)
#install.packages("tspredit")

# Loading the packages
library(daltoolbox)
library(tspredit) 

# Series for study

data(tsd)

# Series visualization
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Sliding windows

sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
summary(ts[,10])

# Target (t0) visualization after windowing
library(ggplot2)
plot_ts(y=ts[,10]) + theme(text = element_text(size=16))

# Normalization

preproc <- ts_norm_an()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
summary(tst[,10])
plot_ts(y=ts[1,]) + theme(text = element_text(size=16))
