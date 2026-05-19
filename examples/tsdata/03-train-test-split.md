## Time-Ordered Train/Test Split

About the technique
- `ts_sample()` creates training and test segments without shuffling the series.
- In forecasting, preserving chronology is essential because the model must learn from the past and be evaluated on future observations only.

Didactic goal: understand how `tspredit` defines a valid forecasting split before any model is fitted.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
#install.packages("tspredit")

# Loading the package
library(tspredit) 
```

We load the example series that will be used throughout the demonstration.


``` r
# Series for study

data(tsd)
```

We plot the data here so the effect of the next transformation can be compared visually.


``` r
library(ggplot2)
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-3](fig/03-train-test-split/unnamed-chunk-3-1.png)

The next step organizes the series into sliding windows, which is the tabular representation used by the later transformations and models.


``` r
# Sliding windows

sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974
##             t2        t1        t0
## [1,] 0.9839859 0.9092974 0.7780732
## [2,] 0.9092974 0.7780732 0.5984721
## [3,] 0.7780732 0.5984721 0.3816610
```

This chunk sampling (train and test).


``` r
# Sampling (train and test)

test_size <- 3
samp <- ts_sample(ts, test_size)
```

This chunk first five rows of the train set.


``` r
# First five rows of the train set
ts_head(samp$train, 5)
```

```
##             t9        t8        t7        t6        t5        t4        t3
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974
## [4,] 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974 0.7780732
## [5,] 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974 0.7780732 0.5984721
##             t2        t1         t0
## [1,] 0.9839859 0.9092974  0.7780732
## [2,] 0.9092974 0.7780732  0.5984721
## [3,] 0.7780732 0.5984721  0.3816610
## [4,] 0.5984721 0.3816610  0.1411200
## [5,] 0.3816610 0.1411200 -0.1081951
```

This chunk last five rows of the train set.


``` r
# Last five rows of the train set
ts_head(samp$train[-c(1:(nrow(samp$train)-5)),])
```

```
##               t9          t8        t7        t6        t5        t4        t3
## [1,] -0.27941550 -0.03317922 0.2151200 0.4500441 0.6569866 0.8230809 0.9380000
## [2,] -0.03317922  0.21511999 0.4500441 0.6569866 0.8230809 0.9380000 0.9945988
## [3,]  0.21511999  0.45004407 0.6569866 0.8230809 0.9380000 0.9945988 0.9893582
## [4,]  0.45004407  0.65698660 0.8230809 0.9380000 0.9945988 0.9893582 0.9226042
## [5,]  0.65698660  0.82308088 0.9380000 0.9945988 0.9893582 0.9226042 0.7984871
##             t2        t1        t0
## [1,] 0.9945988 0.9893582 0.9226042
## [2,] 0.9893582 0.9226042 0.7984871
## [3,] 0.9226042 0.7984871 0.6247240
## [4,] 0.7984871 0.6247240 0.4121185
## [5,] 0.6247240 0.4121185 0.1738895
```

This chunk test data.


``` r
# Test data
ts_head(samp$test)
```

```
##             t9        t8        t7        t6        t5        t4        t3
## [1,] 0.8230809 0.9380000 0.9945988 0.9893582 0.9226042 0.7984871 0.6247240
## [2,] 0.9380000 0.9945988 0.9893582 0.9226042 0.7984871 0.6247240 0.4121185
## [3,] 0.9945988 0.9893582 0.9226042 0.7984871 0.6247240 0.4121185 0.1738895
##               t2          t1          t0
## [1,]  0.41211849  0.17388949 -0.07515112
## [2,]  0.17388949 -0.07515112 -0.31951919
## [3,] -0.07515112 -0.31951919 -0.54402111
```
