#'@title ARIMA
#'@description Create a time series prediction object based on the
#' AutoRegressive Integrated Moving Average (ARIMA) family.
#'
#' This constructor sets up an S3 time series regressor that leverages the
#' `forecast` package to either automatically select orders via
#' `auto.arima()` or fit a user-specified `(p, d, q)` structure, and provide
#' one-step and multi-step forecasts.
#'
#'@details ARIMA models combine autoregressive (AR), differencing (I), and
#' moving average (MA) components to model temporal dependence in a univariate
#' time series. The `fit()` method uses `forecast::auto.arima()` to select
#' orders using information criteria when `p`, `d`, and `q` are left as
#' `NULL`; otherwise it fits the user-specified order directly.
#' `predict()` supports both a single one-step-ahead over a horizon (rolling)
#' and direct multi-step forecasting.
#'
#' Assumptions include (after differencing) approximate stationarity and
#' homoskedastic residuals. Always inspect residual diagnostics for adequacy.
#'@param p Optional integer autoregressive order. Leave `NULL` to let
#' `auto.arima()` choose it.
#'@param d Optional integer differencing order. Leave `NULL` to let
#' `auto.arima()` choose it.
#'@param q Optional integer moving-average order. Leave `NULL` to let
#' `auto.arima()` choose it.
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
#' library(tspredit)
#' data(tsd)
#'
#'# 1) Wrap the raw vector as `ts_data` with `sw = 1`
#'ts <- ts_data(tsd$y, 1)
#'ts_head(ts, 3)
#'
#'# 2) Split into train/test using the last 5 observations as test
#'samp <- ts_sample(ts, test_size = 5)
#'
#'# 3) Fit a user-specified ARIMA(5,0,0)
#'model <- ts_arima(p = 5, d = 0, q = 0)
#'model <- fit(model, x = samp$train)
#'
#'# 4) Predict 5 steps ahead from the most recent observed point
#'prediction <- predict(model, x = samp$test[1,], steps_ahead = 5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(samp$test)
#'
#'# 5) Evaluate forecast accuracy
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'@export
ts_arima <- function(p = NULL, d = NULL, q = NULL) {
  obj <- ts_reg()
  obj$p <- p
  obj$d <- d
  obj$q <- q
  obj$manual_order <- !is.null(p) && !is.null(d) && !is.null(q)
  obj$include_mean <- isTRUE(obj$manual_order && d == 0)
  obj$include_drift <- isTRUE(obj$manual_order && d == 1)

  class(obj) <- append("ts_arima", class(obj))
  return(obj)
}

#'@importFrom forecast auto.arima
#'@importFrom daltoolbox fit
#'@exportS3Method fit ts_arima
#'@inheritParams do_fit
#'@return A fitted `ts_arima` object with selected orders and parameters.
#'@details Uses `forecast::auto.arima()` with drift/mean allowed when no manual
#' order is supplied; otherwise fits the exact `(p, d, q)` specified in
#' `ts_arima()`.
#'@noRd
fit.ts_arima <- function(obj, x, y = NULL, ...) {
  if (isTRUE(obj$manual_order)) {
    obj$model <- forecast::Arima(
      x,
      order = c(obj$p, obj$d, obj$q),
      include.mean = obj$include_mean,
      include.drift = obj$include_drift
    )
  } else {
    obj$model <- forecast::auto.arima(x, allowdrift = TRUE, allowmean = TRUE)
    order <- obj$model$arma[c(1, 6, 2, 3, 7, 4, 5)]
    obj$p <- order[1]
    obj$d <- order[2]
    obj$q <- order[3]
    obj$include_mean <- isTRUE(obj$d == 0 && !is.element("intercept", names(obj$model$coef)))
    obj$include_drift <- (NCOL(obj$model$xreg) == 1) && is.element("drift", names(obj$model$coef))
  }
  obj$drift <- isTRUE(obj$include_drift)
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
            forecast::Arima(
              y,
              order = c(object$p, object$d, object$q),
              include.mean = isTRUE(object$include_mean),
              include.drift = isTRUE(object$include_drift)
            )
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
