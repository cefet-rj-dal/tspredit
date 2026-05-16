source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# installation
# install.packages(c("tspredit", "daltoolbox", "RSNNS"))

library(daltoolbox)
library(tspredit)

ts_mlp_rsnns_custom <- function(preprocess = ts_norm_gminmax(),
                                input_size = 4,
                                size = 5,
                                learn_rate = 0.1,
                                maxit = 200) {
  obj <- ts_regsw(preprocess = preprocess, input_size = input_size)
  obj$size <- size
  obj$learn_rate <- learn_rate
  obj$maxit <- maxit
  class(obj) <- append("ts_mlp_rsnns_custom", class(obj))
  obj
}

do_fit.ts_mlp_rsnns_custom <- function(obj, x, y) {
  if (!requireNamespace("RSNNS", quietly = TRUE)) {
    stop("This example requires the 'RSNNS' package.")
  }

  obj$model <- RSNNS::mlp(
    x = as.matrix(x),
    y = as.matrix(y),
    size = obj$size,
    learnFuncParams = c(obj$learn_rate),
    maxit = obj$maxit,
    linOut = TRUE
  )

  obj
}

do_predict.ts_mlp_rsnns_custom <- function(obj, x) {
  as.numeric(predict(obj$model, as.matrix(x)))
}

registerS3method("do_fit", "ts_mlp_rsnns_custom", do_fit.ts_mlp_rsnns_custom)
registerS3method("do_predict", "ts_mlp_rsnns_custom", do_predict.ts_mlp_rsnns_custom)

set_example_seed(123L)
data(tsd)

ts <- ts_data(tsd$y, 10)
samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

model <- ts_mlp_rsnns_custom(
  preprocess = ts_norm_gminmax(),
  input_size = 4,
  size = 5,
  learn_rate = 0.05,
  maxit = 300
)

set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)

adjust <- as.vector(predict(model, io_train$input))
train_eval <- evaluate(model, as.vector(io_train$output), adjust)
train_eval$metrics

prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
test_eval <- evaluate(model, as.vector(io_test$output), prediction)
test_eval$metrics
