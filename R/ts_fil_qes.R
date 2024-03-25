#'@title Quadratic Exponential Smoothing
#'@description This code implements quadratic exponential smoothing on a time series.
#'Quadratic exponential smoothing is a smoothing technique that includes components of
#'both trend and seasonality in time series forecasting.
#'@param gamma If TRUE, enables the gamma seasonality component.
#'@return a `ts_fil_qes` obj.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_qes()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_qes <- function(gamma = FALSE) {
  obj <- dal_transform()
  obj$gamma <- gamma
  class(obj) <- append("ts_fil_qes", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom stats HoltWinters
#'@export
transform.ts_fil_qes <- function(obj, data, ...) {
  adjust <- stats::HoltWinters(data, beta=TRUE, gamma=obj$gamma)
  result <- as.vector(adjust$fitted[,1])
  return(result)
}

