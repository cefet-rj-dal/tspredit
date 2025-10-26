#'@title LOWESS Smoothing
#'@description Locally Weighted Scatterplot Smoothing (LOWESS) fits local
#' regressions to capture the primary trend while reducing noise and spikes.
#'@param f smoothing parameter. The larger this value, the smoother the series will be.
#'         This provides the proportion of points on the plot that influence the smoothing.
#'@return A `ts_fil_lowess` object.
#'
#'@references
#' - W. S. Cleveland (1979). Robust locally weighted regression and smoothing
#'   scatterplots. Journal of the American Statistical Association.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_lowess(f = 0.2)
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@export
ts_fil_lowess <- function(f = 0.2){
  obj <- dal_transform()
  obj$f = f
  class(obj) <- append("ts_fil_lowess",class(obj))
  return(obj)
}


#'@importFrom stats lowess
#'@exportS3Method transform ts_fil_lowess
transform.ts_fil_lowess <- function(obj, data, ...){
  # LOWESS with smoothing fraction `f`
  ts_final <- stats::lowess(x=1:length(data),  y = data, f = obj$f)$y
  return(ts_final)
}

