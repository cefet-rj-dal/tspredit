#'@title No Normalization
#'@description Identity transform that leaves data unchanged but aligns with
#' the pre/post-processing interface.
#'@return A `ts_norm_none` object.
#'@examples
#'# Identity normalization (no scaling applied)
#' # Load package and example data
#' library(daltoolbox)
#' data(tsd)
#'
#'# Convert to sliding windows
#' xw <- ts_data(tsd$y, 10)
#'
#'# No data normalization — transform returns inputs unchanged
#' normalize <- ts_norm_none()
#' normalize <- fit(normalize, xw)
#' xa <- transform(normalize, xw)
#' ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_norm_none <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_norm_none", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_norm_none
transform.ts_norm_none <- function(obj, data, ...) {
  result <- data
  idx <- c(1:nrow(result))
  attr(result, "idx") <- idx
  return(result)
}

