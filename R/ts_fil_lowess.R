#'@title Lowess Smoothing
#'@description It is a smoothing method that preserves the primary trend of the original observations and is used to remove noise and spikes in a way that allows data reconstruction and smoothing.
#'@param f smoothing parameter. The larger this value, the smoother the series will be.
#'         This provides the proportion of points on the plot that influence the smoothing.
#'@return a `ts_fil_lowess` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_lowess(f = 0.2)
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@export
ts_fil_lowess <- function(f = 0.2){
  obj <- dal_transform()
  obj$f = f
  class(obj) <- append("ts_fil_lowess",class(obj))
  return(obj)
}


#'@importFrom stats lowess
#'@export transform.ts_fil_lowess
#'@export
transform.ts_fil_lowess <- function(obj, data, ...){
  ts_final <- stats::lowess(x=1:length(data),  y = data, f = obj$f)$y
  return(ts_final)
}

