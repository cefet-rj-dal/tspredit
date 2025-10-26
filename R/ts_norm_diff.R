#ts_norm_diff
#'@title First Differences
#'@description Transform a series by first differences to remove level and
#' highlight changes; normalization is then applied to the differenced series.
#'@param outliers Indicate outliers transformation class. NULL can avoid outliers removal.
#'@return A `ts_norm_diff` object.
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
#'preproc <- ts_norm_diff()
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'summary(tst[,9])
#'@importFrom daltoolbox outliers_boxplot
#'@export
ts_norm_diff <- function(outliers = outliers_boxplot()) {
  obj <- dal_transform()
  obj$outliers <- outliers
  class(obj) <- append("ts_norm_diff", class(obj))
  return(obj)
}

#'@exportS3Method fit ts_norm_diff
fit.ts_norm_diff <- function(obj, data, ...) {
  data <- data[,2:ncol(data)]-data[,1:(ncol(data)-1)]
  obj <- fit.ts_norm_gminmax(obj, data)
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_norm_diff
transform.ts_norm_diff <- function(obj, data, x=NULL, ...) {
  if (!is.null(x)) {
    ref <- attr(data, "ref")
    sw <- attr(data, "sw")
    x <- x-ref
    x <- (x-obj$gmin)/(obj$gmax-obj$gmin)
    return(x)
  }
  else {
    ref <- as.vector(data[,ncol(data)])
    cnames <- colnames(data)
    for (i in (ncol(data)-1):1)
      data[,i+1] <- data[, i+1] - data[,i]
    data <- data[,2:ncol(data)]
    data <- (data-obj$gmin)/(obj$gmax-obj$gmin)
    attr(data, "ref") <- ref
    attr(data, "sw") <- ncol(data)
    attr(data, "cnames") <- cnames
    return(data)
  }
}

#'@importFrom daltoolbox inverse_transform
#'@exportS3Method inverse_transform ts_norm_diff
inverse_transform.ts_norm_diff <- function(obj, data, x=NULL, ...) {
  cnames <- attr(data, "cnames")
  ref <- attr(data, "ref")
  sw <- attr(data, "sw")
  if (!is.null(x)) {
    x <- x * (obj$gmax-obj$gmin) + obj$gmin
    x <- x + ref
    return(x)
  }
  else {
    data <- data * (obj$gmax-obj$gmin) + obj$gmin
    data <- cbind(data, ref)
    for (i in (ncol(data)-1):1)
      data[,i] <- data[, i+1] - data[,i]
    colnames(data) <- cnames
    attr(data, "ref") <- ref
    attr(data, "sw") <- ncol(data)
    attr(data, "cnames") <- cnames
    return(data)
  }
}

