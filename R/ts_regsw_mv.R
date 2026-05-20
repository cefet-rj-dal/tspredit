#'@title Multivariate Model Specification
#'@description Wrap a univariate forecasting model so it can be orchestrated
#' inside a multivariate workflow.
#'
#'@details
#' `ts_mv_spec()` is the object-oriented contract that describes how one
#' variable-specific predictive pipeline should be assembled inside
#' `ts_regsw_mv()`.
#'
#' Each specification can declare:
#' - `model`: the learner responsible for the variable
#' - `variables`: which synchronized series are allowed as inputs to this
#'   learner
#' - `lags`: which lag positions are extracted from each variable block
#' - `transforms`: optional raw-series transformations applied per variable
#'   before the multivariate windows are built
#'
#' This design lets different variables use different forecasting strategies
#' while preserving a single orchestration contract. For example:
#' - the target `y` may use `ts_lstm(ts_norm_an(), ...)`
#' - `x1` may use `ts_mlp(ts_norm_diff(), ...)`
#' - `x2` may use `ts_rf(ts_norm_gminmax(), ...)` plus a smoothing filter
#' - deterministic auxiliary variables may use `ts_deterministic()`,
#'   `ts_periodic()`, or `ts_persist()`
#'
#' In other words, the multivariate layer coordinates the pipelines, but the
#' behavior of each variable still lives inside its own object.
#'
#'@param model Base model object. It can be a sliding-window regressor such as
#' `ts_mlp()` or a raw-series model such as `ts_arima()`.
#'@param variables Optional character vector. Variables used as predictors for
#' this submodel. When omitted, defaults depend on the context:
#' target model uses all variables, auxiliary models use their own variable.
#'@param lags Optional named list with one integer vector per variable. When
#' omitted, each variable uses all lags from `0:(window_size-1)`.
#'@param transforms Optional named list of raw-series transformations applied
#' per variable before the multivariate windows are built. Each entry can be a
#' single transform object or a list of transforms. These transformations act as
#' variable-specific feature engineering and are orchestrated by the
#' multivariate wrapper.
#'@return A `ts_mv_spec` object.
#'@examples
#'spec_y <- ts_mv_spec(ts_mlp(ts_norm_gminmax()), variables = c("y", "x1"))
#'spec_x1 <- ts_mv_spec(ts_deterministic("periodic", period = 7), variables = "x1")
#'@export
ts_mv_spec <- function(model, variables = NULL, lags = NULL, transforms = NULL) {
  obj <- list(
    model = model,
    variables = variables,
    lags = lags,
    transforms = transforms
  )
  class(obj) <- "ts_mv_spec"
  obj
}

