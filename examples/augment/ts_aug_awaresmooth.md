Objective: Augment data with temporal awareness and progressive smoothing, reducing noise and prioritizing recent samples.


``` r
# Installing the package (if needed)
#install.packages("tspredit")
```


``` r
# Loading the packages
library(daltoolbox)
library(tspredit) 
```



``` r
# Cosine series with noise for study

i <- seq(0, 2*pi+8*pi/50, pi/50)
x <- cos(i)
noise <- rnorm(length(x), 0, sd(x)/10)

x <- x + noise
x[30] <- rnorm(1, 0, sd(x))

x[60] <- rnorm(1, 0, sd(x))

x[90] <- rnorm(1, 0, sd(x))


options(repr.plot.width=6, repr.plot.height=5)  
par(mfrow = c(1, 1))
plot(i, x)
lines(i, x)
```

![plot of chunk unnamed-chunk-3](fig/ts_aug_awaresmooth/unnamed-chunk-3-1.png)


``` r
# Sliding windows

sw_size <- 10
xw <- ts_data(x, sw_size)
i <- 1:nrow(xw)
y <- xw[,sw_size]

plot(i, y)
lines(i, y)
```

![plot of chunk unnamed-chunk-4](fig/ts_aug_awaresmooth/unnamed-chunk-4-1.png)


``` r
# Augmentation (awareness + smoothing)

filter <- tspredit::ts_aug_awaresmooth(0.25)
xa <- transform(filter, xw)
idx <- attr(xa, "idx")
```


``` r
# Plot (original vs augmented windows)

plot(x = i, y = y, main = "cosine")
lines(x = i, y = y, col="black")
for (j in 1:nrow(xa)) {
  lines(x = (idx[j]-sw_size+1):idx[j], y = xa[j,1:sw_size], col="green")
}
```

![plot of chunk unnamed-chunk-6](fig/ts_aug_awaresmooth/unnamed-chunk-6-1.png)

