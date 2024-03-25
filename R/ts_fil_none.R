#'@title no filter
#'@description Does not make data filter
#'@return a `ts_fil_none` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_none()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_none <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_fil_none", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@export
transform.ts_fil_none <- function(obj, data, ...) {
  result <- data
  return(result)
}