#'@title Multivariate Sliding-Window Regressor
#'@description Orchestrate one target model and one auxiliary model per
#' covariate, while reusing the existing univariate learners from `tspredit`.
#'
#'@details
#' `ts_regsw_mv()` is the first multivariate forecasting orchestrator in
#' `tspredit`. It keeps the package centered on a target variable `y`, while
#' allowing every auxiliary variable `x1, ..., xn` to be forecast by its own
#' pipeline.
#'
#' The workflow is:
#' 1. store aligned multivariate observations in `ts_data_mv()`
#' 2. define one `ts_mv_spec()` for `y`
#' 3. define one `ts_mv_spec()` for each `x`
#' 4. fit the composed system with `fit()`
#' 5. forecast recursively with `predict(..., steps_ahead = h)`
#'
#' The current implementation keeps a single `window_size` as the base temporal
#' memory available to every variable. After that, each specification decides
#' which variables and which lag positions are actually used by its learner.
#'
#' This means the multivariate extension does not replace the existing
#' univariate models. It reuses them as polymorphic building blocks.
#'
#' Supported configurations in this first version:
#' - the target model must inherit from `ts_regsw`
#' - auxiliary models may inherit from `ts_regsw` or from `ts_reg`
#' - raw-series auxiliary models such as `ts_arima()` currently use only their
#'   own variable as input
#'
#' The method returns the forecast of `y` as a numeric vector. The recursive
#' path of `y` and all auxiliary predictions is attached to that vector as
#' attributes, so the interface stays target-centered without discarding the
#' system forecast.
#'
#'@param model_y A `ts_mv_spec` or a fitted-model constructor for the target
#' variable.
#'@param models_x Named list with one `ts_mv_spec` (or plain model object) per
#' auxiliary variable.
#'@param window_size Integer. Base window size available to each variable.
#'@return A `ts_regsw_mv` object.
#'@examples
#'data(tsd)
#'x1 <- c(tsd$y[-1], tail(tsd$y, 1))
#'x2 <- stats::filter(tsd$y, rep(1/3, 3), sides = 1)
#'x2[is.na(x2)] <- tsd$y[is.na(x2)]
#'
#'mv <- ts_data_mv(data.frame(y = tsd$y, x1 = x1, x2 = x2), y = "y")
#'samp <- ts_sample(mv, test_size = 5)
#'
#'model <- ts_regsw_mv(
#'   model_y = ts_mv_spec(
#'     ts_mlp(ts_norm_an(), input_size = 4, size = 4, decay = 0),
#'     variables = c("y", "x1", "x2"),
#'     transforms = list(y = ts_fil_ma(3))
#'   ),
#'   models_x = list(
#'     x1 = ts_mv_spec(ts_deterministic("periodic", period = 7)),
#'     x2 = ts_mv_spec(ts_deterministic("periodic", period = 7))
#'   ),
#'   window_size = 10
#' )
#'
#'model <- daltoolbox::fit(model, samp$train)
#'predict(model, steps_ahead = 1)
#'predict(model, steps_ahead = 5)
#'pred <- predict(model, steps_ahead = 5)
#'attr(pred, "system")
#'@export
ts_regsw_mv <- function(model_y, models_x, window_size = 30) {
  if (missing(model_y)) {
    stop("model_y must be provided.")
  }
  if (missing(models_x) || length(models_x) == 0) {
    stop("models_x must provide one model per auxiliary variable.")
  }
  if (is.null(names(models_x)) || any(names(models_x) == "")) {
    stop("models_x must be a named list.")
  }
  if (!is.numeric(window_size) || length(window_size) != 1 || window_size < 1) {
    stop("window_size must be a positive integer.")
  }

  obj <- ts_reg()
  obj$model_y <- model_y
  obj$models_x <- models_x
  obj$window_size <- as.integer(window_size)
  obj$fitted_models_x <- list()
  obj$history <- NULL
  obj$y_name <- NULL
  obj$x_names <- NULL
  class(obj) <- append("ts_regsw_mv", class(obj))
  obj
}

mv_default_lags <- function(window_size) {
  0:(window_size - 1)
}

mv_as_spec <- function(spec, default_variables, allowed_variables, window_size) {
  if (!inherits(spec, "ts_mv_spec")) {
    spec <- ts_mv_spec(spec)
  }

  if (is.null(spec$variables)) {
    spec$variables <- default_variables
  }

  if (!all(spec$variables %in% allowed_variables)) {
    extra <- setdiff(spec$variables, allowed_variables)
    stop(sprintf("Unknown variables in multivariate specification: %s", paste(extra, collapse = ", ")))
  }

  if (is.null(spec$lags)) {
    spec$lags <- stats::setNames(
      lapply(spec$variables, function(...) mv_default_lags(window_size)),
      spec$variables
    )
  } else {
    missing_vars <- setdiff(spec$variables, names(spec$lags))
    for (var in missing_vars) {
      spec$lags[[var]] <- mv_default_lags(window_size)
    }
    spec$lags <- spec$lags[spec$variables]
  }

  spec$lags <- lapply(spec$lags, function(lag_values) {
    lag_values <- unique(as.integer(lag_values))
    lag_values <- lag_values[is.finite(lag_values)]
    if (length(lag_values) == 0 || any(lag_values < 0)) {
      stop("Lag definitions must contain non-negative integers.")
    }
    sort(lag_values, decreasing = TRUE)
  })

  spec$transforms <- mv_normalize_transforms(
    transforms = spec$transforms,
    variables = spec$variables
  )

  spec
}

mv_normalize_transforms <- function(transforms, variables) {
  if (is.null(transforms)) {
    transforms <- vector("list", length(variables))
    names(transforms) <- variables
    return(transforms)
  }

  if (!is.list(transforms)) {
    stop("transforms must be NULL or a named list.")
  }

  if (is.null(names(transforms)) || any(names(transforms) == "")) {
    stop("transforms must be a named list keyed by variable name.")
  }

  unknown <- setdiff(names(transforms), variables)
  if (length(unknown) > 0) {
    stop(sprintf("Unknown variables in transforms: %s", paste(unknown, collapse = ", ")))
  }

  normalized <- stats::setNames(vector("list", length(variables)), variables)
  for (var in variables) {
    entry <- transforms[[var]]
    if (is.null(entry)) {
      normalized[[var]] <- list()
    } else if (is.list(entry) && !inherits(entry, "dal_transform")) {
      normalized[[var]] <- entry
    } else {
      normalized[[var]] <- list(entry)
    }
  }

  normalized
}

