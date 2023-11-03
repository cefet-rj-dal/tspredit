#'@title Time Series Smooth
#'@description Used to remove or reduce randomness (noise).
#'@return a `ts_fil_smooth` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'filter <- ts_fil_smooth()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_smooth <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_fil_smooth", class(obj))
  return(obj)
}

#'@importFrom stats na.omit
#'@importFrom graphics boxplot
#'@importFrom daltoolbox transform
#'@export transform.ts_fil_smooth
#'@export
transform.ts_fil_smooth <- function(obj, data, ...) {
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
  xd <- progressive_smoothing(data)
  return(xd)
}

