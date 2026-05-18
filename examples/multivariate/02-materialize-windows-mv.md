## Materialize Multivariate Windows

About the concept
- `ts_window_mv()` turns the aligned multivariate object into explicit lagged blocks.
- This is the step where terms such as `y_t6`, `x1_t3`, or `x2_t0` become visible as columns.

Didactic goal: inspect how the multivariate lagged structure is materialized before the learning algorithms consume it.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Materialize multivariate windows

# Installing the package (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```

We reuse the same benchmark setup so the lagged structure can be inspected on a realistic multivariate dataset.


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

The first materialization uses the full base window for every variable.


``` r
windows_full <- ts_window_mv(mv, window_size = 7)
ts_head(windows_full, 3)
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

The resulting columns are organized by variable blocks.


``` r
colnames(windows_full)
```

```
##  [1] "y_t6"  "y_t5"  "y_t4"  "y_t3"  "y_t2"  "y_t1"  "y_t0"  "x1_t6" "x1_t5"
## [10] "x1_t4" "x1_t3" "x1_t2" "x1_t1" "x1_t0" "x2_t6" "x2_t5" "x2_t4" "x2_t3"
## [19] "x2_t2" "x2_t1" "x2_t0"
```

We can also request only specific lag positions for each variable. This is a useful intermediate view before the complete forecasting pipeline is assembled.


``` r
windows_selected <- ts_window_mv(
  mv,
  window_size = 7,
  lags = list(
    y = c(6, 3, 0),
    x1 = c(1, 0),
    x2 = c(6, 0)
  )
)

ts_head(windows_selected, 3)
```

```
##   y_t6 y_t3 y_t0 x1_t1 x1_t0 x2_t6 x2_t0
## 1  797  757  818     2     3     0     0
## 2  777  707  818     3     4     0     0
## 3  797  730  803     4     5     0     0
```

Finally, the same step can reflect variable-specific raw-series transformations before the lagged blocks are created.


``` r
windows_transformed <- ts_window_mv(
  mv,
  window_size = 7,
  transforms = list(y = ts_fil_ma(3))
)

ts_head(windows_transformed, 3)
```

```
##       y_t6     y_t5     y_t4     y_t3     y_t2     y_t1     y_t0 x1_t6 x1_t5
## 1       NA       NA 790.3333 777.0000 753.6667 731.3333 751.6667     4     5
## 2       NA 790.3333 777.0000 753.6667 731.3333 751.6667 788.6667     5     6
## 3 790.3333 777.0000 753.6667 731.3333 751.6667 788.6667 813.0000     6     7
##   x1_t4 x1_t3 x1_t2 x1_t1 x1_t0 x2_t6 x2_t5 x2_t4 x2_t3 x2_t2 x2_t1 x2_t0
## 1     6     7     1     2     3     0     0     0     1     1     0     0
## 2     7     1     2     3     4     0     0     1     1     0     0     0
## 3     1     2     3     4     5     0     1     1     0     0     0     0
```

What this example shows
- `ts_window_mv()` is the explicit multivariate lag-materialization step.
- The base window is shared, but each variable can expose different lag positions.
- Raw-series transforms can be applied before the lagged blocks are assembled.
