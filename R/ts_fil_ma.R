#'@title Time Series Moving Average
#'@description Used to smooth out fluctuations and reduce noise in a time series.
#'@param ma moving average size
#'@return a `ts_fil_ma` object.
#'@examples
#'# time series with noise
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'# convert to sliding windows
#'ts <- ts_data(sin_data$y, 10)
#'ts_head(ts, 3)
#'summary(ts[,10])
#'
#'# filter
#'filter <- ts_fil_ma(3)
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@export
ts_fil_ma <- function(ma = 3) {
  obj <- dal_transform()
  obj$ma <- ma
  class(obj) <- append("ts_fil_ma", class(obj))
  return(obj)
}

#'@export
transform.ts_fil_ma <- function(obj, data, ...) {
  data <- ts_data(data, obj$ma)
  ma <- apply(data, 1, mean)
  result <- c(rep(NA, obj$ma-1), ma)
  return(result)
}

