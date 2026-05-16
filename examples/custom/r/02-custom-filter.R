source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# installation
# install.packages(c("tspredit", "daltoolbox"))

library(daltoolbox)
library(tspredit)
library(ggplot2)

ts_fil_median_custom <- function(k = 5) {
  if (k %% 2 == 0) {
    k <- k + 1
  }

  obj <- daltoolbox::dal_transform()
  obj$k <- k
  class(obj) <- append("ts_fil_median_custom", class(obj))
  obj
}

transform.ts_fil_median_custom <- function(obj, data, ...) {
  result <- stats::runmed(as.numeric(data), k = obj$k, endrule = "keep")
  result[is.na(result)] <- as.numeric(data)[is.na(result)]
  result
}

data(tsd)
y_noisy <- tsd$y
y_noisy[c(10, 20, 30)] <- y_noisy[c(10, 20, 30)] + c(1, -1.2, 1.1)

filter_custom <- ts_fil_median_custom(k = 5)
y_filtered <- transform(filter_custom, y_noisy)

plot_ts_pred(y = y_noisy, yadj = y_filtered) + theme(text = element_text(size = 16))

ts_filtered <- ts_data(y_filtered, 10)
samp <- ts_sample(ts_filtered, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

model <- ts_mlp(ts_norm_gminmax(), input_size = 4, size = 4, decay = 0, maxit = 1000)
set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)

prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
evaluate(model, as.vector(io_test$output), prediction)$metrics
