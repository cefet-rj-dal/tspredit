#'@title Moving Average (MA)
#'@description Smooth out fluctuations and reduce noise by averaging over a
#' fixed-size rolling window.
#'@param ma moving average size
#'@return A `ts_fil_ma` object.
#'
#'@details Larger windows produce smoother series but may lag turning points.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_ma(3)
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_ma <- function(ma = 3) {
  obj <- dal_transform()
  obj$ma <- ma
  class(obj) <- append("ts_fil_ma", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_fil_ma
transform.ts_fil_ma <- function(obj, data, ...) {
  # Convert to windows of size `ma` then take row means
  data <- ts_data(data, obj$ma)
  ma <- apply(data, 1, mean)
  # Left-pad NAs to match original length
  result <- c(rep(NA, obj$ma-1), ma)
  return(result)
}

