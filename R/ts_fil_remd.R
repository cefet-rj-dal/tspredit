#'@title Robust EMD Filter
#'@description Ensemble/robust EMD-based denoising using CEEMD to separate
#' noise-dominated IMFs and reconstruct the signal.
#'@param noise Noise amplitude passed to CEEMD.
#'@param trials Number of CEEMD ensemble trials.
#'@param max_imfs Maximum number of high-frequency IMFs to remove. If `NULL`,
#' the cutoff is selected automatically from the cumulative roughness curve.
#'@return A `ts_fil_remd` object.
#'
#'@details CEEMD decomposes the series into intrinsic mode functions (IMFs).
#' Early IMFs usually contain faster oscillations, while later IMFs represent
#' slower components. This filter estimates a roughness score for each IMF,
#' selects a cutoff from the cumulative roughness curve, and removes the
#' selected high-frequency IMFs from the original series. Use `max_imfs` to cap
#' the number of removed IMFs when preserving cycles or seasonal behavior is
#' more important than aggressive denoising.
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
ts_fil_remd <- function(noise = 0.1, trials = 5, max_imfs = NULL) {
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
  obj$noise <- noise
  obj$trials <- as.integer(trials)
  obj$max_imfs <- if (is.null(max_imfs)) NULL else as.integer(max_imfs)
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
#'@importFrom hht CEEMD
#'@importFrom stats sd
#'@exportS3Method transform ts_fil_remd
transform.ts_fil_remd <- function(obj, data, ...) {
  data <- as.numeric(data)
  n <- length(data)

  if (n < 4 || any(is.na(data))) {
    return(data)
  }

  id <- seq_len(n)

  # Use named CEEMD arguments to avoid relying on positional matching across
  # hht versions.
  ceemd_result <- tryCatch(
    {
      suppressWarnings(
        hht::CEEMD(
          sig = data,
          tt = id,
          noise.amp = obj$noise,
          trials = obj$trials,
          verbose = FALSE
        )
      )
    },
    error = function(e) NULL
  )

  if (is.null(ceemd_result) || is.null(ceemd_result$imf) ||
      is.null(ceemd_result$nimf)) {
    return(data)
  }

  imfs <- ceemd_result$imf
  nimf <- ceemd_result$nimf
  if (nimf < 2) {
    return(data)
  }

  roughness <- numeric(nimf)
  for (k in seq_len(nimf)) {
    roughness[k] <- fc_roughness(imfs[, k])
  }

  # Select how many high-frequency IMFs should be treated as noise. The optional
  # max_imfs cap keeps the filter from removing too much cyclical structure.
  cutoff <- remd_cutoff(cumsum(roughness), obj$max_imfs, nimf)
  if (cutoff < 1) {
    return(data)
  }

  noise_imfs <- imfs[, seq_len(cutoff), drop = FALSE]
  noise_imfs[is.na(noise_imfs)] <- 0
  noise <- rowSums(noise_imfs)

  # Remove accumulated high-frequency IMFs from the original signal.
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
