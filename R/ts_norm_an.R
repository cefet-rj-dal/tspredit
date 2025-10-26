#'@title Adaptive Normalization
#'@description Transform data to a common scale while adapting to changes in
#' distribution over time (optionally over a trailing window).
#'@param outliers Indicate outliers transformation class. NULL can avoid outliers removal.
#'@param nw integer: window size.
#'@return A `ts_norm_an` object.
#'
#'@references
#' Ogasawara, E., Martinez, L. C., De Oliveira, D., Zimbrão, G., Pappa, G. L.,
#' Mattoso, M. (2010). Adaptive Normalization: A novel data normalization
#' approach for non-stationary time series. Proceedings of the International
#' Joint Conference on Neural Networks (IJCNN). doi:10.1109/IJCNN.2010.5596746
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
#'preproc <- ts_norm_an()
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'summary(tst[,10])
#'@importFrom daltoolbox outliers_boxplot
#'@export
ts_norm_an <- function(outliers = outliers_boxplot(), nw = 0) {
  obj <- dal_transform()
  obj$outliers <- outliers
  obj$ma <- function(obj, data, func) {
    if (obj$nw != 0) {
      cols <- ncol(data) - ((obj$nw-1):0)
      data <- data[,cols]

    }
    an <- apply(data, 1, func, na.rm=TRUE)
  }
  obj$an_mean <- mean
  obj$nw <- nw
  class(obj) <- append("ts_norm_an", class(obj))
  return(obj)
}

#'@exportS3Method fit ts_norm_an
fit.ts_norm_an <- function(obj, data, ...) {
  # Subtract moving average (adaptive) from inputs to center windows
  input <- data[,1:(ncol(data)-1)]
  an <- obj$ma(obj, input, obj$an_mean)
  data <- data - an

  if (!is.null(obj$outliers)) {
    out <- obj$outliers
    out <- fit(out, data)
    data <- transform(out, data)
  }

  obj$gmin <- min(data)
  obj$gmax <- max(data)

  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_norm_an
transform.ts_norm_an <- function(obj, data, x=NULL, ...) {
  if (!is.null(x)) {
    # Apply stored moving average then global min-max scaling
    an <- attr(data, "an")
    x <- x - an
    x <- (x - obj$gmin) / (obj$gmax-obj$gmin)
    return(x)
  }
  else {
    # Recompute moving average for these windows
    an <- obj$ma(obj, data, obj$an_mean)
    data <- data - an
    data <- (data - obj$gmin) / (obj$gmax-obj$gmin)
    attr(data, "an") <- an
    return (data)
  }
}

#'@importFrom daltoolbox inverse_transform
#'@exportS3Method inverse_transform ts_norm_an
inverse_transform.ts_norm_an <- function(obj, data, x=NULL, ...) {
  an <- attr(data, "an")
  if (!is.null(x)) {
    # Reverse global scaling and add back the moving average component
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    x <- x + an
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    data <- data + an
    attr(data, "an") <- an
    return (data)
  }
}
