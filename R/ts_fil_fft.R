#'@title FFT Filter
#'@description Frequency-domain low-pass smoothing using the Fast Fourier
#' Transform (FFT), reflected boundary padding, and a smooth cosine roll-off.
#'
#'@param threshold Cumulative non-constant spectral energy threshold to retain.
#' Larger values keep more frequency components.
#'@param pad_pct Fraction of the series length used for reflected boundary
#' padding.
#'@param taper_pct Width of the cosine transition band relative to the cutoff
#' index.
#'@return A `ts_fil_fft` object.
#'
#'@details The implementation ignores the constant component when selecting the
#' cutoff. This prevents a large mean level from dominating the energy
#' criterion and collapsing the output into an almost flat series. It keeps the
#' lowest frequencies that explain the requested share of non-constant spectral
#' energy, applies a cosine roll-off after the cutoff to reduce ringing, and
#' reconstructs the original-length series after removing the reflected
#' boundary padding.
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
ts_fil_fft <- function(threshold = 0.90, pad_pct = 0.25, taper_pct = 0.15) {
  if (!is.numeric(threshold) || length(threshold) != 1 ||
      is.na(threshold) || threshold <= 0 || threshold > 1) {
    stop("Invalid threshold value", call. = FALSE)
  }
  if (!is.numeric(pad_pct) || length(pad_pct) != 1 ||
      is.na(pad_pct) || pad_pct < 0) {
    stop("Invalid pad_pct value", call. = FALSE)
  }
  if (!is.numeric(taper_pct) || length(taper_pct) != 1 ||
      is.na(taper_pct) || taper_pct < 0) {
    stop("Invalid taper_pct value", call. = FALSE)
  }

  obj <- dal_transform()
  obj$threshold <- threshold
  obj$pad_pct <- pad_pct
  obj$taper_pct <- taper_pct
  obj$cutindex <- NULL
  obj$pad_len <- NULL
  class(obj) <- append("ts_fil_fft", class(obj))
  return(obj)
}

compute_cut_index <- function(freqs, threshold = 0.90) {
  freqs <- as.vector(freqs)
  if (length(freqs) <= 1) {
    return(1L)
  }

  ac_freqs <- freqs[-1]
  total_ac_energy <- sum(ac_freqs)
  if (total_ac_energy <= .Machine$double.eps) {
    return(1L)
  }

  # Keep the smallest low-frequency band that explains the requested
  # non-constant spectral energy.
  cumulative_energy <- cumsum(ac_freqs) / total_ac_energy
  cut_ac <- which(cumulative_energy >= threshold)[1]
  if (is.na(cut_ac)) {
    cut_ac <- length(ac_freqs)
  }

  as.integer(cut_ac + 1L)
}


#'@importFrom daltoolbox fit
#'@importFrom stats fft
#'@exportS3Method fit ts_fil_fft
fit.ts_fil_fft <- function(obj, data, ...) {
  data <- as.numeric(data)
  n <- length(data)

  if (n < 4 || any(is.na(data))) {
    return(obj)
  }

  # Estimate the cutoff on a reflected series so the selected spectrum is less
  # affected by artificial discontinuities at the endpoints.
  pad_len <- fft_pad_length(n, obj$pad_pct)
  padded <- fft_reflect_pad(data, pad_len)
  n_pad <- length(padded)

  fft_signal <- stats::fft(padded)
  spectrum <- base::Mod(fft_signal) ^ 2
  half_len <- floor(n_pad / 2) + 1L

  obj$cutindex <- compute_cut_index(spectrum[seq_len(half_len)], obj$threshold)
  obj$pad_len <- pad_len
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom stats fft
#'@exportS3Method transform ts_fil_fft
transform.ts_fil_fft <- function(obj, data, ...) {
  data <- as.numeric(data)
  n <- length(data)

  if (n < 4 || any(is.na(data))) {
    return(data)
  }

  # Rebuild the same reflected boundary used during fitting. If transform() is
  # called without fit(), compute the padding and cutoff from the new data.
  pad_len <- if (is.null(obj$pad_len)) fft_pad_length(n, obj$pad_pct) else obj$pad_len
  padded <- fft_reflect_pad(data, pad_len)
  n_pad <- length(padded)

  fft_signal <- stats::fft(padded)
  half_len <- floor(n_pad / 2) + 1L

  cutindex <- obj$cutindex
  if (is.null(cutindex)) {
    spectrum <- base::Mod(fft_signal) ^ 2
    cutindex <- compute_cut_index(spectrum[seq_len(half_len)], obj$threshold)
  }

  cutindex <- min(max(1L, cutindex), half_len)

  # Use a tapered low-pass mask instead of a hard cutoff to soften Gibbs
  # ringing around abrupt frequency truncation.
  weights <- fft_lowpass_weights(n_pad, half_len, cutindex, obj$taper_pct)
  filtered_fft <- fft_signal * weights
  reconstructed <- base::Re(stats::fft(filtered_fft, inverse = TRUE) / n_pad)
  result <- reconstructed[(pad_len + 1L):(pad_len + n)]
  return(result)
}

fft_pad_length <- function(n, pad_pct) {
  min(max(1L, floor(n * pad_pct)), n - 1L)
}

fft_reflect_pad <- function(data, pad_len) {
  n <- length(data)

  # Antisymmetric reflection preserves endpoint values and reduces slope jumps
  # before applying the FFT.
  left_pad <- 2 * data[1L] - data[(pad_len + 1L):2L]
  right_pad <- 2 * data[n] - data[(n - 1L):(n - pad_len)]
  c(left_pad, data, right_pad)
}

fft_lowpass_weights <- function(n, half_len, cutindex, taper_pct) {
  weights <- numeric(half_len)
  taper_len <- max(1L, floor(cutindex * taper_pct))

  for (k in seq_len(half_len)) {
    if (k <= cutindex) {
      weights[k] <- 1
    } else if (k <= cutindex + taper_len) {
      phase <- pi * (k - cutindex) / taper_len
      weights[k] <- 0.5 * (1 + cos(phase))
    }
  }

  full_weights <- numeric(n)
  full_weights[seq_len(half_len)] <- weights
  if (n > 2) {
    full_weights[(half_len + 1L):n] <- rev(weights[2L:(n - half_len + 1L)])
  }

  full_weights
}
