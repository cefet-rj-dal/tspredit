#'@title FFT Filter
#'@description FFT Filter
#'@return a `ts_fil_fft` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_fft()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_fft <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_fil_fft", class(obj))
  return(obj)
}

compute_cut_index <- function(freqs) {
  cutindex <- which.max(freqs)
  if (min(freqs) != max(freqs)) {
    threshold <- mean(freqs) + 2.968 * sd(freqs)
    freqs[freqs < threshold] <- min(freqs) + max(freqs)
    cutindex <- which.min(freqs)
  }
  return(cutindex)
}


#'@importFrom daltoolbox transform
#'@importFrom stats fft
#'@importFrom stats sd
#'@export
transform.ts_fil_fft <- function(obj, data, ...) {

  fft_signal <- stats::fft(data)

  spectrum <- base::Mod(fft_signal) ^ 2
  half_spectrum <- spectrum[1:(length(obj$serie) / 2 + 1)]

  cutindex <- compute_cut_index(half_spectrum)
  n <- length(fft_signal)

  fft_signal[1:cutindex] <- 0
  fft_signal[(n - cutindex):n] <- 0

  noise <- base::Re(stats::fft(fft_signal, inverse = TRUE) / n)

  result <- data - noise

  return(result)
}

