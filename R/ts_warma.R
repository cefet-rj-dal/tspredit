#'@title WARMA
#'@description Create a window-based ARMA-inspired regressor with local
#' stepwise normalization for the `ts_regsw` workflow.
#'
#'@details
#' `ts_warma()` is a `tspredit` implementation inspired by the WARMA proposal:
#' a window-based view of non-stationary series in which local preprocessing is
#' interpreted in steps.
#'
#' In this adaptation:
#'
#' - step `0` leaves the local window unchanged
#' - step `1` subtracts the local mean of each window
#' - step `2` subtracts the local mean and scales by the local standard
#'   deviation
#'
#' The implementation follows the package's sliding-window lineage, so it uses
#' the fully overlapping window regime naturally induced by `ts_data(..., sw)`
#' and `ts_regsw`. The resulting representation is then modeled with a linear
#' regressor over the normalized lagged inputs.
#'
#' This makes `ts_warma()` a computationally light competitor to `ts_darima()`
#' and a practical univariate block for the multivariate target-centered
#' workflow.
#'
#' When `steps = NA`, the model chooses the smallest step in `{0, 1, 2}` whose
#' locally transformed reconstructed series reaches integration order zero
#' according to `forecast::ndiffs()`.
#'
#' The current implementation should be understood as the `tspredit`
#' interpretation of WARMA inside the package's object-oriented
#' sliding-window pipeline. In other words, it is an adaptation aligned with
#' `ts_regsw`, not a separate estimation framework detached from the rest of the
#' library.
#'
#'@param preprocess External preprocessing object applied before the WARMA local
#' steps. Defaults to `ts_norm_none()`.
#'@param input_size Integer. Number of lagged inputs used by the model.
#'@param input_map Lag-selection strategy object created by `ts_lagmap()`.
#'@param steps Integer in `{0, 1, 2}` or `NA`. When `NA`, infer the smallest
#' suitable step automatically.
#'@param intercept Logical. Whether to include an intercept in the linear model
#' fitted over the locally normalized lagged inputs.
#'@return A `ts_warma` object inheriting from `ts_regsw`.
#'@references
#' - Box GEP, Jenkins GM, Reinsel GC, Ljung GM (2015). Time Series Analysis:
#'   Forecasting and Control. Wiley.
#' - Hyndman RJ, Athanasopoulos G (2021). Forecasting: Principles and Practice.
#'   Third Edition. OTexts. https://otexts.com/fpp3/
#' - Ogasawara E, Pereira ACM, Bernardes GFR, Brandão AAF, Albuquerque MP
#'   (2010). Adaptive normalization: A novel data normalization approach for
#'   non-stationary time series. IJCNN.
#' - Local WARMA manuscript used as implementation reference:
#'   2026_04_SBBD_WARMA.pdf.
#'@examples
#'data(tsd)
#'
#'ts <- ts_data(tsd$y, 8)
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'model <- ts_warma(input_size = 5, steps = NA)
#'model <- daltoolbox::fit(model, io_train$input, io_train$output)
#'
#'prediction <- predict(model, io_test$input[1, ], steps_ahead = 5)
#'prediction
#'@export
ts_warma <- function(preprocess = ts_norm_none(),
                     input_size = NA,
                     input_map = ts_lagmap(),
                     steps = NA,
                     intercept = TRUE) {
  if (!is.na(steps)) {
    if (!is.numeric(steps) || length(steps) != 1 || !steps %in% 0:2) {
      stop("steps must be 0, 1, 2, or NA.")
    }
    steps <- as.integer(steps)
  }

  obj <- ts_regsw(preprocess, input_size, input_map)
  obj$steps <- steps
  obj$intercept <- isTRUE(intercept)
  class(obj) <- append("ts_warma", class(obj))
  obj
}

