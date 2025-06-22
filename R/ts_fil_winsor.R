#'@title Winsorization of Time Series
#'@description This code implements the Winsorization technique on a time series.
#'Winsorization is a statistical method used to handle extreme values in a time series
#'by replacing them with values closer to the center of the distribution.
#'@return a `ts_fil_winsor` obj.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_winsor()
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_winsor <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_fil_winsor", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom DescTools Winsorize
#'@importFrom stats quantile
#'@exportS3Method transform ts_fil_winsor
transform.ts_fil_winsor <- function(obj, data, ...) {
  adjust <-DescTools::Winsorize(data)
  result <- as.vector(adjust)
  return(result)
}

