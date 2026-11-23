#'@title EMD Filter
#'@description Empirical Mode Decomposition (EMD) filter that decomposes a
#' signal into intrinsic mode functions (IMFs) and reconstructs a smoothed
#' component by removing the first (highest-frequency) IMF.
#'@param engine Decomposition engine: "emd" (single pass, default) or "eemd"
#' (noise-assisted ensemble).
#'@param noise Relative noise width used when `engine = "eemd"`.
#'@param trials Number of ensemble trials used when `engine = "eemd"`.
#'@param random_state Optional seed for the ensemble noise (reproducibility).
#'@return A `ts_fil_emd` object.
#'
#'@details This is a native implementation (base R + `stats::splinefun`) that does
#' not depend on external EMD packages. It is the canonical counterpart of the
#' Python `pytspredit` implementation (which this backports), and is orders of
#' magnitude faster than ensemble EMD via `hht`. EMD is an adaptive, data-driven
#' method; the ensemble engine is stochastic, so results are compared at the
#' quality level (denoising), not value-for-value, across implementations.
#'
#'@references
#' - N. E. Huang et al. (1998). The Empirical Mode Decomposition and the
#'   Hilbert Spectrum for nonlinear and non-stationary time series analysis.
#'   Proceedings of the Royal Society A.
#' - Z. Wu and N. E. Huang (2009). Ensemble Empirical Mode Decomposition: a
#'   noise-assisted data analysis method. Advances in Adaptive Data Analysis.
#' - G. Rilling, P. Flandrin, P. Goncalves (2003). On empirical mode decomposition
#'   and its algorithms (boundary mirroring). IEEE-EURASIP NSIP.
#'@examples
#'# EMD-based smoothing: remove first IMF as noise
#' # Load package and example data
#' library(daltoolbox)
#' library(tspredit)
#' data(tsd)
#' tsd$y[9] <- 2 * tsd$y[9]  # inject an outlier
#'
#' # Fit EMD filter and reconstruct without the first (noisiest) IMF
#' filter <- ts_fil_emd()
#' filter <- daltoolbox::fit(filter, tsd$y)
#' y <- transform(filter, tsd$y)
#'
#' # Compare original vs smoothed series
#' plot_ts_pred(y = tsd$y, yadj = y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_emd <- function(engine = "emd", noise = 0.1, trials = 5, random_state = NULL) {
  obj <- dal_transform()
  obj$engine <- engine
  obj$noise <- noise
  obj$trials <- trials
  obj$random_state <- random_state
  class(obj) <- append("ts_fil_emd", class(obj))
  return(obj)
}

# ---- Native EMD/EEMD core (shared by ts_fil_emd and ts_fil_remd) -------------

# Interior local maxima / minima via derivative sign change (mirrors the Python
# pytspredit.emd implementation this backports).
emd_extrema <- function(x) {
  d <- diff(x)
  right <- c(d, 0)
  left <- c(0, d)
  list(maxima = which(right < 0 & left > 0),
       minima = which(right > 0 & left < 0))
}

# Cubic-spline envelope through the given extrema (1-based positions), with
# Rilling-style boundary mirroring of the first/last two extrema.
emd_envelope <- function(idx, x, n) {
  i0 <- idx - 1               # work in 0-based coordinates
  v <- x[idx]
  m <- length(i0)
  k <- min(2L, m)
  left_i <- -rev(i0[seq_len(k)])
  left_v <- rev(v[seq_len(k)])
  right_i <- 2 * (n - 1) - rev(i0[(m - k + 1):m])
  right_v <- rev(v[(m - k + 1):m])
  ei <- c(left_i, i0, right_i)
  ev <- c(left_v, v, right_v)
  f <- stats::splinefun(ei, ev, method = "fmm")
  f(0:(n - 1))
}

# Empirical Mode Decomposition: returns a matrix (n_imf x n); rows sum to x
# (last row is the residual trend).
emd_decompose <- function(x, max_imf = 12L, sift_max = 100L, sd_tol = 0.2) {
  x <- as.numeric(x)
  n <- length(x)
  imfs <- list()
  residual <- x
  for (mi in seq_len(max_imf)) {
    h <- residual
    for (si in seq_len(sift_max)) {
      ex <- emd_extrema(h)
      if (length(ex$maxima) < 2 || length(ex$minima) < 2) break
      mean_env <- 0.5 * (emd_envelope(ex$maxima, h, n) + emd_envelope(ex$minima, h, n))
      h_next <- h - mean_env
      sd_val <- sum((h - h_next)^2) / (sum(h^2) + 1e-12)
      h <- h_next
      if (sd_val < sd_tol) break
    }
    imfs[[length(imfs) + 1]] <- h
    residual <- residual - h
    ex <- emd_extrema(residual)
    if (length(ex$maxima) + length(ex$minima) < 2) break
  }
  imfs[[length(imfs) + 1]] <- residual
  do.call(rbind, imfs)
}

# Ensemble EMD: average IMFs over `trials` noisy copies (noise std =
# noise_width * population sd of x, matching the Python reference).
eemd_decompose <- function(x, trials = 100L, noise_width = 0.05, max_imf = 12L,
                           random_state = NULL) {
  if (!is.null(random_state)) set.seed(random_state)
  x <- as.numeric(x)
  n <- length(x)
  scale <- noise_width * sqrt(mean((x - mean(x))^2))
  acc <- matrix(0, max_imf + 2L, n)
  counts <- numeric(max_imf + 2L)
  for (t in seq_len(trials)) {
    im <- emd_decompose(x + stats::rnorm(n) * scale, max_imf = max_imf)
    k <- nrow(im)
    acc[1:k, ] <- acc[1:k, ] + im
    counts[1:k] <- counts[1:k] + 1
  }
  k <- sum(counts > 0)
  acc[1:k, , drop = FALSE] / pmax(counts[1:k], 1)
}

# Dispatch to the chosen engine.
emd_imfs <- function(obj, data) {
  if (!is.null(obj$engine) && obj$engine == "eemd") {
    return(eemd_decompose(data, trials = obj$trials, noise_width = obj$noise,
                          random_state = obj$random_state))
  }
  emd_decompose(data)
}

# -----------------------------------------------------------------------------

#'@importFrom daltoolbox transform
#'@importFrom stats splinefun rnorm
#'@exportS3Method transform ts_fil_emd
transform.ts_fil_emd <- function(obj, data, ...) {
  data <- as.numeric(data)
  if (length(data) < 4 || anyNA(data)) {
    return(data)
  }
  imfs <- emd_imfs(obj, data)
  if (nrow(imfs) < 2) {
    return(data)
  }
  data - imfs[1, ]
}
