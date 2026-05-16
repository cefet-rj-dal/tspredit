source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load package and example data.
library(daltoolbox)
library(tspredit)
library(ggplot2)

data(tsd)

# Visualize the series before splitting it.
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))

# Keep the series as a single ordered sequence.
ts <- ts_data(tsd$y, 0)

# Reserve the last five observations for rolling-origin evaluation.
samp <- ts_sample(ts, test_size = 5)
ts_head(samp$train, 3)
ts_head(samp$test, 3)

# Fit ARIMA on the training data.
model <- ts_arima(p = 5, d = 0, q = 0)
set_example_seed()
model <- fit(model, x = samp$train)

# Predict one step at a time across the test horizon.
prediction <- predict(model, x = samp$test, steps_ahead = 1)
prediction <- as.vector(prediction)

output <- as.vector(samp$test)
ev_test <- evaluate(model, output, prediction)
ev_test

# Compare observed and predicted values over the rolling horizon.
data.frame(
  step = seq_along(output),
  observed = output,
  predicted = prediction
)

# Plot fitted values and rolling-origin predictions.
adjust <- as.vector(predict(model, samp$train))
yvalues <- c(samp$train, samp$test)

plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "green") +
  theme(text = element_text(size = 16))
