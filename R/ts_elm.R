#'@title ELM
#'@description Create a time series prediction object that uses
#' Extreme Learning Machine (ELM) regression.
#'
#' It wraps the `elmNNRcpp` package to train single-hidden-layer networks with
#' randomly initialized hidden weights and closed-form output weights.
#'
#'@details ELMs are efficient to train and can perform well with appropriate
#' hidden size and activation choice. Consider normalizing inputs and tuning
#' `nhid` and the activation function.
#'
#'@param preprocess Normalization preprocessor (e.g., `ts_norm_gminmax()`).
#'@param input_size Integer. Number of lagged inputs used by the model.
#'@param nhid Integer. Hidden layer size.
#'@param actfun Character. One of 'sig', 'radbas', 'tribas', 'relu', 'purelin'.
#'@return A `ts_elm` object (S3) inheriting from `ts_regsw`.
#'
#'@references
#' - G.-B. Huang, Q.-Y. Zhu, and C.-K. Siew (2006). Extreme Learning Machine:
#'   Theory and Applications. Neurocomputing, 70(1–3), 489–501.
#'@examples
#'# Example: ELM with sliding-window inputs
#'library(daltoolbox)
#'data(tsd)
#'ts <- ts_data(tsd$y, 10)
#'ts_head(ts, 3)
#'
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'model <- ts_elm(ts_norm_gminmax(), input_size = 4, nhid = 3, actfun = "purelin")
#'model <- fit(model, x=io_train$input, y=io_train$output)
#'
#'prediction <- predict(model, x=io_test$input[1,], steps_ahead=5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(io_test$output)
#'
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'@export
ts_elm <- function(preprocess=NA, input_size=NA, nhid=NA, actfun='purelin') {
  obj <- ts_regsw(preprocess, input_size)
  if (is.na(nhid))
    nhid <- input_size/3  # heuristic hidden size
  obj$nhid <- nhid
  obj$actfun <- as.character(actfun)

  class(obj) <- append("ts_elm", class(obj))
  return(obj)
}

#'@importFrom elmNNRcpp elm_train
#'@exportS3Method do_fit ts_elm
#'@inheritParams do_fit
#'@return A fitted `ts_elm` object with trained ELM model.
do_fit.ts_elm <- function(obj, x, y) {
  # Train ELM with random hidden layer and closed-form output weights
  obj$model <- elmNNRcpp::elm_train(x, y, nhid = obj$nhid, actfun = obj$actfun, init_weights = "uniform_positive", bias = FALSE, verbose = FALSE)
  return(obj)
}

#'@importFrom elmNNRcpp elm_predict
#'@exportS3Method do_predict ts_elm
#'@inheritParams do_predict
#'@return Numeric vector with predictions.
do_predict.ts_elm <- function(obj, x) {
  if (is.data.frame(x))
    x <- as.matrix(x)  # elm_predict expects a matrix
  prediction <- elmNNRcpp::elm_predict(obj$model, x)
  return(prediction)
}
