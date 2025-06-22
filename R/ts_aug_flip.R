#'@title Augmentation by flip
#'@description Time series data augmentation is a technique used to increase the size and diversity of a time series dataset by creating new instances of the original data through transformations or modifications. The goal is to improve the performance of machine learning models trained on time series data by reducing overfitting and improving generalization.
#'Flip mirror the sliding observations relative to the mean of the sliding windows.
#'@return a `ts_aug_flip` object.
#'@examples
#'library(daltoolbox)
#'data(tsd)
#'
#'#convert to sliding windows
#'xw <- ts_data(tsd$y, 10)
#'
#'#data augmentation using flip
#'augment <- ts_aug_flip()
#'augment <- fit(augment, xw)
#'xa <- transform(augment, xw)
#'ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@importFrom daltoolbox adjust_ts_data
#'@export
ts_aug_flip <- function() {
  obj <- dal_transform()
  obj$preserve_data <- TRUE
  class(obj) <- append("ts_aug_flip", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_flip
transform.ts_aug_flip <- function(obj, data, ...) {
  add.ts_aug_flip <- function(obj, data) {
    an <- apply(data, 1, mean)
    x <- data - an
    data <- an - x
    attr(data, "idx") <- 1:nrow(data)
    return(data)
  }
  result <- add.ts_aug_flip(obj, data)
  if (obj$preserve_data) {
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- daltoolbox::adjust_ts_data(result)
    attr(result, "idx") <- idx
  }
  return(result)
}

