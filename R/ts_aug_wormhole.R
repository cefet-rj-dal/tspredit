#'@title Augmentation by wormhole
#'@description Time series data augmentation is a technique used to increase the size and diversity of a time series dataset by creating new instances of the original data through transformations or modifications. The goal is to improve the performance of machine learning models trained on time series data by reducing overfitting and improving generalization.
#'Wormhole does data augmentation by removing lagged terms and adding old terms.
#'@return a `ts_aug_wormhole` object.
#'@examples
#'data(sin_data)
#'
#'#convert to sliding windows
#'xw <- ts_data(sin_data$y, 10)
#'
#'#data augmentation using flip
#'augment <- ts_aug_wormhole()
#'augment <- fit(augment, xw)
#'xa <- transform(augment, xw)
#'ts_head(xa)
#'@export
ts_aug_wormhole <- function() {
  obj <- dal_transform()
  obj$preserve_data <- TRUE
  obj$fold <- 1
  class(obj) <- append("ts_aug_wormhole", class(obj))
  return(obj)
}

#'@importFrom utils combn
#'@export
transform.ts_aug_wormhole <- function(obj, data, ...) {
  add.ts_aug_wormhole <- function(data) {
    n <- ncol(data)
    x <- c(as.vector(data[1,1:(n-1)]), as.vector(data[,n]))
    ts <- ts_data(x, n+1)
    space <- combn(1:n, n-1)
    data <- NULL
    idx <- NULL
    for (i in 1:obj$fold) {
      temp <- adjust_ts_data(ts[,c(space[,ncol(space)-i], ncol(ts))])
      idx <- c(idx, 1:nrow(temp))
      data <- rbind(data, temp)
    }
    attr(data, "idx") <- idx
    return(data)
  }
  result <- add.ts_aug_wormhole(data)
  if (obj$preserve_data) {
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- adjust_ts_data(result)
    attr(result, "idx") <- idx
  }
  return(result)
}

