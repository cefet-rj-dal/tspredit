#'@title Augmentation by Wormhole
#'@description Generate augmented windows by selectively replacing lag terms
#' with older lagged values, creating plausible alternative trajectories.
#'@return A `ts_aug_wormhole` object.
#'
#'@details This combinatorial replacement preserves overall scale while
#' introducing temporal permutations of lag content.
#'
#'@references
#' - Q. Wen et al. (2021). Time Series Data Augmentation for Deep Learning:
#'   A Survey. IJCAI Workshop on Time Series.
#'@examples
#'# Wormhole augmentation replaces some lags with older values
#' # Load package and example dataset
#' library(daltoolbox)
#' data(tsd)
#'
#' # Convert to sliding windows and preview
#' xw <- ts_data(tsd$y, 10)
#' ts_head(xw)
#'
#' # Apply wormhole augmentation and inspect augmented windows
#' augment <- ts_aug_wormhole()
#' augment <- fit(augment, xw)
#' xa <- transform(augment, xw)
#' ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_aug_wormhole <- function() {
  obj <- dal_transform()
  obj$preserve_data <- TRUE
  obj$fold <- 1
  class(obj) <- append("ts_aug_wormhole", class(obj))
  return(obj)
}

#'@importFrom utils combn
#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_wormhole
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

