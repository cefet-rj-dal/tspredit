## Train and Test Splits for Windowed Multivariate Data

About the concept
- In sliding-window forecasting workflows, train/test splitting should happen after the lagged representation is materialized.
- The split must preserve the temporal synchronization between `y` and all auxiliary variables.

Didactic goal: inspect how the aligned multivariate data becomes lagged windows and why the split should happen at that stage.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Train and test splits for windowed multivariate data

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
if (!is.null(attr(EUNITE.Reg, "url"))) {
  EUNITE.Reg <- loadfulldata(EUNITE.Reg)
}

load_cols <- setdiff(names(EUNITE.Loads), "split")
y <- apply(EUNITE.Loads[, load_cols, drop = FALSE], 1, max)
x1 <- as.numeric(EUNITE.Reg$Weekday)
x2 <- as.numeric(EUNITE.Reg$Weekday %in% c(1, 7))

mv <- ts_data_mv(
  data.frame(y = y, x1 = x1, x2 = x2),
  y = "y"
)
```

We first materialize the aligned multivariate object into lagged windows.


``` r
windows <- ts_data_mv(mv, sw = 7)

ts_head(windows, 3)
```

```
##   y_t6 y_t5 y_t4 y_t3 y_t2 y_t1 y_t0 x1_t6 x1_t5 x1_t4 x1_t3 x1_t2 x1_t1 x1_t0 x2_t6 x2_t5 x2_t4 x2_t3 x2_t2 x2_t1 x2_t0
## 1  797  777  797  757  707  730  818     4     5     6     7     1     2     3     0     0     0     1     1     0     0
## 2  777  797  757  707  730  818  818     5     6     7     1     2     3     4     0     0     1     1     0     0     0
## 3  797  757  707  730  818  818  803     6     7     1     2     3     4     5     0     1     1     0     0     0     0
```

We then split the lagged representation into train and test partitions.


``` r
samp <- ts_sample(windows, test_size = 10)

ts_head(samp$train, 3)
```

```
##   y_t6 y_t5 y_t4 y_t3 y_t2 y_t1 y_t0 x1_t6 x1_t5 x1_t4 x1_t3 x1_t2 x1_t1 x1_t0 x2_t6 x2_t5 x2_t4 x2_t3 x2_t2 x2_t1 x2_t0
## 1  797  777  797  757  707  730  818     4     5     6     7     1     2     3     0     0     0     1     1     0     0
## 2  777  797  757  707  730  818  818     5     6     7     1     2     3     4     0     0     1     1     0     0     0
## 3  797  757  707  730  818  818  803     6     7     1     2     3     4     5     0     1     1     0     0     0     0
```

``` r
ts_head(samp$test, 3)
```

```
##     y_t6 y_t5 y_t4 y_t3 y_t2 y_t1 y_t0 x1_t6 x1_t5 x1_t4 x1_t3 x1_t2 x1_t1 x1_t0 x2_t6 x2_t5 x2_t4 x2_t3 x2_t2 x2_t1 x2_t0
## 746  738  699  782  782  792  801  781     7     1     2     3     4     5     6     1     1     0     0     0     0     0
## 747  699  782  782  792  801  781  731     1     2     3     4     5     6     7     1     0     0     0     0     0     1
## 748  782  782  792  801  781  731  708     2     3     4     5     6     7     1     0     0     0     0     0     1     1
```

This is the important detail inherited from the univariate workflow: the first
rows of the test partition already carry lagged values whose context comes from
the end of the training period. If we split the raw aligned series first and
only then materialize the windows, we lose that boundary information.

What this example shows
- `ts_data_mv(..., sw > 1)` is the multivariate bridge from aligned observations to lagged forecasting inputs.
- `ts_sample()` should be applied after the lagged representation is materialized when the goal is a sliding-window train/test split.
- The forecasting workflow remains time-aware from the raw multivariate data to the final train/test window partitions.
