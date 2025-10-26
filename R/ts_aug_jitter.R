#'@title Augmentation by Jitter
#'@description Time series augmentation by adding low-amplitude random noise to
#' each point to increase robustness and reduce overfitting.
#'@return A `ts_aug_jitter` object.
#'
#'@details Noise scale is estimated from within-window deviations.
#'
#'@references
#' - J. T. Um et al. (2017). Data augmentation of wearable sensor data for
#'   Parkinson’s disease monitoring using convolutional neural networks.
#' - Q. Wen et al. (2021). Time Series Data Augmentation for Deep Learning:
#'   A Survey. IJCAI Workshop on Time Series.
#'@examples
#'# Jitter augmentation with noise estimated from windows
#' # Load package and example dataset
#' library(daltoolbox)
#' data(tsd)
#'
#' # Convert to sliding windows and preview
#' xw <- ts_data(tsd$y, 10)
#' ts_head(xw)
#'
#' # Apply jitter (adds small noise; keeps target column unchanged)
#' augment <- ts_aug_jitter()
#' augment <- fit(augment, xw)
#' xa <- transform(augment, xw)
#' ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_aug_jitter <- function() {
  obj <- dal_transform()
  obj$preserve_data <- TRUE
  class(obj) <- append("ts_aug_jitter", class(obj))
  return(obj)
}

#'@importFrom stats sd
#'@importFrom daltoolbox fit
#'@exportS3Method fit ts_aug_jitter
fit.ts_aug_jitter <- function(obj, data, ...) {
  # Estimate noise scale from within-window deviations
  an <- apply(data, 1, mean)
  x <- data - an
  obj$sd <- stats::sd(x)
  return(obj)
}

#'@importFrom stats rnorm
#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_jitter
transform.ts_aug_jitter <- function(obj, data, ...) {
  add.ts_aug_jitter <- function(obj, data) {
    # Draw i.i.d. Gaussian noise and avoid perturbing target column
    x <- stats::rnorm(length(data), mean = 0, sd = obj$sd)
    x <- matrix(x, nrow=nrow(data), ncol=ncol(data))
    x[,ncol(data)] <- 0
    data <- data + x
    attr(data, "idx") <- 1:nrow(data)
    return(data)
  }
  result <- add.ts_aug_jitter(obj, data)
  if (obj$preserve_data) {
    # Keep original + jittered rows together
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- adjust_ts_data(result)
    attr(result, "idx") <- idx
  }
  return(result)
}

