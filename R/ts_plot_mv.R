#'@title Plot Multivariate Forecast Paths
#'@description Plot observed and forecast trajectories for the target series and
#' auxiliary variables returned by the multivariate workflow.
#'
#'@details
#' `plot_ts_pred_mv()` extends the visual logic already used in the univariate
#' examples. It reuses `daltoolbox::plot_ts_pred()` variable by variable and
#' returns either:
#' - one plot when `variable` is provided
#' - a named list of plots when `variable = NULL`
#'
#' The intended workflow is:
#' - fit a `ts_regsw_mv` model
#' - call `predict(..., return_all = TRUE)`
#' - compare the predicted paths against the held-out aligned multivariate data
#'
#'@param history A `ts_data_mv` or data.frame with the observed history used as
#' context for the plot.
#'@param future Optional `ts_data_mv` or data.frame with the held-out aligned
#' observations. When supplied, the observed future is shown together with the
#' recursive predictions.
#'@param prediction Multivariate forecast returned by `predict()` in the
#' multivariate workflows. The target forecast is returned as a vector and the
#' full system forecast is stored in attributes. Older list-based
#' `ts_mv_prediction` objects are also accepted for compatibility.
#'@param variable Optional character scalar. Name of a single variable to plot.
#' When omitted, plots are returned for every variable in the prediction.
#'@param label_x x-axis label.
#'@param label_y y-axis label prefix. The variable name is appended when several
#' plots are returned.
#'@param color observed series color.
#'@param color_adjust history color.
#'@param color_prediction prediction color.
#'@return A single `ggplot` object or a named list of `ggplot` objects.
#'@examples
#'library(daltoolbox)
#'data(tsd)
#'x1 <- c(tsd$y[-1], tail(tsd$y, 1))
#'x2 <- stats::filter(tsd$y, rep(1/3, 3), sides = 1)
#'x2[is.na(x2)] <- tsd$y[is.na(x2)]
#'
#'mv <- ts_data_mv(data.frame(y = tsd$y, x1 = x1, x2 = as.numeric(x2)), y = "y")
#'samp <- ts_sample(mv, test_size = 5)
#'
#'model <- ts_regsw_mv(
#'   model_y = ts_mv_spec(ts_mlp(ts_norm_gminmax(), input_size = 4), variables = c("y", "x1", "x2")),
#'   models_x = list(
#'     x1 = ts_mv_spec(ts_arima()),
#'     x2 = ts_mv_spec(ts_rf(ts_norm_gminmax(), input_size = 4, ntree = 10), variables = c("x2", "y"))
#'   ),
#'   window_size = 5
#' )
#'model <- fit(model, samp$train)
#'pred <- predict(model, steps_ahead = 5, return_all = TRUE)
#'plots <- plot_ts_pred_mv(samp$train, samp$test, pred)
#'@export
plot_ts_pred_mv <- function(history, future = NULL, prediction, variable = NULL,
                            label_x = "", label_y = "Value",
                            color = "black", color_adjust = "blue",
                            color_prediction = "green") {
  if (!inherits(prediction, "ts_mv_prediction")) {
    stop("prediction must be a multivariate prediction returned by predict().")
  }

  history <- as.data.frame(history)
  if (!is.null(future)) {
    future <- as.data.frame(future)
  }

  variables <- attr(prediction, "variables")
  y_name <- attr(prediction, "y_name")
  x_names <- attr(prediction, "x_names")
  if (is.null(variables) || is.null(y_name) || is.null(x_names)) {
    stop("prediction is missing multivariate metadata attributes.")
  }

  system_prediction <- attr(prediction, "system")
  if (is.null(system_prediction)) {
    prediction_values <- c(list(as.vector(prediction)), attr(prediction, "prediction_x"))
    names(prediction_values) <- c(y_name, x_names)
  } else {
    prediction_values <- lapply(c(y_name, x_names), function(name) as.vector(system_prediction[[name]]))
    names(prediction_values) <- c(y_name, x_names)
  }

  if (!is.null(variable)) {
    if (!(variable %in% variables)) {
      stop("Requested variable is not present in prediction.")
    }
    variables <- variable
  }

  plots <- lapply(variables, function(var_name) {
    observed_history <- as.vector(history[[var_name]])
    observed_future <- if (is.null(future)) numeric(0) else as.vector(future[[var_name]])
    observed <- c(observed_history, observed_future)
    adjusted <- observed_history
    predicted <- as.vector(prediction_values[[var_name]])
    x <- seq_along(observed)

    daltoolbox::plot_ts_pred(
      x = x,
      y = observed,
      yadj = adjusted,
      ypred = predicted,
      label_x = label_x,
      label_y = if (length(variables) == 1) label_y else sprintf("%s: %s", label_y, var_name),
      color = color,
      color_adjust = color_adjust,
      color_prediction = color_prediction
    )
  })
  names(plots) <- variables

  if (!is.null(variable)) {
    return(plots[[1]])
  }

  plots
}
