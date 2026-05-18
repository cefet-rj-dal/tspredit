#'@title Multivariate Lagged Windows
#'@description Materialize an aligned multivariate series into an explicit
#' lagged-window table.
#'
#'@details
#' `ts_window_mv()` is the public bridge between the raw aligned representation
#' created by `ts_data_mv()` and the model-ready structures consumed by the
#' multivariate forecasting workflow.
#'
#' The function keeps one base window size for every selected variable, then
#' expands the aligned data into blocks such as:
#'
#' - `y_t6, ..., y_t0`
#' - `x1_t6, ..., x1_t0`
#' - `x2_t6, ..., x2_t0`
#'
#' When `lags` is provided, the function keeps only the requested lag positions
#' for each variable, which makes it useful for inspecting the exact feature
#' space seen by a variable-specific pipeline.
#'
#' Optional `transforms` are applied per variable before the lagged blocks are
#' built. This mirrors the multivariate forecasting workflow, where each
#' variable may carry its own preprocessing logic.
#'
#'@param data A `ts_data_mv` object or compatible data.frame with aligned
#' multivariate observations.
#'@param window_size Integer. Base number of recent observations available per
#' variable.
#'@param variables Optional character vector. Variables to include in the
#' materialized window. By default, all variables stored in `data` are used.
#'@param lags Optional named list with one integer vector per variable. When
#' omitted, every variable uses all lags from `0:(window_size-1)`.
#'@param transforms Optional named list of raw-series transformations applied per
#' variable before the windows are built. Each entry can be a single transform
#' object or a list of transforms.
#'@return A `ts_window_mv` object stored as a data.frame.
#'@examples
#'data(tsd)
#'x1 <- c(tsd$y[-1], tail(tsd$y, 1))
#'x2 <- stats::filter(tsd$y, rep(1/3, 3), sides = 1)
#'x2[is.na(x2)] <- tsd$y[is.na(x2)]
#'
#'mv <- ts_data_mv(
#'  data.frame(y = tsd$y, x1 = x1, x2 = as.numeric(x2)),
#'  y = "y"
#')
#'
#'windows <- ts_window_mv(mv, window_size = 5)
#'ts_head(windows, 3)
#'@export
ts_window_mv <- function(data, window_size = 30, variables = NULL, lags = NULL,
                         transforms = NULL) {
  if (inherits(data, "ts_data_mv")) {
    y_name <- attr(data, "y")
    available <- attr(data, "variables")
  } else {
    data <- as.data.frame(data)
    y_name <- names(data)[1]
    available <- names(data)
  }

  if (!is.numeric(window_size) || length(window_size) != 1 || window_size < 1) {
    stop("window_size must be a positive integer.")
  }

  if (is.null(variables)) {
    variables <- available
  }

  if (!all(variables %in% available)) {
    stop("All requested variables must be present in the aligned multivariate data.")
  }

  spec <- ts_mv_spec(
    model = ts_reg(),
    variables = variables,
    lags = lags,
    transforms = transforms
  )
  spec <- mv_as_spec(
    spec = spec,
    default_variables = variables,
    allowed_variables = available,
    window_size = as.integer(window_size)
  )

  prepared <- mv_prepare_data_for_spec(as.data.frame(data), spec)
  max_lag <- max(unlist(spec$lags))
  n <- nrow(prepared)
  if (n <= max_lag) {
    stop("Not enough observations to build the requested multivariate window.")
  }

  origins <- (max_lag + 1):n
  windows <- mv_build_input_matrix(prepared, spec, origins)
  class(windows) <- append("ts_window_mv", class(windows))
  attr(windows, "y") <- y_name
  attr(windows, "variables") <- variables
  attr(windows, "lags") <- spec$lags
  attr(windows, "window_size") <- as.integer(window_size)
  windows
}
