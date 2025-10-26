#'@title Smoothing Splines
#'@description Fit a cubic smoothing spline to a time series for smooth trend
#' extraction with a tunable roughness penalty.
#'@param spar smoothing parameter. When spar is specified, the coefficient
#'            of the integral of the squared second derivative in the fitting criterion (penalized log-likelihood)
#'            is a monotone function of spar.
#'@return A `ts_fil_spline` object.
#'
#'@references
#' - P. Craven and G. Wahba (1978). Smoothing noisy data with spline functions.
#'   Numerische Mathematik.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_spline(spar = 0.5)
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
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
#'@exportS3Method transform ts_fil_spline
transform.ts_fil_spline <- function(obj, data, ...) {
  ts_final <- smooth.spline(x = data, spar = obj$spar)$y
  result <- ts_final
  return(result)
}
