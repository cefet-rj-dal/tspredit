## Objective

This notebook introduces `tsd`, the smallest dataset distributed with `tspredit`. The goal is to inspect its structure and plot the synthetic target series used throughout the introductory examples.

## Method at a glance

This is a dataset-orientation notebook. It does not fit a model. Instead, it inspects the packaged object so the reader understands why `tsd` is the didactic entry point of the package.

## What you will do

- load `tsd`
- inspect its dimensions and columns
- summarize the variables
- plot the target series


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)
library(ggplot2)
```


``` r
data(tsd)
cat("Dataset: tsd\n")
```

```
## Dataset: tsd
```

``` r
cat("Rows:", nrow(tsd), "\n")
```

```
## Rows: 41
```

``` r
cat("Columns:", paste(names(tsd), collapse = ", "), "\n")
```

```
## Columns: x, y
```

``` r
head(tsd)
```

```
##      x         y
## 1 0.00 0.0000000
## 2 0.25 0.2474040
## 3 0.50 0.4794255
## 4 0.75 0.6816388
## 5 1.00 0.8414710
## 6 1.25 0.9489846
```


``` r
summary(tsd)
```

```
##        x              y          
##  Min.   : 0.0   Min.   :-0.9993  
##  1st Qu.: 2.5   1st Qu.:-0.3508  
##  Median : 5.0   Median : 0.2474  
##  Mean   : 5.0   Mean   : 0.1719  
##  3rd Qu.: 7.5   3rd Qu.: 0.7985  
##  Max.   :10.0   Max.   : 0.9975
```


``` r
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))
```

![plot of chunk unnamed-chunk-4](fig/01-tsd/unnamed-chunk-4-1.png)

## References

- Generated for package examples and documentation.
