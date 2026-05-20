## Adaptive Softdivide Normalization

About the technique

- Softdivide adaptive normalization blends subtractive and divisive behavior through a stabilized denominator.
- It is useful when the series can be close to zero in some windows but still exhibit heteroscedastic scaling in others.
- Within the adaptive-normalization family implemented by `ts_norm_an()`, this corresponds to `operation = "softdivide"`.
- The adaptive center and scale are estimated on the full supervised window, then the resulting values are globally rescaled by the internal min-max stage.

Didactic goal: see how a smooth transition between additive and relative normalization regimes can stabilize windows without losing scale comparability.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Softdivide Normalization

# Installing the package (if needed)
#install.packages("tspredit")
```

We start by loading the packages used throughout this example.


``` r
library(daltoolbox)
library(tspredit)
library(ggplot2)
```

We load the example series that will be used throughout the demonstration.


``` r
data(tsd)
```

The first plot shows the original series. This is the common visual reference
for all normalization examples in this folder.


``` r
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))
```

![plot of chunk unnamed-chunk-4](fig/07-adaptive-softdivide-normalization/unnamed-chunk-4-1.png)

The next step organizes the series into sliding windows, which is the tabular
representation used by the later transformations and models.


``` r
sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3        t2        t1        t0
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974 0.7780732
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974 0.7780732 0.5984721
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974 0.7780732 0.5984721 0.3816610
```

``` r
summary(ts[, 10])
```

```
##        t0          
##  Min.   :-0.99929  
##  1st Qu.:-0.55091  
##  Median : 0.05397  
##  Mean   : 0.02988  
##  3rd Qu.: 0.63279  
##  Max.   : 0.99460
```

We now apply the smooth hybrid normalization operator and compare the
supervised target column (`t0`) before and after the transformation.


``` r
preproc <- ts_norm_an(operation = "softdivide", scale = "sd", lambda = 1)
set_example_seed()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3        t2        t1        t0
## [1,] 0.1912055 0.3024095 0.4066993 0.4975909 0.5694328 0.6177584 0.6395630 0.6334909 0.5999197 0.5409365
## [2,] 0.2810741 0.3827776 0.4714149 0.5414752 0.5886023 0.6098661 0.6039446 0.5712060 0.5136856 0.4349600
## [3,] 0.3775969 0.4657268 0.5353859 0.5822431 0.6033852 0.5974976 0.5649464 0.5077554 0.4294806 0.3349886
```

``` r
summary(tst[, 10])
```

```
##        t0        
##  Min.   :0.0000  
##  1st Qu.:0.1630  
##  Median :0.4157  
##  Mean   :0.4492  
##  3rd Qu.:0.7245  
##  Max.   :0.9975
```

``` r
compare_t0 <- rbind(
  data.frame(idx = seq_len(nrow(ts)), value = as.vector(ts[, ncol(ts)]), series = "original t0"),
  data.frame(idx = seq_len(nrow(tst)), value = as.vector(tst[, ncol(tst)]), series = "transformed t0")
)

plot_ts_pred(
  x = compare_t0[compare_t0$series == "original t0", "idx"],
  y = compare_t0[compare_t0$series == "original t0", "value"],
  yadj = compare_t0[compare_t0$series == "transformed t0", "value"]
) + theme(text = element_text(size = 16))
```

![plot of chunk unnamed-chunk-6](fig/07-adaptive-softdivide-normalization/unnamed-chunk-6-1.png)

What to observe

- The transformed target behaves more like a difference near zero and more like a ratio at higher levels.
- This is the main compromise operator of the adaptive-normalization family.

References

- Ogasawara, E., Martinez, L. C., De Oliveira, D., Zimbrão, G., Pappa, G. L., Mattoso, M. (2010).
Adaptive Normalization: A novel data normalization approach for non-stationary time series.
Proceedings of the International Joint Conference on Neural Networks (IJCNN).
doi:10.1109/IJCNN.2010.5596746
- Huber, P. J. (1964). Robust Estimation of a Location Parameter.
Annals of Mathematical Statistics, 35(1), 73-101. doi:10.1214/aoms/1177703732
