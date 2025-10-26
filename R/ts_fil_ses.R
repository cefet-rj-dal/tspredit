#'@title Simple Exponential Smoothing
#'@description Exponential smoothing focused on the level component, with
#' optional extensions to trend/seasonality via Holt–Winters variants.
#'@param gamma If TRUE, enables the gamma seasonality component.
#'@return A `ts_fil_ses` object.
#'
#'@references
#' - R. G. Brown (1959). Statistical Forecasting for Inventory Control.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_ses()
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
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
#'@exportS3Method transform ts_fil_ses
transform.ts_fil_ses <- function(obj, data, ...) {
  adjust <- stats::HoltWinters(data, beta=FALSE, gamma=obj$gamma)
  result <- as.vector(adjust$fitted[,1])
  return(result)
}
