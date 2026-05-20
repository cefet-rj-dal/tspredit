#'@title FFT Filter
#'@description Frequency-domain smoothing using the Fast Fourier Transform
#' (FFT) to attenuate high-frequency components.
#'
#'@return A `ts_fil_fft` object.
#'
#'@details The implementation keeps the lowest frequencies that explain most of
#' the spectral energy and reconstructs the series from that low-pass spectrum.
#'
#'@references
#' - J. W. Cooley and J. W. Tukey (1965). An algorithm for the machine
#'   calculation of complex Fourier series. Math. Comput.
#'@examples
#'# Frequency-domain smoothing via FFT low-pass reconstruction
#' # Load package and example data
#' library(daltoolbox)
#' library(tspredit)
#' x <- seq(0, 4 * pi, length.out = 128)
#' y <- sin(x) + 0.25 * sin(12 * x)
#'
#' # Fit FFT-based filter and reconstruct the low-frequency signal
#' filter <- ts_fil_fft()
#' filter <- daltoolbox::fit(filter, y)
#' yhat <- transform(filter, y)
#'
#' # Compare original vs frequency-smoothed series
#' plot_ts_pred(y = y, yadj = yhat)
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
  freqs <- as.vector(freqs)
  if (length(freqs) <= 1) {
    return(1L)
  }

  total_energy <- sum(freqs)
  if (total_energy <= .Machine$double.eps) {
    return(length(freqs))
  }

  # Keep the smallest low-frequency band that explains most spectral energy.
  cumulative_energy <- cumsum(freqs) / total_energy
  cutindex <- which(cumulative_energy >= 0.9)[1]
  return(max(2L, cutindex))
}


#'@importFrom daltoolbox transform
#'@importFrom stats fft
#'@importFrom stats sd
#'@exportS3Method transform ts_fil_fft
transform.ts_fil_fft <- function(obj, data, ...) {
  data <- as.numeric(data)
  fft_signal <- stats::fft(data)

  spectrum <- base::Mod(fft_signal) ^ 2
  n <- length(fft_signal)
  half_spectrum <- spectrum[1:(floor(n / 2) + 1)]

  cutindex <- compute_cut_index(half_spectrum)
  filtered_fft <- complex(length.out = n)
  filtered_fft[1:cutindex] <- fft_signal[1:cutindex]

  mirror_start <- max(1L, n - cutindex + 2L)
  filtered_fft[mirror_start:n] <- fft_signal[mirror_start:n]

  result <- base::Re(stats::fft(filtered_fft, inverse = TRUE) / n)

  return(result)
}

