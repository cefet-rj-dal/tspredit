# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_tconv1d
# loadlibrary("reticulate")
# source_python('ts_tconv1d.py')

#'@title
#'@description
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param epochs
#'@return
#'@examples
#'@export
ts_tconv1d <- function(preprocess = NA, input_size = NA, epochs = 10000L) {
  obj <- tsreg_sw(preprocess, input_size)
  obj$deep_debug <- FALSE
  obj$epochs <- epochs
  class(obj) <- append("ts_tconv1d", class(obj))
  return(obj)
}

#'@export
set_params.ts_tconv1d <- function(obj, params) {
  if (!is.null(params$epochs))
    obj$epochs <- as.integer(params$epochs)
  return(obj)
}

#'@export
do_fit.ts_tconv1d <- function(obj, x, y) {
  if (is.null(obj$model))
    obj$model <- python_env$create_torch_conv1d()

  df_train <- as.data.frame(x)
  df_train$t0 <- as.vector(y)

  obj$model <- python_env$train_torch_conv1d(obj$model, df_train, obj$epochs, obj$deep_debug, obj$reproduce)

  return(obj)
}

#'@export
do_predict.ts_tconv1d <- function(obj, x) {
  X_values <- as.data.frame(x)
  X_values$t0 <- 0
  prediction <- python_env$predict_torch_conv1d(obj$model, X_values)
  prediction <- as.vector(prediction)
  return(prediction)
}
