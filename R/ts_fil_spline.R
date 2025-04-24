#'@title Smoothing Splines
#'@description Fits a cubic smoothing spline to a time series.
#'@param spar smoothing parameter. When spar is specified, the coefficient
#'            of the integral of the squared second derivative in the fitting criterion (penalized log-likelihood)
#'            is a monotone function of spar.
#'#'@return a `ts_fil_spline` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_spline(spar = 0.5)
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
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
