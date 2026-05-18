## Train and Test Splits for Multivariate Data

About the concept
- In the multivariate workflow, train/test splitting happens on the aligned object before forecasting.
- The split must preserve the temporal synchronization between `y` and all auxiliary variables.

Didactic goal: inspect how the aligned multivariate data and the lagged materialization behave before and after the time-aware split.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Train and test splits for multivariate data

# Installing the package (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```


``` r
data(EUNITE.Loads)
data(EUNITE.Reg)

if (!is.null(attr(EUNITE.Loads, "url"))) {
  EUNITE.Loads <- loadfulldata(EUNITE.Loads)
}
```

```
## Warning in attr(EUNITE.Loads, "url"): 'xfun::attr()' é obsoleto.
## Use 'xfun::attr2()' em seu lugar.
## Veja help("Deprecated")
```

``` r
if (!is.null(attr(EUNITE.Reg, "url"))) {
  EUNITE.Reg <- loadfulldata(EUNITE.Reg)
}
```

```
## Warning in attr(EUNITE.Reg, "url"): 'xfun::attr()' é obsoleto.
## Use 'xfun::attr2()' em seu lugar.
## Veja help("Deprecated")
```

``` r
load_cols <- setdiff(names(EUNITE.Loads), "split")
y <- apply(EUNITE.Loads[, load_cols, drop = FALSE], 1, max)
x1 <- as.numeric(EUNITE.Reg$Weekday)
x2 <- as.numeric(EUNITE.Reg$Weekday %in% c(1, 7))

mv <- ts_data_mv(
  data.frame(y = y, x1 = x1, x2 = x2),
  y = "y"
)
```

We first split the aligned multivariate object.


``` r
samp <- ts_sample(mv, test_size = 5)

ts_head(samp$train, 3)
```

```
##     y x1 x2
## 1 797  4  0
## 2 777  5  0
## 3 797  6  0
```

``` r
ts_head(samp$test, 3)
```

```
##       y x1 x2
## 757 791  4  0
## 758 776  5  0
## 759 792  6  0
```

The same split can then be materialized into lagged windows separately for training and test.


``` r
train_windows <- ts_window_mv(samp$train, window_size = 7)
test_windows <- ts_window_mv(samp$test, window_size = 5)

ts_head(train_windows, 3)
```

```
##   y_t6 y_t5 y_t4 y_t3 y_t2 y_t1 y_t0 x1_t6 x1_t5 x1_t4 x1_t3 x1_t2 x1_t1 x1_t0
## 1  797  777  797  757  707  730  818     4     5     6     7     1     2     3
## 2  777  797  757  707  730  818  818     5     6     7     1     2     3     4
## 3  797  757  707  730  818  818  803     6     7     1     2     3     4     5
##   x2_t6 x2_t5 x2_t4 x2_t3 x2_t2 x2_t1 x2_t0
## 1     0     0     0     1     1     0     0
## 2     0     0     1     1     0     0     0
## 3     0     1     1     0     0     0     0
```

``` r
ts_head(test_windows, 1)
```

```
##   y_t4 y_t3 y_t2 y_t1 y_t0 x1_t4 x1_t3 x1_t2 x1_t1 x1_t0 x2_t4 x2_t3 x2_t2
## 1  791  776  792  763  743     4     5     6     7     1     0     0     0
##   x2_t1 x2_t0
## 1     1     1
```

This makes the temporal boundary explicit: the learner sees lagged windows built from the training portion only, while the held-out tail remains untouched for forecasting and evaluation.

What this example shows
- `ts_sample()` keeps the multivariate alignment intact.
- Window materialization can be applied independently to train and test partitions.
- The forecasting workflow remains time-aware from the raw data to the lagged representation.
