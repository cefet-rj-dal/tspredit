source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Filter - seasonal adjustment

# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit) 

# Prepare a synthetic seasonal series with known frequency
set_example_seed()
x <- seq_len(120)
trend <- x / 100
seasonal <- sin(2 * pi * x / 12)
noise <- rnorm(length(x), 0, 0.03)
y <- trend + seasonal + noise

library(ggplot2)
# Visualize original seasonal series
plot_ts(x = x, y = y) + theme(text = element_text(size=16))

# Apply seasonal adjustment

filter <- ts_fil_seas_adj(frequency = 12)
set_example_seed()
filter <- fit(filter, y)
yhat <- transform(filter, y)

comparison <- rbind(
  data.frame(idx = x, value = y, series = "original"),
  data.frame(idx = x, value = yhat, series = "seasonally adjusted")
)

ggplot(comparison, aes(x = idx, y = value, color = series)) +
  geom_line(linewidth = 0.7) +
  scale_color_manual(values = c("original" = "black", "seasonally adjusted" = "dodgerblue3")) +
  theme_minimal(base_size = 14)
