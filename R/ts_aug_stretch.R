#'@title Augmentation by Stretch
#'@description Increase within-window deviation magnitude by a scaling factor
#' to produce higher-variance variants.
#'@param scale_factor Numeric factor used to scale deviations.
#'@return A `ts_aug_stretch` object.
#'
#'@references
#' - Q. Wen et al. (2021). Time Series Data Augmentation for Deep Learning:
#'   A Survey. IJCAI Workshop on Time Series.
#'@examples
#'# Stretch augmentation increases within-window deviations
#' # Load package and example dataset
#' library(daltoolbox)
#' data(tsd)
#'
#' # Convert to sliding windows and preview
#' xw <- ts_data(tsd$y, 10)
#' ts_head(xw)
#'
#' # Apply stretch augmentation and inspect augmented windows
#' augment <- ts_aug_stretch()
#' augment <- fit(augment, xw)
#' xa <- transform(augment, xw)
#' ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_aug_stretch <- function(scale_factor=1.2) {
  obj <- dal_transform()
  obj$preserve_data <- TRUE
  obj$scale_factor <- scale_factor
  class(obj) <- append("ts_aug_stretch", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_stretch
transform.ts_aug_stretch <- function(obj, data, ...) {
  add.ts_aug_stretch <- function(obj, data) {
    # Amplify deviations from the mean by `scale_factor`
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
    # Concatenate original and augmented samples, preserving indices
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- adjust_ts_data(result)
    attr(result, "idx") <- idx
  }
  return(result)
}

