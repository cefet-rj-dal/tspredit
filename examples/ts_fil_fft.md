## Filter - FFT


```r
# tspredit: Time Series Prediction Integrated Tuning
# version 1.0.787



#loading TSPredIT
library(daltoolbox) 
library(tspredit) 

source("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/R/ts_fil_fft.R")
```

### Series for studying with added noise


```r
data(sin_data)
y <- sin_data$y
noise <- rnorm(length(y), 0, sd(y)/10)
spike <- rnorm(1, 0, sd(y))
sin_data$y <- sin_data$y + noise
sin_data$y[10] <- sin_data$y[10] + spike
sin_data$y[20] <- sin_data$y[20] + spike
sin_data$y[30] <- sin_data$y[30] + spike
```


```r
library(ggplot2)
plot_ts(x=sin_data$x, y=sin_data$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-3](fig/ts_fil_fft/unnamed-chunk-3-1.png)

### smooth


```r
filter <- ts_fil_fft()
filter <- fit(filter, sin_data$y)
y <- transform(filter, sin_data$y)
plot_ts_pred(y=sin_data$y, yadj=y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-4](fig/ts_fil_fft/unnamed-chunk-4-1.png)
