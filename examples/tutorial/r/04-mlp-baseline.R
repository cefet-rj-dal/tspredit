source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load packages and example series.
library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed(123L)
data(tsd)

# Inspect the original series.
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))

# Create sliding windows with 10 lagged values per row.
sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)

# Split the windows in time order and project them into X and y.
samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

# Define the preprocessing object used by the model.
preproc <- ts_norm_gminmax()
preproc

# Configure and fit the baseline MLP model.
model <- ts_mlp(
  preprocess = ts_norm_gminmax(),
  input_size = 4,
  size = 4,
  decay = 0,
  maxit = 1000
)

set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)

# Evaluate the fitted values on the training portion.
adjust <- predict(model, io_train$input)
adjust <- as.vector(adjust)

ev_adjust <- evaluate(model, as.vector(io_train$output), adjust)
ev_adjust$metrics

# Forecast the five-point test horizon.
prediction <- predict(model, x = io_test$input[1:1, ], steps_ahead = 5)
prediction <- as.vector(prediction)

output <- as.vector(io_test$output)
ev_test <- evaluate(model, output, prediction)
ev_test

# Plot the baseline MLP fit and forecast.
yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
