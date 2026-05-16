## Exponential Moving Average Filter

About the method
- The exponential moving average smooths the series with weights that decay over time.
- Compared with a simple moving average, it reacts faster to recent changes because the newest observations receive more weight.

Didactic goal: understand a basic smoothing method that balances denoising and recency.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Filter - Exponential Moving Average (EMA)

# Installing the package (if needed)
#install.packages("tspredit")
```

We start by loading the packages used throughout this example.


``` r
# Loading the packages
library(daltoolbox)
library(tspredit) 
```


We load the example series that will be used throughout the demonstration.


``` r
# Series for study with artificial noise and spikes

data(tsd)
y <- tsd$y
noise <- rnorm(length(y), 0, sd(y)/10)
spike <- rnorm(1, 0, sd(y))
tsd$y <- tsd$y + noise
tsd$y[10] <- tsd$y[10] + spike
tsd$y[20] <- tsd$y[20] + spike
tsd$y[30] <- tsd$y[30] + spike
```

We plot the data here so the effect of the next transformation can be compared visually.


``` r
library(ggplot2)
# Noisy series visualization
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-4](fig/03-exponential-moving-average-filter/unnamed-chunk-4-1.png)

Now we applying the ema filter.


``` r
# Applying the EMA filter

filter <- ts_fil_ema(3)
set_example_seed()
filter <- fit(filter, tsd$y)
y <- transform(filter, tsd$y)
plot_ts_pred(y=tsd$y, yadj=y) + theme(text = element_text(size=16))
```

```
## Warning: Removed 2 rows containing missing values or values outside the scale range (`geom_line()`).
```

![plot of chunk unnamed-chunk-5](fig/03-exponential-moving-average-filter/unnamed-chunk-5-1.png)

References
- R. G. Brown (1959). Exponential Smoothing for Predicting Demand. Addison-Wesley.

