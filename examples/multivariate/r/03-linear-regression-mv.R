source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Target-centered multivariate linear regression

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

samp <- ts_sample(mv, test_size = 5)

model <- ts_lm_mv(formula = y ~ x1 + x2)
model <- fit(model, samp$train)

pred_1 <- predict(model, x = samp$test, steps_ahead = 1)
pred_1

pred_5 <- predict(model, x = samp$test, steps_ahead = 5)
pred_5

pred_all <- predict(model, x = samp$test, steps_ahead = 5, return_all = TRUE)
pred_all

ev_test <- evaluate(model, tail(samp$test$y, 5), pred_5)
ev_test$metrics
