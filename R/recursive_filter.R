#'@title Recursive Filter
#'@description Applies linear filtering to a univariate time series or to each series within a multivariate time series. It is useful for outlier detection, and the calculation is done recursively. This recursive calculation has the effect of reducing autocorrelation among observations, so that for each detected outlier, the filter is recalculated until there are no more outliers in the residuals.
#'@param filter smoothing parameter. The larger the value, the greater the smoothing. The smaller the value, the less smoothing, and the resulting series shape is more similar to the original series.
#'@return a `ts_fil_recursive` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_recursive(filter =  0.05)
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_recursive <- function(filter){
  obj <- dal_transform()
  obj$filter = filter
  class(obj) <- append("ts_fil_recursive",class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_fil_recursive
transform.ts_fil_recursive <- function(obj, data, ...){
  ts_final <- stats::filter(x = data, filter = obj$filter, method = "recursive")
  return(ts_final)
}
