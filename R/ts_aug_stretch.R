#'@title Augmentation by stretch
#'@description Time series data augmentation is a technique used to increase the size and diversity of a time series dataset by creating new instances of the original data through transformations or modifications. The goal is to improve the performance of machine learning models trained on time series data by reducing overfitting and improving generalization.
#'stretch does data augmentation by increasing the volatility of the time series.
#'@param scale_factor for stretch
#'@return a `ts_aug_stretch` object.
#'@examples
#'library(daltoolbox)
#'data(sin_data)
#'
#'#convert to sliding windows
#'xw <- ts_data(sin_data$y, 10)
#'
#'#data augmentation using flip
#'augment <- ts_aug_stretch()
#'augment <- fit(augment, xw)
#'xa <- transform(augment, xw)
#'ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@importFrom daltoolbox adjust_ts_data
#'@export
ts_aug_stretch <- function(scale_factor=1.2) {
  obj <- dal_transform()
  obj$preserve_data <- TRUE
  obj$scale_factor <- scale_factor
  class(obj) <- append("ts_aug_stretch", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@export
transform.ts_aug_stretch <- function(obj, data, ...) {
  add.ts_aug_stretch <- function(obj, data) {
    an <- apply(data, 1, mean)
    x <- data - an
    x <- x * obj$scale_factor
    x[,ncol(data)] <- 0
    data <- data + x
    attr(data, "idx") <- 1:nrow(data)
    return(data)
  }
  result <- add.ts_aug_stretch(obj, data)
  if (obj$preserve_data) {
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- daltoolbox::adjust_ts_data(result)
    attr(result, "idx") <- idx
  }
  return(result)
}

