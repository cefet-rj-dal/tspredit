## Adaptive Divisive Normalization

About the technique

- Divisive adaptive normalization rescales each window by its own adaptive reference level.
- It is useful when the same local pattern appears at different amplitudes and should be seen as similar by the predictor.
- Within the adaptive-normalization family implemented by `ts_norm_an()`, this is the default operator: `operation = "divide"`.

Didactic goal: understand adaptive normalization as a relative-scale transformation that tracks level drift over time.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Divisive Normalization

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

![plot of chunk unnamed-chunk-4](fig/05-adaptive-normalization/unnamed-chunk-4-1.png)

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

We now apply the divisive version of adaptive normalization and compare the
supervised target column (`t0`) before and after the transformation.


``` r
preproc <- ts_norm_an()
set_example_seed()
preproc <- fit(preproc, ts)
tst <- transform(preproc, ts)
ts_head(tst, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3        t2        t1        t0
## [1,] 0.4104005 0.4703532 0.5265782 0.5755799 0.6143115 0.6403650 0.6521203 0.6488467 0.6307477 0.5989485
## [2,] 0.4655475 0.5172657 0.5623396 0.5979666 0.6219317 0.6327448 0.6297336 0.6130853 0.5838351 0.5438015
## [3,] 0.5153781 0.5596557 0.5946534 0.6181952 0.6288172 0.6258592 0.6095050 0.5807715 0.5414451 0.4939710
```

``` r
summary(tst[, 10])
```

```
##        t0          
##  Min.   :-11.3835  
##  1st Qu.:  0.3097  
##  Median :  0.4831  
##  Mean   :  0.1555  
##  3rd Qu.:  0.6143  
##  Max.   :  2.6473
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

![plot of chunk unnamed-chunk-6](fig/05-adaptive-normalization/unnamed-chunk-6-1.png)

What to observe

- The transformed target emphasizes relative deviations from the adaptive local level.
- This is the most direct adaptive alternative when scale invariance matters more than additive offsets.

References

- Ogasawara, E., Martinez, L. C., De Oliveira, D., Zimbrão, G., Pappa, G. L., Mattoso, M. (2010).
Adaptive Normalization: A novel data normalization approach for non-stationary time series.
Proceedings of the International Joint Conference on Neural Networks (IJCNN).
doi:10.1109/IJCNN.2010.5596746
