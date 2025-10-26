#'@title Global Min–Max Normalization
#'@description Rescale values so the global minimum maps to 0 and the global
#' maximum maps to 1 over the training set.
#'@param outliers Indicate outliers transformation class. NULL can avoid outliers removal.
#'@return A `ts_norm_gminmax` object.
#'@details The same scaling is applied to inputs and inverted on predictions
#' via `inverse_transform`.
#'
#'@references
#' Ogasawara, E., Murta, L., Zimbrão, G., Mattoso, M. (2009). Neural networks
#' cartridges for data mining on time series. Proceedings of the International
#' Joint Conference on Neural Networks (IJCNN). doi:10.1109/IJCNN.2009.5178615
#'@examples
#'# time series to normalize
#'library(daltoolbox)
#'data(tsd)
#'
#'# convert to sliding windows
#'ts <- ts_data(tsd$y, 10)
#'ts_head(ts, 3)
#'summary(ts[,10])
#'
#'# normalization
#'preproc <- ts_norm_gminmax()
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'summary(tst[,10])
#'@importFrom daltoolbox outliers_boxplot
#'@export
ts_norm_gminmax <- function(outliers = outliers_boxplot()) {
  obj <- dal_transform()
  obj$outliers <- outliers
  class(obj) <- append("ts_norm_gminmax", class(obj))
  return(obj)
}

#'@exportS3Method fit ts_norm_gminmax
fit.ts_norm_gminmax <- function(obj, data, ...) {
  if (!is.null(obj$outliers)) {
    # Optionally mitigate outliers prior to range estimation
    out <- obj$outliers
    out <- fit(out, data)
    data <- transform(out, data)
  }

  # Global min/max over training data
  obj$gmin <- min(data)
  obj$gmax <- max(data)

  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_norm_gminmax
transform.ts_norm_gminmax <- function(obj, data, x=NULL, ...) {
  if (!is.null(x)) {
    # Scale features with global min/max
    x <- (x-obj$gmin)/(obj$gmax-obj$gmin)
    return(x)
  }
  else {
    # Scale entire windowed dataset
    data <- (data-obj$gmin)/(obj$gmax-obj$gmin)
    return(data)
  }
}

#'@importFrom daltoolbox inverse_transform
#'@exportS3Method inverse_transform ts_norm_gminmax
inverse_transform.ts_norm_gminmax <- function(obj, data, x=NULL, ...) {
  if (!is.null(x)) {
    # Map back to original scale
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    return (data)
  }
}
