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
    ts_conv1d(ts_norm_gminmax(), input_size = 4, epochs = 250),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 250),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 250),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 250),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_conv1d(ts_norm_gminmax(), input_size = 3, epochs = 250),
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
## [1] 86.91065
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
## [1] 87.31257
## 
## attr(,"prediction_x")$high
## [1] 88.62595
## 
## attr(,"prediction_x")$low
## [1] 85.99574
## 
## attr(,"prediction_x")$volume
## [1] 23544511
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 86.91065 87.31257 88.62595 85.99574 23544511
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 86.91065 88.24291 87.14563 86.88355 87.81946
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
## [1] 87.31257 87.82819 87.56717 88.01512 88.45589
## 
## attr(,"prediction_x")$high
## [1] 88.62595 90.77804 90.63519 89.65869 90.07406
## 
## attr(,"prediction_x")$low
## [1] 85.99574 87.32941 86.26192 86.12640 87.04067
## 
## attr(,"prediction_x")$volume
## [1] 23544511 26505994 26617528 25856977 25620391
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 86.91065 87.31257 88.62595 85.99574 23544511
## 2 88.24291 87.82819 90.77804 87.32941 26505994
## 3 87.14563 87.56717 90.63519 86.26192 26617528
## 4 86.88355 88.01512 89.65869 86.12640 25856977
## 5 87.81946 88.45589 90.07406 87.04067 25620391
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##      close     open     high      low   volume
## 1 86.91065 87.31257 88.62595 85.99574 23544511
## 2 88.24291 87.82819 90.77804 87.32941 26505994
## 3 87.14563 87.56717 90.63519 86.26192 26617528
## 4 86.88355 88.01512 89.65869 86.12640 25856977
## 5 87.81946 88.45589 90.07406 87.04067 25620391
```


``` r
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse      smape        R2
## 1 1.609549 0.01307407 0.2379964
```


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

![plot of chunk unnamed-chunk-9](fig/16-stock-close-conv1d-regression/unnamed-chunk-9-1.png)

What this example shows
- `ts_conv1d()` can be reused directly as the target learner inside `ts_regsw_mv()`.
- The same learner family can be reused for the target and for all endogenous auxiliaries when the goal is a cleaner didactic comparison.
