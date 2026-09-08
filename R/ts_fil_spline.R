#'@title Smoothing Splines
#'@description Fit a cubic smoothing spline to a time series for smooth trend
#' extraction with a tunable roughness penalty.
#'@param spar Smoothing parameter. If `NULL`, it is selected automatically by
#' generalized cross-validation.
#'@return A `ts_fil_spline` object.
#'
#'@details The spline is fitted against the time index `1:length(data)` rather
#' than against the observed values themselves. This preserves the chronological
#' order of the series while smoothing the observed values along that time axis.
#'
#'@references
#' - P. Craven and G. Wahba (1978). Smoothing noisy data with spline functions.
#'   Numerische Mathematik.
#'@examples
#'# Smoothing splines with adjustable roughness penalty
#' # Load package and example data
#' library(daltoolbox)
#' library(tspredit)
#' data(tsd)
#' tsd$y[9] <- 2 * tsd$y[9]  # inject an outlier
#'
#' # Fit spline smoother and transform
#' filter <- ts_fil_spline(spar = 0.5)
#' filter <- daltoolbox::fit(filter, tsd$y)
#' y <- transform(filter, tsd$y)
#'
#' # Compare original vs smoothed series
#' plot_ts_pred(y = tsd$y, yadj = y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_spline <- function(spar = NULL) {
  obj <- dal_transform()
  obj$spar <- spar
  class(obj) <- append("ts_fil_spline", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom stats smooth.spline
#'@importFrom stats predict
#'@exportS3Method transform ts_fil_spline
transform.ts_fil_spline <- function(obj, data, ...) {
  data <- as.numeric(data)
  n <- length(data)

  if (n < 4) {
    return(data)
  }

  x <- seq_len(n)
  valid <- !is.na(data)

  if (sum(valid) < 4) {
    return(data)
  }

  # Fit against the time index, not against the observed values, so the smoother
  # preserves the chronological order of the series.
  spline_fit <- tryCatch(
    {
      if (is.null(obj$spar)) {
        stats::smooth.spline(x = x[valid], y = data[valid])
      } else {
        stats::smooth.spline(x = x[valid], y = data[valid], spar = obj$spar)
      }
    },
    error = function(e) NULL
  )

  if (is.null(spline_fit)) {
    return(data)
  }

  result <- stats::predict(spline_fit, x = x)$y
  result[is.na(result)] <- data[is.na(result)]
  return(result)
}
