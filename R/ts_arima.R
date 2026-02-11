#'@title ARIMA
#'@description Create a time series prediction object based on the
#' AutoRegressive Integrated Moving Average (ARIMA) family.
#'
#' This constructor sets up an S3 time series regressor that leverages the
#' `forecast` package to automatically select orders via `auto.arima` and
#' provide one-step and multi-step forecasts.
#'
#'@details ARIMA models combine autoregressive (AR), differencing (I), and
#' moving average (MA) components to model temporal dependence in a univariate
#' time series. The `fit()` method uses `forecast::auto.arima()` to select
#' orders using information criteria, and `predict()` supports both a single
#' one-step-ahead over a horizon (rolling) and direct multi-step forecasting.
#'
#' Assumptions include (after differencing) approximate stationarity and
#' homoskedastic residuals. Always inspect residual diagnostics for adequacy.
#'
#'@return A `ts_arima` object (S3), which inherits from `ts_reg`.
#'
#'@references
#' - G. E. P. Box, G. M. Jenkins, G. C. Reinsel, and G. M. Ljung (2015).
#'   Time Series Analysis: Forecasting and Control. Wiley.
#' - R. J. Hyndman and Y. Khandakar (2008). Automatic time series forecasting:
#'   The forecast package for R. Journal of Statistical Software, 27(3), 1–22.
#'   doi:10.18637/jss.v027.i03
#'@examples
#'# Example: rolling-origin evaluation with multi-step prediction
#' # Load package and dataset
#' library(daltoolbox)
#' data(tsd)
#'
#'# 1) Wrap the raw vector as `ts_data` without sliding windows
#'ts <- ts_data(tsd$y, 0)
#'ts_head(ts, 3)
#'
#'# 2) Split into train/test using the last 5 observations as test
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'# 3) Fit ARIMA via auto.arima
#'model <- ts_arima()
#'model <- fit(model, x = io_train$input, y = io_train$output)
#'
#'# 4) Predict 5 steps ahead from the most recent observed point
#'prediction <- predict(model, x = io_test$input[1,], steps_ahead = 5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(io_test$output)
#'
#'# 5) Evaluate forecast accuracy
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'@export
ts_arima <- function() {
  obj <- ts_reg()

  class(obj) <- append("ts_arima", class(obj))
  return(obj)
}

#'@importFrom forecast auto.arima
#'@importFrom daltoolbox fit
#'@exportS3Method fit ts_arima
#'@inheritParams do_fit
#'@return A fitted `ts_arima` object with selected orders and parameters.
#'@details Uses `forecast::auto.arima()` with drift/mean allowed to determine
#' model orders and whether a drift term should be included.
#'@noRd
fit.ts_arima <- function(obj, x, y = NULL, ...) {
  obj$model <- forecast::auto.arima(x, allowdrift = TRUE, allowmean = TRUE)
  order <- obj$model$arma[c(1, 6, 2, 3, 7, 4, 5)]
  obj$p <- order[1]
  obj$d <- order[2]
  obj$q <- order[3]
  obj$drift <- (NCOL(obj$model$xreg) == 1) && is.element("drift", names(obj$model$coef))
  params <- list(p = obj$p, d = obj$d, q = obj$q, drift = obj$drift)
  attr(obj, "params") <- params

  return(obj)
}

#'@importFrom forecast forecast
#'@importFrom forecast Arima
#'@importFrom forecast auto.arima
#'@exportS3Method predict ts_arima
#'@inheritParams do_predict
#'@param steps_ahead Integer. If NULL, uses `length(x)`. If 1 and `x` has
#' multiple points, performs iterative one-step-ahead forecasting across the
#' horizon; otherwise forecasts `h = steps_ahead` directly.
#'@return A numeric vector of forecasts.
#'@noRd
predict.ts_arima <- function(object, x, y = NULL, steps_ahead=NULL, ...) {
  if (!is.null(x) && (length(object$model$x) == length(x)) && (sum(object$model$x-x) == 0)){
    # If x equals the training series, return the in-sample fit (yhat = x - residuals)
    pred <- object$model$x - object$model$residuals
  }
  else {
    if (is.null(steps_ahead))
      steps_ahead <- length(x)
    if ((steps_ahead == 1) && (length(x) != 1)) {
      # Rolling one-step-ahead forecast across the horizon
      pred <- NULL
      model <- object$model
      i <- 1
      y <- model$x
      while (i <= length(x)) {
        # Forecast next point
        pred <- c(pred, forecast::forecast(model, h = 1)$mean)
        y <- c(y, x[i])

        # Refit quickly using known orders; if that fails, fall back to auto.arima
        model <- tryCatch(
          {
            forecast::Arima(y, order=c(object$p, object$d, object$q), include.drift = object$drift)
          },
          error = function(cond) {
            forecast::auto.arima(y, allowdrift = TRUE, allowmean = TRUE)
          }
        )
        i <- i + 1
      }
    }
    else {
      # Direct h-step forecast from the fitted model
      pred <- forecast::forecast(object$model, h = steps_ahead)$mean
    }
  }
  return(pred)
}
