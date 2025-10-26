#'@title Time Series Projection
#'@description Split a `ts_data` (sliding windows) into input features and
#' output targets for modeling.
#'
#'@details For a multi-column `ts_data`, returns all but the last column as
#' inputs and the last column as the output. For a single-row matrix, returns
#' `ts_data`-wrapped inputs/outputs preserving names and window size.
#'
#'@param ts Matrix or data.frame containing a `ts_data` representation.
#'@return A `ts_projection` object with two elements: `$input` and `$output`.
#'@examples
#'# Setting up a ts_data and projecting (X, y)
#'data(tsd)
#'ts <- ts_data(tsd$y, 10)
#'
#'io <- ts_projection(ts)
#'
#'#input data
#'ts_head(io$input)
#'
#'#output data
#'ts_head(io$output)
#'@export
ts_projection <- function(ts) {
  input <- ts
  output <- ts

  if (is.matrix(ts) || is.data.frame(ts)) {
    if (nrow(ts) > 1) {
      input <- ts[,1:(ncol(ts)-1)]
      colnames(input) <- colnames(ts)[1:(ncol(ts)-1)]
      output <- ts[,ncol(ts)]
      colnames(output) <- colnames(ts)[ncol(ts)]
    }
    else {
      input <- ts_data(ts[,1:(ncol(ts)-1)], ncol(ts)-1)
      colnames(input) <- colnames(ts)[1:(ncol(ts)-1)]
      output <- ts_data(ts[,ncol(ts)], 1)
      colnames(output) <- colnames(ts)[ncol(ts)]
    }
  }

  proj <- list(input = input, output = output)
  attr(proj, "class") <- "ts_projection"
  return(proj)
}

