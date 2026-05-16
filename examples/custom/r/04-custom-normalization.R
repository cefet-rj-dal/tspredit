source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# installation
# install.packages(c("tspredit", "daltoolbox"))

library(daltoolbox)
library(tspredit)

ts_norm_an_div_custom <- function(outliers = daltoolbox::outliers_boxplot(),
                                  nw = 0,
                                  eps = 1e-8) {
  obj <- daltoolbox::dal_transform()
  obj$outliers <- outliers
  obj$nw <- nw
  obj$eps <- eps
  obj$an_mean <- mean
  obj$ma <- function(obj, data, func) {
    data <- unclass(as.matrix(data))
    if (obj$nw != 0) {
      cols <- ncol(data) - ((obj$nw - 1):0)
      data <- data[, cols, drop = FALSE]
    }
    apply(data, 1, func, na.rm = TRUE)
  }
  class(obj) <- append("ts_norm_an_div_custom", class(obj))
  obj
}

fit.ts_norm_an_div_custom <- function(obj, data, ...) {
  input <- data[, 1:(ncol(data) - 1)]
  an <- obj$ma(obj, input, obj$an_mean)
  denom <- ifelse(abs(an) < obj$eps, obj$eps, an)
  data <- sweep(data, 1, denom, "/")

  if (!is.null(obj$outliers)) {
set_example_seed()
    out <- fit(obj$outliers, data)
    data <- transform(out, data)
  }

  obj$gmin <- min(data)
  obj$gmax <- max(data)
  obj
}

transform.ts_norm_an_div_custom <- function(obj, data, x = NULL, ...) {
  if (!is.null(x)) {
    denom <- attr(data, "an_denom")
    x <- x / denom
    x <- (x - obj$gmin) / (obj$gmax - obj$gmin)
    return(x)
  }

  an <- obj$ma(obj, data, obj$an_mean)
  denom <- ifelse(abs(an) < obj$eps, obj$eps, an)
  data <- sweep(data, 1, denom, "/")
  data <- (data - obj$gmin) / (obj$gmax - obj$gmin)
  attr(data, "an_mean") <- an
  attr(data, "an_denom") <- denom
  data
}

inverse_transform.ts_norm_an_div_custom <- function(obj, data, x = NULL, ...) {
  denom <- attr(data, "an_denom")

  if (!is.null(x)) {
    x <- x * (obj$gmax - obj$gmin) + obj$gmin
    x <- x * denom
    return(x)
  }

  data <- data * (obj$gmax - obj$gmin) + obj$gmin
  data <- data * denom
  attr(data, "an_denom") <- denom
  data
}

registerS3method("fit", "ts_norm_an_div_custom", fit.ts_norm_an_div_custom)
registerS3method("transform", "ts_norm_an_div_custom", transform.ts_norm_an_div_custom)
registerS3method("inverse_transform", "ts_norm_an_div_custom", inverse_transform.ts_norm_an_div_custom)

data(gdp)
series <- gdp$usa_gdp

ts <- ts_data(series, 10)
normalizer <- ts_norm_an_div_custom(nw = 3)
set_example_seed()
normalizer <- fit(normalizer, ts)
tst <- transform(normalizer, ts)

ts_head(tst, 3)

samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

model <- ts_mlp(
  preprocess = ts_norm_an_div_custom(nw = 3),
  input_size = 4,
  size = 4,
  decay = 0,
  maxit = 1000
)

set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)
prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
evaluate(model, as.vector(io_test$output), prediction)$metrics
