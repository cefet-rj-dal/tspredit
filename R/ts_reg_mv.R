#'@title Target-Centered Multivariate Regression Base
#'@description Base class for singular multivariate time-series models that
#' operate on aligned observations (`sw = 1`).
#'
#'@details
#' `ts_reg_mv()` is the multivariate counterpart of the raw-series branch of
#' `tspredit`.
#'
#' It is intended for models that consume aligned multivariate observations
#' directly, without first materializing explicit lagged windows in
#' `ts_data_mv(..., sw > 1)`.
#'
#' This branch is appropriate when the multivariate relationship is naturally
#' expressed at the aligned-observation level, for example:
#' - target-centered linear regression over synchronized covariates
#' - ARIMA with external regressors (`ARIMAX`)
#' - vector autoregression over the whole system
#'
#' The design remains target-centered:
#' - the multivariate object still declares one target variable `y`
#' - `predict()` returns the forecast of `y` by default
#' - descendants may also expose the forecast path of the remaining variables
#'   when `return_all = TRUE`
#'
#' Typical descendants are:
#' - `ts_arimax()`: target-centered dynamic regression with ARIMA errors
#' - `ts_lm_mv()`: target-centered multivariate linear regression
#' - `ts_var()`: vector autoregression, still exposed through a target-centered
#'   interface
#'
#' The interface keeps a distinguished target variable `y`, but models may also
#' return the forecast path of the remaining variables when requested.
#'
#'@param models_x Optional named list with one univariate model per auxiliary
#' variable. These models are used to generate future paths for `x1, ..., xn`
#' when the target-centered model needs auxiliary forecasts along the horizon.
#' They are not required when future auxiliary values are supplied directly at
#' prediction time.
#'@return A `ts_reg_mv` object.
#'@export
ts_reg_mv <- function(models_x = NULL) {
  obj <- ts_reg()
  obj$models_x <- models_x
  obj$fitted_models_x <- list()
  obj$history <- NULL
  obj$y_name <- NULL
  obj$x_names <- NULL
  obj$variables <- NULL
  class(obj) <- append("ts_reg_mv", class(obj))
  obj
}

reg_mv_validate_data <- function(x) {
  if (!inherits(x, "ts_data_mv")) {
    stop("This method expects a ts_data_mv object.")
  }
  if (!identical(attr(x, "representation"), "aligned")) {
    stop("This method expects aligned ts_data_mv data (sw = 1).")
  }
  x
}

reg_mv_set_metadata <- function(obj, data) {
  obj$y_name <- attr(data, "y")
  obj$x_names <- attr(data, "x")
  obj$variables <- attr(data, "variables")
  obj$history <- adjust_ts_data_mv(
    as.data.frame(data),
    y = obj$y_name,
    x = obj$x_names,
    sw = 1,
    representation = "aligned"
  )
  obj
}

reg_mv_validate_models_x <- function(obj, data) {
  x_names <- attr(data, "x")

  if (is.null(obj$models_x)) {
    obj$models_x <- list()
  }

  if (length(obj$models_x) == 0) {
    return(obj)
  }

  if (is.null(names(obj$models_x)) || any(names(obj$models_x) == "")) {
    stop("models_x must be a named list.")
  }

  if (!setequal(names(obj$models_x), x_names)) {
    stop("models_x must contain exactly one named model per auxiliary variable.")
  }

  for (name in x_names) {
    model <- obj$models_x[[name]]
    if (!inherits(model, "ts_reg")) {
      stop("All auxiliary models in models_x must inherit from ts_reg.")
    }
  }

  obj$models_x <- obj$models_x[x_names]
  obj
}

reg_mv_fit_aux_models <- function(obj, data) {
  obj$fitted_models_x <- list()
  if (length(obj$models_x) == 0) {
    return(obj)
  }

  for (name in obj$x_names) {
    obj$fitted_models_x[[name]] <- fit(obj$models_x[[name]], x = data[[name]])
  }

  obj
}

reg_mv_known_future_x <- function(object, x, steps_ahead) {
  if (is.null(x)) {
    return(NULL)
  }

  if (inherits(x, "ts_data_mv")) {
    future <- as.data.frame(x)
  } else {
    future <- as.data.frame(x)
  }

  if (!all(object$x_names %in% names(future))) {
    stop("Provided future multivariate data must contain all auxiliary variables.")
  }

  future <- future[, object$x_names, drop = FALSE]
  if (nrow(future) < steps_ahead) {
    stop("Provided future multivariate data has fewer rows than steps_ahead.")
  }

  future[seq_len(steps_ahead), , drop = FALSE]
}

reg_mv_forecast_aux <- function(object, x = NULL, steps_ahead = 1) {
  known_x <- reg_mv_known_future_x(object, x, steps_ahead)
  if (!is.null(known_x)) {
    return(known_x)
  }

  if (length(object$fitted_models_x) == 0) {
    stop("Future auxiliary values are required. Provide x or fit models_x.")
  }

  prediction_x <- setNames(vector("list", length(object$x_names)), object$x_names)
  for (name in object$x_names) {
    pred <- predict(object$fitted_models_x[[name]], x = NULL, steps_ahead = steps_ahead)
    prediction_x[[name]] <- as.vector(pred)
  }

  as.data.frame(prediction_x, optional = TRUE, stringsAsFactors = FALSE)
}

reg_mv_update_history <- function(object, future_x, prediction_y) {
  next_rows <- future_x
  next_rows[[object$y_name]] <- as.vector(prediction_y)
  next_rows <- next_rows[, object$variables, drop = FALSE]

  history <- rbind(as.data.frame(object$history), next_rows)
  adjust_ts_data_mv(history, y = object$y_name, x = object$x_names, sw = 1, representation = "aligned")
}
