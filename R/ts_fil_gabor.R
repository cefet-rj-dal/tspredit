#'@title One-Dimensional Gabor Filter
#'@description Smooth a time series with a one-dimensional Gabor kernel, which
#' combines a Gaussian envelope with a cosine carrier to perform localized
#' frequency-aware smoothing.
#'
#'@param window_size Positive numeric value. Standard deviation of the Gaussian
#' envelope, in observations. Larger values use a wider local window.
#'@param central_frequency Numeric value in `[0, 0.5]`. Central frequency of the
#' cosine carrier, expressed in cycles per observation. Values close to zero
#' behave more like Gaussian smoothing; larger values emphasize oscillatory
#' local structure.
#'@return A `ts_fil_gabor` object.
#'
#'@details
#' The filter builds a symmetric kernel
#' `g(t) = exp(-t^2 / (2 * window_size^2)) * cos(2 * pi * central_frequency * t)`
#' over a finite window of radius `3 * window_size`. The kernel is normalized
#' to preserve the local level when its sum is non-zero, then applied by
#' centered convolution with reflected boundary padding. The reflected padding
#' reduces edge artifacts without changing the output length.
#'
#' This implementation is intended for offline smoothing. Because it uses a
#' centered window, values near time `t` depend on observations on both sides of
#' `t`. Use it before fitting a forecasting model, not as a causal real-time
#' filter.
#'
#'@references
#' - D. Gabor (1946). Theory of communication. Journal of the Institution of
#'   Electrical Engineers - Part III: Radio and Communication Engineering, 93,
#'   429-457.
#'@examples
#'# Gabor smoothing on a noisy seasonal signal
#'library(daltoolbox)
#'library(tspredit)
#'x <- seq(0, 6 * pi, length.out = 120)
#'y <- sin(x) + 0.3 * sin(8 * x)
#'
#'filter <- ts_fil_gabor(window_size = 3, central_frequency = 0.05)
#'filter <- daltoolbox::fit(filter, y)
#'yhat <- transform(filter, y)
#'
#'plot_ts_pred(y = y, yadj = yhat)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_gabor <- function(window_size = 3, central_frequency = 0.1) {
  if (!is.numeric(window_size) || length(window_size) != 1 ||
      is.na(window_size) || window_size <= 0) {
    stop("Invalid window_size value", call. = FALSE)
  }
  if (!is.numeric(central_frequency) || length(central_frequency) != 1 ||
      is.na(central_frequency) || central_frequency < 0 ||
      central_frequency > 0.5) {
    stop("Invalid central_frequency value", call. = FALSE)
  }

  obj <- dal_transform()
  obj$window_size <- window_size
  obj$central_frequency <- central_frequency
  class(obj) <- append("ts_fil_gabor", class(obj))
  return(obj)
}

#'@importFrom daltoolbox fit
#'@exportS3Method fit ts_fil_gabor
fit.ts_fil_gabor <- function(obj, data, ...) {
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_fil_gabor
transform.ts_fil_gabor <- function(obj, data, ...) {
  data <- as.numeric(data)
  n <- length(data)

  if (n < 4 || sum(!is.na(data)) < 4) {
    return(data)
  }

  radius <- max(1L, ceiling(3 * obj$window_size))
  radius <- min(radius, n - 1L)

  # Use a finite symmetric Gabor kernel centered at the current observation.
  kernel <- gabor_kernel(radius, obj$window_size, obj$central_frequency)

  # Reflect the boundaries so centered convolution can be evaluated at the
  # original first and last observations without shortening the output.
  left_pad <- rev(data[2:(radius + 1L)])
  right_pad <- rev(data[(n - radius):(n - 1L)])
  padded <- c(left_pad, data, right_pad)

  filtered <- stats::filter(padded, kernel, sides = 2)
  result <- as.numeric(filtered[(radius + 1L):(radius + n)])
  result[is.na(result)] <- data[is.na(result)]
  return(result)
}

gabor_kernel <- function(radius, window_size, central_frequency) {
  x <- -radius:radius

  # The Gaussian envelope localizes the filter in time, while the cosine
  # carrier controls the frequency emphasized by the local smoothing kernel.
  envelope <- exp(-(x ^ 2) / (2 * window_size ^ 2))
  kernel <- envelope * cos(2 * pi * central_frequency * x)
  kernel_sum <- sum(kernel)

  if (abs(kernel_sum) > .Machine$double.eps) {
    kernel <- kernel / kernel_sum
  }

  kernel
}
