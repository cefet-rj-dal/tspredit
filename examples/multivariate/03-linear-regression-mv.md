## Target-Centered Multivariate Linear Regression

About the method
- `ts_lm_mv()` is the simplest model in the singular multivariate branch.
- It keeps one target `y` as the main forecasting objective and expresses its relation with the auxiliary variables through a regression formula.

Didactic goal: show how the formula-based style from `daltoolbox` enters the multivariate time-series workflow of `tspredit`.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Target-centered multivariate linear regression

# Installing the package (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```

We reuse a compact synthetic multivariate system built from the benchmark series
`tsd$y`.


``` r
data(tsd)

x1 <- c(tsd$y[-1], tail(tsd$y, 1))
x2 <- stats::filter(tsd$y, rep(1/3, 3), sides = 1)
x2[is.na(x2)] <- tsd$y[is.na(x2)]

mv <- ts_data_mv(
  data.frame(y = tsd$y, x1 = x1, x2 = as.numeric(x2)),
  y = "y"
)

samp <- ts_sample(mv, test_size = 5)
```

The experiment now follows the same structure used in the other singular
multivariate notebooks: define the split, fit the model, inspect the one-step
forecast, inspect the multi-step target forecast, inspect the synchronized
system forecast, and then evaluate the target trajectory.

The formula makes the relation between the target and the auxiliaries explicit.


``` r
model <- ts_lm_mv(formula = y ~ x1 + x2)
model <- fit(model, samp$train)
```

In this first singular example, we assume that the future auxiliaries are known
and therefore use the held-out rows directly during prediction.


``` r
pred_1 <- predict(model, x = samp$test, steps_ahead = 1)
pred_1
```

```
## [1] 0.4116193
## attr(,"y_name")
## [1] "y"
## attr(,"x_names")
## [1] "x1" "x2"
## attr(,"variables")
## [1] "y"  "x1" "x2"
## attr(,"steps_ahead")
## [1] 1
## attr(,"prediction_x")
## attr(,"prediction_x")$x1
## [1] 0.1738895
## 
## attr(,"prediction_x")$x2
## [1] 0.6117765
## 
## attr(,"system")
##           y        x1        x2
## 1 0.4116193 0.1738895 0.6117765
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, x = samp$test, steps_ahead = 5)
pred_5
```

```
## [1]  0.41161932  0.17404351 -0.07477247 -0.31935845 -0.44889824
## attr(,"y_name")
## [1] "y"
## attr(,"x_names")
## [1] "x1" "x2"
## attr(,"variables")
## [1] "y"  "x1" "x2"
## attr(,"steps_ahead")
## [1] 5
## attr(,"prediction_x")
## attr(,"prediction_x")$x1
## [1]  0.17388949 -0.07515112 -0.31951919 -0.54402111 -0.54402111
## 
## attr(,"prediction_x")$x2
## [1]  0.61177652  0.40357731  0.17028562 -0.07359361 -0.31289714
## 
## attr(,"system")
##             y          x1          x2
## 1  0.41161932  0.17388949  0.61177652
## 2  0.17404351 -0.07515112  0.40357731
## 3 -0.07477247 -0.31951919  0.17028562
## 4 -0.31935845 -0.54402111 -0.07359361
## 5 -0.44889824 -0.54402111 -0.31289714
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```

The prediction itself is the target path. The synchronized multivariate
forecast is attached as an attribute.


``` r
attr(pred_5, "system")
```

```
##             y          x1          x2
## 1  0.41161932  0.17388949  0.61177652
## 2  0.17404351 -0.07515112  0.40357731
## 3 -0.07477247 -0.31951919  0.17028562
## 4 -0.31935845 -0.54402111 -0.07359361
## 5 -0.44889824 -0.54402111 -0.31289714
```

The target values remain available for direct evaluation.


``` r
ev_test <- evaluate(model, tail(samp$test$y, 5), pred_5)
ev_test$metrics
```

```
##           mse      smape       R2
## 1 0.001809761 0.03985082 0.984369
```

What this example shows
- `ts_lm_mv()` is the most direct entry point into the singular multivariate branch.
- The `formula` argument makes the structural relation between `y` and the auxiliary variables explicit.
- When future auxiliary values are known, singular multivariate prediction can use the held-out aligned rows directly.
