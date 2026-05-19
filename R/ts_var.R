#'@title Vector Autoregression
#'@description Create a target-centered vector autoregression over aligned
#' multivariate observations.
#'
#'@details
#' `ts_var()` models the multivariate system directly, but keeps the `tspredit`
#' interface centered on a distinguished target variable `y`.
#'
#' This means:
#' - the full system is learned jointly
#' - `predict()` returns the target forecast by default
#' - `predict(..., return_all = TRUE)` exposes the forecast path of all system
#'   variables
#'
#' The current implementation uses ordinary least squares over lagged aligned
#' observations and can choose the lag order automatically by minimizing AICc
#' over `1:p_max`.
#'
#' This makes `ts_var()` conceptually different from `ts_arimax()`:
#' - `ts_arimax()` treats the auxiliaries as regressors for one main target
#' - `ts_var()` treats all variables as part of the dynamic system
#'
#' Even so, `tspredit` still lets the user mark one variable as the main target
#' for evaluation and default return behavior.
#'
#'@param target Optional target variable name. When omitted, use the `y`
#' attribute stored in `ts_data_mv`.
#'@param p Optional lag order. When `NULL`, choose the order automatically.
#'@param p_max Maximum lag order considered in the automatic search.
#'@param intercept Logical. Whether to include an intercept in each equation.
#'@return A `ts_var` object inheriting from `ts_reg_mv`.
#'@references
#' - Lütkepohl H (2005). New Introduction to Multiple Time Series Analysis.
#'   Springer.
#' - Tsay RS (2014). Multivariate Time Series Analysis with R and Financial
#'   Applications. Wiley.
#'@examples
#'data(tsd)
#'x1 <- c(tsd$y[-1], tail(tsd$y, 1))
#'x2 <- stats::filter(tsd$y, rep(1/3, 3), sides = 1)
#'x2[is.na(x2)] <- tsd$y[is.na(x2)]
#'
#'mv <- ts_data_mv(data.frame(y = tsd$y, x1 = x1, x2 = as.numeric(x2)), y = "y")
#'samp <- ts_sample(mv, test_size = 5)
#'
#'model <- ts_var(p_max = 3)
#'model <- fit(model, samp$train)
#'predict(model, steps_ahead = 5)
#'@export
ts_var <- function(target = NULL, p = NULL, p_max = 5, intercept = TRUE) {
  obj <- ts_reg_mv(models_x = NULL)
  obj$target <- target
  obj$p <- p
  obj$p_max <- as.integer(p_max)
  obj$intercept <- isTRUE(intercept)
  class(obj) <- append("ts_var", class(obj))
  obj
}

ts_var_build_design <- function(data, variables, p, intercept = TRUE) {
  n <- nrow(data)
  if (n <= p) {
    stop("Not enough observations for the requested VAR order.")
  }

  y <- as.matrix(data[(p + 1):n, variables, drop = FALSE])
  x_blocks <- list()
  if (intercept) {
    x_blocks[[1]] <- rep(1, n - p)
  }
  idx <- if (intercept) 2 else 1

  for (lag_value in seq_len(p)) {
    block <- as.matrix(data[(p + 1 - lag_value):(n - lag_value), variables, drop = FALSE])
    colnames(block) <- paste0(variables, "_t", lag_value)
    x_blocks[[idx]] <- block
    idx <- idx + 1
  }

  x <- do.call(cbind, x_blocks)
  if (is.null(dim(x))) {
    x <- matrix(x, ncol = 1)
  }

  list(x = x, y = y)
}

ts_var_fit_order <- function(data, variables, p, intercept = TRUE) {
  design <- ts_var_build_design(data, variables, p, intercept = intercept)
  fit <- stats::lm.fit(x = design$x, y = design$y)
  coef <- fit$coefficients
  coef[is.na(coef)] <- 0
  fitted <- design$x %*% coef
  resid <- design$y - fitted
  nobs <- nrow(design$y)
  m <- ncol(design$y)
  sigma <- crossprod(resid) / nobs
  det_sigma <- determinant(sigma, logarithm = TRUE)
  if (!isTRUE(det_sigma$sign > 0)) {
    logdet <- Inf
  } else {
    logdet <- as.numeric(det_sigma$modulus)
  }
  loglik <- -(nobs * m / 2) * (log(2 * pi) + 1) - (nobs / 2) * logdet
  kparams <- ncol(design$x) * m
  aic <- -2 * loglik + 2 * kparams
  aicc <- if ((nobs - kparams - 1) > 0) {
    aic + (2 * kparams * (kparams + 1)) / (nobs - kparams - 1)
  } else {
    Inf
  }

  list(
    coefficients = coef,
    residuals = resid,
    sigma = sigma,
    loglik = loglik,
    aic = aic,
    aicc = aicc,
    p = p,
    intercept = intercept
  )
}

