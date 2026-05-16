## Spline Filter

About the method
- Spline smoothing fits a smooth curve whose roughness is controlled by a smoothing parameter.
- It is useful when you want explicit control over the tradeoff between fidelity to the data and smoothness.

Didactic goal: inspect how spline-based smoothing changes the signal and how it differs from local smoothing.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Filter - Spline

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

![plot of chunk unnamed-chunk-4](fig/06-spline-filter/unnamed-chunk-4-1.png)

Now we applying the spline filter.


``` r
# Applying the Spline filter

filter <-  ts_fil_spline(spar = 0.5)
set_example_seed()
filter <- fit(filter, tsd$y)
y <- transform(filter, tsd$y)
plot_ts_pred(y=tsd$y, yadj=y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-5](fig/06-spline-filter/unnamed-chunk-5-1.png)

References
- G. Wahba (1990). Spline Models for Observational Data. SIAM.

