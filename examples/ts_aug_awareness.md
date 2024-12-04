---
title: An R Markdown document converted from "Rmd/examples/ts_aug_awareness.ipynb"
output: html_document
---

## Time series preprocessing


```r
# TSPredIT
# version 1.0.767

source("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/jupyter.R")

#loading TSPredIT
load_library("daltoolbox") 
```

```
## Loading required package: daltoolbox
```

```
## Registered S3 method overwritten by 'quantmod':
##   method            from
##   as.zoo.data.frame zoo
```

```
## 
## Attaching package: 'daltoolbox'
```

```
## The following object is masked from 'package:base':
## 
##     transform
```

```r
load_library("tspredit") 
```

```
## Loading required package: tspredit
```

### Noise cosine series for studying


```r
i <- seq(0, 2*pi+8*pi/50, pi/50)
x <- cos(i)
noise <- rnorm(length(x), 0, sd(x)/10)

x <- x + noise
x[30] <-rnorm(1, 0, sd(x))

x[60] <-rnorm(1, 0, sd(x))

x[90] <-rnorm(1, 0, sd(x))


options(repr.plot.width=6, repr.plot.height=5)  
par(mfrow = c(1, 1))
plot(i, x)
lines(i, x)
```

![plot of chunk unnamed-chunk-2](fig/ts_aug_awareness/unnamed-chunk-2-1.png)

### sliding windows


```r
sw_size <- 10
xw <- ts_data(x, sw_size)
i <- 1:nrow(xw)
y <- xw[,sw_size]

plot(i, y)
lines(i, y)
```

![plot of chunk unnamed-chunk-3](fig/ts_aug_awareness/unnamed-chunk-3-1.png)

### Augment


```r
filter <- ts_aug_awareness(0.25)
xa <- transform(filter, xw)
idx <- attr(xa, "idx")
```

### Plot


```r
plot(x = i, y = y, main = "cosine")
lines(x = i, y = y, col="black")
for (j in 1:nrow(xa)) {
lines(x = (idx[j]-sw_size+1):idx[j], y = xa[j,1:sw_size], col="green")
}
```

![plot of chunk unnamed-chunk-5](fig/ts_aug_awareness/unnamed-chunk-5-1.png)

