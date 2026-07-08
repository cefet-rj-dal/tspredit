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
## [1] 64.21256
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
## [1] 56.43872
## 
## attr(,"prediction_x")$high
## [1] 59.18546
## 
## attr(,"prediction_x")$low
## [1] 67.18695
## 
## attr(,"prediction_x")$volume
## [1] 22833129
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 64.21256 56.43872 59.18546 67.18695 22833129
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 64.21256 63.12149 62.10226 61.22563 60.52991
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
## [1] 56.43872 58.24267 58.88176 59.30090 59.56145
## 
## attr(,"prediction_x")$high
## [1] 59.18546 60.13043 60.07667 60.07203 60.07816
## 
## attr(,"prediction_x")$low
## [1] 67.18695 62.90900 61.27096 60.32860 59.79816
## 
## attr(,"prediction_x")$volume
## [1] 22833129 22832406 22831996 22830873 22829695
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 64.21256 56.43872 59.18546 67.18695 22833129
## 2 63.12149 58.24267 60.13043 62.90900 22832406
## 3 62.10226 58.88176 60.07667 61.27096 22831996
## 4 61.22563 59.30090 60.07203 60.32860 22830873
## 5 60.52991 59.56145 60.07816 59.79816 22829695
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##      close     open     high      low   volume
## 1 64.21256 56.43872 59.18546 67.18695 22833129
## 2 63.12149 58.24267 60.13043 62.90900 22832406
## 3 62.10226 58.88176 60.07667 61.27096 22831996
## 4 61.22563 59.30090 60.07203 60.32860 22830873
## 5 60.52991 59.56145 60.07816 59.79816 22829695
```


``` r
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse     smape        R2
## 1 642.3235 0.3381634 -303.0932
```


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

![plot of chunk unnamed-chunk-9](fig/18-stock-close-lstm-regression/unnamed-chunk-9-1.png)

What this example shows
- `ts_lstm()` can be reused directly as the target learner inside `ts_regsw_mv()`.
- The same learner family can be reused for the target and for all endogenous auxiliaries when the goal is a cleaner didactic comparison.
