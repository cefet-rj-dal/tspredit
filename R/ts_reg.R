#'@title TSReg
#'@description Base class for time series regression models that operate
#' directly on time series (non-sliding-window specialization).
#'
#'@details This class is intended to be subclassed by modeling backends that
#' do not require the sliding-window interface. Methods such as `fit()`,
#' `predict()`, and `evaluate()` dispatch on this class.
#'
#'@return A `ts_reg` object (S3) to be extended by concrete models.
#'@examples
#'# Abstract base class — instantiate concrete subclasses instead
#' # Examples: ts_mlp(), ts_rf(), ts_svm(), ts_arima()
#'@importFrom daltoolbox predictor
#'@export
ts_reg <- function() {
  obj <- predictor()
  class(obj) <- append("ts_reg", class(obj))
  return(obj)
}

#'@importFrom daltoolbox action
#'@exportS3Method action ts_reg
action.ts_reg <- function(obj, ...) {
  thiscall <- match.call(expand.dots = TRUE)
  thiscall[[1]] <- as.name("predict")
  result <- eval.parent(thiscall)
  return(result)
}

#'@exportS3Method predict ts_reg
#'@inheritParams do_predict
#'@return The last column of `x` (baseline predictor).
predict.ts_reg <- function(object, x, ...) {
  # Default baseline: predict last column (t0) as-is
  return(x[,ncol(x)])
}

#'@title Fit Time Series Model
#'@description Generic for fitting a time series model.
#' Descendants should implement `do_fit.<class>`.
#'@param obj Model object to be fitted.
#'@param x Matrix or data.frame with input features.
#'@param y Vector or matrix with target values.
#'@return A fitted object (same class as `obj`).
#'@export
do_fit <- function(obj, x, y = NULL) {
  UseMethod("do_fit")
}

#'@title Predict Time Series Model
#'@description Generic for predicting with a fitted time series model.
#' Descendants should implement `do_predict.<class>`.
#'@param obj Fitted model object.
#'@param x Matrix or data.frame with input features to predict.
#'@return Numeric vector with predicted values.
#'@export
do_predict <- function(obj, x) {
  UseMethod("do_predict")
}

#'@title MSE
#'@description Compute mean squared error (MSE) between actual and predicted values.
#'@param actual Numeric vector of observed values.
#'@param prediction Numeric vector of predicted values.
#'@return Numeric scalar with the MSE.
#'@details MSE = mean((actual - prediction)^2).
#'@export
MSE.ts <- function (actual, prediction) {
  if (length(actual) != length(prediction))
    stop("actual and prediction have different lengths")
  n <- length(actual)
  # Mean of squared residuals
  res <- mean((actual - prediction)^2)
  res
}

#'@title sMAPE
#'@description Compute symmetric mean absolute percent error (sMAPE).
#'@param actual Numeric vector of observed values.
#'@param prediction Numeric vector of predicted values.
#'@return Numeric scalar with the sMAPE.
#'@details sMAPE = mean( |a - p| / ((|a| + |p|)/2) ), excluding zero denominators.
#'@references
#' - S. Makridakis and M. Hibon (2000). The M3-Competition: results,
#'   conclusions and implications. International Journal of Forecasting, 16(4).
#'@export
sMAPE.ts <- function (actual, prediction) {
  if (length(actual) != length(prediction))
    stop("actual and prediction have different lengths")
  n <- length(actual)
  # Symmetric absolute percentage error (averaged)
  num <- abs(actual - prediction)
  denom <- (abs(actual) + abs(prediction))/2
  i <- denom != 0
  num <- num[i]
  denom <- denom[i]
  res <- (1/n) * sum(num/denom)
  res
}

#'@title R2
#'@description Compute coefficient of determination (R-squared).
#'@param actual Numeric vector of observed values.
#'@param prediction Numeric vector of predicted values.
#'@return Numeric scalar with R-squared.
#'@export
R2.ts <- function (actual, prediction) {
  if (length(actual) != length(prediction))
    stop("actual and prediction have different lengths")
  # 1 - SSE/SST
  res <-  1 - sum((prediction - actual)^2)/sum((mean(actual) - actual)^2)
  res
}


#'@exportS3Method evaluate ts_reg
evaluate.ts_reg <- function(obj, values, prediction, ...) {
  result <- list(values=values, prediction=prediction)

  result$smape <- sMAPE.ts(values, prediction)
  result$mse <- MSE.ts(values, prediction)
  result$R2 <- R2.ts(values, prediction)

  result$metrics <- data.frame(mse=result$mse, smape=result$smape, R2 = result$R2)

  return(result)
}

