#'@title Time Series Exponential Moving Average
#'@description Used to smooth out fluctuations, while giving more weight to
#' recent observations. Particularly useful when the data has a trend or
#' seasonality component.
#'@param ema exponential moving average size
#'@return a `ts_fil_ema` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'# convert to sliding windows
#'ts <- ts_data(sin_data$y, 10)
#'ts_head(ts, 3)
#'summary(ts[,10])
#'
#'# filter
#'filter <- ts_fil_ema(ema = 3)
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_ema <- function(ema = 3) {
  obj <- dal_transform()
  obj$ema <- ema
  class(obj) <- append("ts_fil_ema", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@export
transform.ts_fil_ema <- function(obj, data, ...) {
  exp_mean <- function(x) {
    n <- length(x)
    y <- rep(0,n)
    alfa <- 1 - 2.0 / (n + 1);
    for (i in 0:(n-1)) {
      y[n-i] <- alfa^i
    }
    m <- sum(y * x)/sum(y)
    return(m)
  }

  data <- ts_data(data, obj$ema)
  ema <- apply(data, 1, exp_mean)
  result <- c(rep(NA, obj$ema-1), ema)
  return(result)
}
