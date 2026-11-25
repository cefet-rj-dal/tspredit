## Stock Closing-Price Forecasting with MLP as Target Learner

About the method
- This example keeps the same stock-closing-price scenario, but now the target `close` is forecast with `ts_mlp()`.

Didactic goal: inspect how a multilayer perceptron behaves as the target learner inside the target-centered multivariate workflow.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Stock closing-price forecasting with MLP as target learner

# Installing packages (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```


``` r
data(stocks)

if (!is.null(attr(stocks, "url"))) {
  stocks <- loadfulldata(stocks)
}

ticker_name <- if ("VALE3" %in% names(stocks)) "VALE3" else names(stocks)[1]
ticker <- stocks[[ticker_name]]
ticker <- ticker[, c("date", "open", "high", "low", "close", "volume")]
ticker <- stats::na.omit(ticker)
ticker <- subset(ticker, open > 0 & high > 0 & low > 0 & volume > 0)
cutoff_date <- max(ticker$date) - 365
ticker <- ticker[ticker$date > cutoff_date, ]

mv <- ts_data_mv(
  ticker[, c("open", "high", "low", "close", "volume")],
  y = "close",
  x = c("open", "high", "low", "volume")
)

samp <- ts_sample(mv, test_size = 5)
output <- tail(samp$test$close, 5)
```


``` r
model <- ts_regsw_mv(
  model_y = ts_mv_spec(
    ts_mlp(ts_norm_gminmax(), input_size = 4, size = 3, decay = 0, maxit = 50),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_mlp(ts_norm_gminmax(), input_size = 3, size = 3, decay = 0, maxit = 50),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_mlp(ts_norm_gminmax(), input_size = 3, size = 3, decay = 0, maxit = 50),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_mlp(ts_norm_gminmax(), input_size = 3, size = 3, decay = 0, maxit = 50),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_mlp(ts_norm_gminmax(), input_size = 3, size = 3, decay = 0, maxit = 50),
      variables = c("volume", "close", "open")
    )
  ),
  window_size = 5
)
```


``` r
set_example_seed()
model <- fit(model, samp$train)
pred_1 <- predict(model, steps_ahead = 1)
pred_1
```

```
## [1] 85.71934
## attr(,"y_name")
## [1] "close"
## attr(,"x_names")
## [1] "open"   "high"   "low"    "volume"
## attr(,"variables")
## [1] "close"  "open"   "high"   "low"    "volume"
## attr(,"steps_ahead")
## [1] 1
## attr(,"prediction_x")
## attr(,"prediction_x")$open
## [1] 86.00116
## 
## attr(,"prediction_x")$high
## [1] 87.49194
## 
## attr(,"prediction_x")$low
## [1] 85.52673
## 
## attr(,"prediction_x")$volume
## [1] 23156233
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 85.71934 86.00116 87.49194 85.52673 23156233
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 85.71934 86.72840 86.81184 86.14814 86.02339
## attr(,"y_name")
## [1] "close"
## attr(,"x_names")
## [1] "open"   "high"   "low"    "volume"
## attr(,"variables")
## [1] "close"  "open"   "high"   "low"    "volume"
## attr(,"steps_ahead")
## [1] 5
## attr(,"prediction_x")
## attr(,"prediction_x")$open
## [1] 86.00116 85.19367 85.60119 86.40139 85.80143
## 
## attr(,"prediction_x")$high
## [1] 87.49194 88.53915 88.59214 88.13705 87.80729
## 
## attr(,"prediction_x")$low
## [1] 85.52673 85.92770 85.33525 85.90062 85.78070
## 
## attr(,"prediction_x")$volume
## [1] 23156233 29050471 27906794 26263887 24386466
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 85.71934 86.00116 87.49194 85.52673 23156233
## 2 86.72840 85.19367 88.53915 85.92770 29050471
## 3 86.81184 85.60119 88.59214 85.33525 27906794
## 4 86.14814 86.40139 88.13705 85.90062 26263887
## 5 86.02339 85.80143 87.80729 85.78070 24386466
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##      close     open     high      low   volume
## 1 85.71934 86.00116 87.49194 85.52673 23156233
## 2 86.72840 85.19367 88.53915 85.92770 29050471
## 3 86.81184 85.60119 88.59214 85.33525 27906794
## 4 86.14814 86.40139 88.13705 85.90062 26263887
## 5 86.02339 85.80143 87.80729 85.78070 24386466
```


``` r
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse      smape        R2
## 1 4.010121 0.01863371 -0.898499
```


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

```
## Error:
## ! 'plot_ts_pred' is not an exported object from 'namespace:daltoolbox'
```

What this example shows
- `ts_mlp()` can be reused directly as the target learner inside `ts_regsw_mv()`.
- The same learner family can be reused for the target and for all endogenous auxiliaries when the goal is a cleaner didactic comparison.
