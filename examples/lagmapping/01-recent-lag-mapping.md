## Recent Lag Mapping

About the technique
- `recent` keeps the most recent `input_size` lagged observations.
- It reproduces the historical behavior of the package and is therefore the reference baseline for all other mapping rules.

Didactic goal: show the default lag selection used by `tspredit` before any adaptive mapping is introduced.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Recent lag mapping
```


``` r
library(daltoolbox)
library(tspredit)
```


``` r
data(tsd)
plot_ts(x = tsd$x, y = tsd$y)
```

![plot of chunk unnamed-chunk-3](fig/01-recent-lag-mapping/unnamed-chunk-3-1.png)


``` r
sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)
ts_head(io_train$input, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3        t2        t1
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974 0.7780732
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974 0.7780732 0.5984721
```


``` r
mapper <- ts_lagmap(method = "recent")
mapper <- fit(mapper, io_train$input, io_train$output, input_size = 4)
mapper$lags
```

```
## [1] 4 3 2 1
```

``` r
mapper$columns
```

```
## [1] "t4" "t3" "t2" "t1"
```


``` r
model <- ts_knn(
  preprocess = ts_norm_gminmax(),
  input_size = 4,
  input_map = ts_lagmap(method = "recent"),
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
## [1]  0.5349524  0.3737510  0.1381953 -0.1059528 -0.3435132
## 
## $smape
## [1] 0.8890066
## 
## $mse
## [1] 0.0372727
## 
## $R2
## [1] 0.6780737
## 
## $metrics
##         mse     smape        R2
## 1 0.0372727 0.8890066 0.6780737
```
