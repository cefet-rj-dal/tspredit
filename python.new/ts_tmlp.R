# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_tmlp
# loadlibrary("reticulate")
# source_python('ts_tmlp.py')

#'@title
#'@description
#'@details
#'
#'@param preprocess
#'@param input_size
#'@param hidden_size
#'@param epochs
#'@return
#'@examples
#'@export
ts_tmlp <- function(preprocess = NA, input_size = NA, hidden_size = 16, epochs = 10000L) {
  obj <- tsreg_sw(preprocess, input_size)
  obj$deep_debug <- FALSE
  obj$hidden_size <- hidden_size
  obj$epochs <- epochs
  class(obj) <- append("ts_tmlp", class(obj))
  return(obj)
}

#'@export
set_params.ts_tmlp <- function(obj, params) {
  if (!is.null(params$hidden_size))
    obj$hidden_size <- as.integer(params$hidden_size)
  if (!is.null(params$epochs))
    obj$epochs <- as.integer(params$epochs)
  return(obj)
}

#'@export
do_fit.ts_tmlp <- function(obj, x, y) {
  if (is.null(obj$model))
    obj$model <- python_env$create_torch_mlp(obj$input_size, obj$hidden_size)

  df_train <- as.data.frame(x)
  df_train$t0 <- as.vector(y)

  obj$model <- python_env$train_torch_mlp(obj$model, df_train, obj$epochs, obj$deep_debug, obj$reproduce)

  return(obj)
}

#'@export
do_predict.ts_tmlp <- function(obj, x) {
  X_values <- as.data.frame(x)
  X_values$t0 <- 0
  prediction <- python_env$predict_torch_mlp(obj$model, X_values)
  prediction <- as.vector(prediction)
  return(prediction)
}
