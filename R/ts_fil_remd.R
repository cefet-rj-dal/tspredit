#'@title Robust EMD Filter
#'@description Robust EMD-based denoising that separates noise-dominated IMFs and
#' reconstructs the signal by removing the selected high-frequency IMFs.
#'@param engine Decomposition engine: "emd" (single pass, default) or "eemd"
#' (noise-assisted ensemble).
#'@param noise Relative noise width used when `engine = "eemd"`.
#'@param trials Number of ensemble trials used when `engine = "eemd"`.
#'@param max_imfs Maximum number of high-frequency IMFs to remove. If `NULL`,
#' the cutoff is selected automatically from the cumulative roughness curve.
#'@param random_state Optional seed for the ensemble noise (reproducibility).
#'@return A `ts_fil_remd` object.
#'
#'@details The signal is decomposed into intrinsic mode functions (IMFs) with the
#' EMD/EEMD engine (see \code{\link{ts_fil_emd}}). Early IMFs usually contain faster
#' oscillations, while later IMFs
#' represent slower components. This filter estimates a roughness score for each
#' IMF, selects a cutoff from the cumulative roughness curve (via
#' \code{fit_curvature_min}), and removes the selected high-frequency IMFs from the
#' original series. Use `max_imfs` to cap the number of removed IMFs when preserving
#' cycles or seasonal behavior is more important than aggressive denoising.
#'
#'@references
#' - Z. Wu and N. E. Huang (2009). Ensemble Empirical Mode Decomposition: a
#'   noise-assisted data analysis method. Advances in Adaptive Data Analysis.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'library(tspredit)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_remd()
#'filter <- daltoolbox::fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_remd <- function(engine = "emd", noise = 0.1, trials = 5, max_imfs = NULL,
                        random_state = NULL) {
  if (!is.numeric(noise) || length(noise) != 1 || is.na(noise) || noise < 0) {
    stop("Invalid noise value", call. = FALSE)
  }
  if (!is.numeric(trials) || length(trials) != 1 ||
      is.na(trials) || trials < 1) {
    stop("Invalid trials value", call. = FALSE)
  }
  if (!is.null(max_imfs) && (!is.numeric(max_imfs) || length(max_imfs) != 1 ||
      is.na(max_imfs) || max_imfs < 0)) {
    stop("Invalid max_imfs value", call. = FALSE)
  }

  obj <- dal_transform()
  obj$engine <- engine
  obj$noise <- noise
  obj$trials <- as.integer(trials)
  obj$max_imfs <- if (is.null(max_imfs)) NULL else as.integer(max_imfs)
  obj$random_state <- random_state
  class(obj) <- append("ts_fil_remd", class(obj))
  return(obj)
}

fc_roughness <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) <= 2) {
    return(0)
  }

  firstD <- diff(x)
  scale <- stats::sd(firstD)
  if (is.na(scale) || scale <= .Machine$double.eps) {
    return(0)
  }

  # Roughness metric based on normalized first differences.
  normFirstD <- (firstD - mean(firstD)) / scale
  roughness <- (diff(normFirstD) ^ 2) / 4
  return(mean(roughness))
}

#'@importFrom daltoolbox fit
#'@exportS3Method fit ts_fil_remd
fit.ts_fil_remd <- function(obj, data, ...) {
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom daltoolbox fit_curvature_min
#'@exportS3Method transform ts_fil_remd
transform.ts_fil_remd <- function(obj, data, ...) {
  data <- as.numeric(data)
  n <- length(data)

  if (n < 4 || any(is.na(data))) {
    return(data)
  }

  imfs <- emd_imfs(obj, data)   # native EMD/EEMD (matrix n_imf x n, last row = residual)
  nimf <- nrow(imfs) - 1L       # exclude the residual trend
  if (nimf < 2) {
    return(data)
  }

  roughness <- vapply(seq_len(nimf), function(k) fc_roughness(imfs[k, ]), numeric(1))

  # Select how many high-frequency IMFs should be treated as noise. The optional
  # max_imfs cap keeps the filter from removing too much cyclical structure.
  cutoff <- remd_cutoff(cumsum(roughness), obj$max_imfs, nimf)
  if (cutoff < 1) {
    return(data)
  }

  noise <- colSums(imfs[seq_len(cutoff), , drop = FALSE])
  result <- data - noise
  result[is.na(result)] <- data[is.na(result)]
  return(result)
}

remd_cutoff <- function(cumulative_roughness, max_imfs, nimf) {
  cutoff <- 1L

  if (nimf >= 3 && all(!is.na(cumulative_roughness)) &&
      sum(cumulative_roughness) > .Machine$double.eps) {
    res <- tryCatch(
      daltoolbox::transform(daltoolbox::fit_curvature_min(), cumulative_roughness),
      error = function(e) NULL
    )
    if (!is.null(res) && !is.null(res$x) && !is.na(res$x)) {
      cutoff <- as.integer(res$x)
    }
  }

  if (!is.null(max_imfs)) {
    cutoff <- min(cutoff, max_imfs)
  }

  max(0L, min(cutoff, nimf - 1L))
}
