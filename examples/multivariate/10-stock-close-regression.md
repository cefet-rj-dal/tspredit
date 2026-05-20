## Stock Closing-Price Forecasting with Non-Deterministic Auxiliaries

About the method
- This workflow keeps `close` as the forecasting target and treats `open`, `high`, `low`, and `volume` as non-deterministic auxiliary variables.
- Unlike the previous example, the auxiliary variables are not governed by a fixed law of formation. They need their own forecasting models.

Didactic goal: compare a direct `ARIMA` baseline on the closing price against a target-centered multivariate workflow whose auxiliary variables mix `ts_mlp()`, `ts_elm()`, `ts_darima()`, and `ts_warma()`.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Stock closing-price forecasting with non-deterministic auxiliaries

# Installing the package (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```

We now switch to a different multivariate scenario. Instead of deterministic
calendar auxiliaries, we use market variables from the packaged `stocks`
collection. The target is the closing price, while the other fields behave as
non-deterministic auxiliary series.

For a faster didactic run, we keep only the last two years of valid
observations.


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

ts_head(mv, 3)
```

```
##      close  open  high   low   volume
## 6057 65.72 65.99 66.14 65.51 12497900
## 6058 65.51 65.50 65.87 65.04 17360200
## 6059 68.00 66.49 68.32 66.34 40947100
```

The aligned object can now be split in time just like any other target-centered
multivariate dataset.


``` r
samp <- ts_sample(mv, test_size = 5)
```

Before introducing the multivariate workflow, we build a direct univariate
baseline on the closing price itself. This keeps the interpretation honest: we
first ask how far a classical `ARIMA` can go before bringing in the auxiliary
variables.


``` r
close_ts <- ts_data(ticker$close, 1)
close_samp <- ts_sample(close_ts, test_size = 5)

arima_baseline <- ts_arima()
arima_baseline <- fit(arima_baseline, x = close_samp$train)

pred_arima <- predict(arima_baseline, x = close_samp$test[1,], steps_ahead = 5)
pred_arima <- as.vector(pred_arima)
ev_arima <- evaluate(arima_baseline, as.vector(close_samp$test), pred_arima)
ev_arima$metrics
```

```
##        mse      smape        R2
## 1 6.768766 0.02329364 -2.204515
```

The multivariate experiment below follows the same structure used in the model
comparison notebooks that come next: fit the system, inspect the one-step
target forecast, inspect the five-step target forecast, inspect the full
multivariate forecast table, plot the target, and evaluate the target
trajectory.

This time, the auxiliary variables are not deterministic. We therefore assign
real forecasting models to them. After a few trial configurations, a `Random
Forest` worked better as the target learner for this particular stock holdout,
while the auxiliaries remain intentionally heterogeneous:

- `open` uses `ELM`
- `high` uses `DARIMA`
- `low` uses `MLP`
- `volume` uses `WARMA`


``` r
model <- ts_regsw_mv(
  model_y = ts_mv_spec(
    ts_rf(ts_norm_gminmax(), input_size = 4),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_elm(ts_norm_gminmax(), input_size = 3, nhid = 3, actfun = "purelin"),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_darima(ts_norm_diff(), input_size = 3),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_mlp(ts_norm_gminmax(), input_size = 3, size = 2, decay = 0.1),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_warma(input_size = 3, steps = 1),
      variables = c("volume")
    )
  ),
  window_size = 5
)
```

This mixed specification also clarifies an important point of the current API:
the univariate support models used inside `ts_regsw_mv` do not need to be all
of the same family. Here:

- `ts_rf()` gives a more stable target learner for this stock example
- `ts_elm()` offers a lighter neural alternative for one auxiliary variable
- `ts_darima()` acts as a lightweight ARIMA-like learner in the
  sliding-window world, with differencing delegated to preprocessing
- `ts_mlp()` remains available as a nonlinear auxiliary learner
- `ts_warma()` acts as a local-normalization competitor in the same
  `ts_regsw` lineage


``` r
set_example_seed()
model <- fit(model, samp$train)
```

We first inspect the next closing-price forecast.


``` r
pred_1 <- predict(model, steps_ahead = 1)
pred_1
```

```
## [1] 86.1927
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
## [1] 85.99456
## 
## attr(,"prediction_x")$low
## [1] 82.20966
## 
## attr(,"prediction_x")$volume
## [1] 33076060
## 
## attr(,"system")
##     close     open     high      low   volume
## 1 86.1927 85.78517 85.99456 82.20966 33076060
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```

We then inspect the recursive multi-step path for the target.


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 86.1927 86.1368 85.7986 85.7490 85.7441
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
## [1] 85.78517 84.00956 85.78546 86.87644 85.34103
## 
## attr(,"prediction_x")$high
## [1] 85.99456 87.11913 87.63444 86.98998 86.67025
## 
## attr(,"prediction_x")$low
## [1] 82.20966 82.47191 82.21620 82.24374 82.37079
## 
## attr(,"prediction_x")$volume
## [1] 33076060 33506772 34513366 33013400 31279800
## 
## attr(,"system")
##     close     open     high      low   volume
## 1 86.1927 85.78517 85.99456 82.20966 33076060
## 2 86.1368 84.00956 87.11913 82.47191 33506772
## 3 85.7986 85.78546 87.63444 82.21620 34513366
## 4 85.7490 86.87644 86.98998 82.24374 33013400
## 5 85.7441 85.34103 86.67025 82.37079 31279800
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```

