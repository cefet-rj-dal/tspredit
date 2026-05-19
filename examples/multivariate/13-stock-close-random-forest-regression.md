## Stock Closing-Price Forecasting with Random Forest as Target Learner

About the method
- This example keeps the same stock-closing-price scenario, but now the target `close` is forecast with `ts_rf()`.

Didactic goal: inspect how a random forest behaves as the target learner inside the target-centered multivariate workflow.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Stock closing-price forecasting with Random Forest as target learner

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
cutoff_date <- max(ticker$date) - 365 * 2
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
    ts_rf(ts_norm_gminmax(), input_size = 4, nodesize = 1, ntree = 100),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_rf(ts_norm_gminmax(), input_size = 3, nodesize = 1, ntree = 100),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_rf(ts_norm_gminmax(), input_size = 3, nodesize = 1, ntree = 100),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_rf(ts_norm_gminmax(), input_size = 3, nodesize = 1, ntree = 100),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_rf(ts_norm_gminmax(), input_size = 3, nodesize = 1, ntree = 100),
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
## [1] 86.3301
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
## [1] 86.3875
## 
## attr(,"prediction_x")$high
## [1] 87.8604
## 
## attr(,"prediction_x")$low
## [1] 85.3674
## 
## attr(,"prediction_x")$volume
## [1] 33311755
## 
## attr(,"system")
##     close    open    high     low   volume
## 1 86.3301 86.3875 87.8604 85.3674 33311755
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 86.3301 86.0448 85.4388 85.7633 85.9880
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
## [1] 86.3875 86.6744 86.0593 86.3069 86.6225
## 
## attr(,"prediction_x")$high
## [1] 87.8604 87.9481 87.4504 87.5042 87.8782
## 
## attr(,"prediction_x")$low
## [1] 85.3674 85.5644 84.9202 85.2543 85.4405
## 
## attr(,"prediction_x")$volume
## [1] 33311755 39028010 36387377 32137987 33762048
## 
## attr(,"system")
##     close    open    high     low   volume
## 1 86.3301 86.3875 87.8604 85.3674 33311755
## 2 86.0448 86.6744 87.9481 85.5644 39028010
## 3 85.4388 86.0593 87.4504 84.9202 36387377
## 4 85.7633 86.3069 87.5042 85.2543 32137987
## 5 85.9880 86.6225 87.8782 85.4405 33762048
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##     close    open    high     low   volume
## 1 86.3301 86.3875 87.8604 85.3674 33311755
## 2 86.0448 86.6744 87.9481 85.5644 39028010
## 3 85.4388 86.0593 87.4504 84.9202 36387377
## 4 85.7633 86.3069 87.5042 85.2543 32137987
## 5 85.9880 86.6225 87.8782 85.4405 33762048
```


``` r
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse      smape        R2
## 1 4.264516 0.01950095 -1.018936
```


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

![plot of chunk unnamed-chunk-9](fig/13-stock-close-random-forest-regression/unnamed-chunk-9-1.png)

What this example shows
- `ts_rf()` can be reused directly as the target learner inside `ts_regsw_mv()`.
- The same learner family can be reused for the target and for all endogenous auxiliaries when the goal is a cleaner didactic comparison.
