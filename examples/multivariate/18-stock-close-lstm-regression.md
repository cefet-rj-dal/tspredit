## Stock Closing-Price Forecasting with LSTM as Target Learner

About the method
- This example keeps the same stock-closing-price scenario, but now the target `close` is forecast with `ts_lstm()`.

Didactic goal: inspect how an LSTM behaves as the target learner inside the target-centered multivariate workflow.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Stock closing-price forecasting with LSTM as target learner

# Installing packages (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(daltoolboxdp)
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
    ts_lstm(ts_norm_gminmax(), input_size = 4, epochs = 10),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_lstm(ts_norm_gminmax(), input_size = 3, epochs = 10),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_lstm(ts_norm_gminmax(), input_size = 3, epochs = 10),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_lstm(ts_norm_gminmax(), input_size = 3, epochs = 10),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_lstm(ts_norm_gminmax(), input_size = 3, epochs = 10),
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
## [1] 74.49954
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
## [1] 67.13967
## 
## attr(,"prediction_x")$high
## [1] 67.86573
## 
## attr(,"prediction_x")$low
## [1] 67.06578
## 
## attr(,"prediction_x")$volume
## [1] 23279579
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 74.49954 67.13967 67.86573 67.06578 23279579
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 74.49954 73.57838 71.07175 69.89868 68.04403
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
## [1] 67.13967 67.70867 66.18850 64.68147 63.51151
## 
## attr(,"prediction_x")$high
## [1] 67.86573 67.95517 65.77867 66.50032 65.21691
## 
## attr(,"prediction_x")$low
## [1] 67.06578 66.91908 67.35802 66.82295 66.66033
## 
## attr(,"prediction_x")$volume
## [1] 23279579 24004661 23914327 23421989 23079636
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 74.49954 67.13967 67.86573 67.06578 23279579
## 2 73.57838 67.70867 67.95517 66.91908 24004661
## 3 71.07175 66.18850 65.77867 67.35802 23914327
## 4 69.89868 64.68147 66.50032 66.82295 23421989
## 5 68.04403 63.51151 65.21691 66.66033 23079636
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##      close     open     high      low   volume
## 1 74.49954 67.13967 67.86573 67.06578 23279579
## 2 73.57838 67.70867 67.95517 66.91908 24004661
## 3 71.07175 66.18850 65.77867 67.35802 23914327
## 4 69.89868 64.68147 66.50032 66.82295 23421989
## 5 68.04403 63.51151 65.21691 66.66033 23079636
```


``` r
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse     smape        R2
## 1 263.2779 0.2034654 -123.6428
```


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

![plot of chunk unnamed-chunk-9](fig/18-stock-close-lstm-regression/unnamed-chunk-9-1.png)

What this example shows
- `ts_lstm()` can be reused directly as the target learner inside `ts_regsw_mv()`.
- The same learner family can be reused for the target and for all endogenous auxiliaries when the goal is a cleaner didactic comparison.
