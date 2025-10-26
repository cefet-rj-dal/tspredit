#'@title Augmentation by Shrink
#'@description Decrease within-window deviation magnitude by a scaling factor
#' to generate lower-variance variants while preserving the mean.
#'@param scale_factor Numeric factor used to scale deviations.
#'@return A `ts_aug_shrink` object.
#'@examples
#'library(daltoolbox)
#'data(tsd)
#'
#'#convert to sliding windows
#'xw <- ts_data(tsd$y, 10)
#'
#'#data augmentation using flip
#'augment <- ts_aug_shrink()
#'augment <- fit(augment, xw)
#'xa <- transform(augment, xw)
#'ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_aug_shrink <- function(scale_factor = 0.8) {
  obj <- dal_transform()
  obj$preserve_data <- TRUE
  obj$scale_factor <- scale_factor
  class(obj) <- append("ts_aug_shrink", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_shrink
transform.ts_aug_shrink <- function(obj, data, ...) {
  add.ts_aug_shrink <- function(obj, data) {
    an <- apply(data, 1, mean)
    x <- data - an
    x <- x * obj$scale_factor
    x[,ncol(data)] <- 0
    data <- data + x
    attr(data, "idx") <- 1:nrow(data)
    return(data)
  }
  result <- add.ts_aug_shrink(obj, data)
  if (obj$preserve_data) {
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- adjust_ts_data(result)
    attr(result, "idx") <- idx
  }
  return(result)
}

