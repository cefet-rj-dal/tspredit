## Geometric Lag Mapping

About the technique
- `geom` concentrates more lags near the present while still preserving a few distant observations.
- It is a compact multiscale heuristic for problems where very recent dynamics dominate but older echoes may still matter.

Didactic goal: show a nonlinear spacing of selected lags that balances recency and long-range coverage.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Geometric lag mapping
```


``` r
library(daltoolbox)
library(tspredit)
```


``` r
data(tsd)
plot_ts(x = tsd$x, y = tsd$y)
```

![plot of chunk unnamed-chunk-3](fig/03-geometric-lag-mapping/unnamed-chunk-3-1.png)


``` r
sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)
```


``` r
mapper <- ts_lagmap(method = "geom")
mapper <- fit(mapper, io_train$input, io_train$output, input_size = 4)
mapper$lags
```

```
## [1] 9 4 2 1
```

``` r
mapper$columns
```

```
## [1] "t9" "t4" "t2" "t1"
```


``` r
model <- ts_knn(
  preprocess = ts_norm_gminmax(),
  input_size = 4,
  input_map = ts_lagmap(method = "geom"),
  k = 3
)
set_example_seed()
model <- fit(model, io_train$input, io_train$output)
prediction <- predict(model, io_test$input[1, ], steps_ahead = 5)
evaluate(model, as.vector(io_test$output), as.vector(prediction))
```

```
## $values
## [1]  0.41211849  0.17388949 -0.07515112 -0.31951919 -0.54402111
## 
## $prediction
## [1]  0.5349524  0.1381953 -0.1059528 -0.3435132 -0.5597157
## 
## $smape
## [1] 0.1858229
## 
## $mse
## [1] 0.003626603
## 
## $R2
## [1] 0.9686768
## 
## $metrics
##           mse     smape        R2
## 1 0.003626603 0.1858229 0.9686768
```
