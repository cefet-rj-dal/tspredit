source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load package and example data.
library(daltoolbox)
library(tspredit)
library(ggplot2)

data(tsd)

# Plot the full series.
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))

# Build the series object without sliding windows.
ts <- ts_data(tsd$y, 1)

# Reserve the final five observations for a multi-step-ahead forecast.
samp <- ts_sample(ts, test_size = 5)
ts_head(samp$train, 3)
ts_head(samp$test, 3)

# Fit the ARIMA model.
model <- ts_arima(p = 5, d = 0, q = 0)
set_example_seed()
model <- fit(model, x = samp$train)

# Forecast five future values directly from the trained model.
prediction <- predict(model, x = samp$test[1], steps_ahead = 5)
prediction <- as.vector(prediction)

output <- as.vector(samp$test)
ev_test <- evaluate(model, output, prediction)
ev_test

# Show the five-step-ahead forecast next to the observed horizon.
data.frame(
  step = seq_along(output),
  observed = output,
  predicted = prediction
)

# Plot training adjustment and direct multi-step forecast.
adjust <- as.vector(predict(model, samp$train))
yvalues <- c(samp$train, samp$test)

plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
