## Adaptive Asinh Normalization

About the technique

- Adaptive asinh normalization applies an inverse-hyperbolic-sine contrast around the adaptive local level.
- It is useful when the analyst wants a transformation that is approximately linear near zero and progressively log-like for larger magnitudes.
- Within the adaptive-normalization family implemented by `ts_norm_an()`, this corresponds to `operation = "asinh"`.

Didactic goal: understand a smooth nonlinear alternative that connects additive and multiplicative interpretations without a hard switch.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Asinh Normalization

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

![plot of chunk unnamed-chunk-4](fig/08-adaptive-asinh-normalization/unnamed-chunk-4-1.png)

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

We now apply the adaptive asinh operator and compare the supervised target
column (`t0`) before and after the transformation.


``` r
preproc <- ts_norm_an(operation = "asinh", scale = "sd", lambda = 1)
set_example_seed()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3        t2        t1        t0
## [1,] 0.2262389 0.3352009 0.4289621 0.5011678 0.5519707 0.5832954 0.5967386 0.5930364 0.5719840 0.5324504
## [2,] 0.3189801 0.4108290 0.4818765 0.5320312 0.5630196 0.5763321 0.5726651 0.5518244 0.5127444 0.4537091
## [3,] 0.4069396 0.4777221 0.5277275 0.5586382 0.5719204 0.5682616 0.5474698 0.5084945 0.4496521 0.3696621
```

``` r
summary(tst[, 10])
```

```
##        t0         
##  Min.   :0.06292  
##  1st Qu.:0.19582  
##  Median :0.44171  
##  Mean   :0.45703  
##  3rd Qu.:0.68093  
##  Max.   :0.94882
```

``` r
compare_t0 <- rbind(
  data.frame(idx = seq_len(nrow(ts)), value = as.vector(ts[, ncol(ts)]), series = "original t0"),
  data.frame(idx = seq_len(nrow(tst)), value = as.vector(tst[, ncol(tst)]), series = "transformed t0")
)

ggplot(compare_t0, aes(x = idx, y = value, color = series)) +
  geom_line(linewidth = 0.7) +
  theme_minimal(base_size = 14)
```

![plot of chunk unnamed-chunk-6](fig/08-adaptive-asinh-normalization/unnamed-chunk-6-1.png)

What to observe

- Near zero, the transformed target stays close to an additive contrast.
- For larger deviations, the transformation becomes progressively more log-like without switching abruptly.

References

- Burbidge, J. B., Magee, L., Robb, A. L. (1988). Alternative Transformations to Handle Extreme Values of the Dependent Variable.
Journal of the American Statistical Association, 83(401), 123-127.
- Bellemare, M. F., Wichman, C. J. (2020). Elasticities and the Inverse Hyperbolic Sine Transformation.
Oxford Bulletin of Economics and Statistics, 82(1), 50-61. doi:10.1111/obes.12325
