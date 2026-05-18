## Build Multivariate Time-Series Data

About the concept
- `ts_data_mv()` is the multivariate entry point of `tspredit` 2.0.
- It does not build lagged windows immediately. Its job is to preserve the temporal alignment between the target `y` and the auxiliary variables `x1, ..., xn`.

Didactic goal: understand how the multivariate workflow starts before any forecasting model is trained.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Build multivariate time-series data

# Installing the package (if needed)
# install.packages("tspredit")
```

We begin by loading the packages used in the example.


``` r
library(daltoolbox)
```

```
## Warning: pacote 'daltoolbox' foi compilado no R versão 4.5.1
```

```
## 
## Anexando pacote: 'daltoolbox'
```

```
## O seguinte objeto é mascarado por 'package:base':
## 
##     transform
```

``` r
library(tspredit)
```

```
## Registered S3 method overwritten by 'quantmod':
##   method            from
##   as.zoo.data.frame zoo
```

We now use package benchmarks already distributed with `tspredit`. We extract:

- the daily maximum load from `EUNITE.Loads` as the target `y`
- the weekday code from `EUNITE.Reg` as `x1`
- a weekend indicator derived from `EUNITE.Reg` as `x2`


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
```

We now build the aligned multivariate object. Every row corresponds to the same
time instant for `y`, `x1`, and `x2`.


``` r
mv <- ts_data_mv(
  data.frame(
    y = y,
    x1 = x1,
    x2 = x2
  ),
  y = "y"
)

ts_head(mv, 5)
```

```
##     y x1 x2
## 1 797  4  0
## 2 777  5  0
## 3 797  6  0
## 4 757  7  1
## 5 707  1  1
```

The object keeps the target and the auxiliary variable names as metadata.


``` r
attr(mv, "y")
```

```
## Warning in attr(mv, "y"): 'xfun::attr()' é obsoleto.
## Use 'xfun::attr2()' em seu lugar.
## Veja help("Deprecated")
```

```
## [1] "y"
```

``` r
attr(mv, "x")
```

```
## Warning in attr(mv, "x"): 'xfun::attr()' é obsoleto.
## Use 'xfun::attr2()' em seu lugar.
## Veja help("Deprecated")
```

```
## [1] "x1" "x2"
```

``` r
attr(mv, "variables")
```

```
## Warning in attr(mv, "variables"): 'xfun::attr()' é obsoleto.
## Use 'xfun::attr2()' em seu lugar.
## Veja help("Deprecated")
```

```
## [1] "y"  "x1" "x2"
```

The next step in most workflows is a time-aware split.


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

What this example shows
- `ts_data_mv()` is the aligned multivariate representation used by the rest of the multivariate workflow.
- The object preserves the semantic distinction between the target and the auxiliary variables.
- `ts_sample()` works on `ts_data_mv()` just as it does on the univariate workflow, but without losing temporal alignment.
