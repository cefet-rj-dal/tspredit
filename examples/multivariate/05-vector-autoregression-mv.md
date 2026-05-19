## Target-Centered Vector Autoregression

About the method
- `ts_var()` models the multivariate system jointly.
- Even so, `tspredit` keeps one target `y` as the main variable of interest and returns its forecast by default.

Didactic goal: show how a system model can coexist with a target-centered interface.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Target-centered vector autoregression

# Installing the package (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```

We use the same aligned multivariate system as in the previous singular
examples, so the only change is the model family.


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

The vector autoregression is fitted on the whole aligned system. Here, the
target remains `y`, but the system forecast includes `x1` and `x2` as well.


``` r
model <- ts_var(p_max = 3)
model <- fit(model, samp$train)
```


``` r
pred_1 <- predict(model, steps_ahead = 1)
pred_1
```

```
## [1] 0.4121185
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
## 1 0.4121185 0.1738895 0.6117765
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
pred_5 <- predict(model, steps_ahead = 5)
pred_5
```

```
## [1]  0.41211849  0.17388949 -0.07515112 -0.31951919 -0.54402111
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
## [1]  0.17388949 -0.07515112 -0.31951919 -0.54402111 -0.73469843
## 
## attr(,"prediction_x")$x2
## [1]  0.61177652  0.40357731  0.17028562 -0.07359361 -0.31289714
## 
## attr(,"system")
##             y          x1          x2
## 1  0.41211849  0.17388949  0.61177652
## 2  0.17388949 -0.07515112  0.40357731
## 3 -0.07515112 -0.31951919  0.17028562
## 4 -0.31951919 -0.54402111 -0.07359361
## 5 -0.54402111 -0.73469843 -0.31289714
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_5, "system")
```

```
##             y          x1          x2
## 1  0.41211849  0.17388949  0.61177652
## 2  0.17388949 -0.07515112  0.40357731
## 3 -0.07515112 -0.31951919  0.17028562
## 4 -0.31951919 -0.54402111 -0.07359361
## 5 -0.54402111 -0.73469843 -0.31289714
```

The target can still be evaluated exactly as in the target-centered models.


``` r
ev_test <- evaluate(model, tail(samp$test$y, 5), pred_5)
ev_test$metrics
```

```
##            mse      smape R2
## 1 1.960019e-30 4.3389e-15  1
```

What this example shows
- `ts_var()` models the multivariate system jointly, not just one regression equation for `y`.
- Even in that systemic setting, the `tspredit` interface can keep a distinguished target variable.
- The target forecast is returned directly, while the full system forecast remains available as an attribute of that vector.
