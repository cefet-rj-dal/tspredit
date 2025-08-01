#'@title Seasonal Adjustment
#'@description Removes the seasonal component from the time series without affecting the other components.
#'@param frequency Frequency of the time series. It is an optional parameter.
#' It can be configured when the frequency of the time series is known.
#'@return a `ts_fil_seas_adj` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_seas_adj(frequency = 26)
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_seas_adj <- function(frequency = NULL){
  obj <- dal_transform()
  obj$frequency <- frequency
  class(obj) <- append("ts_fil_seas_adj",class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom forecast bats
#'@importFrom stats ts
#'@importFrom stats fitted
#'@exportS3Method transform ts_fil_seas_adj
transform.ts_fil_seas_adj <- function(obj, data, ...){
  if (!is.null(obj$frequency))
    data<- ts(data, frequency = obj$frequency)
  ts_adj <- forecast::bats(data)
  result <- as.vector(stats::fitted(ts_adj))
  return(result)
}

