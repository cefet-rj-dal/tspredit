## Train and Test Splits for Singular Multivariate Data

About the concept
- The singular multivariate branch works with aligned observations, that is, with `ts_data_mv(..., sw = 1)`.
- This is the natural input for the new `ts_reg_mv` family, which includes `ts_lm_mv()`, `ts_arimax()`, and `ts_var()`.

Didactic goal: inspect how the aligned multivariate object is split in time before fitting singular multivariate models.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Train and test splits for singular multivariate data

# Installing the package (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```

For the singular branch, it is useful to start from a compact synthetic
multivariate system built from the benchmark series `tsd$y`.


``` r
data(tsd)

x1 <- c(tsd$y[-1], tail(tsd$y, 1))
x2 <- stats::filter(tsd$y, rep(1/3, 3), sides = 1)
x2[is.na(x2)] <- tsd$y[is.na(x2)]

mv <- ts_data_mv(
  data.frame(y = tsd$y, x1 = x1, x2 = as.numeric(x2)),
  y = "y"
)

ts_head(mv, 5)
```

```
##           y        x1        x2
## 1 0.0000000 0.2474040 0.0000000
## 2 0.2474040 0.4794255 0.2474040
## 3 0.4794255 0.6816388 0.2422765
## 4 0.6816388 0.8414710 0.4694894
## 5 0.8414710 0.9489846 0.6675118
```

Because this branch operates directly on synchronized observations, the split is
performed on the aligned object itself.


``` r
samp <- ts_sample(mv, test_size = 5)

ts_head(samp$train, 3)
```

```
##           y        x1        x2
## 1 0.0000000 0.2474040 0.0000000
## 2 0.2474040 0.4794255 0.2474040
## 3 0.4794255 0.6816388 0.2422765
```

``` r
ts_head(samp$test, 3)
```

```
##              y          x1        x2
## 37  0.41211849  0.17388949 0.6117765
## 38  0.17388949 -0.07515112 0.4035773
## 39 -0.07515112 -0.31951919 0.1702856
```

The target remains explicit, but the future auxiliary values are also available
in the held-out partition. This matters because singular multivariate models may
use them in two different ways:

- directly, when the future auxiliaries are already known
- indirectly, when the auxiliaries must be forecast by their own univariate models


``` r
tail(samp$train$y, 3)
```

```
## [1] 0.9226042 0.7984871 0.6247240
```

``` r
as.data.frame(samp$test)[, c("x1", "x2")]
```

```
##             x1          x2
## 37  0.17388949  0.61177652
## 38 -0.07515112  0.40357731
## 39 -0.31951919  0.17028562
## 40 -0.54402111 -0.07359361
## 41 -0.54402111 -0.31289714
```

What this example shows
- `ts_sample()` should be applied directly to the aligned `ts_data_mv()` object in the singular multivariate branch.
- The test partition keeps the future rows of `x1, ..., xn`, which can be supplied directly to `ts_lm_mv()` or `ts_arimax()`.
- This branch is conceptually different from the sliding-window branch, where the split happens after the lagged materialization.
