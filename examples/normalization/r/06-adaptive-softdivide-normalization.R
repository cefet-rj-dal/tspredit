source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Softdivide Normalization

# Installing the package (if needed)
#install.packages("tspredit")

# Loading the packages
library(daltoolbox)
library(tspredit)

# Series for study
data(tsd)

# Series visualization
library(ggplot2)
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))

# Sliding windows
sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
summary(ts[,10])

# Softdivide adaptive normalization
preproc <- ts_norm_an(operation = "softdivide", scale = "sd", lambda = 1)
set_example_seed()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
summary(tst[,10])
plot_ts(y = ts[1,]) + theme(text = element_text(size = 16))
