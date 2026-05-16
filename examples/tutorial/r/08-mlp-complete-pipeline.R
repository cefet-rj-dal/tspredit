source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load package and example data.
library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed(123L)
data(tsd)

# Filter the original series before creating lag windows.
filter_model <- ts_fil_smooth()
set_example_seed()
filter_model <- fit(filter_model, tsd$y)
y_filtered <- transform(filter_model, tsd$y)

# Visualize the filtering effect before moving on.
plot_ts_pred(y = tsd$y, yadj = y_filtered) + theme(text = element_text(size = 16))

# Build windows and split the filtered series into train and test.
ts_filtered <- ts_data(y_filtered, 10)
samp <- ts_sample(ts_filtered, test_size = 5)

train_ts <- samp$train
test_ts <- samp$test

# Apply augmentation only to the training windows.
augment_model <- ts_aug_jitter()
set_example_seed()
augment_model <- fit(augment_model, train_ts)

train_aug <- transform(augment_model, train_ts)
train_aug <- adjust_ts_data(train_aug)

io_train <- ts_projection(train_aug)
io_test <- ts_projection(test_ts)

# Fit the MLP with adaptive normalization on the augmented training windows.
model <- ts_mlp(
  preprocess = ts_norm_an(),
  input_size = 4,
  size = 4,
  decay = 0,
  maxit = 1000
)

set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)

# Evaluate fit on the augmented training set.
adjust <- as.vector(predict(model, io_train$input))
ev_adjust <- evaluate(model, as.vector(io_train$output), adjust)
ev_adjust$metrics

# Forecast the final test horizon with the complete pipeline.
prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
output <- as.vector(io_test$output)

ev_test <- evaluate(model, output, prediction)
ev_test

# Compare observed and predicted values for the final horizon.
data.frame(
  step = 1:5,
  observed = output,
  predicted = prediction
)

# Plot the fit and forecast produced by the complete MLP pipeline.
yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
