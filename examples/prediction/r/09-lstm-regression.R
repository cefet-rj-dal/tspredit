source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Time Series Regression - LSTM

# Installing packages (if needed)

#install.packages("tspredit")

# Loading the packages
library(daltoolbox)
library(daltoolboxdp)
library(tspredit)

# Series for study and sliding windows

data(tsd)
ts <- ts_data(tsd$y, 10)
ts_head(ts, 3)

# Series visualization
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Train-test split and projection (X, y)

samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

# Training the LSTM model

model <- ts_lstm(
  ts_norm_gminmax(),
  input_size = 4,
  hidden_size = 16L,
  mlp_hidden_sizes = c(8L),
  batch_size = 4L,
  epochs = 200L
)
set_example_seed()
model <- fit(model, x=io_train$input, y=io_train$output)

# Fit evaluation (train)

adjust <- predict(model, io_train$input)
adjust <- as.vector(adjust)
output <- as.vector(io_train$output)
ev_adjust <- evaluate(model, output, adjust)
ev_adjust$mse

# Forecast on test set

steps_ahead <- 5
io_test <- ts_projection(samp$test)
prediction <- predict(model, x=io_test$input[1,], steps_ahead=steps_ahead)
prediction <- as.vector(prediction)

output <- as.vector(io_test$output)
if (steps_ahead > 1)
    output <- output[1:steps_ahead]

print(sprintf("%.2f, %.2f", output, prediction))

# Test evaluation

ev_test <- evaluate(model, output, prediction)
print(head(ev_test$metrics))
print(sprintf("smape: %.2f", 100*ev_test$metrics$smape))

# Plot results

yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y=yvalues, yadj=adjust, ypre=prediction, color_prediction=if (steps_ahead == 1) "green" else "orange") + theme(text = element_text(size=16))