mv_max_lag <- function(specs) {
  max(unlist(lapply(specs, function(spec) unlist(spec$lags))), na.rm = TRUE)
}

mv_apply_transform_sequence <- function(series, transforms) {
  result <- series
  if (length(transforms) == 0) {
    return(result)
  }

  for (transformer in transforms) {
    transformer <- fit(transformer, result)
    result <- transform(transformer, result)
  }

  result
}

mv_prepare_data_for_spec <- function(data, spec) {
  data <- as.data.frame(data)
  prepared <- data

  for (var in spec$variables) {
    prepared[[var]] <- mv_apply_transform_sequence(
      series = prepared[[var]],
      transforms = spec$transforms[[var]]
    )
  }

  prepared
}

mv_build_input_matrix <- function(data, spec, origins) {
  blocks <- list()
  cnames <- character(0)
  idx <- 1

  for (var in spec$variables) {
    values <- data[[var]]
    for (lag_value in spec$lags[[var]]) {
      blocks[[idx]] <- values[origins - lag_value]
      cnames[idx] <- sprintf("%s_t%d", var, lag_value)
      idx <- idx + 1
    }
  }

  input <- as.data.frame(blocks, optional = TRUE, stringsAsFactors = FALSE)
  colnames(input) <- cnames
  input
}

mv_prepare_supervised <- function(data, target, spec) {
  prepared <- mv_prepare_data_for_spec(data, spec)
  max_lag <- max(unlist(spec$lags))
  n <- nrow(prepared)
  if (n <= max_lag + 1) {
    stop("Not enough observations to build the requested multivariate window.")
  }

  origins <- (max_lag + 1):(n - 1)
  input <- mv_build_input_matrix(prepared, spec, origins)
  output <- as.vector(data[[target]][origins + 1])
  keep <- stats::complete.cases(input) & is.finite(output)

  list(input = input[keep, , drop = FALSE], output = output[keep])
}

mv_prepare_one_step_input <- function(data, spec) {
  prepared <- mv_prepare_data_for_spec(data, spec)
  origin <- nrow(data)
  mv_build_input_matrix(prepared, spec, origin)
}

mv_compose_prediction <- function(object, prediction_y, prediction_x) {
  prediction_y <- as.numeric(prediction_y)
  prediction_x <- lapply(prediction_x, as.numeric)

  system_prediction <- data.frame(
    stats::setNames(list(prediction_y), object$y_name),
    as.data.frame(prediction_x, optional = TRUE, stringsAsFactors = FALSE),
    check.names = FALSE
  )
  system_prediction <- system_prediction[, c(object$y_name, object$x_names), drop = FALSE]

  attr(prediction_y, "y_name") <- object$y_name
  attr(prediction_y, "x_names") <- object$x_names
  attr(prediction_y, "variables") <- c(object$y_name, object$x_names)
  attr(prediction_y, "steps_ahead") <- length(prediction_y)
  attr(prediction_y, "prediction_x") <- prediction_x
  attr(prediction_y, "system") <- system_prediction
  class(prediction_y) <- unique(c("ts_mv_prediction", class(prediction_y)))

  prediction_y
}

mv_fit_submodel <- function(model, input, output, series = NULL) {
  if (inherits(model, "ts_regsw")) {
    model$input_size <- ncol(input)
    model$input_map <- ts_lagmap("recent")
    return(fit(model, x = input, y = output))
  }

  if (!is.null(series)) {
    return(fit(model, x = series))
  }

  stop("This model type is not supported in multivariate mode.")
}

mv_predict_submodel <- function(template, fitted, spec, history, target) {
  if (inherits(fitted, "ts_regsw")) {
    input <- mv_prepare_one_step_input(history, spec)
    prediction <- predict(fitted, x = input, steps_ahead = 1)
    return(as.vector(prediction)[1])
  }

  series <- as.vector(history[[target]])
  fitted_step <- fit(template, x = series)
  prediction <- predict(fitted_step, x = utils::tail(series, 1), steps_ahead = 1)
  as.vector(prediction)[1]
}

