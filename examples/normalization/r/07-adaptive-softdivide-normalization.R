source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Softdivide Normalization

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

preproc <- ts_norm_an(operation = "softdivide", scale = "sd", lambda = 1)
set_example_seed()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
summary(tst[, 10])

compare_t0 <- rbind(
  data.frame(idx = seq_len(nrow(ts)), value = as.vector(ts[, ncol(ts)]), series = "original t0"),
  data.frame(idx = seq_len(nrow(tst)), value = as.vector(tst[, ncol(tst)]), series = "transformed t0")
)

plot_ts_pred(
  x = compare_t0[compare_t0$series == "original t0", "idx"],
  y = compare_t0[compare_t0$series == "original t0", "value"],
  yadj = compare_t0[compare_t0$series == "transformed t0", "value"]
) + theme(text = element_text(size = 16))
