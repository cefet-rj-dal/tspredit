
``` r
# Filter - Moving Average

# Installing tspredit
install.packages("tspredit")
```


``` r
# Loading tspredit
library(daltoolbox)
library(tspredit) 
```



``` r
# Series for studying with added noise

data(tsd)
y <- tsd$y
noise <- rnorm(length(y), 0, sd(y)/10)
spike <- rnorm(1, 0, sd(y))
tsd$y <- tsd$y + noise
tsd$y[10] <- tsd$y[10] + spike
tsd$y[20] <- tsd$y[20] + spike
tsd$y[30] <- tsd$y[30] + spike
```


``` r
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-4](fig/ts_fil_ma/unnamed-chunk-4-1.png)


``` r
# filtering

filter <- ts_fil_ma(3)
filter <- fit(filter, tsd$y)
y <- transform(filter, tsd$y)
plot_ts_pred(y=tsd$y, yadj=y) + theme(text = element_text(size=16))
```

```
## Warning: Removed 2 rows containing missing values or values outside the scale range (`geom_line()`).
```

![plot of chunk unnamed-chunk-5](fig/ts_fil_ma/unnamed-chunk-5-1.png)

