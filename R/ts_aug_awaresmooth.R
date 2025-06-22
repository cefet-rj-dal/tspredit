#'@title Augmentation by awareness smooth
#'@description Time series data augmentation is a technique used to increase the size and diversity of a time series dataset by creating new instances of the original data through transformations or modifications. The goal is to improve the performance of machine learning models trained on time series data by reducing overfitting and improving generalization.
#'Awareness Smooth reinforce recent data preferably. It also smooths noise data.
#'@param factor increase factor for data augmentation
#'@return a `ts_aug_awaresmooth` object.
#'@examples
#'library(daltoolbox)
#'data(tsd)
#'
#'#convert to sliding windows
#'xw <- ts_data(tsd$y, 10)
#'
#'#data augmentation using awareness
#'augment <- ts_aug_awaresmooth()
#'augment <- fit(augment, xw)
#'xa <- transform(augment, xw)
#'ts_head(xa)
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
#'@importFrom daltoolbox adjust_ts_data
#'@importFrom daltoolbox ts_data
#'@exportS3Method transform ts_aug_awaresmooth
transform.ts_aug_awaresmooth <- function(obj, data, ...) {
  progressive_smoothing <- function(serie) {
    serie <- stats::na.omit(serie)
    repeat {
      n <- length(serie)
      diff <- serie[2:n] - serie[1:(n-1)]

      names(diff) <- 1:length(diff)
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
    result <- daltoolbox::adjust_ts_data(result)
    attr(result, "idx") <- idx
    return(result)
  }

  n <- ncol(data)
  x <- c(as.vector(data[1,1:(n-1)]), as.vector(data[,n]))
  xd <- progressive_smoothing(x)
  result <- daltoolbox::ts_data(xd, n)

  result <- transform_ts_aug_awareness(result, obj$factor)

  idx <- attr(result, "idx")
  return(result)
}

