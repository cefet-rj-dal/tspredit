#'@title Deterministic Univariate Predictor
#'@description Forecast a univariate series using a deterministic law of
#' formation instead of a statistical learner.
#'
#'@details
#' `ts_deterministic()` defines a small family of rule-based predictors that
#' can operate either on raw time series or on sliding-window inputs.
#'
#' The current deterministic modes are:
#' - `"periodic"`: repeat a learned cycle of fixed length
#' - `"persist"`: repeat the most recent observed value
#'
#' This family is useful for variables whose future behavior is structurally
#' determined, such as:
#' - day-of-week codes
#' - weekend indicators
#' - fixed operational calendars
#' - slowly changing auxiliary variables
#'
#' Because the forecasting rule is deterministic, the same object can be used
#' in two contexts:
#' - direct raw-series prediction, in the lineage of `ts_arima()`
#' - sliding-window prediction, in the lineage of `ts_regsw`
#'
#' In other words, `ts_deterministic()` unifies both views for cases where the
#' predictive mechanism is a rule, not a learner over lagged attributes.
#'
#'@param mode Character. Deterministic mode. Supported values are
#' `"periodic"` and `"persist"`.
#'@param period Optional integer. Required when `mode = "periodic"`.
#'@param context_size Optional integer. Number of most recent values used to
#' identify the next state in a periodic cycle. When omitted, the smallest
#' non-ambiguous context is inferred from the learned cycle.
#'@return A `ts_deterministic` object.
#'@examples
#'series <- c(4, 5, 6, 7, 1, 2, 3)
#'model <- ts_deterministic("periodic", period = 7)
#'model <- fit(model, x = series)
#'predict(model, steps_ahead = 5)
#'
#'sw <- ts_data(series, sw = 4)
#'io <- ts_projection(sw)
#'model <- fit(ts_deterministic("persist"), io$input, io$output)
#'predict(model, io$input[1:2, ], steps_ahead = 1)
#'@export
ts_deterministic <- function(mode = c("periodic", "persist"),
                             period = NULL,
                             context_size = NULL) {
  mode <- match.arg(mode)

  if (mode == "periodic") {
    if (!is.numeric(period) || length(period) != 1 || period < 1) {
      stop("period must be a positive integer when mode = 'periodic'.")
    }
    period <- as.integer(period)
  }

  if (!is.null(context_size)) {
    if (!is.numeric(context_size) || length(context_size) != 1 || context_size < 1) {
      stop("context_size must be a positive integer.")
    }
    context_size <- as.integer(context_size)
  }

  obj <- ts_reg()
  obj$mode <- mode
  obj$period <- period
  obj$context_size <- context_size
  obj$cycle <- numeric(0)
  obj$last_value <- NA_real_
  obj$history <- numeric(0)
  class(obj) <- append("ts_deterministic", class(obj))
  obj
}

ts_det_as_series <- function(x, y = NULL) {
  if (!is.null(y)) {
    return(tslagutils()$reconstruct_series(x, y))
  }

  if (is.data.frame(x) || is.matrix(x)) {
    x <- as.matrix(x)
    if (ncol(x) == 1) {
      return(as.numeric(x[, 1]))
    }
    if (nrow(x) == 1) {
      return(as.numeric(x[1, ]))
    }
  }

  as.numeric(x)
}

ts_det_infer_context_size <- function(cycle) {
  period <- length(cycle)
  extended <- c(cycle, cycle)

  for (k in seq_len(period)) {
    keys <- vapply(seq_len(period), function(i) {
      paste(extended[i:(i + k - 1)], collapse = "\r")
    }, character(1))
    next_values <- extended[seq_len(period) + k]
    groups <- split(next_values, keys)
    if (all(vapply(groups, function(values) length(unique(values)) == 1L, logical(1)))) {
      return(k)
    }
  }

  period
}

ts_det_context_matrix <- function(x, context_size) {
  if (is.null(x)) {
    return(matrix(numeric(0), nrow = 1))
  }

  if (is.data.frame(x) || is.matrix(x)) {
    x <- as.matrix(x)
    k <- min(context_size, ncol(x))
    return(x[, (ncol(x) - k + 1):ncol(x), drop = FALSE])
  }

  x <- as.numeric(x)
  k <- min(context_size, length(x))
  matrix(utils::tail(x, k), nrow = 1)
}

ts_det_match_context <- function(candidate, context) {
  isTRUE(all.equal(as.numeric(candidate), as.numeric(context),
                   tolerance = sqrt(.Machine$double.eps)))
}

ts_det_periodic_next <- function(object, history) {
  if (length(object$cycle) == 0) {
    stop("ts_deterministic(periodic) has not been fitted yet.")
  }

  if (length(history) == 0) {
    return(object$cycle[1])
  }

  cycle <- as.numeric(object$cycle)
  period <- length(cycle)
  extended <- c(cycle, cycle)
  k_max <- min(length(history), object$context_size)

  for (k in seq(k_max, 1)) {
    context <- utils::tail(history, k)
    matches <- numeric(0)
    for (i in seq_len(period)) {
      candidate <- extended[i:(i + k - 1)]
      if (ts_det_match_context(candidate, context)) {
        matches <- c(matches, extended[i + k])
      }
    }
    matches <- unique(matches)
    if (length(matches) == 1) {
      return(matches[1])
    }
  }

  cycle[1]
}

