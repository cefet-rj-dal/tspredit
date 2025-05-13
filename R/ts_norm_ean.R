#'@title Time Series Adaptive Normalization (Exponential Moving Average - EMA)
#'@description Creates a normalization object for time series data using an Exponential Moving Average (EMA) method.
#'This normalization approach adapts to changes in the time series and optionally removes outliers.
#'@param outliers Indicate outliers transformation class. NULL can avoid outliers removal.
#'@param nw windows size
#'@return returns a `ts_norm_ean` object.
#'@examples
#'# time series to normalize
#'library(daltoolbox)
#'data(sin_data)
#'
#'# convert to sliding windows
#'ts <- ts_data(sin_data$y, 10)
#'ts_head(ts, 3)
#'summary(ts[,10])
#'
#'# normalization
#'preproc <- ts_norm_ean()
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'summary(tst[,10])
#'@importFrom daltoolbox outliers_boxplot
#'@export
ts_norm_ean <- function(outliers = outliers_boxplot(), nw = 0) {
  emean <- function(data, na.rm = FALSE) {
    n <- length(data)

    y <- rep(0, n)
    alfa <- 1 - 2.0 / (n + 1);
    for (i in 0:(n-1)) {
      y[n-i] <- alfa^i
    }

    m <- sum(y * data, na.rm = na.rm)/sum(y, na.rm = na.rm)
    return(m)
  }
  obj <- ts_norm_an(outliers, nw = nw)
  obj$an_mean <- emean
  class(obj) <- append("ts_norm_ean", class(obj))
  return(obj)
}

