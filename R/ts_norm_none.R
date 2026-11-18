#'@title No Normalization
#'@description Identity transform that leaves data unchanged but aligns with
#' the pre/post-processing interface.
#'@return A `ts_norm_none` object.
#'@examples
#'# Identity normalization (no scaling applied)
#' # Load package and example data
#' library(daltoolbox)
#' library(tspredit)
#' data(tsd)
#'
#'# Convert to sliding windows
#' xw <- ts_data(tsd$y, 10)
#'
#'# No data normalization — transform returns inputs unchanged
#' normalize <- ts_norm_none()
#' normalize <- daltoolbox::fit(normalize, xw)
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
transform.ts_norm_none <- function(obj, data, x = NULL, ...) {
  # When an aligned target/forecast `x` is supplied (as done by ts_regsw during
  # fit/predict), return it unchanged. The identity transform must not replace the
  # target with the window matrix, which would break sliding-window regressors.
  if (!is.null(x)) {
    return(x)
  }
  result <- data
  idx <- c(1:nrow(result))
  attr(result, "idx") <- idx
  return(result)
}

#'@importFrom daltoolbox inverse_transform
#'@exportS3Method inverse_transform ts_norm_none
inverse_transform.ts_norm_none <- function(obj, data, x = NULL, ...) {
  # Identity inverse: mirror the transform contract on both the data and the
  # target/forecast paths so predictions pass through unchanged.
  if (!is.null(x)) {
    return(x)
  }
  return(data)
}

