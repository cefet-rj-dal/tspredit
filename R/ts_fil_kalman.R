#'@title Kalman Filter
#'@description The Kalman filter is an estimation algorithm that produces estimates of certain variables based on imprecise measurements to provide a prediction of the future state of the system.
#'@param Q variance or covariance matrix of the process noise. This noise follows a zero-mean Gaussian distribution. It is added to the equation to account for uncertainties or unmodeled disturbances in the state evolution. The higher this value, the greater the uncertainty in the state transition process.
#'@param H variance or covariance matrix of the measurement noise. This noise pertains to the relationship between the true system state and actual observations. Measurement noise is added to the measurement equation to account for uncertainties or errors associated with real observations. The higher this value, the higher the level of uncertainty in the observations.
#'@return a `ts_fil_kalman` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_kalman()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_kalman <- function(H = 0.1, Q = 1) {
  obj <- dal_transform()
  obj$H <- H
  obj$Q <- Q
  class(obj) <- append("ts_fil_kalman", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom KFAS SSModel
#'@importFrom KFAS KFS
#'@importFrom KFAS SSMtrend
#'@export
transform.ts_fil_kalman <- function(obj, data, ...) {
  logmodel <- KFAS::SSModel(data ~ SSMtrend(1, Q = obj$Q), H = obj$H)
  ajuste <- KFAS::KFS(logmodel)
  result <- as.vector(ajuste$att)
  return(result)
}
