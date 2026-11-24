#'@title Wavelet Filter
#'@description Denoise a series using the Maximal Overlap Discrete Wavelet Transform
#' (MODWT): decompose the signal, zero the finest-scale detail, and reconstruct.
#'@param filter Available wavelet filters: 'haar', 'd4', 'la8', 'bl14', 'c6'. A vector
#' of names selects, in `fit`, the filter that best preserves the signal (highest R2).
#'@return A `ts_fil_wavelet` object.
#'
#'@details The MODWT is a shift-invariant, undecimated wavelet transform implemented
#' as a pyramid algorithm (Percival & Walden, 2000), with the wavelet/scaling filter
#' coefficients (Daubechies, least-asymmetric, coiflet, best-localized) carried as
#' internal constants. This function is a backport of the canonical Python `pytspredit`
#' implementation; the two share the same algorithm and coefficients. Because the
#' MODWT is a deterministic linear transform, parity is value-for-value (~5e-6). Note:
#' the published coiflet ('c6') coefficients are only approximately orthogonal, so c6
#' reconstructs to ~1e-6 (as in any package).
#'
#'@references
#' - S. Mallat (1989). A Theory for Multiresolution Signal Decomposition: The Wavelet
#'   Representation. IEEE Transactions on Pattern Analysis and Machine Intelligence.
#' - D. B. Percival and A. T. Walden (2000). Wavelet Methods for Time Series Analysis.
#'   Cambridge University Press (MODWT pyramid algorithm).
#' - I. Daubechies (1992). Ten Lectures on Wavelets. SIAM (source of the Daubechies /
#'   least-asymmetric / coiflet filter coefficient families).
#'@examples
#'# Denoising with discrete wavelets (optionally selecting best filter)
#' # Load package and example data
#' library(daltoolbox)
#' library(tspredit)
#' data(tsd)
#' tsd$y[9] <- 2 * tsd$y[9]  # inject an outlier
#'
#' # Fit wavelet filter ("haar" by default; can pass a vector to select best)
#' filter <- ts_fil_wavelet()
#' filter <- daltoolbox::fit(filter, tsd$y)
#' y <- transform(filter, tsd$y)
#'
#' # Compare original vs wavelet-denoised series
#' plot_ts_pred(y = tsd$y, yadj = y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_wavelet <- function(filter = "haar") {
  obj <- dal_transform()
  obj$filter <- filter
  class(obj) <- append("ts_fil_wavelet", class(obj))
  return(obj)
}

# ---- Native MODWT core (base R; mirrors the Python pytspredit.wavelet) --------

# (scaling g, wavelet h) coefficients, from R wavelets::wt.filter, full precision.
wave_coef <- list(
  haar = list(g = c(0.707106781186547, 0.707106781186547),
              h = c(0.707106781186547, -0.707106781186547)),
  d4 = list(g = c(0.482962913144534, 0.836516303737808, 0.224143868042013, -0.12940952255126),
            h = c(-0.12940952255126, -0.224143868042013, 0.836516303737808, -0.482962913144534)),
  la8 = list(g = c(-0.0757657147893407, -0.0296355276459541, 0.497618667632458, 0.803738751805216, 0.297857795605542, -0.0992195435769354, -0.0126039672622612, 0.0322231006040713),
             h = c(0.0322231006040713, 0.0126039672622612, -0.0992195435769354, -0.297857795605542, 0.803738751805216, -0.497618667632458, -0.0296355276459541, 0.0757657147893407)),
  bl14 = list(g = c(0.0120154192834842, 0.0172133762994439, -0.0649080035533744, -0.064131289818917, 0.360218460898555, 0.781921593296555, 0.483610915693782, -0.0568044768822707, -0.101010920866413, 0.0447423494687405, 0.0204642075778225, -0.0181266051311065, -0.0032832978473081, 0.0022918339541009),
              h = c(0.0022918339541009, 0.0032832978473081, -0.0181266051311065, -0.0204642075778225, 0.0447423494687405, 0.101010920866413, -0.0568044768822707, -0.483610915693782, 0.781921593296555, -0.360218460898555, -0.064131289818917, 0.0649080035533744, 0.0172133762994439, -0.0120154192834842)),
  c6 = list(g = c(-0.0156557285289848, -0.0727326213410511, 0.384864856538113, 0.85257204164239, 0.337897670951159, -0.0727322757411889),
            h = c(-0.0727322757411889, -0.337897670951159, 0.85257204164239, -0.384864856538113, -0.0727326213410511, 0.0156557285289848))
)

# circular shift: roll(v, k)[i] = v[(i - k) mod n]  (matches numpy np.roll)
wave_roll <- function(v, k) {
  n <- length(v)
  v[((seq_len(n) - 1 - k) %% n) + 1]
}

wave_nlevels <- function(n, L) {
  max(1L, as.integer(floor(log2((n - 1) / (L - 1) + 1))))
}

# Forward MODWT (periodic boundary): returns list(W = list of details, V = smooth).
wave_modwt <- function(x, filter, J = NULL) {
  co <- wave_coef[[filter]]
  gt <- co$g / sqrt(2); ht <- co$h / sqrt(2); L <- length(co$g)
  v <- as.numeric(x); n <- length(v)
  levels <- if (is.null(J)) wave_nlevels(n, L) else J
  W <- vector("list", levels)
  for (j in seq_len(levels)) {
    s <- 2^(j - 1)
    wj <- numeric(n); vj <- numeric(n)
    for (l in seq_len(L)) {
      shifted <- wave_roll(v, s * (l - 1))
      wj <- wj + ht[l] * shifted
      vj <- vj + gt[l] * shifted
    }
    W[[j]] <- wj; v <- vj
  }
  list(W = W, V = v)
}

# Inverse MODWT.
wave_imodwt <- function(W, V, filter) {
  co <- wave_coef[[filter]]
  gt <- co$g / sqrt(2); ht <- co$h / sqrt(2); L <- length(co$g)
  vj <- as.numeric(V); n <- length(vj)
  for (j in seq(length(W), 1)) {
    s <- 2^(j - 1); wj <- W[[j]]; vprev <- numeric(n)
    for (l in seq_len(L)) {
      vprev <- vprev + ht[l] * wave_roll(wj, -s * (l - 1)) + gt[l] * wave_roll(vj, -s * (l - 1))
    }
    vj <- vprev
  }
  vj
}

# Denoise: reconstruct with the finest detail (level 1) zeroed.
wave_denoise <- function(x, filter) {
  m <- wave_modwt(x, filter)
  m$W[[1]] <- numeric(length(x))
  wave_imodwt(m$W, m$V, filter)
}

# -----------------------------------------------------------------------------

#'@importFrom daltoolbox fit
#'@exportS3Method fit ts_fil_wavelet
fit.ts_fil_wavelet <- function(obj, data, ...) {
  if (length(obj$filter) > 1) {
    sel_filter <- ""
    bestr2 <- -.Machine$double.xmax
    for (f in obj$filter) {
      yhatV <- wave_denoise(as.numeric(data), f)
      r2 <- R2.ts(data, yhatV)
      if (r2 > bestr2) {
        sel_filter <- f
        bestr2 <- r2
      }
    }
    obj$filter <- sel_filter
  }
  return(obj)
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_fil_wavelet
transform.ts_fil_wavelet <- function(obj, data, ...) {
  wave_denoise(as.numeric(data), obj$filter)
}
