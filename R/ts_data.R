#'@title ts_data
#'@description Construct a time series data object used throughout the
#' DAL Toolbox.
#'
#' Accepts either a vector (raw time series) or a matrix/data.frame already
#' organized in sliding windows. Internally, a `ts_data` is stored as a matrix
#' with `sw` lag columns named `t{lag}` (e.g., `t9, t8, ..., t0`). When `sw` is
#' zero or one, the series is stored as a single column (`t0`).
#'
#'@param y Numeric vector or matrix-like. Time series values or sliding windows.
#'@param sw Integer. Sliding-window size (number of lag columns).
#'@return A `ts_data` object (matrix with attributes and column names).
#'@examples
#'# Example: building sliding windows
#'data(tsd)
#'head(tsd)
#'
#'# 1) Single-column ts_data (no windows)
#'data <- ts_data(tsd$y)
#'ts_head(data)
#'
#'# 2) 10-lag sliding windows (t9 ... t0)
#'data10 <- ts_data(tsd$y, 10)
#'ts_head(data10)
#'@export
ts_data <- function(y, sw=1) {
  #https://stackoverflow.com/questions/7532845/matrix-losing-class-attribute-in-r
  ts_sw <- function(x, sw) {
    ts_lag <- function(x, k)
    {
      # Left-pad with NA and truncate to original length to create lag k
      c(rep(NA, k), x)[1 : length(x)]
    }
    # Build sliding windows as columns from t{sw-1} ... t0
    n <- length(x)-sw+1
    window <- NULL
    for(c in (sw-1):0){
      t  <- ts_lag(x,c)
      t <- t[sw:length(t)]
      window <- cbind(window,t,deparse.level = 0)
    }
    col <- paste("t",c((sw-1):0), sep="")
    colnames(window) <- col
    return(window)
  }

  if (sw > 1)
    y <- ts_sw(as.matrix(y), sw)
  else {
    y <- as.matrix(y)
    sw <- 1
  }

  col <- paste("t",(ncol(y)-1):0, sep="")
  colnames(y) <- col

  # Tag as ts_data and store window size `sw`
  class(y) <- append("ts_data", class(y))
  attr(y, "sw") <- sw
  return(y)
}

#'@title Subset Extraction for Time Series Data
#'@description Extracts a subset of a time series object based on specified rows and columns.
#'The function allows for flexible indexing and subsetting of time series data.
#'@param x `ts_data` object
#'@param i row i
#'@param j column j
#'@param ... optional arguments
#'@return A new `ts_data` object with preserved metadata and column names.
#'@examples
#'data(tsd)
#'data10 <- ts_data(tsd$y, 10)
#'ts_head(data10)
#'#single line
#'data10[12,]
#'
#'#range of lines
#'data10[12:13,]
#'
#'#single column
#'data10[,1]
#'
#'#range of columns
#'data10[,1:2]
#'
#'#range of rows and columns
#'data10[12:13,1:2]
#'
#'#single line and a range of columns
#'#'data10[12,1:2]
#'
#'#range of lines and a single column
#'data10[12:13,1]
#'
#'#single observation
#'data10[12,1]
#'@export
`[.ts_data` <- function(x, i, j, ...) {
  # Subset while preserving class and sliding-window metadata
  y <- unclass(x)[i, j, drop = FALSE, ...]
  class(y) <- append("ts_data", class(y))
  attr(y, "sw") <- ncol(y)
  return(y)
}

#'@title Extract the First Observations from a `ts_data` Object
#'@description Return the first n observations from a `ts_data`.
#'@param x `ts_data` object
#'@param n number of rows to return
#'@param ... optional arguments
#'@return The first n observations of a `ts_data` (as a matrix/data.frame).
#'@examples
#'data(tsd)
#'data10 <- ts_data(tsd$y, 10)
#'ts_head(data10)
#'@importFrom utils head
#'@export
ts_head <- function(x, n = 6L, ...) {
  utils::head(unclass(x), n)
}

#'@title Adjust `ts_data`
#'@description Convert a compatible dataset to a `ts_data` object by setting
#' column names, class, and the `sw` attribute consistently.
#'@param data Matrix or data.frame to adjust.
#'@return An adjusted `ts_data`.
#'@export
adjust_ts_data <- function(data) {
  if (!is.matrix(data))
    data <- as.matrix(data)
  colnames(data) <- paste("t",c((ncol(data)-1):0), sep="")
  # Ensure consistent class and `sw` attribute for downstream functions
  class(data) <- append("ts_data", class(data))
  attr(data, "sw") <- ncol(data)
  return(data)
}
