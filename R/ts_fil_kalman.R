#'@title Kalman Filter
#'@description Estimate a latent trend via a state-space model using the
#' Kalman Filter (KF), wrapping the `KFAS` package.
#'@param Q variance or covariance matrix of the process noise. This noise follows a zero-mean Gaussian distribution. It is added to the equation to account for uncertainties or unmodeled disturbances in the state evolution. The higher this value, the greater the uncertainty in the state transition process.
#'@param H variance or covariance matrix of the measurement noise. This noise pertains to the relationship between the true system state and actual observations. Measurement noise is added to the measurement equation to account for uncertainties or errors associated with real observations. The higher this value, the higher the level of uncertainty in the observations.
#'@return A `ts_fil_kalman` object.
#'
#'@references
#' - R. E. Kalman (1960). A new approach to linear filtering and prediction
#'   problems. Journal of Basic Engineering, 82(1), 35–45.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_kalman()
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
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
#'@exportS3Method transform ts_fil_kalman
transform.ts_fil_kalman <- function(obj, data, ...) {
  logmodel <- KFAS::SSModel(data ~ SSMtrend(1, Q = obj$Q), H = obj$H)
  ajuste <- KFAS::KFS(logmodel)
  result <- as.vector(ajuste$att)
  return(result)
}
