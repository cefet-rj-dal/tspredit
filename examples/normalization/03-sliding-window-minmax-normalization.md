## Sliding-Window Min-Max Normalization

About the technique

- This strategy normalizes each window with its own local minimum and maximum.
- It emphasizes local shape over absolute level, which can help when amplitude varies through time.

Didactic goal: compare local scaling with global scaling and see what information each one keeps or removes.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Window-based Normalization (Min-Max)

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

![plot of chunk unnamed-chunk-4](fig/03-sliding-window-minmax-normalization/unnamed-chunk-4-1.png)

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

We now apply sliding-window min-max normalization and compare the supervised
target column (`t0`) before and after the transformation.


``` r
preproc <- ts_norm_swminmax()
```

```
## Warning: internal error 1 in R_decompress1 with libdeflate
```

```
## Error:
## ! lazy-load database 'C:/R/R-4.5.0/library/tspredit/R/tspredit.rdb' is corrupt
```

``` r
set_example_seed()
preproc <- fit(preproc, ts)
```

```
## Error:
## ! objeto 'preproc' não encontrado
```

``` r
tst <- transform(preproc, ts)
```

```
## Error:
## ! objeto 'preproc' não encontrado
```

``` r
ts_head(tst, 3)
```

```
## Error:
## ! objeto 'tst' não encontrado
```

``` r
summary(tst[, 10])
```

```
## Error:
## ! objeto 'tst' não encontrado
```

``` r
compare_t0 <- rbind(
  data.frame(idx = seq_len(nrow(ts)), value = as.vector(ts[, ncol(ts)]), series = "original t0"),
  data.frame(idx = seq_len(nrow(tst)), value = as.vector(tst[, ncol(tst)]), series = "transformed t0")
)
```

```
## Error:
## ! objeto 'tst' não encontrado
```

``` r
ggplot(compare_t0, aes(x = idx, y = value, color = series)) +
  geom_line(linewidth = 0.7) +
  theme_minimal(base_size = 14)
```

```
## Error:
## ! objeto 'compare_t0' não encontrado
```

What to observe

- The transformed curve reacts to each local window rather than to one global scale.
- Compared with global min-max, this makes local patterns more comparable but removes more absolute-level information.

References

- C. M. Bishop (2006). Pattern Recognition and Machine Learning. Springer.
