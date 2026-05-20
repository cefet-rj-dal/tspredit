source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Time series augmentation - jitter

# Installing the package (if needed)
#install.packages("tspredit")

# Loading the packages
library(daltoolbox)
library(tspredit) 

# Series for study

data(tsd)
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Sliding windows

sw_size <- 10
xw <- ts_data(tsd$y, sw_size)

# Augmentation (jitter)

augment <- ts_aug_jitter()
set_example_seed()
augment <- fit(augment, xw)
xa <- transform(augment, xw)
idx <- attr(xa, "idx")
ts_head(xa)

# Plot a few representative windows on the lag axis
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
