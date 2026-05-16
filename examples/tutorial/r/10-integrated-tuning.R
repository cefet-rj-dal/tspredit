source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load packages and the example dataset.
library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed(123L)
data(tsd)

# Create sliding windows and preserve time order in the split.
ts <- ts_data(tsd$y, 10)
samp <- ts_sample(ts, test_size = 5)

io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

# Define the integrated search space.
tune <- ts_integtune(
  input_size = 3:5,
  base_model = ts_mlp(),
  folds = 3,
  preprocess = list(ts_norm_gminmax(), ts_norm_an()),
  augment = list(ts_aug_none(), ts_aug_jitter()),
  ranges = list(
    size = 2:4,
    decay = c(0, 0.01),
    maxit = c(500)
  )
)

# Fit the integrated tuning process.
set_example_seed()
model <- fit(tune, x = io_train$input, y = io_train$output)

# Inspect the best configuration found by the tuner.
attr(model, "params")

# Inspect the tuning table generated during the search.
head(attr(model, "hyperparameters"))

# Forecast the final five-step horizon with the tuned pipeline.
prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
output <- as.vector(io_test$output)

ev_test <- evaluate(model, output, prediction)
ev_test

# Evaluate the tuned model on the training data.
adjust <- as.vector(predict(model, io_train$input))
ev_adjust <- evaluate(model, as.vector(io_train$output), adjust)
ev_adjust$metrics

# Plot the tuned fit and forecast.
yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
