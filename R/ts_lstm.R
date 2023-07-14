#'@title LSTM
#'@description Creates a time series prediction object that uses the LSTM.
#' It wraps the pytorch library.
#'@param preprocess normalization
#'@param input_size input size for machine learning model
#'@param epochs maximum number of epochs
#'@return a `ts_lstm` object.
#'@examples
#'\dontrun{
#'data(sin_data)
#'ts <- ts_data(sin_data$y, 10)
#'ts_head(ts, 3)
#'
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'model <- ts_lstm(ts_norm_gminmax(), input_size=4, epochs = 10000L)
#'model <- fit(model, x=io_train$input, y=io_train$output)
#'
#'prediction <- predict(model, x=io_test$input[1,], steps_ahead=5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(io_test$output)
#'
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'}
#'@import reticulate
#'@export
ts_lstm <- function(preprocess = NA, input_size = NA, epochs = 10000L) {
  obj <- ts_regsw(preprocess, input_size)
  obj$epochs <- epochs
  class(obj) <- append("ts_lstm", class(obj))

  return(obj)
}



#'@export
do_fit.ts_lstm <- function(obj, x, y) {
  if (!exists("ts_lstm_create"))
    reticulate::source_python(system.file("python", "ts_lstm.py", package = "daltoolbox"))

  if (is.null(obj$model))
    obj$model <- ts_lstm_create(obj$input_size, obj$input_size)

  df_train <- as.data.frame(x)
  df_train$t0 <- as.vector(y)

  obj$model <- ts_lstm_fit(obj$model, df_train, obj$epochs, 0.001)

  return(obj)
}

#'@export
do_predict.ts_lstm <- function(obj, x) {
  if (!exists("ts_lstm_predict"))
    reticulate::source_python(system.file("python", "ts_lstm.py", package = "daltoolbox"))

  X_values <- as.data.frame(x)
  X_values$t0 <- 0
  prediction <- ts_lstm_predict(obj$model, X_values)
  prediction <- as.vector(prediction)
  return(prediction)
}
