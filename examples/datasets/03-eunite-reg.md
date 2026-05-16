## Objective

This notebook introduces `EUNITE.Reg`, the regressor table packaged with the EUNITE competition data.

## Method at a glance

The goal is to inspect the categorical and calendar-style variables that complement the load and temperature series.

## What you will do

- load `EUNITE.Reg`
- inspect dimensions and column names
- preview the first rows
- summarize the regressors


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
data(EUNITE.Reg)
EUNITE.Reg <- expand_dataset(EUNITE.Reg)
cat("Dataset: EUNITE.Reg\n")
```

```
## Dataset: EUNITE.Reg
```

``` r
cat("Rows:", nrow(EUNITE.Reg), "\n")
```

```
## Rows: 761
```

``` r
cat("Columns:", paste(names(EUNITE.Reg), collapse = ", "), "\n")
```

```
## Columns: Holiday, Weekday, split
```

``` r
head(EUNITE.Reg)
```

```
##   Holiday Weekday split
## 1       1       4 train
## 2       0       5 train
## 3       0       6 train
## 4       0       7 train
## 5       0       1 train
## 6       1       2 train
```


``` r
summary(EUNITE.Reg)
```

```
##     Holiday           Weekday        split    
##  Min.   :0.00000   Min.   :1.000   train:730  
##  1st Qu.:0.00000   1st Qu.:2.000   test : 31  
##  Median :0.00000   Median :4.000              
##  Mean   :0.04205   Mean   :4.004              
##  3rd Qu.:0.00000   3rd Qu.:6.000              
##  Max.   :1.00000   Max.   :7.000
```

## References

- Chen, B.-J., Chang, M.-W., and Lin, C.-J. (2004). Load forecasting using support vector machines: a study on EUNITE competition 2001.
