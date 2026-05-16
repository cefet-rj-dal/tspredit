## Objective

This notebook introduces `ipeadata.d`, the daily macroeconomic dataset from Ipea.

## Method at a glance

The notebook inspects the wide table layout used to package multiple univariate daily series in one object.

## What you will do

- load `ipeadata.d`
- inspect dimensions and column names
- preview the first rows
- plot the first available series


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)
```


``` r
expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}
```


``` r
data(ipeadata.d)
ipeadata.d <- expand_dataset(ipeadata.d)
cat("Dataset: ipeadata.d\n")
```

```
## Dataset: ipeadata.d
```

``` r
cat("Rows:", nrow(ipeadata.d), "\n")
```

```
## Rows: 8184
```

``` r
cat("Columns:", ncol(ipeadata.d), "\n")
```

```
## Columns: 13
```

``` r
head(names(ipeadata.d))
```

```
## [1] "GM366_IBVSP366"  "GM366_ERC366"    "GM366_EREURO366" "GM366_ERPV366"   "GM366_ERV366"    "GM366_TJOVER366"
```

``` r
head(ipeadata.d[, 1:4])
```

```
##   GM366_IBVSP366 GM366_ERC366 GM366_EREURO366 GM366_ERPV366
## 1         3580.8  1.15200e-09        0.841157   1.34545e-13
## 2         3564.3  1.15200e-09        0.847678   1.38182e-13
## 3         3753.5  1.15200e-09        0.859567   1.30909e-13
## 4         3904.9  1.17382e-09        0.852447   1.27273e-13
## 5         4051.9  1.17382e-09        0.861268   1.45455e-13
## 6         4010.8  1.17382e-09        0.868371   1.63636e-13
```


``` r
ts.plot(ipeadata.d[[1]], ylab = "Value", xlab = "Day", main = names(ipeadata.d)[1])
```

![plot of chunk unnamed-chunk-4](fig/05-ipeadata-daily/unnamed-chunk-4-1.png)

## References

- Ipea. Ipeadata portal.
