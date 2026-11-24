#'@title ARIMA
#'@description Create a time series prediction object based on the
#' AutoRegressive Integrated Moving Average (ARIMA) family.
#'
#' Native implementation (base R `stats::arima`): no dependency on the `forecast`
#' package. Orders can be given explicitly or selected automatically:
#' `auto = "aicc"` (a compact AICc search) or `auto = "cv"` (**ARIMA++**).
#'
#'@details ARIMA models combine autoregressive (AR), differencing (I), and
#' moving average (MA) components. When `p`, `d`, `q` are `NULL` **or all `0`**
#' (`(0, 0, 0)` is read as the auto-fit sentinel, so a pure white-noise model is not
#' reachable), `fit()` selects the order automatically via the exported [fit_arima()].
#' `auto = "cv"` (ARIMA++) is a smarter selector that
#' fixes two weaknesses of the classic `auto.arima`:
#' \enumerate{
#'   \item the (p, q) candidates come from the significant ACF/PACF lags
#'     (Box-Jenkins identification) instead of a fixed cap of 5, so a seasonal
#'     spike (e.g. lag 12) enters the search;
#'   \item the order is chosen by rolling-origin cross-validation matched to the
#'     forecast horizon (out-of-sample sMAPE), not by the in-sample AICc proxy.
#' }
#' This is the canonical counterpart of the Python `pytspredit` `TsArima(auto="cv")`
#' and is exported for reuse (e.g. by harbinger).
#'@param p Optional integer autoregressive order (NULL or (0,0,0) -> automatic).
#'@param d Optional integer differencing order (NULL or (0,0,0) -> automatic).
#'@param q Optional integer moving-average order (NULL or (0,0,0) -> automatic).
#'@param auto Automatic selector when orders are NULL: "aicc" (default) or "cv".
#'@param max_order Cap for ACF/PACF-driven candidate lags (ARIMA++).
#'@param cv_folds Number of rolling origins for the CV selection (ARIMA++).
#'@param horizon CV horizon (ARIMA++); NULL -> the detected seasonal period.
#'
#'@return A `ts_arima` object (S3), which inherits from `ts_reg`.
#'
#'@references
#' - G. E. P. Box, G. M. Jenkins, G. C. Reinsel, and G. M. Ljung (2015).
#'   Time Series Analysis: Forecasting and Control. Wiley (ACF/PACF identification).
#' - R. J. Hyndman and Y. Khandakar (2008). Automatic time series forecasting:
#'   The forecast package for R. Journal of Statistical Software, 27(3), 1-22.
#'   doi:10.18637/jss.v027.i03
#' - L. J. Tashman (2000). Out-of-sample tests of forecasting accuracy.
#'   International Journal of Forecasting, 16(4), 437-450 (rolling-origin evaluation).
#' - D. Kwiatkowski, P. C. B. Phillips, P. Schmidt, Y. Shin (1992). Testing the null
#'   hypothesis of stationarity. Journal of Econometrics, 54(1-3), 159-178 (KPSS).
#'@examples
#'# Example: rolling-origin evaluation with multi-step prediction
#' library(daltoolbox)
#' library(tspredit)
#' data(tsd)
#'ts <- ts_data(tsd$y, 1)
#'samp <- ts_sample(ts, test_size = 5)
#'model <- ts_arima(p = 5, d = 0, q = 0)
#'model <- daltoolbox::fit(model, x = samp$train)
#'prediction <- as.vector(predict(model, x = samp$test[1,], steps_ahead = 5))
#'ev_test <- daltoolbox::evaluate(model, as.vector(samp$test), prediction)
#'ev_test
#'@export
ts_arima <- function(p = NULL, d = NULL, q = NULL, auto = "aicc",
                     max_order = 12, cv_folds = 2, horizon = NULL) {
  obj <- ts_reg()
  obj$p <- p
  obj$d <- d
  obj$q <- q
  obj$auto <- auto
  obj$max_order <- max_order
  obj$cv_folds <- cv_folds
  obj$horizon <- horizon
  specified <- !is.null(p) && !is.null(d) && !is.null(q)
  auto_zero <- specified && p == 0 && d == 0 && q == 0  # (0,0,0) = auto-fit sentinel
  obj$manual_order <- specified && !auto_zero
  obj$include_mean <- isTRUE(obj$manual_order && d == 0)

  class(obj) <- append("ts_arima", class(obj))
  return(obj)
}

