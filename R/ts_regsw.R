#'@title TSRegSW
#'@description Base class for time series regression models built on
#' sliding-window representations.
#'
#'@details This class provides helpers to map `ts_data` matrices into the
#' input window expected by ML backends and to apply pre/post processing
#' (e.g., normalization) consistently during fit and predict.
#'
#' The preprocessing stage runs before `input_map` is fitted. So lag selection
#' is learned on the transformed representation actually delivered to the
#' backend model, not on the raw pre-transform window. This matters for
#' preprocessors such as `ts_norm_diff()` that change the effective window
#' geometry.
#'
#'@param preprocess Normalization preprocessor (e.g., `ts_norm_gminmax()`).
#'@param input_size Integer. Number of lagged inputs per example.
#'@param input_map Lag-selection strategy object created by `ts_lagmap()`.
#'@return A `ts_regsw` object (S3) to be extended by concrete models.
#'@examples
#'# Abstract base class for sliding-window regressors
#' # Use concrete subclasses such as ts_mlp(), ts_rf(), ts_svm(), ts_elm()
#'@export
ts_regsw <- function(preprocess = NA, input_size = NA, input_map = ts_lagmap()) {
  obj <- ts_reg()
  obj$ts_as_matrix <- function(data, input_map, input_size) {
    if (length(input_map$positions) == 0) {
      input_map <- fit(input_map, data, input_size = input_size)
    }

    # Apply the learned lag mapping so every backend receives the same
    # selected attributes during fit and predict.
    data[, input_map$positions, drop = FALSE]
  }
  obj$preprocess <- preprocess
  obj$input_size <- input_size
  obj$input_map <- input_map

  class(obj) <- append("ts_regsw", class(obj))
  return(obj)
}

#'@exportS3Method fit ts_regsw
#'@inheritParams do_fit
#'@return A fitted object with learned backend model and fitted preprocessor.
#'@noRd
fit.ts_regsw <- function(obj, x, y, ...) {
  # Fit preprocessor on input windows
  obj$preprocess <- fit(obj$preprocess, x)

  # Transform inputs using fitted preprocessor before learning the lag map.
  # This keeps column selection aligned when preprocessing changes the
  # window representation, as in first-difference normalization.
  x <- transform(obj$preprocess, x)

  # Transform outputs consistently (e.g., inverse-scaling later)
  y <- transform(obj$preprocess, x, y)

  # Fit the lag mapping on the representation actually seen by the backend.
  obj$input_map <- fit(obj$input_map, x, y, input_size = obj$input_size)

  # Train the backend model using only the feature columns
  x_model <- obj$ts_as_matrix(x, obj$input_map, obj$input_size)
  obj <- do_fit(obj, x_model, y)

  return(obj)
}

#'@exportS3Method predict ts_regsw
#'@inheritParams do_predict
#'@param steps_ahead Integer. If 1, predicts per row; if > 1, performs
#' iterative forecasting starting from a single last row of `x`.
#'@return Numeric vector with predictions.
#'@noRd
predict.ts_regsw <- function(object, x, steps_ahead=1, ...) {
  if (steps_ahead == 1) {
    # One-step ahead per row
    x <- transform(object$preprocess, x)
    data <- object$ts_as_matrix(x, object$input_map, object$input_size)
    y <- do_predict(object, data)
    # Map predictions back to original scale if needed
    y <- inverse_transform(object$preprocess, x, y)
    return(as.vector(y))
  }
  else {
    if (nrow(x) > 1)
      stop("In steps ahead, x should have a single row")
    prediction <- NULL
    cnames <- colnames(x)
    x <- x[1,]
    for (i in 1:steps_ahead) {
      # Iteratively predict one step and roll the window forward
      colnames(x) <- cnames
      x <- transform(object$preprocess, x)
      y <- do_predict(object, object$ts_as_matrix(x, object$input_map, object$input_size))
      # Rebuild ts_data in original scale to manage the rolling window
      x <- adjust_ts_data(inverse_transform(object$preprocess, x))
      y <- inverse_transform(object$preprocess, x, y)
      for (j in 1:(ncol(x)-1)) {
        x[1, j] <- x[1, j+1]
      }
      x[1, ncol(x)] <- y
      prediction <- c(prediction, y)
    }
    return(as.vector(prediction))
  }
  return(prediction)
}

#'@importFrom stats predict
#'@exportS3Method do_predict ts_regsw
#'@inheritParams do_predict
#'@return Numeric vector with predictions using the backend's `predict`.
#'@noRd
do_predict.ts_regsw <- function(obj, x) {
  prediction <- stats::predict(obj$model, x)
  return(prediction)
}


