#'@title Multivariate Time Series Data
#'@description Construct a multivariate time-series object used throughout the
#' target-centered multivariate workflow.
#'
#'@details
#' `ts_data_mv()` follows the same design principle as `ts_data()` in the
#' univariate path:
#'
#' - with `sw = 1`, it stores aligned multivariate observations
#' - with `sw > 1`, it materializes multivariate lagged windows
#'
#' This keeps a single data abstraction for both the aligned and the lagged
#' representations.
#'
#' In aligned mode (`sw = 1`):
#' - each row is a time instant
#' - each column is one variable
#'
#' In lagged mode (`sw > 1`):
#' - each row is a forecasting origin
#' - each variable contributes one lag block
#' - column names follow the pattern `var_tk`
#'
#' Optional `variables`, `lags`, and `transforms` let the caller inspect a
#' specific multivariate feature space while staying inside the `ts_data_mv`
#' abstraction.
#'
#'@param data data.frame or matrix with one column per variable and one row per
#' time index. It can also be an existing `ts_data_mv`, in which case the
#' stored metadata is reused by default.
#'@param y Optional character scalar. Name of the target variable. When `data`
#' already inherits from `ts_data_mv`, this defaults to the stored target name.
#'@param x Optional character vector. Names of the auxiliary variables. By
#' default, all columns except `y` are used.
#'@param sw Integer. Temporal width of the representation. Use `sw = 1` for
#' aligned multivariate observations and `sw > 1` for lagged windows.
#'@param variables Optional character vector. Variables to include when
#' `sw > 1`. By default, all variables stored in `data` are used.
#'@param lags Optional named list with one integer vector per variable. When
#' omitted, every variable uses all lags from `0:(sw-1)`.
#'@param transforms Optional named list of raw-series transformations applied per
#' variable before the lagged blocks are built. Each entry can be a single
#' transform object or a list of transforms.
#'@return A `ts_data_mv` object.
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
#'ts_head(mv, 3)
#'
#'mv_sw <- ts_data_mv(mv, sw = 5)
#'ts_head(mv_sw, 3)
#'@export
ts_data_mv <- function(data, y = NULL, x = NULL, sw = 1,
                       variables = NULL, lags = NULL, transforms = NULL) {
  inherited_mv <- inherits(data, "ts_data_mv")
  if (inherited_mv) {
    stored_y <- attr(data, "y")
    stored_x <- attr(data, "x")
    data <- as.data.frame(data)
    class(data) <- setdiff(class(data), "ts_data_mv")
    if (is.null(y)) {
      y <- stored_y
    }
    if (is.null(x)) {
      x <- stored_x
    }
  } else {
    data <- as.data.frame(data)
  }

  if (is.null(y) || !is.character(y) || length(y) != 1 || !y %in% names(data)) {
    stop("y must be the name of a column in data.")
  }

  if (!is.numeric(sw) || length(sw) != 1 || sw < 1) {
    stop("sw must be a positive integer.")
  }
  sw <- as.integer(sw)

  if (is.null(x)) {
    x <- setdiff(names(data), y)
  }

  if (!all(x %in% names(data))) {
    stop("All x variables must be present in data.")
  }

  if (anyDuplicated(c(y, x)) > 0) {
    stop("y and x must not contain duplicated variable names.")
  }

  raw_variables <- c(y, x)
  numeric_cols <- vapply(data[, raw_variables, drop = FALSE], is.numeric, logical(1))
  if (!all(numeric_cols)) {
    stop("All variables in ts_data_mv must be numeric.")
  }

  data <- data[, raw_variables, drop = FALSE]

  if (sw == 1 && is.null(variables) && is.null(lags) && is.null(transforms)) {
    return(adjust_ts_data_mv(
      data = data,
      y = y,
      x = x,
      sw = 1,
      representation = "aligned"
    ))
  }

  selected_variables <- variables
  if (is.null(selected_variables)) {
    selected_variables <- raw_variables
  }

  spec <- ts_mv_spec(
    model = ts_reg(),
    variables = selected_variables,
    lags = lags,
    transforms = transforms
  )
  spec <- mv_as_spec(
    spec = spec,
    default_variables = selected_variables,
    allowed_variables = raw_variables,
    window_size = sw
  )

  prepared <- mv_prepare_data_for_spec(data, spec)
  max_lag <- max(unlist(spec$lags))
  n <- nrow(prepared)
  if (n <= max_lag) {
    stop("Not enough observations to build the requested multivariate window.")
  }

  origins <- (max_lag + 1):n
  windows <- mv_build_input_matrix(prepared, spec, origins)

  adjust_ts_data_mv(
    data = windows,
    y = y,
    x = setdiff(selected_variables, y),
    sw = sw,
    variables = selected_variables,
    lags = spec$lags,
    representation = "windowed"
  )
}

#'@title Adjust `ts_data_mv`
#'@description Restore the multivariate time-series metadata after subsetting
#' or data manipulation.
#'@details
#' This helper mirrors `adjust_ts_data()` from the univariate workflow. It
#' preserves whether the multivariate object is aligned (`sw = 1`) or lagged
#' (`sw > 1`).
#'@param data Matrix or data.frame.
#'@param y Character scalar. Target variable name.
#'@param x Character vector. Auxiliary variable names.
#'@param sw Integer. Temporal width of the representation.
#'@param variables Character vector. Variables represented in the object.
#'@param lags Named list of lag positions per variable.
#'@param representation Character. Either `"aligned"` or `"windowed"`.
#'@return A `ts_data_mv` object.
#'@export
adjust_ts_data_mv <- function(data, y, x = NULL, sw = 1,
                              variables = NULL, lags = NULL,
                              representation = c("aligned", "windowed")) {
  data <- as.data.frame(data)
  representation <- match.arg(representation)

  if (is.null(variables)) {
    variables <- c(y, x)
  }
  if (is.null(x)) {
    x <- setdiff(variables, y)
  }

  if (representation == "aligned") {
    data <- data[, c(y, x), drop = FALSE]
  }

  class(data) <- append("ts_data_mv", class(data))
  attr(data, "y") <- y
  attr(data, "x") <- x
  attr(data, "variables") <- variables
  attr(data, "lags") <- lags
  attr(data, "sw") <- as.integer(sw)
  attr(data, "representation") <- representation

  data
}

#'@export
`[.ts_data_mv` <- function(x, i, j, drop = FALSE) {
  data <- as.data.frame(x)
  class(data) <- setdiff(class(data), "ts_data_mv")

  if (missing(i) && missing(j)) {
    out <- data[, , drop = FALSE]
  } else if (missing(i)) {
    out <- data[, j, drop = FALSE]
  } else if (missing(j)) {
    out <- data[i, , drop = FALSE]
  } else {
    out <- data[i, j, drop = FALSE]
  }

  representation <- attr(x, "representation")
  y <- attr(x, "y")
  xvars <- attr(x, "x")
  variables <- attr(x, "variables")

  if (representation == "aligned") {
    if (!y %in% names(out)) {
      stop("Subsetting aligned ts_data_mv must preserve the target column.")
    }
    xvars <- intersect(xvars, names(out))
    variables <- c(y, xvars)
  }

  adjust_ts_data_mv(
    out,
    y = y,
    x = xvars,
    sw = attr(x, "sw"),
    variables = variables,
    lags = attr(x, "lags"),
    representation = representation
  )
}
