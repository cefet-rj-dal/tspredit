source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Adaptive Normalization Visual Comparison

# Installing the package (if needed)
#install.packages("tspredit")

library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed()

n <- 200
t <- seq_len(n)

synthetic <- list(
  near_zero = 0.03 * sin(t / 5) + rnorm(n, sd = 0.01),
  level_shift = c(rep(0.3, 70), rep(1.2, 60), rep(0.6, 70)) + 0.08 * sin(t / 7),
  heteroscedastic = sin(t / 6) * seq(0.2, 2.2, length.out = n),
  mixed = 0.2 * sin(t / 8) + seq(-0.4, 1.8, length.out = n) + rnorm(n, sd = seq(0.02, 0.25, length.out = n))
)

ops <- list(
  divide = ts_norm_an(operation = "divide"),
  subtract = ts_norm_an(operation = "subtract"),
  softdivide = ts_norm_an(operation = "softdivide", scale = "sd", lambda = 1),
  asinh = ts_norm_an(operation = "asinh", scale = "sd", lambda = 1)
)

collect_transforms <- function(y, series_name) {
  tsw <- ts_data(y, 12)
  out <- data.frame()

  for (op_name in names(ops)) {
    preproc <- ops[[op_name]]
    preproc <- fit(preproc, tsw)
    yt <- transform(preproc, tsw)
    out <- rbind(
      out,
      data.frame(
        idx = seq_len(nrow(yt)),
        value = as.vector(yt[, ncol(yt)]),
        operator = op_name,
        series = series_name
      )
    )
  }

  out
}

comparison <- do.call(
  rbind,
  Map(collect_transforms, synthetic, names(synthetic))
)

ggplot(comparison, aes(x = idx, y = value, color = operator)) +
  geom_line(linewidth = 0.5) +
  facet_wrap(~ series, scales = "free_y", ncol = 2) +
  theme_minimal(base_size = 14)
