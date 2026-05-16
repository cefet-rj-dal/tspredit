source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Install tspredit if needed
#install.packages("tspredit")

# Load packages
library(daltoolbox)
library(tspredit) 

# Create a simple cosine series for demonstration

i <- seq(0, 25, 0.25)
x <- cos(i)

# Visualize the time series
plot_ts(x=i, y=x) + theme(text = element_text(size=16))

# Sliding windows

# Create a sliding-window matrix for supervised learning.
# Each row contains 10 attributes (t9..t0) representing the last 10 observations.
sw_size <- 10
ts <- ts_data(x, sw_size)
ts_head(ts, 3)

# Data sampling (train/test split)

test_size <- 1                  # keep last step for testing
samp <- ts_sample(ts, test_size)
ts_head(samp$train, 3)
ts_head(samp$test)

# Define integrated tuning

# We will:
# - search over input window sizes (3..5)
# - use ELM as the base model
# - apply global min-max normalization as preprocessing
# - explore ranges for hidden units and activation function

tune <- ts_integtune(
  input_size = c(3:5),
  base_model = ts_elm(),
  preprocess = list(ts_norm_gminmax()),
  ranges = list(
    nhid = 1:10,
    actfun = c("sig", "radbas", "relu", "purelin")
  )
)


# Fit the tuned pipeline on training data

io_train <- ts_projection(samp$train)
set_example_seed()
model <- fit(tune, x=io_train$input, y=io_train$output)

# Evaluate training adjustment (in-sample)

adjust <- predict(model, io_train$input)
ev_adjust <- evaluate(model, io_train$output, adjust)
print(head(ev_adjust$metrics))

# Forecast on the test segment

steps_ahead <- 1
io_test <- ts_projection(samp$test)
prediction <- predict(model, x=io_test$input, steps_ahead=steps_ahead)
prediction <- as.vector(prediction)

output <- as.vector(io_test$output)
if (steps_ahead > 1)
    output <- output[1:steps_ahead]

print(sprintf("%.2f, %.2f", output, prediction))

# Evaluate test performance

ev_test <- evaluate(model, output, prediction)
print(head(ev_test$metrics))
print(sprintf("smape: %.2f", 100*ev_test$metrics$smape))

# Plot results

yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y=yvalues, yadj=adjust, ypre=prediction, color_prediction=if (steps_ahead == 1) "green" else "orange") + theme(text = element_text(size=16))

# Example hyperparameter ranges by model

# ELM
ranges_elm <- list(
  nhid = 1:10,
  actfun = c("sig", "radbas", "relu", "purelin")
)

# MLP
ranges_mlp <- list(
  size = 1:8,
  decay = c(0, 1e-4, 1e-3, 1e-2, 1e-1),
  maxit = c(500, 1000, 2000)
)

# RF
ranges_rf <- list(
  nodesize = c(1, 3, 5),
  ntree = c(50, 100, 200),
  mtry = 1:3
)

# SVM
ranges_svm <- list(
  kernel = c("radial", "linear", "polynomial", "sigmoid"),
  epsilon = c(0, 0.01, 0.05, 0.1, 0.2),
  cost = c(1, 5, 10, 20, 50)
)

# LSTM
ranges_lstm <- list(hidden_size = c(4L, 8L, 16L), epochs = c(50L, 100L, 200L))

# CNN
ranges_cnn <- list(conv_channels = c(16L, 32L, 64L), epochs = c(50L, 100L, 200L))
