#'@title Time Series Sample
#'@description Split a `ts_data` into train and test sets.
#'
#' Extracts `test_size` rows from the end (minus an optional `offset`) as the
#' test set. The remaining initial rows form the training set. The `offset`
#' is useful to reproduce experiments with different forecast origins.
#'
#'@param ts A `ts_data` matrix.
#'@param test_size Integer. Number of rows in the test split (default = 1).
#'@param offset Integer. Offset from the end before the test split (default = 0).
#'@return A list with `$train` and `$test` (both `ts_data`).
#'@examples
#'# Setting up a ts_data and making a temporal split
#'data(tsd)
#'ts <- ts_data(tsd$y, 10)
#'
#'# Separating into train and test
#'test_size <- 3
#'samp <- ts_sample(ts, test_size)
#'
#'# First five rows from training data
#'ts_head(samp$train, 5)
#'
#'# Last five rows from training data
#'ts_head(samp$train[-c(1:(nrow(samp$train)-5)),])
#'
#'# Testing data
#'ts_head(samp$test)
#'@export
ts_sample <- function(ts, test_size=1, offset=0) {
  # Compute split index counting back from the end minus optional offset
  offset <- nrow(ts) - test_size - offset
  train <- ts[1:offset, ]
  test <- ts[(offset+1):(offset+test_size),]
  # Keep column names consistent across splits
  colnames(test) <- colnames(train)
  samp <- list(train = train, test = test)
  attr(samp, "class") <- "ts_sample"
  return(samp)
}


