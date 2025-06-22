#'@title Hodrick-Prescott Filter
#'@description This filter eliminates the cyclical component of the series, performs smoothing on it, making it more sensitive to long-term fluctuations. Each observation is decomposed into a cyclical and a growth component.
#'@param lambda It is the smoothing parameter of the Hodrick-Prescott filter.
#'Lambda = 100*(frequency)^2
#'Correspondence between frequency and lambda values
#'annual => frequency = 1 // lambda = 100
#'quarterly => frequency = 4 // lambda = 1600
#'monthly => frequency = 12 // lambda = 14400
#'weekly => frequency = 52 // lambda = 270400
#'daily (7 days a week) => frequency = 365 // lambda = 13322500
#'daily (5 days a week) => frequency = 252 // lambda = 6812100
#'@param preserve value between 0 and 1. Balance the composition of observations and applied filter.
#'Values close to 1 preserve original values. Values close to 0 adopts HP filter values.
#'@return a `ts_fil_hp` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_hp(lambda = 100*(26)^2)  #frequency assumed to be 26
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_hp <- function(lambda = 100, preserve = 0.9) {
  if((preserve > 1) || (preserve < 0)) stop("Invalid preserve value", call. = FALSE)

  obj <- dal_transform()
  obj$lambda <- lambda
  obj$preserve <- preserve
  class(obj) <- append("ts_fil_hp", class(obj))
  return(obj)
}

#'@importFrom mFilter hpfilter
#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_fil_hp
transform.ts_fil_hp <- function(obj, data, ...) {
  ts_filter <- mFilter::hpfilter(data, freq = obj$lambda, type = "lambda")$trend
  result = as.vector(obj$preserve * data + (1 - obj$preserve) * ts_filter)
  return(result)
}

