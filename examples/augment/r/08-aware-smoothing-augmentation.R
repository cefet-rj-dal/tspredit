source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Installing the package (if needed)
#install.packages("tspredit")

# Loading the packages
library(daltoolbox)
library(tspredit) 

# Cosine series with noise for study

i <- seq(0, 2*pi+8*pi/50, pi/50)
x <- cos(i)
set_example_seed()
noise <- rnorm(length(x), 0, sd(x)/10)

x <- x + noise
x[30] <- rnorm(1, 0, sd(x))

x[60] <- rnorm(1, 0, sd(x))

x[90] <- rnorm(1, 0, sd(x))


options(repr.plot.width=6, repr.plot.height=5)  
par(mfrow = c(1, 1))
plot(i, x)
lines(i, x)

# Sliding windows

sw_size <- 10
xw <- ts_data(x, sw_size)
i <- 1:nrow(xw)
y <- xw[,sw_size]

plot(i, y)
lines(i, y)

# Augmentation (awareness + smoothing)

filter <- tspredit::ts_aug_awaresmooth(0.25)
xa <- transform(filter, xw)
idx <- attr(xa, "idx")

# Plot a few representative windows on the lag axis
library(ggplot2)
aug_rows <- (nrow(xw) + 1):min(nrow(xa), nrow(xw) + 6)
comparison <- do.call(
  rbind,
  lapply(aug_rows, function(row_id) {
    source_row <- idx[row_id]
    rbind(
      data.frame(lag = seq_len(sw_size), value = as.numeric(xw[source_row, 1:sw_size]), series = "original", sample = paste("window", source_row)),
      data.frame(lag = seq_len(sw_size), value = as.numeric(xa[row_id, 1:sw_size]), series = "augmented", sample = paste("window", source_row))
    )
  })
)

ggplot(comparison, aes(x = lag, y = value, color = series, group = series)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.2) +
  facet_wrap(~ sample, ncol = 3) +
  theme_minimal(base_size = 14)
