#'@title Exponential Moving Average (EMA)
#'@description Smooth a series by exponentially decaying weights that give more
#' importance to recent observations.
#'@param ema exponential moving average size
#'@return A `ts_fil_ema` object.
#'
#'@details EMA is related to simple exponential smoothing; it reacts faster
#' to level changes than a simple moving average while reducing noise.
#'
#'@references
#' - C. C. Holt (1957). Forecasting trends and seasonals by exponentially
#'   weighted moving averages. O.N.R. Research Memorandum.
#'@examples
#'# Exponential moving average smoothing on a noisy series
#' # Load package and example data
#' library(daltoolbox)
#' data(tsd)
#'
#' # Inject an outlier to illustrate smoothing effect
#' tsd$y[9] <- 2 * tsd$y[9]
#'
#' # Define EMA filter, fit and transform the series
#' filter <- ts_fil_ema(ema = 3)
#' filter <- fit(filter, tsd$y)
#' y <- transform(filter, tsd$y)
#'
#' # Compare original vs smoothed series
#' plot_ts_pred(y = tsd$y, yadj = y)
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
#'@exportS3Method transform ts_fil_ema
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
