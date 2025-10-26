#'@title Hodrick-Prescott Filter
#'@description Decompose a series into trend and cyclical components using the
#' Hodrick–Prescott (HP) filter and optionally blend with the original series.
#'
#' This filter removes short-term fluctuations by penalizing changes in the
#' growth rate of the trend component.
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
#'@return A `ts_fil_hp` object.
#'
#'@details The filter strength is governed by `lambda = 100 * frequency^2`.
#' Use `preserve` in (0, 1] to convex-combine the raw series and the HP trend.
#'
#'@references
#' - R. J. Hodrick and E. C. Prescott (1997). Postwar U.S. business cycles:
#'   An empirical investigation. Journal of Money, Credit and Banking, 29(1).
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
  # Extract HP trend component and blend with original series
  ts_filter <- mFilter::hpfilter(data, freq = obj$lambda, type = "lambda")$trend
  result = as.vector(obj$preserve * data + (1 - obj$preserve) * ts_filter)
  return(result)
}

