#'@title KNN Time Series Prediction
#'@description Create a prediction object that uses the
#' K-Nearest Neighbors regression for time series via sliding windows.
#'
#'@details KNN regression predicts a value as the average (or weighted average)
#' of the outputs of the k most similar windows in the training set. Similarity
#' is computed in the feature space induced by lagged inputs. Consider
#' normalization for distance-based methods.
#'
#'@param preprocess Normalization preprocessor (e.g., `ts_norm_gminmax()`).
#'@param input_size Integer. Number of lagged inputs.
#'@param k Integer. Number of neighbors.
#'@return A `ts_knn` object (S3) inheriting from `ts_regsw`.
#'
#'@references
#' - T. M. Cover and P. E. Hart (1967). Nearest neighbor pattern classification.
#'   IEEE Transactions on Information Theory, 13(1), 21–27.
#'@examples
#'# Example: distance-based regression on sliding windows
#'library(daltoolbox)
#'data(tsd)
#'ts <- ts_data(tsd$y, 10)
#'ts_head(ts, 3)
#'
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'model <- ts_knn(ts_norm_gminmax(), input_size = 4, k = 3)
#'model <- fit(model, x=io_train$input, y=io_train$output)
#'
#'prediction <- predict(model, x=io_test$input[1,], steps_ahead=5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(io_test$output)
#'
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'@export
ts_knn <- function(preprocess=NA, input_size=NA, k=NA) {
  obj <- ts_regsw(preprocess, input_size)
  if (is.na(k))
    k <- input_size/3
  obj$k <- k

  class(obj) <- append("ts_knn", class(obj))
  return(obj)
}

#'@importFrom FNN knn.reg
#'@importFrom daltoolbox adjust_data.frame
#'@exportS3Method do_fit ts_knn
#'@inheritParams do_fit
#'@return A fitted `ts_knn` object storing training data for prediction.
do_fit.ts_knn <- function(obj, x, y) {
  # Ensure inputs/targets are data.frames for FNN API
  x <- adjust_data.frame(x)
  y <- adjust_data.frame(y)

  # Store training data for lazy KNN predictions
  obj$model <- list(x=x, y=y, k=obj$k)

  return(obj)
}

#'@importFrom FNN knn.reg
#'@importFrom daltoolbox adjust_data.frame
#'@exportS3Method do_predict ts_knn
#'@inheritParams do_predict
#'@return Numeric vector with predictions.
do_predict.ts_knn <- function(obj, x) {
  #develop from FNN https://daviddalpiaz.github.io/r4sl/knn-reg.html
  x <- adjust_data.frame(x)
  prediction <- FNN::knn.reg(train = obj$model$x, test = x, y = obj$model$y, k = obj$model$k)
  prediction <- prediction$pred
  return(prediction)
}
