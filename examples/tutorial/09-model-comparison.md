# Tutorial 09 - Comparing ARIMA and MLP

By now we have seen two modeling families:

- ARIMA, which works directly on the ordered series;
- MLP, which works on lagged windows and an explicit preprocessing pipeline.

This tutorial compares them under the same data and three forecasting protocols.

The purpose is not to declare a universal winner, but to show how the ranking can change when the prediction task changes.

## Goal

Compare ARIMA and MLP in:

- one-step prediction;
- rolling-origin evaluation;
- multiple steps ahead.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load the example dataset.
library(daltoolbox)
library(tspredit)

set_example_seed(123L)
data(tsd)
```

The next block prepares both data views: the raw sequence for ARIMA and the sliding-window representation for MLP.


``` r
# Prepare the raw-series and sliding-window views of the same signal.
ts_raw <- ts_data(tsd$y, 0)
ts_win <- ts_data(tsd$y, 10)
```

## One-step prediction

We start with the easiest protocol: forecast a single future point.


``` r
# Create one-step train/test splits for both representations.
samp_raw_1 <- ts_sample(ts_raw, test_size = 1)
samp_win_1 <- ts_sample(ts_win, test_size = 1)

io_win_train_1 <- ts_projection(samp_win_1$train)
io_win_test_1 <- ts_projection(samp_win_1$test)
```

Now we fit both models and generate their one-step forecasts.


``` r
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
```

We compare the metrics side by side.

The same interpretation applies in every table below: lower `mse` and `smape` are better, while higher `R2` is better. In particular, `R2 < 0` means the model is doing worse than the constant-mean baseline on that forecasting protocol.


``` r
# Compare one-step metrics.
rbind(
  cbind(model = "ARIMA", evaluate(arima_1, obs_1, pred_arima_1)$metrics),
  cbind(model = "MLP", evaluate(mlp_1, obs_1, pred_mlp_1)$metrics)
)
```

```
##   model          mse       smape R2
## 1 ARIMA 5.742510e-02 0.564906650 NA
## 2   MLP 1.444428e-05 0.006961741 NA
```

## Rolling-origin evaluation

Next, we compare repeated one-step forecasts across a longer test horizon.


``` r
# Build rolling-origin splits with five held-out observations.
samp_raw_roll <- ts_sample(ts_raw, test_size = 5)
samp_win_roll <- ts_sample(ts_win, test_size = 5)

io_win_train_roll <- ts_projection(samp_win_roll$train)
io_win_test_roll <- ts_projection(samp_win_roll$test)
```


``` r
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
```


``` r
# Compare rolling-origin metrics.
rbind(
  cbind(model = "ARIMA", evaluate(arima_roll, obs_roll, pred_arima_roll)$metrics),
  cbind(model = "MLP", evaluate(mlp_roll, obs_roll, pred_mlp_roll)$metrics)
)
```

```
##   model          mse     smape        R2
## 1 ARIMA 5.416739e-02 1.0075409 0.5321534
## 2   MLP 2.136026e-05 0.0148602 0.9998155
```

## Multiple steps ahead

Finally, we compare direct multi-step forecasts over the same horizon.


``` r
# Compare direct multi-step forecasts over the same five-step horizon.
pred_arima_ms <- as.vector(predict(arima_roll, x = samp_raw_roll$test[1], steps_ahead = 5))
pred_mlp_ms <- as.vector(predict(mlp_roll, x = io_win_test_roll$input[1:1, ], steps_ahead = 5))

obs_ms <- as.vector(io_win_test_roll$output)
```


``` r
# Compare multi-step-ahead metrics.
rbind(
  cbind(model = "ARIMA", evaluate(arima_roll, obs_ms, pred_arima_ms)$metrics),
  cbind(model = "MLP", evaluate(mlp_roll, obs_ms, pred_mlp_ms)$metrics)
)
```

```
##   model          mse      smape        R2
## 1 ARIMA 0.4904025339 1.48971099 -3.235632
## 2   MLP 0.0001001462 0.06058831  0.999135
```

To close the comparison, we place the observed and predicted trajectories together.


``` r
# Inspect the final multi-step trajectories.
data.frame(
  step = 1:5,
  observed = obs_ms,
  pred_arima = pred_arima_ms,
  pred_mlp = pred_mlp_ms
)
```

```
##   step    observed pred_arima    pred_mlp
## 1    1  0.41211849  0.6011374  0.41787725
## 2    2  0.17388949  0.5784414  0.18362848
## 3    3 -0.07515112  0.5566023 -0.06273766
## 4    4 -0.31951919  0.5355877 -0.30699150
## 5    5 -0.54402111  0.5153665 -0.53616730
```

## Interpretation

This comparison shows an important practical point: the best model can depend on the forecasting protocol.

A model may be strong when forecasting one point ahead and weaker when projecting several values into the future. That is why the evaluation protocol should always match the intended use case.

