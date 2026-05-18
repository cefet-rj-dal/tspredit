#'@title DARIMA
#'@description Create a delegated-differencing ARIMA-like regressor for the
#' sliding-window workflow of `tspredit`.
#'
#'@details
#' `ts_darima()` is a univariate model in the `ts_regsw` lineage. It was
#' designed as an elegant `tspredit` adaptation of classical ARIMA ideas to the
#' supervised sliding-window world already used by the package.
#'
#' The key design decision is that the integration component is delegated to the
#' preprocessing pipeline rather than embedded inside the model itself. In
#' practice, this means that:
#'
#' - autoregressive structure is learned directly from lagged windows
#' - the `d` of the ARIMA logic is handled by preprocessors such as
#'   `ts_norm_diff()` or `ts_norm_an()`
#' - multi-step forecasting reuses the standard recursive engine of `ts_regsw`
#'
#' This keeps the model computationally light and naturally compatible with the
#' target-centered multivariate workflow, where each endogenous auxiliary
#' variable may need its own univariate learner.
#'
#' `ts_darima()` is therefore best understood as a `tspredit` adaptation,
#' inspired by ARIMA but intentionally expressed in the package's own
#' object-oriented pipeline.
#'
#' In particular, the class is meant to be read together with the package's
#' preprocessing abstractions:
#' - use `ts_norm_none()` when no integration-like step is desired
#' - use `ts_norm_diff()` when first differencing should be delegated to the
#'   pipeline
#' - use `ts_norm_an()` when an adaptive normalization view is preferred
#'
#'@param preprocess Preprocessing object. This is where delegated differencing
#' and adaptive normalization usually live. Defaults to `ts_norm_none()`.
#'@param input_size Integer. Number of lagged inputs used by the model.
#'@param input_map Lag-selection strategy object created by `ts_lagmap()`.
#'@param intercept Logical. Whether to include an intercept in the linear model
#' fitted over the lagged inputs.
#'@return A `ts_darima` object inheriting from `ts_regsw`.
#'@references
#' - Box GEP, Jenkins GM, Reinsel GC, Ljung GM (2015). Time Series Analysis:
#'   Forecasting and Control. Wiley.
#' - Hyndman RJ, Athanasopoulos G (2021). Forecasting: Principles and Practice.
#'   Third Edition. OTexts. https://otexts.com/fpp3/
#' - Ogasawara E, Pereira ACM, Bernardes GFR, Brandão AAF, Albuquerque MP
#'   (2010). Adaptive normalization: A novel data normalization approach for
#'   non-stationary time series. IJCNN.
#'@examples
#'data(tsd)
#'
#'ts <- ts_data(tsd$y, 8)
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'model <- ts_darima(ts_norm_diff(), input_size = 5)
#'model <- fit(model, io_train$input, io_train$output)
#'
#'prediction <- predict(model, io_test$input[1, ], steps_ahead = 5)
#'prediction
#'@export
ts_darima <- function(preprocess = ts_norm_none(),
                      input_size = NA,
                      input_map = ts_lagmap(),
                      intercept = TRUE) {
  obj <- ts_regsw(preprocess, input_size, input_map)
  obj$intercept <- isTRUE(intercept)
  class(obj) <- append("ts_darima", class(obj))
  obj
}

ts_darima_as_matrix <- function(x) {
  if (inherits(x, "ts_data")) {
    class(x) <- setdiff(class(x), "ts_data")
  }
  if (is.null(dim(x))) {
    x_names <- names(x)
    x_attrs <- attributes(x)
    x <- matrix(as.numeric(x), nrow = 1)
    if (!is.null(x_names)) {
      colnames(x) <- x_names
    }
    for (nm in setdiff(names(x_attrs), c("names"))) {
      attr(x, nm) <- x_attrs[[nm]]
    }
  } else if (!is.matrix(x)) {
    x <- as.matrix(x)
  }
  x
}

ts_darima_as_numeric <- function(x) {
  if (inherits(x, "ts_data")) {
    class(x) <- setdiff(class(x), "ts_data")
  }
  as.numeric(x)
}

ts_darima_design <- function(x, feature_names = NULL) {
  x <- ts_darima_as_matrix(x)
  x <- as.data.frame(x)
  if (is.null(feature_names)) {
    feature_names <- paste0("lag", seq_len(ncol(x)))
  }
  colnames(x) <- feature_names
  x
}

