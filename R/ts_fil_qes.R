#'@title Quadratic Exponential Smoothing
#'@description Double/triple exponential smoothing capturing level, trend,
#' and optionally seasonality components.
#'@param gamma If TRUE, enables the gamma seasonality component.
#'@return A `ts_fil_qes` object.
#' The transformed series is aligned to the input length and may contain leading
#' `NA` values while the Holt-Winters state is being initialized.
#'
#'@references
#' - P. R. Winters (1960). Forecasting sales by exponentially weighted moving
#'   averages. Management Science.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'library(tspredit)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_qes()
#'filter <- daltoolbox::fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_qes <- function(gamma = FALSE) {
  obj <- dal_transform()
  obj$gamma <- gamma
  class(obj) <- append("ts_fil_qes", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom stats HoltWinters
#'@exportS3Method transform ts_fil_qes
transform.ts_fil_qes <- function(obj, data, ...) {
  # Quadratic smoothing via Holt-Winters with beta (trend) and optional gamma (seasonality)
  adjust <- stats::HoltWinters(data, beta=TRUE, gamma=obj$gamma)
  # Preserve input length; Holt-Winters fitted values start after warm-up
  result <- c(rep(NA_real_, length(data) - nrow(adjust$fitted)), as.vector(adjust$fitted[,1]))
  return(result)
}

