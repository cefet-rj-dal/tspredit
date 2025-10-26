#'@title SVM
#'@description Create a time series prediction object that uses
#' Support Vector Regression (SVR) on sliding-window inputs.
#'
#' It wraps the `e1071` package to fit epsilon-insensitive regression with
#' linear, radial, polynomial, or sigmoid kernels.
#'
#'@details SVR aims to find a function with at most epsilon deviation from
#' each training point while being as flat as possible. The `cost` parameter
#' controls the trade-off between margin width and violations; `epsilon`
#' controls the insensitivity tube width. RBF kernels often work well for
#' nonlinear series; tune `cost`, `epsilon`, and kernel hyperparameters.
#'
#'@param preprocess Normalization preprocessor (e.g., `ts_norm_gminmax()`).
#'@param input_size Integer. Number of lagged inputs used by the model.
#'@param kernel Character. One of 'linear', 'radial', 'polynomial', 'sigmoid'.
#'@param epsilon Numeric. Epsilon-insensitive loss width.
#'@param cost Numeric. Regularization parameter controlling margin violations.
#'@return A `ts_svm` object (S3) inheriting from `ts_regsw`.
#'
#'@references
#' - C. Cortes and V. Vapnik (1995). Support-Vector Networks. Machine Learning,
#'   20, 273–297.
#'@examples
#'# Example: SVR with min–max normalization
#' # Load package and dataset
#' library(daltoolbox)
#' data(tsd)
#'
#' # Create sliding windows and preview
#' ts <- ts_data(tsd$y, 10)
#' ts_head(ts, 3)
#'
#' # Temporal split and (X, y) projection
#' samp <- ts_sample(ts, test_size = 5)
#' io_train <- ts_projection(samp$train)
#' io_test <- ts_projection(samp$test)
#'
#' # Define SVM regressor and fit to training data
#' model <- ts_svm(ts_norm_gminmax(), input_size = 4)
#' model <- fit(model, x = io_train$input, y = io_train$output)
#'
#' # Multi-step forecast and evaluation
#' prediction <- predict(model, x = io_test$input[1,], steps_ahead = 5)
#' prediction <- as.vector(prediction)
#' output <- as.vector(io_test$output)
#'
#' ev_test <- evaluate(model, output, prediction)
#' ev_test
#'@export
ts_svm <- function(preprocess=NA, input_size=NA, kernel="radial", epsilon=0, cost=10) {
  obj <- ts_regsw(preprocess, input_size)

  # Kernel and hyperparameters for epsilon-SVR
  obj$kernel <- kernel # c("radial", "poly", "linear", "sigmoid")
  obj$epsilon <- epsilon # width of epsilon-insensitive tube
  obj$cost <- cost      # regularization strength

  class(obj) <- append("ts_svm", class(obj))
  return(obj)
}

#'@importFrom e1071 svm
#'@exportS3Method do_fit ts_svm
#'@inheritParams do_fit
#'@return A fitted `ts_svm` object with trained SVR model.
do_fit.ts_svm <- function(obj, x, y) {
  # e1071::svm expects data.frame for x
  obj$model <- e1071::svm(x = as.data.frame(x), y = y, epsilon=obj$epsilon, cost=obj$cost, kernel=obj$kernel)
  return(obj)
}

#'@importFrom stats predict
#'@exportS3Method do_predict ts_svm
#'@inheritParams do_predict
#'@return Numeric vector with predictions.
do_predict.ts_svm <- function(obj, x) {
  # Predict with same data.frame interface
  prediction <- stats::predict(obj$model, as.data.frame(x))
  return(prediction)
}
