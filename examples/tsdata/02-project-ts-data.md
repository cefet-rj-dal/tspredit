## Project `ts_data` into `X` and `y`

About the technique
- `ts_projection()` separates the lagged attributes from the forecast target.
- This is the bridge between the time-series representation and the supervised-learning interface expected by forecasting models.

Didactic goal: see exactly how a time-series window becomes model input (`X`) and expected output (`y`).


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

Before moving on, we visualize the series so the effect of the next transformation can be compared against the original signal.


``` r
# Series visualization
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-3](fig/02-project-ts-data/unnamed-chunk-3-1.png)

The next step organizes the series into sliding windows, which is the tabular representation used by the later transformations and models.


``` r
# Sliding windows

sw_size <- 5
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
```

```
##             t4        t3        t2        t1        t0
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388 0.8414710
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950
```

We now preserve the time order, split the data into train and test partitions, and project the windows into inputs and targets.


``` r
# Projection (X, y)

io <- ts_projection(ts)
```

This chunk input data (x).


``` r
# Input data (X)
ts_head(io$input)
```

```
##             t4        t3        t2        t1
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846
## [4,] 0.6816388 0.8414710 0.9489846 0.9974950
## [5,] 0.8414710 0.9489846 0.9974950 0.9839859
## [6,] 0.9489846 0.9974950 0.9839859 0.9092974
```

This chunk output data (y).


``` r
# Output data (y)
ts_head(io$output)
```

```
##             t0
## [1,] 0.8414710
## [2,] 0.9489846
## [3,] 0.9974950
## [4,] 0.9839859
## [5,] 0.9092974
## [6,] 0.7780732
```
