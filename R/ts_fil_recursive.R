#'@title Recursive Filter
#'@description Apply recursive linear filtering (ARMA-style recursion) to a
#' univariate series or each column of a multivariate series. Useful for
#' smoothing and mitigating autocorrelation.
#'@param filter smoothing parameter. The larger the value, the greater the smoothing. The smaller the value, the less smoothing, and the resulting series shape is more similar to the original series.
#'@return A `ts_fil_recursive` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_recursive(filter =  0.05)
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
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
  # Apply recursive linear filter with coefficient `filter`
  ts_final <- stats::filter(x = data, filter = obj$filter, method = "recursive")
  return(ts_final)
}
