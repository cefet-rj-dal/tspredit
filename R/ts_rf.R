#'@title Random Forest
#'@description Create a time series prediction object that uses
#' Random Forest regression on sliding-window inputs.
#'
#' It wraps the `randomForest` package to fit an ensemble of decision trees.
#'
#'@details Random Forests reduce variance by averaging many decorrelated trees.
#' For tabular sliding-window features, they can capture nonlinearities and
#' interactions without heavy feature engineering. Consider normalizing inputs
#' for comparability across windows and tuning `mtry`, `ntree`, and `nodesize`.
#'
#'@param preprocess Normalization preprocessor (e.g., `ts_norm_gminmax()`).
#'@param input_size Integer. Number of lagged inputs used by the model.
#'@param nodesize Integer. Minimum terminal node size.
#'@param ntree Integer. Number of trees in the forest.
#'@param mtry Integer. Number of variables randomly sampled at each split.
#'@return A `ts_rf` object (S3) inheriting from `ts_regsw`.
#'
#'@references
#' - L. Breiman (2001). Random forests. Machine Learning, 45(1), 5–32.
#'@examples
#'# Example: sliding-window Random Forest
#' # Load tools and data
#' library(daltoolbox)
#' data(tsd)
#'
#' # Turn series into 10-lag windows and preview
#' ts <- ts_data(tsd$y, 10)
#' ts_head(ts, 3)
#'
#' # Train/test split and (X, y) projection
#' samp <- ts_sample(ts, test_size = 5)
#' io_train <- ts_projection(samp$train)
#' io_test <- ts_projection(samp$test)
#'
#' # Define Random Forest and fit (tune ntree/mtry/nodesize as needed)
#' model <- ts_rf(ts_norm_gminmax(), input_size = 4, nodesize = 3, ntree = 50)
#' model <- fit(model, x = io_train$input, y = io_train$output)
#'
#' # Forecast multiple steps and assess error
#' prediction <- predict(model, x = io_test$input[1,], steps_ahead = 5)
#' prediction <- as.vector(prediction)
#' output <- as.vector(io_test$output)
#'
#' ev_test <- evaluate(model, output, prediction)
#' ev_test
#'@export
ts_rf <- function(preprocess=NA, input_size=NA, nodesize = 1, ntree = 10, mtry = NULL) {
  obj <- ts_regsw(preprocess, input_size)

  obj$nodesize <- nodesize
  obj$ntree <- ntree
  obj$mtry <- mtry

  class(obj) <- append("ts_rf", class(obj))
  return(obj)
}


#'@importFrom randomForest randomForest
#'@exportS3Method do_fit ts_rf
#'@inheritParams do_fit
#'@return A fitted `ts_rf` object with a trained forest.
do_fit.ts_rf <- function(obj, x, y) {
  if (is.null(obj$mtry))
    obj$mtry <- ceiling(obj$input_size/3)  # default to ~1/3 of features
  # Cast to data.frame for randomForest API and fit ensemble
  obj$model <- randomForest::randomForest(x = as.data.frame(x), y = as.vector(y), mtry=obj$mtry, nodesize = obj$nodesize, ntree=obj$ntree)
  return(obj)
}

#'@importFrom stats predict
#'@exportS3Method do_predict ts_rf
#'@inheritParams do_predict
#'@return Numeric vector with predictions.
do_predict.ts_rf <- function(obj, x) {
  # randomForest expects data.frame at predict time
  prediction <- stats::predict(obj$model, as.data.frame(x))
  return(prediction)
}
