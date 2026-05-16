#' @title Time Series Lag Utilities
#' @description
#' Utility object that groups helper functions used to select lag subsets for
#' sliding-window predictors.
#'
#' @details
#' These helpers are organized by the type of evidence they use to choose lags.
#'
#' \strong{Positional mappings}
#'
#' - `lag_recent()` keeps the most recent lags and reproduces the package's
#'   original behavior.
#' - `lag_even()` spreads the selected lags evenly across the available window.
#' - `lag_geom()` emphasizes recent lags while still sampling older history on
#'   a geometric scale.
#'
#' \strong{Correlation-driven mappings}
#'
#' - `lag_acf()` ranks lags by the absolute autocorrelation of the reconstructed
#'   training series.
#' - `lag_pacf()` ranks lags by the absolute partial autocorrelation.
#' - `lag_peaks()` keeps local maxima of the ACF or PACF profile to avoid
#'   selecting many redundant neighboring lags.
#' - `lag_seasonal()` prioritizes multiples of an estimated or user-provided
#'   seasonal period.
#' - `lag_acf_seasonal()` and `lag_pacf_seasonal()` combine seasonal lags with
#'   correlation-based completion.
#' - `lag_blocks()` expands neighborhoods around the strongest correlation peaks.
#'
#' \strong{Supervised mappings}
#'
#' - `lag_mi()` ranks lags by discretized mutual information with the target.
#' - `lag_mrmr()` greedily maximizes relevance to the target while reducing
#'   redundancy among already selected lags.
#'
#' The mutual-information criteria use quantile discretization and therefore
#' provide deterministic approximations suitable for lightweight dependency-free
#' lag selection inside the package.
#'
#' @return A `tslagutils` object exposing the helper functions.
#'
#' @examples
#' utils <- tslagutils()
#'
#' # Positional baselines
#' utils$lag_recent(total = 9, input_size = 4)
#' utils$lag_even(total = 9, input_size = 4)
#'
#' # Reconstruct a raw series from sliding windows and aligned outputs
#' data(tsd)
#' ts <- ts_data(tsd$y, 10)
#' io <- ts_projection(ts)
#' series <- utils$reconstruct_series(io$input, io$output)
#' head(series)
#'
#' # Correlation profile over available lags
#' utils$score_acf(series, lag_max = 9)
#'
#' @references
#' - Box GEP, Jenkins GM, Reinsel GC, Ljung GM (2015). Time Series Analysis:
#'   Forecasting and Control. Fifth Edition. Wiley.
#' - Hyndman RJ, Athanasopoulos G (2021). Forecasting: Principles and Practice.
#'   Third Edition. OTexts. https://otexts.com/fpp3/
#' - Peng H, Long F, Ding C (2005). Feature selection based on mutual
#'   information criteria of max-dependency, max-relevance, and min-redundancy.
#'   IEEE Transactions on Pattern Analysis and Machine Intelligence, 27(8),
#'   1226-1238. doi:10.1109/TPAMI.2005.159
#' - Leites J, Cerqueira V, Soares C (2024). Selecting time lags for time
#'   series forecasting: an empirical study. arXiv:2405.11237.
#'
#' @importFrom daltoolbox dal_base
#' @export
tslagutils <- function() {
  obj <- dal_base()
  class(obj) <- append("tslagutils", class(obj))

  obj$parse_lag_numbers <- tslag_parse_lag_numbers
  obj$lag_to_position <- tslag_lag_to_position
  obj$position_to_lag <- tslag_position_to_lag
  obj$complete_positions <- tslag_complete_positions
  obj$reconstruct_series <- tslag_reconstruct_series
  obj$estimate_seasonality <- tslag_estimate_seasonality
  obj$score_acf <- tslag_score_acf
  obj$score_pacf <- tslag_score_pacf
  obj$lag_recent <- tslag_recent
  obj$lag_even <- tslag_even
  obj$lag_geom <- tslag_geom
  obj$lag_acf <- tslag_acf
  obj$lag_pacf <- tslag_pacf
  obj$lag_peaks <- tslag_peaks
  obj$lag_seasonal <- tslag_seasonal
  obj$lag_acf_seasonal <- tslag_acf_seasonal
  obj$lag_pacf_seasonal <- tslag_pacf_seasonal
  obj$lag_blocks <- tslag_blocks
  obj$lag_mi <- tslag_mi
  obj$lag_mrmr <- tslag_mrmr

  obj
}

