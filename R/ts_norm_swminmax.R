#'@title Sliding-Window Min–Max Normalization
#'@description Create an object for normalizing each window by its own min and
#' max, preserving local contrast while standardizing scales.
#'@param outliers Indicate outliers transformation class. NULL can avoid outliers removal.
#'@return A `ts_norm_swminmax` object.
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
#'preproc <- ts_norm_swminmax()
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'summary(tst[,10])
#'@importFrom daltoolbox outliers_boxplot
#'@export
ts_norm_swminmax <- function(outliers = outliers_boxplot()) {
  obj <- dal_transform()
  obj$outliers <- outliers
  class(obj) <- append("ts_norm_swminmax", class(obj))
  return(obj)
}

#'@exportS3Method fit ts_norm_swminmax
fit.ts_norm_swminmax <- function(obj, data, ...) {
  if (!is.null(obj$outliers)) {
    # Optionally mitigate outliers per window before min/max
    out <- obj$outliers
    out <- fit(out, data)
    data <- transform(out, data)
  }
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_norm_swminmax
transform.ts_norm_swminmax <- function(obj, data, x=NULL, ...) {
  if (!is.null(x)) {
    # Use window-specific min/max stored on transformed data
    i_min <- attr(data, "i_min")
    i_max <- attr(data, "i_max")
    x <- (x-i_min)/(i_max-i_min)
    return(x)
  }
  else {
    # Compute per-row (window) min/max
    i_min <- apply(data, 1, min)
    i_max <- apply(data, 1, max)
    data <- (data-i_min)/(i_max-i_min)
    attr(data, "i_min") <- i_min
    attr(data, "i_max") <- i_max
    return(data)
  }
}

#'@importFrom daltoolbox inverse_transform
#'@exportS3Method inverse_transform ts_norm_swminmax
inverse_transform.ts_norm_swminmax <- function(obj, data, x=NULL, ...) {
  # Retrieve per-window min/max for inverse scaling
  i_min <- attr(data, "i_min")
  i_max <- attr(data, "i_max")
  if (!is.null(x)) {
    x <- x * (i_max - i_min) + i_min
    return(x)
  }
  else {
    data <- data * (i_max - i_min) + i_min
    attr(data, "i_min") <- i_min
    attr(data, "i_max") <- i_max
    return(data)
  }
}
