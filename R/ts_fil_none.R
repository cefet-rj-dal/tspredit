#'@title no filter
#'@description Does not make data filter
#'@return a `ts_fil_none` object.
#'@examples
#'library(daltoolbox)
#'data(sin_data)
#'
#'#convert to sliding windows
#'xw <- ts_data(sin_data$y, 10)
#'
#'#no data filter
#'filtering <- ts_fil_none()
#'filtering <- fit(filtering, xw)
#'xa <- transform(filtering, xw)
#'ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_none <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_fil_none", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@export transform.ts_fil_none
#'@export
transform.ts_fil_none <- function(obj, data, ...) {
  result <- data
  idx <- c(1:nrow(result))
  attr(result, "idx") <- idx
  return(result)
}