The recursive predictions for the endogenous auxiliary variables are also
attached to that target-centered return object.


``` r
attr(pred_5, "prediction_x")
```

```
## $open
## [1] 85.78517 84.00956 85.78546 86.87644 85.34103
## 
## $high
## [1] 85.99456 87.11913 87.63444 86.98998 86.67025
## 
## $low
## [1] 82.20966 82.47191 82.21620 82.24374 82.37079
## 
## $volume
## [1] 33076060 33506772 34513366 33013400 31279800
```

The synchronized multivariate forecast remains attached as a tabular attribute
of the same target path.


``` r
attr(pred_5, "system")
```

```
##     close     open     high      low   volume
## 1 86.1927 85.78517 85.99456 82.20966 33076060
## 2 86.1368 84.00956 87.11913 82.47191 33506772
## 3 85.7986 85.78546 87.63444 82.21620 34513366
## 4 85.7490 86.87644 86.98998 82.24374 33013400
## 5 85.7441 85.34103 86.67025 82.37079 31279800
```

We keep the plot focused on the target trajectory, because the model-comparison
notebooks after this one reuse the same visual convention.


``` r
plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")
```

![plot of chunk unnamed-chunk-12](fig/10-stock-close-regression/unnamed-chunk-12-1.png)

The held-out target values remain available for evaluation against the target
forecast.


``` r
output <- tail(samp$test$close, 5)
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse      smape        R2
## 1 4.312106 0.01930004 -1.041467
```

We can now compare the direct closing-price baseline against the multivariate
workflow on the same five-step horizon.


``` r
rbind(
  ARIMA_close = ev_arima$metrics,
  MV_mixed = ev_test$metrics
)
```

```
##                  mse      smape        R2
## ARIMA_close 6.768766 0.02329364 -2.204515
## MV_mixed    4.312106 0.01930004 -1.041467
```

What this example shows
- `stocks` provides a natural target-centered multivariate scenario with non-deterministic auxiliary variables.
- A direct `ARIMA` on the closing price remains an important baseline and should be checked before moving to a richer multivariate design.
- Auxiliary variables do not need to share the same learner: some can use `ts_elm()`, others can use `ts_mlp()`, `ts_darima()`, or `ts_warma()`.
- The prediction object is still target-centered, but it preserves the endogenous auxiliary forecasts through `attr(pred, "prediction_x")` and the full synchronized forecast through `attr(pred, "system")`.
- `ts_darima()` and `ts_warma()` are useful support models for the target-centered multivariate workflow because they already live in the `ts_regsw` lineage.
- This is a different scenario from the previous deterministic-auxiliary example: here the auxiliary variables must themselves be forecast as evolving stochastic series.
