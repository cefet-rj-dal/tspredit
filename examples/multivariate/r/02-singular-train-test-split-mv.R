source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Train and test splits for singular multivariate data

# Installing the package (if needed)
# install.packages("tspredit")

library(daltoolbox)
library(tspredit)

data(tsd)

x1 <- c(tsd$y[-1], tail(tsd$y, 1))
x2 <- stats::filter(tsd$y, rep(1/3, 3), sides = 1)
x2[is.na(x2)] <- tsd$y[is.na(x2)]

mv <- ts_data_mv(
  data.frame(y = tsd$y, x1 = x1, x2 = as.numeric(x2)),
  y = "y"
)

ts_head(mv, 5)

samp <- ts_sample(mv, test_size = 5)

ts_head(samp$train, 3)
ts_head(samp$test, 3)

tail(samp$train$y, 3)
as.data.frame(samp$test)[, c("x1", "x2")]
