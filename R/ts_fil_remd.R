#'@title Robust EMD Filter
#'@description Ensemble/robust EMD-based denoising using CEEMD to separate
#' noise-dominated IMFs and reconstruct the signal.
#'@param noise noise
#'@param trials trials
#'@return A `ts_fil_remd` object.
#'
#'@references
#' - Z. Wu and N. E. Huang (2009). Ensemble Empirical Mode Decomposition: a
#'   noise-assisted data analysis method. Advances in Adaptive Data Analysis.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_remd()
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_remd <- function(noise = 0.1, trials = 5) {
  obj <- dal_transform()
  obj$noise <- noise
  obj$trials <- trials
  class(obj) <- append("ts_fil_remd", class(obj))
  return(obj)
}

fc_roughness <- function(x) {
  firstD = diff(x)
  normFirstD = (firstD - mean(firstD)) / sd(firstD)
  roughness = (diff(normFirstD) ** 2) / 4
  return(mean(roughness))
}

#'@importFrom daltoolbox transform
#'@importFrom daltoolbox fit_curvature_min
#'@importFrom hht CEEMD
#'@exportS3Method transform ts_fil_remd
transform.ts_fil_remd <- function(obj, data, ...) {

  id <- 1:length(data)

  suppressWarnings(ceemd.result <- hht::CEEMD(data, id, verbose = FALSE, obj$noise, obj$trials))

  obj$model <- ceemd.result
  ## calculate roughness for each imf
  vec <- vector()
  for (n in 1:obj$model$nimf) {
    vec[n] <- fc_roughness(obj$model[["imf"]][, n])
  }

  vec <- cumsum(vec)

  ## Maximum curvature
  res <- transform(daltoolbox::fit_curvature_min(), vec)
  div <- res$x
  noise <- obj$model[["imf"]][, 1]

  if (div > 1) {
    for (k in 2:div) {
      noise <- noise + obj$model[["imf"]][, k]
    }
  }

  result <- data - noise

  return(result)
}

