#'@title no augmentation
#'@description Does not make data augmentation.
#'@return a `ts_aug_none` object.
#'@examples
#'library(daltoolbox)
#'data(sin_data)
#'
#'#convert to sliding windows
#'xw <- ts_data(sin_data$y, 10)
#'
#'#no data augmentation
#'augment <- ts_aug_none()
#'augment <- fit(augment, xw)
#'xa <- transform(augment, xw)
#'ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_aug_none <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_aug_none", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_none
transform.ts_aug_none <- function(obj, data, ...) {
  result <- data
  idx <- c(1:nrow(result))
  attr(result, "idx") <- idx
  return(result)
}