#'@title Native automatic ARIMA fit
#'@description Selects the ARIMA `(p, d, q)` order automatically and returns the
#' fitted model, with no dependency on the `forecast` package -- the native role of
#' `forecast::auto.arima`. This is the univariate auto-fit entry point used by
#' [ts_arima()] (constructor orders left `NULL` or set to `(0, 0, 0)`), and is
#' exported for standalone reuse (e.g. by harbinger). Its canonical counterpart is
#' the exported `fit_arima()` in Python `pytspredit`.
#'@param x Numeric vector: the training series.
#'@param auto Selector: "aicc" (default, compact AICc search approximating
#' `forecast::auto.arima`) or "cv" (**ARIMA++**: ACF/PACF-driven candidates plus
#' horizon-matched rolling-origin cross-validation).
#'@param max_order Cap for the ACF/PACF-driven candidate lags (ARIMA++).
#'@param cv_folds Number of rolling origins for the CV selection (ARIMA++).
#'@param horizon CV horizon (ARIMA++); NULL -> the detected seasonal period.
#'@return A list with `order` (the selected `c(p, d, q)`), `include_mean`, and the
#' fitted `model` (a `stats::arima` object).
#'@examples
#' x <- as.numeric(co2)[1:60]
#' sel <- fit_arima(x)
#' sel$order
#'@export
fit_arima <- function(x, auto = "aicc", max_order = 12, cv_folds = 2,
                      horizon = NULL) {
  x <- as.numeric(x)
  if (identical(auto, "cv")) {
    arima_auto_cv(x, max_order = max_order, folds = cv_folds, horizon = horizon)
  } else {
    arima_auto_aicc(x)
  }
}

# ---- Native ARIMA order selection (base R; mirrors Python pytspredit.arima) ----

# KPSS level-stationarity statistic (base R; no tseries/urca dependency).
arima_kpss <- function(x) {
  x <- as.numeric(x)
  n <- length(x)
  e <- x - mean(x)
  s <- cumsum(e)
  lags <- floor(4 * (n / 100)^0.25)
  s2 <- sum(e^2) / n
  if (lags >= 1) {
    for (l in seq_len(lags)) {
      w <- 1 - l / (lags + 1)
      s2 <- s2 + 2 * w * sum(e[(l + 1):n] * e[1:(n - l)]) / n
    }
  }
  if (s2 <= 0) return(0)
  (sum(s^2) / n^2) / s2
}

# Number of differences to stationarity (KPSS, 5% level critical value 0.463).
arima_ndiffs <- function(x, max_d = 2, crit = 0.463) {
  v <- as.numeric(x)
  d <- 0
  while (d < max_d && length(v) >= 10) {
    stat <- tryCatch(arima_kpss(v), error = function(e) NA_real_)
    if (is.na(stat) || stat <= crit) break
    v <- diff(v)
    d <- d + 1
  }
  d
}

