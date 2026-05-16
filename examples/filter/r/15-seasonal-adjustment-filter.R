source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Filter - seasonal adjustment

# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit) 

# Prepare a synthetic seasonal series with known frequency
x <- seq_len(120)
trend <- x / 100
seasonal <- sin(2 * pi * x / 12)
noise <- rnorm(length(x), 0, 0.05)
y <- trend + seasonal + noise

library(ggplot2)
# Visualize original seasonal series
plot_ts(x = x, y = y) + theme(text = element_text(size=16))

# Apply seasonal adjustment

filter <- ts_fil_seas_adj(frequency = 12)
set_example_seed()
filter <- fit(filter, y)
yhat <- transform(filter, y)

# Compare original vs seasonally adjusted
plot_ts_pred(x = x, y = y, yadj = yhat) + theme(text = element_text(size=16))
