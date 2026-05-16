source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load packages and the example data.
library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed(123L)
data(tsd)

# Plot the original series.
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))

# Filter the original series before creating the supervised-learning windows.
filter_model <- ts_fil_smooth()
set_example_seed()
filter_model <- fit(filter_model, tsd$y)
y_filtered <- transform(filter_model, tsd$y)

# Compare the original and filtered series.
plot_ts_pred(y = tsd$y, yadj = y_filtered) + theme(text = element_text(size = 16))

# Build the forecasting dataset from the filtered signal.
ts_filtered <- ts_data(y_filtered, 10)
samp <- ts_sample(ts_filtered, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

# Fit a baseline MLP on the filtered series.
model <- ts_mlp(
  preprocess = ts_norm_gminmax(),
  input_size = 4,
  size = 4,
  decay = 0,
  maxit = 1000
)

set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)

# Evaluate fit on train and forecast on the test block.
adjust <- as.vector(predict(model, io_train$input))
prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))

train_metrics <- evaluate(model, as.vector(io_train$output), adjust)$metrics
test_metrics <- evaluate(model, as.vector(io_test$output), prediction)$metrics

train_metrics
test_metrics

# Plot the MLP fit and forecast after filtering.
yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
