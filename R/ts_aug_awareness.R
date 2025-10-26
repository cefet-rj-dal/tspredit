#'@title Augmentation by Awareness
#'@description Bias the augmentation to emphasize more recent points in each
#' window (recency awareness), increasing their contribution to the augmented
#' sample.
#'@param factor Numeric factor controlling the recency weighting.
#'@return A `ts_aug_awareness` object.
#'@examples
#'library(daltoolbox)
#'data(tsd)
#'
#'#convert to sliding windows
#'xw <- ts_data(tsd$y, 10)
#'
#'#data augmentation using awareness
#'augment <- ts_aug_awareness()
#'augment <- fit(augment, xw)
#'xa <- transform(augment, xw)
#'ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_aug_awareness <- function(factor = 1) {
  obj <- dal_transform()
  obj$factor <- factor
  class(obj) <- append("ts_aug_awareness", class(obj))
  return(obj)
}

#'@importFrom stats rexp
#'@importFrom stats rnorm
#'@importFrom stats sd
#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_awareness
transform.ts_aug_awareness <- function(obj, data, ...) {
  noise.parameters <- function(obj, data) {
    an <- apply(data, 1, mean)
    x <- data - an
    obj$xsd <- stats::sd(x)
    return(obj)
  }

  add.noise <- function(obj, data) {
    x <- stats::rnorm(length(data), mean = 0, sd = obj$xsd)
    x <- matrix(x, nrow=nrow(data), ncol=ncol(data))
    x[,ncol(data)] <- 0
    data <- data + x
    return(data)
  }
  filter.data <- function(data) {
    n <- nrow(data)
    rate <- 10/n
    i <- ceiling(stats::rexp(10*n, rate))
    i <- i[(i > 0) & (i < n)]
    i <- sample(i, obj$factor*n)
    i <- n - i + 1
    i <- sort(i)
    return(i)
  }
  obj <- noise.parameters(obj, data)
  i <- filter.data(data)
  ndata <- add.noise(obj, data[i,])
  result <- ndata
  attr(result, "idx") <-  i
  idx <- c(1:nrow(data), attr(result, "idx"))
  result <- rbind(data, result)
  result <- adjust_ts_data(result)
  attr(result, "idx") <- idx
  return(result)
}

