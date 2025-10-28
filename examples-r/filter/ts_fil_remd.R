# Filter - REMD

# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit) 

# Prepare a noisy series with spikes
data(tsd)
y <- tsd$y
noise <- rnorm(length(y), 0, sd(y)/10)
spike <- rnorm(1, 0, sd(y))
tsd$y <- tsd$y + noise
tsd$y[10] <- tsd$y[10] + spike
tsd$y[20] <- tsd$y[20] + spike
tsd$y[30] <- tsd$y[30] + spike

library(ggplot2)
# Visualize the noisy input
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Apply REMD (robust EMD)

filter <- ts_fil_remd()         # data-driven decomposition into IMFs (robust)
filter <- fit(filter, tsd$y)
y <- transform(filter, tsd$y)   # reconstruction after robust decomposition

# Compare original vs denoised
plot_ts_pred(y=tsd$y, yadj=y) + theme(text = element_text(size=16))
