source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Filter - Gabor

# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit)

set_example_seed()
x <- seq(0, 6 * pi, length.out = 120)
y <- sin(x) + 0.3 * sin(8 * x) + rnorm(length(x), 0, 0.12)

library(ggplot2)
# Visualize noisy input
plot_ts(y = y) + theme(text = element_text(size = 16))

# Apply Gabor smoothing
filter <- ts_fil_gabor(window_size = 3, central_frequency = 0.05)
filter <- daltoolbox::fit(filter, y)
yhat <- transform(filter, y)

# Compare original vs filtered series
plot_ts_pred(y = y, yadj = yhat) + theme(text = element_text(size = 16))
