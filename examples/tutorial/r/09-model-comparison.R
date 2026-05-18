source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load the example dataset.
library(daltoolbox)
library(tspredit)

set_example_seed(123L)
data(tsd)

# Prepare the raw-series and sliding-window views of the same signal.
ts_raw <- ts_data(tsd$y, 1)
ts_win <- ts_data(tsd$y, 10)

# Create one-step train/test splits for both representations.
samp_raw_1 <- ts_sample(ts_raw, test_size = 1)
samp_win_1 <- ts_sample(ts_win, test_size = 1)

io_win_train_1 <- ts_projection(samp_win_1$train)
io_win_test_1 <- ts_projection(samp_win_1$test)

# Fit both models and forecast one point ahead.
arima_1 <- ts_arima()
set_example_seed()
arima_1 <- fit(arima_1, x = samp_raw_1$train)
pred_arima_1 <- as.vector(predict(arima_1, x = samp_raw_1$test, steps_ahead = 1))

mlp_1 <- ts_mlp(ts_norm_gminmax(), input_size = 4, size = 4, decay = 0, maxit = 1000)
set_example_seed()
mlp_1 <- fit(mlp_1, x = io_win_train_1$input, y = io_win_train_1$output)
pred_mlp_1 <- as.vector(predict(mlp_1, x = io_win_test_1$input[1:1, ], steps_ahead = 1))

obs_1 <- as.vector(io_win_test_1$output)

# Compare one-step metrics.
rbind(
  cbind(model = "ARIMA", evaluate(arima_1, obs_1, pred_arima_1)$metrics),
  cbind(model = "MLP", evaluate(mlp_1, obs_1, pred_mlp_1)$metrics)
)

# Build rolling-origin splits with five held-out observations.
samp_raw_roll <- ts_sample(ts_raw, test_size = 5)
samp_win_roll <- ts_sample(ts_win, test_size = 5)

io_win_train_roll <- ts_projection(samp_win_roll$train)
io_win_test_roll <- ts_projection(samp_win_roll$test)

# Fit both models and run rolling-origin forecasts.
arima_roll <- ts_arima()
set_example_seed()
arima_roll <- fit(arima_roll, x = samp_raw_roll$train)
pred_arima_roll <- as.vector(predict(arima_roll, x = samp_raw_roll$test, steps_ahead = 1))

mlp_roll <- ts_mlp(ts_norm_gminmax(), input_size = 4, size = 4, decay = 0, maxit = 1000)
set_example_seed()
mlp_roll <- fit(mlp_roll, x = io_win_train_roll$input, y = io_win_train_roll$output)
pred_mlp_roll <- as.vector(predict(mlp_roll, x = io_win_test_roll$input, steps_ahead = 1))

obs_roll <- as.vector(io_win_test_roll$output)

# Compare rolling-origin metrics.
rbind(
  cbind(model = "ARIMA", evaluate(arima_roll, obs_roll, pred_arima_roll)$metrics),
  cbind(model = "MLP", evaluate(mlp_roll, obs_roll, pred_mlp_roll)$metrics)
)

# Compare direct multi-step forecasts over the same five-step horizon.
pred_arima_ms <- as.vector(predict(arima_roll, x = samp_raw_roll$test[1], steps_ahead = 5))
pred_mlp_ms <- as.vector(predict(mlp_roll, x = io_win_test_roll$input[1:1, ], steps_ahead = 5))

obs_ms <- as.vector(io_win_test_roll$output)

# Compare multi-step-ahead metrics.
rbind(
  cbind(model = "ARIMA", evaluate(arima_roll, obs_ms, pred_arima_ms)$metrics),
  cbind(model = "MLP", evaluate(mlp_roll, obs_ms, pred_mlp_ms)$metrics)
)

# Inspect the final multi-step trajectories.
data.frame(
  step = 1:5,
  observed = obs_ms,
  pred_arima = pred_arima_ms,
  pred_mlp = pred_mlp_ms
)
