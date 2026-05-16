source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Mutual information lag mapping

library(daltoolbox)
library(tspredit)

data(tsd)
plot_ts(x = tsd$x, y = tsd$y)

sw_size <- 10
ts <- ts_data(tsd$y, sw_size)
samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

mapper <- ts_lagmap(method = "mi", bins = 8)
mapper <- fit(mapper, io_train$input, io_train$output, input_size = 4)
mapper$lags
mapper$columns

model <- ts_knn(
  preprocess = ts_norm_gminmax(),
  input_size = 4,
  input_map = ts_lagmap(method = "mi", bins = 8),
  k = 3
)
set_example_seed()
model <- fit(model, io_train$input, io_train$output)
prediction <- predict(model, io_test$input[1, ], steps_ahead = 5)
evaluate(model, as.vector(io_test$output), as.vector(prediction))
