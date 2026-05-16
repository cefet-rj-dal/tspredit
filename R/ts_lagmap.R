#' @title Lag Mapping for Sliding-Window Predictors
#' @description
#' Configure how a sliding-window predictor chooses the `input_size` lagged
#' attributes that will be fed to the underlying regression model.
#'
#' @param method Character. Lag-selection strategy:
#'   `"recent"`, `"even"`, `"geom"`, `"acf"`, `"pacf"`, `"peaks"`,
#'   `"seasonal"`, `"acf_seasonal"`, `"pacf_seasonal"`, `"blocks"`, `"mi"`,
#'   or `"mrmr"`.
#' @param seasonality Optional integer. Seasonal period used by the seasonal
#'   lag selectors. If `NULL`, an estimate is derived from the training series.
#' @param peak_basis Character. Correlation profile used by `"peaks"` and
#'   `"blocks"`: `"acf"` or `"pacf"`.
#' @param block_radius Integer. Radius around each selected center when
#'   `method = "blocks"`.
#' @param bins Integer. Number of quantile bins used by the mutual-information
#'   criteria.
#' @return A `ts_lagmap` object.
#'
#' @details
#' The lag mapper is fitted on the training data before the base predictor is
#' trained. During `fit()`, the mapper stores a vector of selected lag columns.
#' The default `"recent"` method reproduces the historical behavior of the
#' package: it keeps the most recent `input_size` observations available in the
#' sliding window.
#'
#' Correlation-based methods operate on the raw training series reconstructed
#' from the input windows and aligned outputs. Supervised methods (`"mi"` and
#' `"mrmr"`) inspect the relationship between each lagged attribute and the
#' training target.
#'
#' @references
#' - Box GEP, Jenkins GM, Reinsel GC, Ljung GM (2015). Time Series Analysis:
#'   Forecasting and Control. Fifth Edition. Wiley.
#' - Peng H, Long F, Ding C (2005). Feature selection based on mutual
#'   information criteria of max-dependency, max-relevance, and min-redundancy.
#'   IEEE Transactions on Pattern Analysis and Machine Intelligence, 27(8),
#'   1226-1238. doi:10.1109/TPAMI.2005.159
#' - Leites J, Cerqueira V, Soares C (2024). Selecting time lags for time
#'   series forecasting: an empirical study. arXiv:2405.11237.
#'
#' @examples
#' library(daltoolbox)
#' library(tspredit)
#' data(tsd)
#'
#' ts <- ts_data(tsd$y, 10)
#' io <- ts_projection(ts)
#'
#' mapper <- ts_lagmap(method = "pacf")
#' mapper <- fit(mapper, io$input, io$output, input_size = 4)
#' mapper$lags
#' mapper$columns
#' @importFrom daltoolbox dal_base
#' @export
ts_lagmap <- function(
  method = c(
    "recent", "even", "geom", "acf", "pacf", "peaks",
    "seasonal", "acf_seasonal", "pacf_seasonal", "blocks", "mi", "mrmr"
  ),
  seasonality = NULL,
  peak_basis = c("acf", "pacf"),
  block_radius = 1,
  bins = 8
) {
  method <- match.arg(method)
  peak_basis <- match.arg(peak_basis)

  obj <- dal_base()
  obj$method <- method
  obj$seasonality <- seasonality
  obj$peak_basis <- peak_basis
  obj$block_radius <- block_radius
  obj$bins <- bins
  obj$utils <- tslagutils()
  obj$positions <- integer(0)
  obj$lags <- integer(0)
  obj$columns <- character(0)
  class(obj) <- append("ts_lagmap", class(obj))
  obj
}

#' @exportS3Method fit ts_lagmap
#' @importFrom daltoolbox fit
fit.ts_lagmap <- function(obj, x, y = NULL, input_size = NULL, ...) {
  x <- as.matrix(x)

  if (is.null(input_size) || is.na(input_size) || input_size < 1) {
    stop("ts_lagmap requires a positive input_size.")
  }

  total <- ncol(x)
  if (input_size > total) {
    stop("input_size cannot be greater than the number of available lag columns.")
  }

  utils <- obj$utils
  requires_target <- c(
    "acf", "pacf", "peaks", "seasonal", "acf_seasonal",
    "pacf_seasonal", "blocks", "mi", "mrmr"
  )
  if (obj$method %in% requires_target && is.null(y)) {
    stop("This lag-mapping method requires aligned training outputs in fit().")
  }

  series <- NULL
  if (!is.null(y)) {
    series <- utils$reconstruct_series(x, y)
  }

  positions <- switch(
    obj$method,
    recent = utils$lag_recent(total, input_size),
    even = utils$lag_even(total, input_size),
    geom = utils$lag_geom(total, input_size),
    acf = utils$lag_acf(series, total, input_size),
    pacf = utils$lag_pacf(series, total, input_size),
    peaks = utils$lag_peaks(series, total, input_size, basis = obj$peak_basis),
    seasonal = utils$lag_seasonal(series, total, input_size, seasonality = obj$seasonality),
    acf_seasonal = utils$lag_acf_seasonal(series, total, input_size, seasonality = obj$seasonality),
    pacf_seasonal = utils$lag_pacf_seasonal(series, total, input_size, seasonality = obj$seasonality),
    blocks = utils$lag_blocks(series, total, input_size, basis = obj$peak_basis, block_radius = obj$block_radius),
    mi = utils$lag_mi(x, y, input_size, bins = obj$bins),
    mrmr = utils$lag_mrmr(x, y, input_size, bins = obj$bins)
  )

  if (is.null(colnames(x))) {
    colnames(x) <- paste0("t", utils$position_to_lag(seq_len(total), total))
  }

  obj$positions <- positions
  obj$lags <- utils$position_to_lag(positions, total)
  obj$columns <- colnames(x)[positions]

  if (is.null(obj$seasonality) && obj$method %in% c("seasonal", "acf_seasonal", "pacf_seasonal")) {
    obj$seasonality_estimate <- utils$estimate_seasonality(series)
  }

  obj
}
