source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Target-centered ARIMAX with auxiliary forecasting

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

y_ts <- ts_data(tsd$y, 1)
y_samp <- ts_sample(y_ts, test_size = 5)

baseline <- ts_arima()
baseline <- fit(baseline, y_samp$train)
pred_base <- predict(baseline, y_samp$test[1, ], steps_ahead = 5)
ev_base <- evaluate(baseline, as.vector(y_samp$test), as.vector(pred_base))
ev_base$metrics

model <- ts_arimax(
  models_x = list(
    x1 = ts_arima(),
    x2 = ts_arima()
  )
)

model <- fit(model, samp$train)

pred_1 <- predict(model, steps_ahead = 1)
pred_1

pred_5 <- predict(model, steps_ahead = 5)
pred_5

attr(pred_5, "system")

ev_test <- evaluate(model, tail(samp$test$y, 5), pred_5)
rbind(
  ARIMA_y = ev_base$metrics,
  ARIMAX_mv = ev_test$metrics
)