ts_darima_positions <- function(positions, n_before, n_after, input_size) {
  positions <- as.integer(positions)
  shift <- max(0L, as.integer(n_before) - as.integer(n_after))
  if (shift > 0L) {
    positions <- positions[positions > shift] - shift
  }
  positions <- positions[positions >= 1L & positions <= n_after]
  needed <- min(input_size, n_after)
  if (length(positions) == 0L) {
    positions <- seq.int(max(1L, n_after - needed + 1L), n_after)
  }
  if (length(positions) < needed) {
    positions <- tslagutils()$complete_positions(positions, n_after, needed)
  }
  positions
}

ts_darima_inverse_safe <- function(preprocess, data, x = NULL) {
  tryCatch(
    inverse_transform(preprocess, data, x),
    error = function(cond) {
      if (is.null(x)) data else x
    }
  )
}

#'@exportS3Method fit ts_darima
#'@inheritParams do_fit
#'@return A fitted `ts_darima` object.
#'@noRd
fit.ts_darima <- function(obj, x, y, ...) {
  x_raw <- ts_darima_as_matrix(x)
  y_raw <- ts_darima_as_numeric(y)

  obj$input_map <- fit(obj$input_map, x_raw, y_raw, input_size = obj$input_size)
  obj$preprocess <- fit(obj$preprocess, x_raw)

  x_tr <- ts_darima_as_matrix(transform(obj$preprocess, x_raw))
  y_tr <- transform(obj$preprocess, x_tr, y_raw)

  positions <- ts_darima_positions(obj$input_map$positions, ncol(x_raw), ncol(x_tr), obj$input_size)
  obj$runtime_positions <- positions
  x_model <- x_tr[, positions, drop = FALSE]
  feature_names <- paste0("lag", seq_len(ncol(x_model)))
  design <- ts_darima_design(x_model, feature_names)
  train <- data.frame(
    y = unname(ts_darima_as_numeric(y_tr)),
    design,
    row.names = NULL,
    check.names = FALSE
  )

  formula <- if (isTRUE(obj$intercept)) {
    stats::as.formula("y ~ .")
  } else {
    stats::as.formula("y ~ . - 1")
  }

  obj$model <- stats::lm(formula, data = train)
  obj$feature_names <- feature_names
  attr(obj, "params") <- list(
    input_size = obj$input_size,
    intercept = obj$intercept
  )
  obj
}

#'@exportS3Method do_fit ts_darima
#'@inheritParams do_fit
#'@return A fitted `ts_darima` object.
#'@noRd
do_fit.ts_darima <- function(obj, x, y) {
  fit.ts_darima(obj, x, y)
}

#'@importFrom stats predict
#'@exportS3Method do_predict ts_darima
#'@inheritParams do_predict
#'@return Numeric vector with DARIMA predictions.
#'@noRd
do_predict.ts_darima <- function(obj, x) {
  design <- ts_darima_design(x, obj$feature_names)
  as.vector(stats::predict(obj$model, newdata = design))
}

#'@exportS3Method predict ts_darima
#'@inheritParams do_predict
#'@return Numeric vector with DARIMA predictions.
#'@noRd
predict.ts_darima <- function(object, x, steps_ahead = 1, ...) {
  x <- ts_darima_as_matrix(x)

  if (steps_ahead == 1) {
    x_tr <- ts_darima_as_matrix(transform(object$preprocess, x))
    positions <- ts_darima_positions(object$input_map$positions, ncol(x), ncol(x_tr), object$input_size)
    x_model <- x_tr[, positions, drop = FALSE]
    y <- do_predict(object, x_model)
    y <- ts_darima_inverse_safe(object$preprocess, x_tr, y)
    return(as.vector(y))
  }

  if (nrow(x) > 1) {
    stop("In steps ahead, x should have a single row")
  }

  prediction <- NULL
  x_roll <- x[1, , drop = FALSE]

  for (i in seq_len(steps_ahead)) {
    x_tr <- ts_darima_as_matrix(transform(object$preprocess, x_roll))
    positions <- ts_darima_positions(object$input_map$positions, ncol(x_roll), ncol(x_tr), object$input_size)
    x_model <- x_tr[, positions, drop = FALSE]
    y <- do_predict(object, x_model)
    y <- ts_darima_inverse_safe(object$preprocess, x_tr, y)
    x_roll <- adjust_ts_data(ts_darima_inverse_safe(object$preprocess, x_tr))

    if (ncol(x_roll) > 1) {
      for (j in seq_len(ncol(x_roll) - 1)) {
        x_roll[1, j] <- x_roll[1, j + 1]
      }
    }
    x_roll[1, ncol(x_roll)] <- y
    prediction <- c(prediction, y)
  }

  as.vector(prediction)
}
