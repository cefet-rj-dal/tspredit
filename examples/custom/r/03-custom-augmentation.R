source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# installation
# install.packages(c("tspredit", "daltoolbox"))

library(daltoolbox)
library(tspredit)

ts_aug_magwarp_custom <- function(sigma = 0.2, knots = 4, preserve_data = TRUE) {
  obj <- daltoolbox::dal_transform()
  obj$sigma <- sigma
  obj$knots <- knots
  obj$preserve_data <- preserve_data
  class(obj) <- append("ts_aug_magwarp_custom", class(obj))
  obj
}

transform.ts_aug_magwarp_custom <- function(obj, data, ...) {
  warp_one <- function(row) {
    p <- length(row) - 1
    if (p < 2) {
      return(row)
    }

    anchor_x <- seq(1, p, length.out = obj$knots)
    anchor_y <- stats::rnorm(obj$knots, mean = 1, sd = obj$sigma)
    curve <- stats::spline(anchor_x, anchor_y, xout = 1:p, method = "natural")$y

    result <- row
    result[1:p] <- row[1:p] * curve
    result
  }

  augmented <- t(apply(data, 1, warp_one))
  augmented <- adjust_ts_data(augmented)
  attr(augmented, "idx") <- 1:nrow(data)

  if (obj$preserve_data) {
    idx <- c(1:nrow(data), attr(augmented, "idx"))
    augmented <- rbind(data, augmented)
    augmented <- adjust_ts_data(augmented)
    attr(augmented, "idx") <- idx
  }

  augmented
}

set_example_seed(123L)
data(tsd)

train_windows <- ts_data(tsd$y, 10)
augment_custom <- ts_aug_magwarp_custom(sigma = 0.15, knots = 4)
train_aug <- transform(augment_custom, train_windows)

data.frame(
  original_rows = nrow(train_windows),
  augmented_rows = nrow(train_aug)
)

samp <- ts_sample(train_windows, test_size = 5)
train_ts <- samp$train
test_ts <- samp$test

train_aug <- transform(augment_custom, train_ts)
train_aug <- adjust_ts_data(train_aug)

io_train <- ts_projection(train_aug)
io_test <- ts_projection(test_ts)

model <- ts_mlp(ts_norm_gminmax(), input_size = 4, size = 4, decay = 0, maxit = 1000)
set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)

prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
evaluate(model, as.vector(io_test$output), prediction)$metrics