ts_var_select_order <- function(data, variables, p_max, intercept = TRUE) {
  p_candidates <- seq_len(max(1L, as.integer(p_max)))
  fits <- lapply(p_candidates, function(p) {
    tryCatch(
      ts_var_fit_order(data, variables, p, intercept = intercept),
      error = function(cond) NULL
    )
  })
  fits <- Filter(Negate(is.null), fits)
  if (length(fits) == 0) {
    stop("Unable to fit any candidate VAR order.")
  }
  scores <- vapply(fits, function(fit) fit$aicc, numeric(1))
  fits[[which.min(scores)]]
}

#'@exportS3Method fit ts_var
#'@inheritParams do_fit
#'@return A fitted `ts_var` object.
#'@noRd
fit.ts_var <- function(obj, x, y = NULL, ...) {
  x <- reg_mv_validate_data(x)
  obj <- reg_mv_set_metadata(obj, x)
  data <- as.data.frame(x)

  if (is.null(obj$target)) {
    obj$target <- obj$y_name
  }
  if (!obj$target %in% obj$variables) {
    stop("target must be one of the variables in ts_data_mv.")
  }

  if (is.null(obj$p)) {
    best_fit <- ts_var_select_order(data, obj$variables, obj$p_max, intercept = obj$intercept)
  } else {
    best_fit <- ts_var_fit_order(data, obj$variables, as.integer(obj$p), intercept = obj$intercept)
  }

  obj$p <- best_fit$p
  obj$model <- best_fit
  obj$y_name <- obj$target
  obj$x_names <- setdiff(obj$variables, obj$y_name)
  attr(obj, "params") <- list(p = obj$p, intercept = obj$intercept, criterion = "AICc")
  obj
}

ts_var_next_row <- function(object, history) {
  values <- numeric(0)
  if (isTRUE(object$model$intercept)) {
    values <- c(values, 1)
  }

  for (lag_value in seq_len(object$p)) {
    row <- as.numeric(history[nrow(history) - lag_value + 1, object$variables, drop = TRUE])
    values <- c(values, row)
  }

  prediction <- as.vector(values %*% object$model$coefficients)
  names(prediction) <- object$variables
  prediction
}

#'@exportS3Method predict ts_var
#'@inheritParams do_predict
#'@param steps_ahead Integer. Forecast horizon.
#'@param return_all Logical. Ignored for compatibility. The method always
#' returns the target forecast as a vector with the full forecast system
#' attached as attributes.
#'@return Numeric vector with target forecasts. The full forecast system is
#' attached as attributes.
#'@noRd
predict.ts_var <- function(object, x = NULL, steps_ahead = 1, return_all = FALSE, ...) {
  steps_ahead <- as.integer(steps_ahead)

  if (is.null(x)) {
    history <- object$history
  } else {
    x <- reg_mv_validate_data(x)
    history <- adjust_ts_data_mv(as.data.frame(x), y = object$y_name, x = object$x_names, sw = 1, representation = "aligned")
  }

  history_df <- as.data.frame(history)
  predictions <- matrix(NA_real_, nrow = steps_ahead, ncol = length(object$variables))
  colnames(predictions) <- object$variables

  for (i in seq_len(steps_ahead)) {
    next_row <- ts_var_next_row(object, history_df)
    predictions[i, ] <- next_row[object$variables]
    history_df <- rbind(history_df, as.data.frame(as.list(next_row), optional = TRUE, stringsAsFactors = FALSE))
  }

  object$history <- adjust_ts_data_mv(history_df, y = object$y_name, x = object$x_names, sw = 1, representation = "aligned")
  prediction_y <- predictions[, object$y_name]

  prediction_x <- as.list(as.data.frame(predictions[, object$x_names, drop = FALSE]))
  mv_compose_prediction(object, prediction_y, prediction_x)
}