mv_validate_model_specs <- function(obj, data) {
  y_name <- attr(data, "y")
  x_names <- attr(data, "x")
  variables <- attr(data, "variables")

  if (!setequal(names(obj$models_x), x_names)) {
    stop("models_x must contain exactly one named model per auxiliary variable in ts_data_mv.")
  }

  obj$model_y <- mv_as_spec(
    obj$model_y,
    default_variables = variables,
    allowed_variables = variables,
    window_size = obj$window_size
  )
  obj$models_x <- lapply(names(obj$models_x), function(name) {
    mv_as_spec(
      obj$models_x[[name]],
      default_variables = name,
      allowed_variables = variables,
      window_size = obj$window_size
    )
  })
  names(obj$models_x) <- x_names

  if (!inherits(obj$model_y$model, "ts_regsw")) {
    stop("The target model in ts_regsw_mv must inherit from ts_regsw.")
  }

  for (name in x_names) {
    spec <- obj$models_x[[name]]
    if (!inherits(spec$model, "ts_reg")) {
      stop("All auxiliary models must inherit from ts_reg.")
    }
    if (!inherits(spec$model, "ts_regsw")) {
      if (!(length(spec$variables) == 1 && spec$variables[1] == name)) {
        stop("Raw-series auxiliary models can only use their own variable as input.")
      }
    }
  }

  obj$y_name <- y_name
  obj$x_names <- x_names
  obj$variables <- variables
  obj
}

#'@exportS3Method fit ts_regsw_mv
fit.ts_regsw_mv <- function(obj, x, y = NULL, ...) {
  if (!inherits(x, "ts_data_mv")) {
    stop("fit.ts_regsw_mv expects a ts_data_mv object.")
  }
  if (!identical(attr(x, "representation"), "aligned")) {
    stop("fit.ts_regsw_mv expects aligned ts_data_mv data (sw = 1).")
  }

  obj <- mv_validate_model_specs(obj, x)
  data <- as.data.frame(x)

  obj$fitted_models_x <- list()
  for (name in obj$x_names) {
    spec <- obj$models_x[[name]]
    if (inherits(spec$model, "ts_regsw")) {
      io <- mv_prepare_supervised(data, name, spec)
      obj$fitted_models_x[[name]] <- mv_fit_submodel(spec$model, io$input, io$output)
    } else {
      obj$fitted_models_x[[name]] <- mv_fit_submodel(spec$model, input = NULL, output = NULL, series = data[[name]])
    }
  }

  io_y <- mv_prepare_supervised(data, obj$y_name, obj$model_y)
  obj$fitted_model_y <- mv_fit_submodel(obj$model_y$model, io_y$input, io_y$output)

  obj$history <- adjust_ts_data_mv(
    data,
    y = obj$y_name,
    x = obj$x_names
  )

  obj
}

#'@exportS3Method predict ts_regsw_mv
predict.ts_regsw_mv <- function(object, x = NULL, steps_ahead = 1, return_all = FALSE, ...) {
  if (is.null(x)) {
    if (is.null(object$history)) {
      stop("This multivariate model has no stored history. Fit the model or provide x.")
    }
    history <- object$history
  } else {
    if (!inherits(x, "ts_data_mv")) {
      stop("predict.ts_regsw_mv expects x to be NULL or a ts_data_mv object.")
    }
    if (!identical(attr(x, "representation"), "aligned")) {
      stop("predict.ts_regsw_mv expects aligned ts_data_mv data (sw = 1).")
    }
    history <- x
  }

  history <- adjust_ts_data_mv(as.data.frame(history), y = object$y_name, x = object$x_names)
  steps_ahead <- as.integer(steps_ahead)
  prediction_y <- numeric(steps_ahead)
  prediction_x <- lapply(object$x_names, function(...) numeric(steps_ahead))
  names(prediction_x) <- object$x_names

  for (step_idx in seq_len(steps_ahead)) {
    next_row <- stats::setNames(as.list(rep(NA_real_, length(object$variables))), object$variables)

    for (name in object$x_names) {
      spec <- object$models_x[[name]]
      next_row[[name]] <- mv_predict_submodel(
        template = spec$model,
        fitted = object$fitted_models_x[[name]],
        spec = spec,
        history = history,
        target = name
      )
      prediction_x[[name]][step_idx] <- next_row[[name]]
    }

    next_row[[object$y_name]] <- mv_predict_submodel(
      template = object$model_y$model,
      fitted = object$fitted_model_y,
      spec = object$model_y,
      history = history,
      target = object$y_name
    )
    prediction_y[step_idx] <- next_row[[object$y_name]]

    next_row <- as.data.frame(next_row, optional = TRUE, stringsAsFactors = FALSE)
    next_row <- next_row[, object$variables, drop = FALSE]
    history <- rbind(as.data.frame(history), next_row)
    history <- adjust_ts_data_mv(history, y = object$y_name, x = object$x_names)
  }

  object$history <- history
  mv_compose_prediction(object, prediction_y, prediction_x)
}
