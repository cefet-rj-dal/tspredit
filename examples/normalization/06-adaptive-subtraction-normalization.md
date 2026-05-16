## Adaptive Subtractive Normalization

About the technique

- Subtractive adaptive normalization removes the adaptive local level from each window.
- It is useful when the relevant signal is a deviation around a moving baseline, especially near zero where divisive normalization can become unstable.
- Within the adaptive-normalization family implemented by `ts_norm_an()`, this corresponds to `operation = "subtract"`.

Didactic goal: see adaptive normalization as a local detrending operator that preserves additive contrasts.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Subtractive Normalization

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

![plot of chunk unnamed-chunk-4](fig/06-adaptive-subtraction-normalization/unnamed-chunk-4-1.png)

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

We now apply the subtractive version of adaptive normalization and compare the
supervised target column (`t0`) before and after the transformation.


``` r
preproc <- ts_norm_an(operation = "subtract")
set_example_seed()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3        t2        t1        t0
## [1,] 0.1770086 0.2931936 0.4021548 0.4971174 0.5721773 0.6226675 0.6454487 0.6391047 0.6040297 0.5424046
## [2,] 0.2650884 0.3740495 0.4690122 0.5440720 0.5945622 0.6173435 0.6109994 0.5759245 0.5142994 0.4299558
## [3,] 0.3677446 0.4627073 0.5377671 0.5882573 0.6110386 0.6046945 0.5696195 0.5079945 0.4236508 0.3218327
```

``` r
summary(tst[, 10])
```

```
##        t0         
##  Min.   :0.04995  
##  1st Qu.:0.15185  
##  Median :0.41183  
##  Mean   :0.44854  
##  3rd Qu.:0.73197  
##  Max.   :0.94995
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

![plot of chunk unnamed-chunk-6](fig/06-adaptive-subtraction-normalization/unnamed-chunk-6-1.png)

What to observe

- The transformed target behaves like a moving-baseline deviation.
- This is the safest adaptive choice when the local reference level can be close to zero.

References

- Ogasawara, E., Martinez, L. C., De Oliveira, D., Zimbrão, G., Pappa, G. L., Mattoso, M. (2010).
Adaptive Normalization: A novel data normalization approach for non-stationary time series.
Proceedings of the International Joint Conference on Neural Networks (IJCNN).
doi:10.1109/IJCNN.2010.5596746
