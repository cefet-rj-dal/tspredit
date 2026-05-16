source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load the package and the example series used throughout the tutorials.
library(daltoolbox)
library(forecast)
library(tspredit)
library(ggplot2)

data(tsd)

# Plot the original series to understand the overall pattern.
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))

# Wrap the raw series without a lag window.
ts <- ts_data(tsd$y, 0)
ts_head(ts, 5)

# Keep the last point for out-of-sample evaluation.
samp <- ts_sample(ts, test_size = 1)
ts_head(samp$train, 3)
ts_head(samp$test, 1)

# Inspect ACF and PACF on the training segment.
forecast::ggAcf(samp$train) + theme(text = element_text(size = 16))
forecast::ggPacf(samp$train) + theme(text = element_text(size = 16))

# Fit an ARIMA with five autoregressive lags.
model <- ts_arima(p = 5, d = 0, q = 0)
set_example_seed()
model <- fit(model, x = samp$train)

attr(model, "params")

# Obtain one-step-ahead fitted values on the training portion.
adjust <- predict(model, samp$train)
adjust <- as.vector(adjust)

ev_adjust <- evaluate(model, as.vector(samp$train), adjust)
ev_adjust$metrics

# Forecast one step ahead from the last observed training point.
prediction <- predict(model, x = samp$test, steps_ahead = 1)
prediction <- as.vector(prediction)

output <- as.vector(samp$test)
ev_test <- evaluate(model, output, prediction)
ev_test

# Plot the one-step fitted segment and the forecasted point.
yvalues <- c(samp$train, samp$test)
plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "green") +
  theme(text = element_text(size = 16))
