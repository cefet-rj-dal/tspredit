#'@title Augmentation by Flip
#'@description Time series augmentation by mirroring sliding-window observations
#' around their mean to increase diversity and reduce overfitting.
#'@return A `ts_aug_flip` object.
#'
#'@details This transformation preserves the window mean while flipping the
#' deviations, effectively generating a symmetric variant of the local pattern.
#'
#'@references
#' - Q. Wen et al. (2021). Time Series Data Augmentation for Deep Learning:
#'   A Survey. IJCAI Workshop on Time Series.
#'@examples
#'# Flip augmentation around the window mean
#' # Load package and example dataset
#' library(daltoolbox)
#' data(tsd)
#'
#' # Convert to sliding windows and preview
#' xw <- ts_data(tsd$y, 10)
#' ts_head(xw)
#'
#' # Apply flip augmentation and inspect augmented windows
#' augment <- ts_aug_flip()
#' augment <- fit(augment, xw)
#' xa <- transform(augment, xw)
#' ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
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
    # Mirror around row mean: (mean - (x - mean))
    an <- apply(data, 1, mean)
    x <- data - an
    data <- an - x
    attr(data, "idx") <- 1:nrow(data)
    return(data)
  }
  result <- add.ts_aug_flip(obj, data)
  if (obj$preserve_data) {
    # Stack original and augmented rows; preserve indices for traceability
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- adjust_ts_data(result)
    attr(result, "idx") <- idx
  }
  return(result)
}