tslag_parse_lag_numbers <- function(names, total = length(names)) {
  if (is.null(names) || any(is.na(names))) {
    return(seq(total, 1))
  }

  lag_numbers <- suppressWarnings(as.integer(sub("^t", "", names)))
  if (any(is.na(lag_numbers))) {
    return(seq(total, 1))
  }

  lag_numbers
}

tslag_lag_to_position <- function(lags, total) {
  total - lags + 1
}

tslag_position_to_lag <- function(positions, total) {
  total - positions + 1
}

tslag_complete_positions <- function(candidates, total, input_size) {
  candidates <- as.integer(candidates)
  candidates <- candidates[is.finite(candidates)]
  candidates <- candidates[candidates >= 1 & candidates <= total]
  selected <- integer(0)

  if (length(candidates) > 0) {
    selected <- unique(candidates)
  }

  if (length(selected) < input_size) {
    fillers <- seq(total, 1)
    fillers <- fillers[!fillers %in% selected]
    selected <- c(selected, fillers)
  }

  selected <- selected[seq_len(min(input_size, length(selected)))]
  sort(unique(selected))
}

tslag_reconstruct_series <- function(x, y) {
  x <- as.matrix(x)
  y <- as.vector(y)

  if (nrow(x) == 0) {
    return(y)
  }

  c(as.numeric(x[1, ]), y)
}

tslag_estimate_seasonality <- function(series, fallback = 1L) {
  frequency <- suppressWarnings(round(forecast::findfrequency(series)))
  if (!is.finite(frequency) || frequency < 2) {
    return(as.integer(fallback))
  }

  as.integer(frequency)
}

tslag_score_acf <- function(series, lag_max) {
  acf_obj <- stats::acf(series, lag.max = lag_max, plot = FALSE, na.action = stats::na.pass)
  as.numeric(acf_obj$acf[-1])
}

tslag_score_pacf <- function(series, lag_max) {
  pacf_obj <- stats::pacf(series, lag.max = lag_max, plot = FALSE, na.action = stats::na.pass)
  as.numeric(pacf_obj$acf)
}

tslag_recent <- function(total, input_size) {
  tslag_complete_positions((total - input_size + 1):total, total, input_size)
}

tslag_even <- function(total, input_size) {
  positions <- round(seq(1, total, length.out = input_size))
  tslag_complete_positions(positions, total, input_size)
}

tslag_geom <- function(total, input_size) {
  lag_candidates <- round(exp(seq(log(1), log(total), length.out = input_size)))
  positions <- tslag_lag_to_position(lag_candidates, total)
  tslag_complete_positions(positions, total, input_size)
}

tslag_select_top_scores <- function(scores, total, input_size) {
  if (length(scores) == 0) {
    return(tslag_recent(total, input_size))
  }

  ranked_lags <- order(abs(scores), decreasing = TRUE)
  positions <- tslag_lag_to_position(ranked_lags, total)
  tslag_complete_positions(positions, total, input_size)
}

tslag_acf <- function(series, total, input_size) {
  scores <- tslag_score_acf(series, total)
  tslag_select_top_scores(scores, total, input_size)
}

tslag_pacf <- function(series, total, input_size) {
  scores <- tslag_score_pacf(series, total)
  tslag_select_top_scores(scores, total, input_size)
}

tslag_peak_lags <- function(scores) {
  if (length(scores) <= 2) {
    return(integer(0))
  }

  peaks <- integer(0)
  values <- abs(scores)
  for (i in 2:(length(values) - 1)) {
    if (values[i] >= values[i - 1] && values[i] >= values[i + 1]) {
      peaks <- c(peaks, i)
    }
  }

  peaks
}

tslag_peaks <- function(series, total, input_size, basis = c("acf", "pacf")) {
  basis <- match.arg(basis)
  scores <- switch(
    basis,
    acf = tslag_score_acf(series, total),
    pacf = tslag_score_pacf(series, total)
  )

  peaks <- tslag_peak_lags(scores)
  if (length(peaks) == 0) {
    return(tslag_select_top_scores(scores, total, input_size))
  }

  peaks <- peaks[order(abs(scores[peaks]), decreasing = TRUE)]
  positions <- tslag_lag_to_position(peaks, total)
  tslag_complete_positions(positions, total, input_size)
}

tslag_seasonal_lags <- function(total, seasonality) {
  if (!is.finite(seasonality) || seasonality < 2 || seasonality > total) {
    return(integer(0))
  }

  seq(seasonality, total, by = seasonality)
}

tslag_seasonal <- function(series, total, input_size, seasonality = NULL) {
  if (is.null(seasonality)) {
    seasonality <- tslag_estimate_seasonality(series)
  }

  positions <- tslag_lag_to_position(tslag_seasonal_lags(total, seasonality), total)
  tslag_complete_positions(positions, total, input_size)
}

