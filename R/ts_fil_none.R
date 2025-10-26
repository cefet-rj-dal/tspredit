#'@title No Filter
#'@description Identity filter that returns the original series unchanged.
#'@return A `ts_fil_none` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_none()
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
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
#'@exportS3Method transform ts_fil_none
transform.ts_fil_none <- function(obj, data, ...) {
  result <- data
  return(result)
}

