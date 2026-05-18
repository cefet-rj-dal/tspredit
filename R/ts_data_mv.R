#'@title Multivariate Time Series Data
#'@description Construct a multivariate time-series object that preserves
#' aligned observations across the target series and its auxiliary variables.
#'
#'@details
#' `ts_data_mv()` is the entry point for the new multivariate workflow.
#' Conceptually, it plays the same role as `ts_data()` in the univariate path,
#' but instead of immediately materializing a sliding-window matrix, it first
#' preserves the synchronized raw observations of every variable involved in the
#' forecasting system.
#'
#' The resulting object stores:
#' - the target variable name (`attr(x, "y")`)
#' - the auxiliary variable names (`attr(x, "x")`)
#' - the ordered set of variables used by the multivariate workflow
#'
#' This representation is intentionally simple: one row per time index and one
#' column per variable. The multivariate regressor later uses these aligned
#' columns to build the expanded lagged windows required by each submodel.
#'
#' The object must remain time-aligned. Every row is interpreted as the same
#' time instant for `y` and all `x` variables.
#'
#'@param data data.frame or matrix with one column per variable and one row per
#' time index.
#'@param y Character scalar. Name of the target variable.
#'@param x Optional character vector. Names of the auxiliary variables. By
#' default, all columns except `y` are used.
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
#'@export
ts_data_mv <- function(data, y, x = NULL) {
  data <- as.data.frame(data)

  if (!is.character(y) || length(y) != 1 || !y %in% names(data)) {
    stop("y must be the name of a column in data.")
  }

  if (is.null(x)) {
    x <- setdiff(names(data), y)
  }

  if (!all(x %in% names(data))) {
    stop("All x variables must be present in data.")
  }

  if (anyDuplicated(c(y, x)) > 0) {
    stop("y and x must not contain duplicated variable names.")
  }

  numeric_cols <- vapply(data[, c(y, x), drop = FALSE], is.numeric, logical(1))
  if (!all(numeric_cols)) {
    stop("All variables in ts_data_mv must be numeric.")
  }

  data <- data[, c(y, x), drop = FALSE]
  class(data) <- append("ts_data_mv", class(data))
  attr(data, "y") <- y
  attr(data, "x") <- x
  attr(data, "variables") <- c(y, x)

  data
}

#'@title Adjust `ts_data_mv`
#'@description Restore the multivariate time-series metadata after subsetting
#' or data manipulation.
#'@details
#' This helper mirrors `adjust_ts_data()` from the univariate workflow. It is
#' mainly useful after operations that return a regular `data.frame` and need to
#' be promoted back to the aligned multivariate representation.
#'@param data Matrix or data.frame.
#'@param y Character scalar. Target variable name.
#'@param x Character vector. Auxiliary variable names.
#'@return A `ts_data_mv` object.
#'@export
adjust_ts_data_mv <- function(data, y, x = NULL) {
  data <- as.data.frame(data)

  if (is.null(x)) {
    x <- setdiff(names(data), y)
  }

  data <- data[, c(y, x), drop = FALSE]
  class(data) <- append("ts_data_mv", class(data))
  attr(data, "y") <- y
  attr(data, "x") <- x
  attr(data, "variables") <- c(y, x)

  data
}

#'@export
`[.ts_data_mv` <- function(x, i, j, drop = FALSE) {
  data <- as.data.frame(x)
  class(data) <- setdiff(class(data), "ts_data_mv")
  y <- attr(x, "y")
  xv <- attr(x, "x")

  if (missing(i) && missing(j)) {
    out <- data[, , drop = FALSE]
  } else if (missing(i)) {
    out <- data[, j, drop = FALSE]
  } else if (missing(j)) {
    out <- data[i, , drop = FALSE]
  } else {
    out <- data[i, j, drop = FALSE]
  }

  if (!y %in% names(out)) {
    stop("Subsetting ts_data_mv must preserve the target column.")
  }

  xv <- intersect(xv, names(out))
  adjust_ts_data_mv(out, y = y, x = xv)
}
