# Filter - Moving Average

# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit) 

# Prepare a noisy series example
# - start from built-in sample data
# - add low-amplitude Gaussian noise
# - inject a few spikes to stress-test robustness

data(tsd)
y <- tsd$y
noise <- rnorm(length(y), 0, sd(y)/10)
spike <- rnorm(1, 0, sd(y))
tsd$y <- tsd$y + noise
tsd$y[10] <- tsd$y[10] + spike
tsd$y[20] <- tsd$y[20] + spike
tsd$y[30] <- tsd$y[30] + spike

library(ggplot2)
# Visualize the noisy series
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Apply the Moving Average filter

filter <- ts_fil_ma(3)            # window size = 3 (use larger to smooth more)
filter <- fit(filter, tsd$y)      # calibrate (no learning; keeps interface consistent)
y <- transform(filter, tsd$y)     # get smoothed series

# Compare original vs smoothed
plot_ts_pred(y=tsd$y, yadj=y) + theme(text = element_text(size=16))
