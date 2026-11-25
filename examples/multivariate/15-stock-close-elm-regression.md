## Stock Closing-Price Forecasting with ELM as Target Learner

About the method
- This example keeps the same stock-closing-price scenario, but now the target `close` is forecast with `ts_elm()`.

Didactic goal: inspect how an Extreme Learning Machine behaves as the target learner inside the target-centered multivariate workflow.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Stock closing-price forecasting with ELM as target learner

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
    ts_elm(ts_norm_gminmax(), input_size = 4, nhid = 3, actfun = "purelin"),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_elm(ts_norm_gminmax(), input_size = 3, nhid = 3, actfun = "purelin"),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_elm(ts_norm_gminmax(), input_size = 3, nhid = 3, actfun = "purelin"),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_elm(ts_norm_gminmax(), input_size = 3, nhid = 3, actfun = "purelin"),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_elm(ts_norm_gminmax(), input_size = 3, nhid = 3, actfun = "purelin"),
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
## [1] 86.41966
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
## [1] 85.78517
## 
## attr(,"prediction_x")$high
## [1] 87.28396
## 
## attr(,"prediction_x")$low
## [1] 84.29388
## 
## attr(,"prediction_x")$volume
## [1] 29758466
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 86.41966 85.78517 87.28396 84.29388 29758466
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 86.41966 85.24063 85.25934 86.01987 85.41508
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
## [1] 85.78517 84.32772 85.60432 86.04642 85.26371
## 
## attr(,"prediction_x")$high
## [1] 87.28396 86.73072 86.82925 87.49822 87.31617
## 
## attr(,"prediction_x")$low
## [1] 84.29388 83.29218 84.12658 84.58520 84.12063
## 
## attr(,"prediction_x")$volume
## [1] 29758466 31997116 31717283 29415006 26845862
## 
## attr(,"system")
##      close     open     high      low   volume
## 1 86.41966 85.78517 87.28396 84.29388 29758466
## 2 85.24063 84.32772 86.73072 83.29218 31997116
## 3 85.25934 85.60432 86.82925 84.12658 31717283
## 4 86.01987 86.04642 87.49822 84.58520 29415006
## 5 85.41508 85.26371 87.31617 84.12063 26845862
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##      close     open     high      low   volume
## 1 86.41966 85.78517 87.28396 84.29388 29758466
## 2 85.24063 84.32772 86.73072 83.29218 31997116
## 3 85.25934 85.60432 86.82925 84.12658 31717283
## 4 86.01987 86.04642 87.49822 84.58520 29415006
## 5 85.41508 85.26371 87.31617 84.12063 26845862
```


``` r
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse      smape       R2
## 1 5.863566 0.02352557 -1.77597
```


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

![plot of chunk unnamed-chunk-9](fig/15-stock-close-elm-regression/unnamed-chunk-9-1.png)

What this example shows
- `ts_elm()` can be reused directly as the target learner inside `ts_regsw_mv()`.
- The same learner family can be reused for the target and for all endogenous auxiliaries when the goal is a cleaner didactic comparison.
