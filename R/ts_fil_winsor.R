#'@title Winsorization of Time Series
#'@description This code implements the Winsorization technique on a time series.
#'Winsorization is a statistical method used to handle extreme values in a time series
#'by replacing them with values closer to the center of the distribution.
#'@param li Defines the Winsorization limit (proportion of values to be trimmed)
#'@return a `ts_fil_winsor` obj.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_winsor()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_winsor <- function(li = 0.05) {
  obj <- dal_transform()
  obj$li <- li
  class(obj) <- append("ts_fil_winsor", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom DescTools Winsorize
#'@export
transform.ts_fil_winsor <- function(obj, data, ...) {
  adjust <- DescTools::Winsorize(data, minval = NULL, maxval = NULL,
                      probs = c(obj$li, (1 - obj$li)), na.rm = FALSE)
  result <- as.vector(adjust)
  return(result)
}