# Sparse (p, q) candidates: base orders {0..base} + the single strongest
# significant ACF/PACF lag beyond base (e.g. a seasonal 12).
arima_candidates <- function(x, d, max_order, base = 3) {
  v <- if (d > 0) diff(as.numeric(x), differences = d) else as.numeric(x)
  n <- length(v)
  base_set <- 0:min(base, max_order)
  maxlag <- as.integer(min(max_order, floor(n / 3), n - 2))
  if (maxlag < 1) return(list(p = base_set, q = base_set))
  band <- 1.96 / sqrt(n)
  a <- tryCatch(abs(stats::acf(v, lag.max = maxlag, plot = FALSE)$acf[-1]),
                error = function(e) numeric(0))
  pp <- tryCatch(abs(stats::pacf(v, lag.max = maxlag, plot = FALSE)$acf),
                 error = function(e) numeric(0))
  top_lag <- function(vals) {
    if (!length(vals)) return(integer(0))
    idx <- which(vals > band & seq_along(vals) > base)
    if (!length(idx)) integer(0) else idx[which.max(vals[idx])]
  }
  list(p = sort(unique(c(base_set, top_lag(pp)))),
       q = sort(unique(c(base_set, top_lag(a)))))
}

arima_fit <- function(x, order, include_mean, xreg = NULL) {
  # Omit xreg entirely when NULL so stats::arima does not store an `xreg` symbol in
  # its call (which would break predict() with "object 'xreg' not found").
  tryCatch(
    suppressWarnings(
      if (is.null(xreg)) {
        stats::arima(x, order = order, include.mean = include_mean,
                     method = "CSS-ML", optim.control = list(maxit = 100))
      } else {
        fit <- stats::arima(x, order = order, include.mean = include_mean, xreg = xreg,
                            method = "CSS-ML", optim.control = list(maxit = 100))
        # stats::arima records the symbol `xreg` in fit$call; predict.Arima then does
        # eval.parent(fit$call$xreg) to recover the training regressors, which fails once
        # this local `xreg` is out of scope ("object 'xreg' not found") -- breaking every
        # ts_arimax forecast. Embed the matrix value in the call so predict() resolves it.
        fit$call$xreg <- xreg
        fit
      }
    ),
    error = function(e) NULL
  )
}

arima_smape <- function(a, p) mean(2 * abs(a - p) / (abs(a) + abs(p) + 1e-9))

# Rolling-origin CV error matched to the forecast horizon (mean multi-step sMAPE).
arima_cv_error <- function(x, order, include_mean, folds, horizon) {
  x <- as.numeric(x)
  n <- length(x)
  need <- sum(order) + 2
  k <- min(folds, (n - need) %/% horizon)
  if (k < 1) return(NA_real_)
  errs <- numeric(0)
  for (i in 0:(k - 1)) {
    cut <- n - (k - i) * horizon
    if (cut <= need) return(NA_real_)
    fit <- arima_fit(x[1:cut], order, include_mean)
    if (is.null(fit)) return(NA_real_)
    pr <- tryCatch(as.numeric(predict(fit, n.ahead = horizon)$pred),
                   error = function(e) NULL)
    if (is.null(pr)) return(NA_real_)
    errs <- c(errs, arima_smape(x[(cut + 1):(cut + horizon)], pr))
  }
  if (!length(errs)) NA_real_ else mean(errs)
}

# ARIMA++ : ACF/PACF-driven candidates + horizon-matched rolling-origin CV.
arima_auto_cv <- function(x, max_order = 12, folds = 2, horizon = NULL) {
  x <- as.numeric(x)
  d <- arima_ndiffs(x)
  im <- (d == 0)
  cand <- arima_candidates(x, d, max_order)
  h <- if (!is.null(horizon)) as.integer(horizon) else max(2, max(c(cand$p, cand$q)))
  best <- NULL
  for (p in cand$p) {
    for (q in cand$q) {
      if ((p == 0 && q == 0) || (p + q > max_order + 3)) next
      e <- arima_cv_error(x, c(p, d, q), im, folds, h)
      if (!is.na(e) && (is.null(best) || e < best$err)) best <- list(err = e, order = c(p, d, q))
    }
  }
  if (is.null(best)) return(arima_auto_aicc(x))
  list(order = best$order, include_mean = im, model = arima_fit(x, best$order, im))
}

