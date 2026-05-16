source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Subtractive Normalization

# Installing the package (if needed)
#install.packages("tspredit")

library(daltoolbox)
library(tspredit)
library(ggplot2)

data(tsd)

plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))

sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
summary(ts[, 10])

preproc <- ts_norm_an(operation = "subtract")
set_example_seed()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
summary(tst[, 10])

compare_t0 <- rbind(
  data.frame(idx = seq_len(nrow(ts)), value = as.vector(ts[, ncol(ts)]), series = "original t0"),
  data.frame(idx = seq_len(nrow(tst)), value = as.vector(tst[, ncol(tst)]), series = "transformed t0")
)

ggplot(compare_t0, aes(x = idx, y = value, color = series)) +
  geom_line(linewidth = 0.7) +
  theme_minimal(base_size = 14)
