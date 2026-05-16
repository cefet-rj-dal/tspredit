#'@title Seasonal Adjustment
#'@description Remove the seasonal component from a time series while preserving
#' level and trend, using STL decomposition.
#'@param frequency Frequency of the time series. It is an optional parameter.
#' It can be configured when the frequency of the time series is known.
#'@return A `ts_fil_seas_adj` object.
#'
#'@references
#' - R. B. Cleveland, W. S. Cleveland, J. E. McRae, and I. Terpenning (1990).
#'   STL: A seasonal-trend decomposition procedure based on loess.
#'   Journal of Official Statistics, 6(1), 3–73.
#'@examples
#'# Seasonal adjustment using STL at known frequency
#' # Load package and build a seasonal signal
#' library(daltoolbox)
#' library(tspredit)
#' x <- seq_len(120)
#' y <- x / 100 + sin(2 * pi * x / 12) + rnorm(120, sd = 0.05)
#'
#' # Fit seasonal adjustment (set frequency if known) and transform
#' filter <- ts_fil_seas_adj(frequency = 12)
#' filter <- fit(filter, y)
#' yhat <- transform(filter, y)
#'
#' # Plot original vs seasonally adjusted series
#' plot_ts_pred(y = y, yadj = yhat)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_seas_adj <- function(frequency = NULL){
  obj <- dal_transform()
  obj$frequency <- frequency
  class(obj) <- append("ts_fil_seas_adj",class(obj))
  return(obj)
}

# Estimate the dominant seasonal period when one is not supplied explicitly.
estimate_seasonal_frequency <- function(data) {
  max_lag <- floor(length(data) / 3)
  if (max_lag < 2) {
    return(1L)
  }

  acf_values <- stats::acf(data, lag.max = max_lag, plot = FALSE)$acf[-1]
  lag <- which.max(acf_values)
  if (length(lag) == 0 || acf_values[lag] <= 0.3) {
    return(1L)
  }

  return(as.integer(lag))
}

#'@importFrom daltoolbox transform
#'@importFrom stats acf
#'@importFrom stats ts
#'@importFrom stats stl
#'@exportS3Method transform ts_fil_seas_adj
transform.ts_fil_seas_adj <- function(obj, data, ...){
  data <- as.numeric(data)
  frequency <- obj$frequency
  if (is.null(frequency)) {
    frequency <- estimate_seasonal_frequency(data)
  }

  # STL needs at least two full periods; otherwise adjustment is not reliable.
  if (frequency < 2 || length(data) < 2 * frequency) {
    return(data)
  }

  series <- stats::ts(data, frequency = frequency)
  decomposition <- stats::stl(series, s.window = "periodic", robust = TRUE)
  result <- as.vector(series - decomposition$time.series[, "seasonal"])
  return(result)
}