# Compact AICc search (native; replaces forecast::auto.arima's default role).
# Optional xreg supports the ARIMAX (external regressors) branch.
arima_auto_aicc <- function(x, xreg = NULL) {
  x <- as.numeric(x)
  n <- length(x)
  best <- NULL
  for (d in 0:2) {
    im <- (d == 0)
    for (p in 0:3) {
      for (q in 0:3) {
        if (p == 0 && q == 0 && d == 0) next
        fit <- arima_fit(x, c(p, d, q), im, xreg = xreg)
        if (is.null(fit)) next
        k <- length(fit$coef) + 1
        aicc <- fit$aic + if (n - k - 1 > 0) 2 * k * (k + 1) / (n - k - 1) else Inf
        if (is.null(best) || aicc < best$aicc) {
          best <- list(aicc = aicc, order = c(p, d, q), include_mean = im, model = fit)
        }
      }
    }
  }
  if (is.null(best)) {
    return(list(order = c(1, 0, 0), include_mean = TRUE,
                model = arima_fit(x, c(1, 0, 0), TRUE, xreg = xreg)))
  }
  list(order = best$order, include_mean = best$include_mean, model = best$model)
}

# -------------------------------------------------------------------------------

#'@importFrom daltoolbox fit
#'@importFrom stats arima acf pacf predict
#'@exportS3Method fit ts_arima
#'@inheritParams do_fit
#'@return A fitted `ts_arima` object with selected orders and parameters.
#'@noRd
fit.ts_arima <- function(obj, x, y = NULL, ...) {
  x <- as.numeric(x)
  obj$train <- x
  if (isTRUE(obj$manual_order)) {
    obj$include_mean <- isTRUE(obj$d == 0)
    obj$model <- arima_fit(x, c(obj$p, obj$d, obj$q), obj$include_mean)
  } else {
    sel <- fit_arima(x, auto = obj$auto, max_order = obj$max_order,
                     cv_folds = obj$cv_folds, horizon = obj$horizon)
    obj$p <- sel$order[1]
    obj$d <- sel$order[2]
    obj$q <- sel$order[3]
    obj$include_mean <- sel$include_mean
    obj$model <- sel$model
  }
  obj$drift <- FALSE
  attr(obj, "params") <- list(p = obj$p, d = obj$d, q = obj$q, drift = obj$drift)
  return(obj)
}

#'@importFrom stats arima predict
#'@exportS3Method predict ts_arima
#'@inheritParams do_predict
#'@param steps_ahead Integer. If NULL, uses `length(x)`. If 1 and `x` has
#' multiple points, performs iterative one-step-ahead forecasting; otherwise
#' forecasts `h = steps_ahead` directly.
#'@return A numeric vector of forecasts.
#'@noRd
predict.ts_arima <- function(object, x, y = NULL, steps_ahead = NULL, ...) {
  x <- if (is.null(x)) NULL else as.numeric(x)
  if (!is.null(x) && length(object$train) == length(x) && sum(object$train - x) == 0) {
    # in-sample fit: yhat = x - residuals
    return(as.numeric(object$train - object$model$residuals))
  }
  if (is.null(steps_ahead)) steps_ahead <- length(x)

  if (!is.null(x) && steps_ahead == 1 && length(x) != 1) {
    pred <- NULL
    model <- object$model
    hist <- object$train
    order <- c(object$p, object$d, object$q)
    for (i in seq_along(x)) {
      pred <- c(pred, as.numeric(predict(model, n.ahead = 1)$pred))
      hist <- c(hist, x[i])
      refit <- arima_fit(hist, order, isTRUE(object$include_mean))
      if (is.null(refit)) {
        sel <- arima_auto_aicc(hist)
        order <- sel$order
        refit <- sel$model
      }
      model <- refit
    }
    return(as.numeric(pred))
  }
  as.numeric(predict(object$model, n.ahead = steps_ahead)$pred)
}
