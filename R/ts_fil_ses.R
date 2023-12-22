#'@title Simple Exponential Smoothing
#'@description This code implements simple exponential smoothing on a time series.
#'Simple exponential smoothing is a smoothing technique that can include or exclude
#'trend and seasonality components in time series forecasting, depending on the specified parameters.
#'@param gamma If TRUE, enables the gamma seasonality component.
#'@return a `ts_fil_ses` obj.
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
#'filter <- ts_fil_ses()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_ses <- function(gamma = FALSE) {
  obj <- dal_transform()
  obj$gamma <- gamma
  class(obj) <- append("ts_fil_ses", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom stats HoltWinters
#'@export
transform.ts_fil_ses <- function(obj, data, ...) {
  adjust <- stats::HoltWinters(data, beta=FALSE, gamma=obj$gamma)
  result <- as.vector(adjust$fitted[,1])
  return(result)
}