tslag_merge_lags <- function(primary_lags, secondary_lags, total, input_size) {
  merged <- unique(c(primary_lags, secondary_lags))
  positions <- tslag_lag_to_position(merged, total)
  tslag_complete_positions(positions, total, input_size)
}

tslag_acf_seasonal <- function(series, total, input_size, seasonality = NULL) {
  if (is.null(seasonality)) {
    seasonality <- tslag_estimate_seasonality(series)
  }

  seasonal_lags <- tslag_seasonal_lags(total, seasonality)
  acf_scores <- tslag_score_acf(series, total)
  acf_lags <- order(abs(acf_scores), decreasing = TRUE)
  tslag_merge_lags(seasonal_lags, acf_lags, total, input_size)
}

tslag_pacf_seasonal <- function(series, total, input_size, seasonality = NULL) {
  if (is.null(seasonality)) {
    seasonality <- tslag_estimate_seasonality(series)
  }

  seasonal_lags <- tslag_seasonal_lags(total, seasonality)
  pacf_scores <- tslag_score_pacf(series, total)
  pacf_lags <- order(abs(pacf_scores), decreasing = TRUE)
  tslag_merge_lags(seasonal_lags, pacf_lags, total, input_size)
}

tslag_blocks <- function(series, total, input_size, basis = c("acf", "pacf"), block_radius = 1) {
  basis <- match.arg(basis)
  scores <- switch(
    basis,
    acf = tslag_score_acf(series, total),
    pacf = tslag_score_pacf(series, total)
  )

  centers <- tslag_peak_lags(scores)
  if (length(centers) == 0) {
    centers <- order(abs(scores), decreasing = TRUE)
  } else {
    centers <- centers[order(abs(scores[centers]), decreasing = TRUE)]
  }

  block_lags <- integer(0)
  for (center in centers) {
    block_lags <- c(
      block_lags,
      seq(max(1, center - block_radius), min(total, center + block_radius))
    )
  }

  positions <- tslag_lag_to_position(block_lags, total)
  tslag_complete_positions(positions, total, input_size)
}

tslag_discretize <- function(x, bins = 8) {
  x <- as.numeric(x)
  if (length(unique(x[is.finite(x)])) <= 1) {
    return(rep(1L, length(x)))
  }

  probs <- seq(0, 1, length.out = bins + 1)
  breaks <- unique(stats::quantile(x, probs = probs, na.rm = TRUE, type = 8))
  if (length(breaks) <= 2) {
    return(as.integer(cut(rank(x, ties.method = "average"), breaks = bins, labels = FALSE)))
  }

  as.integer(cut(x, breaks = breaks, include.lowest = TRUE, labels = FALSE))
}

tslag_mutual_information <- function(x, y, bins = 8) {
  xd <- tslag_discretize(x, bins = bins)
  yd <- tslag_discretize(y, bins = bins)
  tab <- table(xd, yd)
  prob <- tab / sum(tab)
  px <- rowSums(prob)
  py <- colSums(prob)
  mi <- 0

  for (i in seq_len(nrow(prob))) {
    for (j in seq_len(ncol(prob))) {
      pij <- prob[i, j]
      if (pij > 0 && px[i] > 0 && py[j] > 0) {
        mi <- mi + pij * log(pij / (px[i] * py[j]))
      }
    }
  }

  mi
}

tslag_mi <- function(x, y, input_size, bins = 8) {
  x <- as.matrix(x)
  total <- ncol(x)
  relevance <- apply(x, 2, tslag_mutual_information, y = y, bins = bins)
  positions <- order(relevance, decreasing = TRUE)
  tslag_complete_positions(positions, total, input_size)
}

tslag_mrmr <- function(x, y, input_size, bins = 8) {
  x <- as.matrix(x)
  total <- ncol(x)
  relevance <- apply(x, 2, tslag_mutual_information, y = y, bins = bins)
  selected <- integer(0)
  candidates <- seq_len(total)

  while (length(selected) < min(input_size, total) && length(candidates) > 0) {
    if (length(selected) == 0) {
      best <- candidates[which.max(relevance[candidates])]
    } else {
      scores <- sapply(candidates, function(idx) {
        redundancy <- mean(sapply(selected, function(sel) {
          tslag_mutual_information(x[, idx], x[, sel], bins = bins)
        }))
        relevance[idx] - redundancy
      })
      best <- candidates[which.max(scores)]
    }

    selected <- c(selected, best)
    candidates <- setdiff(candidates, best)
  }

  tslag_complete_positions(selected, total, input_size)
}