ts_warma_as_matrix <- function(x) {
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

ts_warma_as_numeric <- function(x) {
  if (inherits(x, "ts_data")) {
    class(x) <- setdiff(class(x), "ts_data")
  }
  as.numeric(x)
}

ts_warma_normalize_xy <- function(x, y = NULL, steps = 0L) {
  x <- ts_warma_as_matrix(x)
  means <- rowMeans(x)
  scales <- rep(1, nrow(x))
  x_norm <- x
  y_norm <- if (is.null(y)) NULL else as.numeric(y)
  if (!is.null(y)) {
    y_norm <- ts_warma_as_numeric(y)
  }

  if (steps >= 1L) {
    x_norm <- sweep(x_norm, 1, means, "-")
    if (!is.null(y_norm)) {
      y_norm <- y_norm - means
    }
  }

  if (steps >= 2L) {
    scales <- apply(x_norm, 1, stats::sd)
    non_zero <- scales > 0
    if (any(non_zero)) {
      x_norm[non_zero, ] <- sweep(x_norm[non_zero, , drop = FALSE], 1, scales[non_zero], "/")
      if (!is.null(y_norm)) {
        y_norm[non_zero] <- y_norm[non_zero] / scales[non_zero]
      }
    }
    if (any(!non_zero)) {
      x_norm[!non_zero, ] <- 0
      if (!is.null(y_norm)) {
        y_norm[!non_zero] <- 0
      }
      scales[!non_zero] <- 1
    }
  }

  list(x = x_norm, y = y_norm, mean = means, scale = scales)
}

ts_warma_inverse_y <- function(y, means, scales, steps) {
  y <- as.numeric(y)
  if (steps >= 2L) {
    y <- y * scales
  }
  if (steps >= 1L) {
    y <- y + means
  }
  y
}

ts_warma_local_series <- function(series, sw, steps) {
  windows <- ts_data(series, sw = sw)
  local <- ts_warma_normalize_xy(windows, steps = steps)
  as.numeric(local$x[, ncol(local$x)])
}

ts_warma_select_steps <- function(series, sw) {
  if (length(series) <= sw) {
    return(0L)
  }

  for (steps in 0:2) {
    local_series <- ts_warma_local_series(series, sw, steps)
    order_d <- forecast::ndiffs(local_series)
    if (isTRUE(order_d == 0L)) {
      return(as.integer(steps))
    }
  }

  2L
}

ts_warma_design <- function(x, feature_names = NULL) {
  x <- ts_warma_as_matrix(x)
  x <- as.data.frame(x)
  if (is.null(feature_names)) {
    feature_names <- paste0("lag", seq_len(ncol(x)))
  }
  colnames(x) <- feature_names
  x
}

ts_warma_positions <- function(positions, n_before, n_after, input_size) {
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

ts_warma_inverse_safe <- function(preprocess, data, x = NULL) {
  tryCatch(
    inverse_transform(preprocess, data, x),
    error = function(cond) {
      if (is.null(x)) data else x
    }
  )
}

#'@exportS3Method fit ts_warma
#'@inheritParams do_fit
#'@return A fitted `ts_warma` object.
#'@noRd
fit.ts_warma <- function(obj, x, y, ...) {
  x_raw <- ts_warma_as_matrix(x)
  y_raw <- ts_warma_as_numeric(y)

  obj$input_map <- fit(obj$input_map, x_raw, y_raw, input_size = obj$input_size)
  obj$preprocess <- fit(obj$preprocess, x_raw)

  x_tr <- ts_warma_as_matrix(transform(obj$preprocess, x_raw))
  y_tr <- transform(obj$preprocess, x_tr, y_raw)

  series_tr <- tslagutils()$reconstruct_series(x_tr, y_tr)
  if (is.na(obj$steps)) {
    obj$steps <- ts_warma_select_steps(series_tr, sw = ncol(x_tr))
  }

  x_local <- ts_warma_normalize_xy(x_tr, y_tr, steps = obj$steps)
  positions <- ts_warma_positions(obj$input_map$positions, ncol(x_raw), ncol(x_local$x), obj$input_size)
  obj$runtime_positions <- positions
  x_model <- as.matrix(x_local$x[, positions, drop = FALSE])
  feature_names <- paste0("lag", seq_len(ncol(x_model)))
  design <- ts_warma_design(x_model, feature_names)
  train <- data.frame(
    y = unname(ts_warma_as_numeric(x_local$y)),
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
    steps = obj$steps,
    intercept = obj$intercept
  )
  obj
}

#'@importFrom stats predict
#'@exportS3Method predict ts_warma
#'@inheritParams do_predict
#'@return Numeric vector with WARMA predictions.
#'@noRd
predict.ts_warma <- function(object, x, steps_ahead = 1, ...) {
  if (steps_ahead == 1) {
    x <- ts_warma_as_matrix(x)
    x_tr <- ts_warma_as_matrix(transform(object$preprocess, x))
    local <- ts_warma_normalize_xy(x_tr, steps = object$steps)
    positions <- ts_warma_positions(object$input_map$positions, ncol(x), ncol(local$x), object$input_size)
    design <- ts_warma_design(
      local$x[, positions, drop = FALSE],
      object$feature_names
    )
    y_norm <- as.vector(stats::predict(object$model, newdata = design))
    y <- ts_warma_inverse_y(y_norm, local$mean, local$scale, object$steps)
    y <- ts_warma_inverse_safe(object$preprocess, x_tr, y)
    return(as.vector(y))
  }

  x <- ts_warma_as_matrix(x)
  if (nrow(x) > 1) {
    stop("In steps ahead, x should have a single row")
  }

  prediction <- NULL
  cnames <- colnames(x)
  x_roll <- x[1, , drop = FALSE]

  for (i in seq_len(steps_ahead)) {
    colnames(x_roll) <- cnames
    x_tr <- ts_warma_as_matrix(transform(object$preprocess, x_roll))
    local <- ts_warma_normalize_xy(x_tr, steps = object$steps)
    positions <- ts_warma_positions(object$input_map$positions, ncol(x_roll), ncol(local$x), object$input_size)
    design <- ts_warma_design(
      local$x[, positions, drop = FALSE],
      object$feature_names
    )
    y_norm <- as.vector(stats::predict(object$model, newdata = design))
    y <- ts_warma_inverse_y(y_norm, local$mean, local$scale, object$steps)
    y <- ts_warma_inverse_safe(object$preprocess, x_tr, y)
    x_roll <- adjust_ts_data(ts_warma_inverse_safe(object$preprocess, x_tr))

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
