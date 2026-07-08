## Stock Closing-Price Forecasting with Conv1D as Target Learner

About the method
- This example keeps the same stock-closing-price scenario, but now the target `close` is forecast with `ts_conv1d()`.

Didactic goal: inspect how a 1D convolutional network behaves as the target learner inside the target-centered multivariate workflow.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Stock closing-price forecasting with Conv1D as target learner

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
    ts_conv1d(ts_norm_gminmax(), input_size = 4, epochs = 10),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 10),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 10),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 10),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 10),
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
## [1] 88.55526
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
## [1] 87.7425
## 
## attr(,"prediction_x")$high
## [1] 89.34911
## 
## attr(,"prediction_x")$low
## [1] 84.28822
## 
## attr(,"prediction_x")$volume
## [1] 28726787
## 
## attr(,"system")
##      close    open     high      low   volume
## 1 88.55526 87.7425 89.34911 84.28822 28726787
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 88.55526 89.23085 89.60964 89.96571 90.73861
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
## [1] 87.74250 88.40583 89.04402 89.56235 90.56488
## 
## attr(,"prediction_x")$high
## [1] 89.34911 90.11322 90.71683 91.42587 92.50438
## 
## attr(,"prediction_x")$low
## [1] 84.28822 84.70000 84.82525 84.99555 85.58810
## 
## attr(,"prediction_x")$volume
## [1] 28726787 30910898 33101213 31815215 30227923
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 88.55526 87.74250 89.34911 84.28822 28726787
## 2 89.23085 88.40583 90.11322 84.70000 30910898
## 3 89.60964 89.04402 90.71683 84.82525 33101213
## 4 89.96571 89.56235 91.42587 84.99555 31815215
## 5 90.73861 90.56488 92.50438 85.58810 30227923
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##      close     open     high      low   volume
## 1 88.55526 87.74250 89.34911 84.28822 28726787
## 2 89.23085 88.40583 90.11322 84.70000 30910898
## 3 89.60964 89.04402 90.71683 84.82525 33101213
## 4 89.96571 89.56235 91.42587 84.99555 31815215
## 5 90.73861 90.56488 92.50438 85.58810 30227923
```


``` r
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse      smape        R2
## 1 8.153164 0.02618311 -2.859927
```


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

![plot of chunk unnamed-chunk-9](fig/17-stock-close-conv1d-regression/unnamed-chunk-9-1.png)

What this example shows
- `ts_conv1d()` can be reused directly as the target learner inside `ts_regsw_mv()`.
- The same learner family can be reused for the target and for all endogenous auxiliaries when the goal is a cleaner didactic comparison.
