#'@title Augmentation by Awareness Smooth
#'@description Recency-aware augmentation that also progressively smooths noise
#' before applying the weighting, producing cleaner augmented samples.
#'@param factor Numeric factor controlling the recency weighting.
#'@return A `ts_aug_awaresmooth` object.
#'
#'@references
#' - Q. Wen et al. (2021). Time Series Data Augmentation for Deep Learning:
#'   A Survey. IJCAI Workshop on Time Series.
#'@examples
#'# Recency-aware augmentation with progressive smoothing
#' # Load package and example dataset
#' library(daltoolbox)
#' data(tsd)
#'
#' # Convert to 10-lag sliding windows and preview
#' xw <- ts_data(tsd$y, 10)
#' ts_head(xw)
#'
#' # Apply awareness+smooth augmentation and inspect result
#' augment <- ts_aug_awaresmooth()
#' augment <- fit(augment, xw)
#' xa <- transform(augment, xw)
#' ts_head(xa)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_aug_awaresmooth <- function(factor = 1) {
  obj <- dal_transform()
  obj$factor <- factor
  class(obj) <- append("ts_aug_awaresmooth", class(obj))
  return(obj)
}

#'@importFrom stats rexp
#'@importFrom stats rnorm
#'@importFrom stats sd
#'@importFrom graphics boxplot
#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_aug_awaresmooth
transform.ts_aug_awaresmooth <- function(obj, data, ...) {
  progressive_smoothing <- function(serie) {
    serie <- stats::na.omit(serie)
    repeat {
      n <- length(serie)
      diff <- serie[2:n] - serie[1:(n-1)]

      names(diff) <- 1:length(diff)
      # Detect large jumps via boxplot (IQR) and iteratively smooth
      bp <- graphics::boxplot(diff, plot = FALSE)
      j <- as.integer(names(bp$out))

      rj <- j[(j > 1) & (j < length(serie))]
      serie[rj] <- (serie[rj-1]+serie[rj+1])/2

      diff <- serie[2:n] - serie[1:(n-1)]
      bpn <- graphics::boxplot(diff, plot = FALSE)

      if ((length(bpn$out) == 0) || (length(bp$out) == length(bpn$out))) {
        break
      }
    }
    return(serie)
  }

  transform_ts_aug_awareness <- function(data, factor) {
    filter_data <- function(data, factor) {
      n <- nrow(data)
      rate <- 10/n
      i <- ceiling(stats::rexp(10*n, rate))
      i <- i[(i > 0) & (i < n)]
      i <- sample(i, factor*n)
      i <- n - i + 1
      i <- sort(i)
      return(i)
    }

    add_noise <- function(input, data) {
      # Estimate noise scale from original data, not the smoothed input
      an <- apply(data, 1, mean)
      x <- data - an
      xsd <- stats::sd(x)
      x <- stats::rnorm(length(input), mean = 0, sd = xsd)
      x <- matrix(x, nrow=nrow(input), ncol=ncol(input))
      x[,ncol(input)] <- 0
      input <- input + x
      return(input)
    }

    i <- filter_data(data, factor)
    result <- data[i,]
    result <- add_noise(result, data)
    attr(result, "idx") <-  i
    idx <- c(1:nrow(data), attr(result, "idx"))
    result <- rbind(data, result)
    result <- adjust_ts_data(result)
    attr(result, "idx") <- idx
    return(result)
  }

  # Smooth each sliding window serialized as a single timeline
  n <- ncol(data)
  x <- c(as.vector(data[1,1:(n-1)]), as.vector(data[,n]))
  xd <- progressive_smoothing(x)
  result <- ts_data(xd, n)

  result <- transform_ts_aug_awareness(result, obj$factor)

  # Keep indices of augmented samples for traceability
  idx <- attr(result, "idx")
  return(result)
}

