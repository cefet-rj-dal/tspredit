source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load packages and example data.
library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed(123L)
data(tsd)

# Build sliding windows from the original series.
ts <- ts_data(tsd$y, 10)
samp <- ts_sample(ts, test_size = 5)

# Split the data in time order before augmentation.
train_ts <- samp$train
test_ts <- samp$test

io_train <- ts_projection(train_ts)
io_test <- ts_projection(test_ts)

# Augment the training windows with jitter.
augment_model <- ts_aug_jitter()
set_example_seed()
augment_model <- fit(augment_model, train_ts)

train_aug <- transform(augment_model, train_ts)
train_aug <- adjust_ts_data(train_aug)
io_train_aug <- ts_projection(train_aug)

# Compare the original and augmented training sizes.
data.frame(
  original_train_rows = nrow(train_ts),
  augmented_train_rows = nrow(train_aug)
)

# Fit the MLP on the augmented training set.
model <- ts_mlp(
  preprocess = ts_norm_gminmax(),
  input_size = 4,
  size = 4,
  decay = 0,
  maxit = 1000
)

set_example_seed()
model <- fit(model, x = io_train_aug$input, y = io_train_aug$output)

# Forecast the test block without augmenting test data.
prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
output <- as.vector(io_test$output)

ev_test <- evaluate(model, output, prediction)
ev_test

# Inspect the forecasted test horizon.
data.frame(
  step = 1:5,
  observed = output,
  predicted = prediction
)

# Plot the fit on the original train horizon and the forecast on test.
adjust <- as.vector(predict(model, io_train$input))
yvalues <- c(io_train$output, io_test$output)

plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
