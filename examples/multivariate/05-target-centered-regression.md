## Target-Centered Multivariate Forecasting with Deterministic Auxiliaries

About the method
- This workflow keeps `y` as the forecasting target and treats `x1, ..., xn` as auxiliary series that also receive their own predictive pipelines.
- The multivariate wrapper reuses the univariate learners already available in `tspredit`, while coordinating how the synchronized lagged windows are built for each variable.

Didactic goal: provide a first overview of how multivariate forecasting works in `tspredit` 2.0 when the auxiliary variables follow deterministic laws of formation.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Target-centered multivariate forecasting with deterministic auxiliaries

# Installing the package (if needed)
# install.packages("tspredit")
```

We begin by loading the packages used in the example.


``` r
library(daltoolbox)
library(tspredit)
```

We now build an aligned multivariate dataset from benchmark data already
available in `tspredit`. We use:

- the daily maximum load extracted from `EUNITE.Loads` as the target `y`
- the weekday code from `EUNITE.Reg` as `x1`
- a weekend indicator derived from `EUNITE.Reg` as `x2`


``` r
data(EUNITE.Loads)
data(EUNITE.Reg)

if (!is.null(attr(EUNITE.Loads, "url"))) {
  EUNITE.Loads <- loadfulldata(EUNITE.Loads)
}
if (!is.null(attr(EUNITE.Reg, "url"))) {
  EUNITE.Reg <- loadfulldata(EUNITE.Reg)
}

load_cols <- setdiff(names(EUNITE.Loads), "split")
y <- apply(EUNITE.Loads[, load_cols, drop = FALSE], 1, max)
x1 <- as.numeric(EUNITE.Reg$Weekday)
x2 <- as.numeric(EUNITE.Reg$Weekday %in% c(1, 7))

mv <- ts_data_mv(
  data.frame(
    y = y,
    x1 = x1,
    x2 = x2
  ),
  y = "y"
)

ts_head(mv, 3)
```

```
##     y x1 x2
## 1 797  4  0
## 2 777  5  0
## 3 797  6  0
```

The multivariate object preserves the temporal alignment across all variables
and can be split in time just like the univariate workflow.


``` r
samp <- ts_sample(mv, test_size = 5)
```

We now define one specification for the target and one specification for each
auxiliary variable. In this example, the auxiliary variables are deterministic
calendar signals, so it is more coherent to forecast them with rule-based
univariate predictors instead of generic learners.


``` r
model <- ts_regsw_mv(
  model_y = ts_mv_spec(
    ts_mlp(ts_norm_an(), input_size = 4, size = 4, decay = 0),
    variables = c("y", "x1", "x2"),
    transforms = list(y = ts_fil_ma(3))
  ),
  models_x = list(
    x1 = ts_mv_spec(ts_deterministic("periodic", period = 7)),
    x2 = ts_mv_spec(ts_deterministic("periodic", period = 7))
  ),
  window_size = 7
)
```

We fit the composed multivariate forecasting system on the training portion of
the aligned series.


``` r
set_example_seed()
model <- fit(model, samp$train)
```

The first forecast mode is one-step ahead. It returns the next value of the
target series.


``` r
pred_1 <- predict(model, steps_ahead = 1)
pred_1
```

```
## [1] 799.21
```

The second forecast mode is recursive multi-step prediction. By default, it
returns the future path of `y`.


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1] 799.2100 786.5946 781.4834 756.8355 712.7802
```

If we want to inspect the whole recursive system, we can ask for the target and
the auxiliary forecasts together.


``` r
pred_all <- predict(model, steps_ahead = 5, return_all = TRUE)
pred_all
```

```
## $y
## [1] 799.2100 786.5946 781.4834 756.8355 712.7802
## 
## $x
## $x$x1
## [1] 4 5 6 7 1
## 
## $x$x2
## [1] 0 0 0 1 1
## 
## 
## attr(,"class")
## [1] "ts_mv_prediction"
## attr(,"y_name")
## [1] "y"
## attr(,"x_names")
## [1] "x1" "x2"
## attr(,"variables")
## [1] "y"  "x1" "x2"
## attr(,"steps_ahead")
## [1] 5
```

The multivariate plotting helper reuses the same visual language already used
throughout the univariate examples, but now it returns one plot per variable.


``` r
plots <- plot_ts_pred_mv(samp$train, samp$test, pred_all)
```

Target trajectory:


``` r
plots$y
```

![plot of chunk unnamed-chunk-11](fig/05-target-centered-regression/unnamed-chunk-11-1.png)

Auxiliary variable `x1`:


``` r
plots$x1
```

![plot of chunk unnamed-chunk-12](fig/05-target-centered-regression/unnamed-chunk-12-1.png)

Auxiliary variable `x2`:


``` r
plots$x2
```

![plot of chunk unnamed-chunk-13](fig/05-target-centered-regression/unnamed-chunk-13-1.png)

The held-out target values remain available for evaluation against the target
forecast.


``` r
output <- tail(samp$test$y, 5)
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
```

```
##        mse      smape        R2
## 1 248.2973 0.01737645 0.2671272
```

What this example shows
- `ts_data_mv()` preserves synchronized multivariate observations before any lag expansion happens.
- `ts_mv_spec()` lets each variable keep its own object-oriented pipeline.
- `ts_regsw_mv()` coordinates one target model and one auxiliary model per covariate while reusing the learners already available in the univariate package.
- Rule-based univariate predictors from the `ts_deterministic()` family are often more appropriate than generic learners for deterministic auxiliary variables.
- This is the deterministic-auxiliary scenario; the next example in the sequence treats non-deterministic auxiliary variables as endogenous series with their own forecasting models.

References
- Hyndman, R. J., & Athanasopoulos, G. Forecasting: Principles and Practice.
- Salles, R., Pacitti, E., Bezerra, E., Marques, C., Pacheco, C., Oliveira, C., Porto, F., Ogasawara, E. (2023). TSPredIT: Integrated Tuning of Data Preprocessing and Time Series Prediction Models.
