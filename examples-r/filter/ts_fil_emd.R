# Filter - EMD

# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit) 

# Prepare a noisy series example
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

# Apply EMD-based filtering (IMF reconstruction)

filter <- ts_fil_emd()          # decompose into IMFs
filter <- fit(filter, tsd$y)    # compute decomposition
y <- transform(filter, tsd$y)   # reconstruct a denoised version

# Compare original vs reconstructed
plot_ts_pred(y=tsd$y, yadj=y) + theme(text = element_text(size=16))