ts_det_persist_value <- function(object, x = NULL) {
  if (!is.null(x)) {
    if (is.data.frame(x) || is.matrix(x)) {
      x <- as.matrix(x)
      return(as.numeric(x[nrow(x), ncol(x)]))
    }
    x <- as.numeric(x)
    if (length(x) > 0) {
      return(utils::tail(x, 1))
    }
  }

  if (is.na(object$last_value)) {
    stop("ts_deterministic(persist) has not been fitted yet.")
  }

  object$last_value
}

#'@exportS3Method fit ts_deterministic
#'@inheritParams do_fit
#'@return A fitted `ts_deterministic` object.
#'@noRd
fit.ts_deterministic <- function(obj, x, y = NULL, ...) {
  series <- ts_det_as_series(x, y)
  if (length(series) == 0) {
    stop("ts_deterministic requires at least one observation.")
  }

  obj$history <- as.numeric(series)

  if (obj$mode == "periodic") {
    if (length(series) < obj$period) {
      stop("ts_deterministic(periodic) requires at least 'period' observations.")
    }
    obj$cycle <- utils::tail(series, obj$period)
    if (is.null(obj$context_size)) {
      obj$context_size <- ts_det_infer_context_size(obj$cycle)
    } else {
      obj$context_size <- min(obj$context_size, obj$period)
    }
    attr(obj, "params") <- list(
      mode = obj$mode,
      period = obj$period,
      context_size = obj$context_size
    )
  } else if (obj$mode == "persist") {
    obj$last_value <- utils::tail(series, 1)
    obj$context_size <- 1L
    attr(obj, "params") <- list(mode = obj$mode)
  }

  obj
}

#'@exportS3Method predict ts_deterministic
#'@inheritParams do_predict
#'@param steps_ahead Integer. When `steps_ahead = 1`, matrix/data.frame inputs
#' are handled rowwise. When `steps_ahead > 1`, the method performs recursive
#' forecasting from a single history.
#'@return Numeric vector with deterministic forecasts.
#'@noRd
predict.ts_deterministic <- function(object, x = NULL, y = NULL, steps_ahead = NULL, ...) {
  if (is.null(steps_ahead)) {
    steps_ahead <- 1L
  }
  steps_ahead <- as.integer(steps_ahead)

  if (steps_ahead == 1L && (is.data.frame(x) || is.matrix(x))) {
    x <- as.matrix(x)
    if (object$mode == "persist") {
      return(as.numeric(x[, ncol(x), drop = TRUE]))
    }

    contexts <- ts_det_context_matrix(x, object$context_size)
    return(apply(contexts, 1, function(row) {
      ts_det_periodic_next(object, as.numeric(row))
    }))
  }

  if (object$mode == "persist") {
    value <- ts_det_persist_value(object, if (steps_ahead == 1L) x else NULL)
    return(rep(value, steps_ahead))
  }

  if (is.null(x)) {
    history <- object$history
  } else if (is.data.frame(x) || is.matrix(x)) {
    x <- as.matrix(x)
    if (nrow(x) > 1 && steps_ahead > 1L) {
      stop("For multi-step deterministic forecasting, x must provide a single history.")
    }
    history <- as.numeric(x[nrow(x), ])
  } else {
    history <- as.numeric(x)
  }

  prediction <- numeric(steps_ahead)
  for (i in seq_len(steps_ahead)) {
    prediction[i] <- ts_det_periodic_next(object, history)
    history <- c(history, prediction[i])
  }

  prediction
}

#'@title Periodic Deterministic Predictor
#'@description Forecast a univariate series by repeating a learned periodic
#' cycle.
#'@param period Integer. Cycle length to repeat.
#'@param context_size Optional integer. Most recent values used to identify the
#' next state within the cycle. When omitted, the smallest non-ambiguous value
#' is inferred automatically.
#'@return A `ts_periodic` object, inheriting from `ts_deterministic`.
#'@examples
#'series <- c(4, 5, 6, 7, 1, 2, 3)
#'model <- ts_periodic(7)
#'model <- fit(model, x = series)
#'predict(model, steps_ahead = 5)
#'@export
ts_periodic <- function(period, context_size = NULL) {
  obj <- ts_deterministic("periodic", period = period, context_size = context_size)
  class(obj) <- append("ts_periodic", class(obj))
  obj
}

#'@title Persistence Deterministic Predictor
#'@description Forecast a univariate series by repeating its most recent
#' observed value.
#'@return A `ts_persist` object, inheriting from `ts_deterministic`.
#'@examples
#'series <- c(10, 11, 11, 11)
#'model <- ts_persist()
#'model <- fit(model, x = series)
#'predict(model, steps_ahead = 3)
#'@export
ts_persist <- function() {
  obj <- ts_deterministic("persist")
  class(obj) <- append("ts_persist", class(obj))
  obj
}
