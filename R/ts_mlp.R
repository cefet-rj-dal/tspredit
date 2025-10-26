#'@title MLP
#'@description Create a time series prediction object based on a
#' Multilayer Perceptron (MLP) regressor.
#'
#' It wraps the `nnet` package to train a single-hidden-layer neural network
#' on sliding-window inputs. Use `ts_regsw` utilities to project inputs/outputs.
#'
#'@details The MLP is a universal function approximator capable of learning
#' non-linear mappings from lagged inputs to next-step values. For stability,
#' consider normalizing inputs (e.g., `ts_norm_gminmax()`). Hidden size and
#' weight decay control capacity and regularization respectively.
#'
#'@param preprocess Normalization preprocessor (e.g., `ts_norm_gminmax()`).
#'@param input_size Integer. Number of lagged inputs used by the model.
#'@param size Integer. Number of hidden neurons.
#'@param decay Numeric. L2 weight decay (regularization) parameter.
#'@param maxit Integer. Maximum number of training iterations.
#'@return A `ts_mlp` object (S3) inheriting from `ts_regsw`.
#'
#'@references
#' - D. E. Rumelhart, G. E. Hinton, and R. J. Williams (1986). Learning
#'   representations by back-propagating errors. Nature 323, 533–536.
#' - W. N. Venables and B. D. Ripley (2002). Modern Applied Statistics with S.
#'   Fourth Edition. Springer. (for the `nnet` package)
#'@examples
#'# Example: MLP on sliding windows with min–max normalization
#'library(daltoolbox)
#'data(tsd)
#'ts <- ts_data(tsd$y, 10)
#'ts_head(ts, 3)
#'
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'# Prepare projection (X, y)
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'# Define and fit the MLP
#'model <- ts_mlp(ts_norm_gminmax(), input_size = 4, size = 4, decay = 0)
#'model <- fit(model, x=io_train$input, y=io_train$output)
#'
#'# Predict 5 steps ahead
#'prediction <- predict(model, x = io_test$input[1,], steps_ahead = 5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(io_test$output)
#'
#'# Evaluate
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'@export
ts_mlp <- function(preprocess=NA, input_size=NA, size=NA, decay=0.01, maxit=1000) {
  obj <- ts_regsw(preprocess, input_size)
  if (is.na(size))
    size <- ceiling(input_size/3)

  obj$size <- size
  obj$decay <- decay
  obj$maxit <- maxit

  class(obj) <- append("ts_mlp", class(obj))
  return(obj)
}


#'@importFrom nnet nnet
#'@exportS3Method do_fit ts_mlp
#'@inheritParams do_fit
#'@return A fitted `ts_mlp` object with trained `nnet` model.
do_fit.ts_mlp <- function(obj, x, y) {
  obj$model <- nnet::nnet(x = x, y = y, size = obj$size, decay=obj$decay, maxit = obj$maxit, linout=TRUE, trace = FALSE)
  return(obj)
}
