#'@title Adaptive Normalization
#'@description Transform data to a common scale while adapting to changes in
#' distribution over time (optionally over a trailing window).
#'@param outliers Indicate outliers transformation class. NULL can avoid outliers removal.
#'@param nw integer: window size.
#'@param average Character. Adaptive reference statistic: `"mean"` or `"ema"`.
#'@param operation Character. Adaptive normalization operator:
#' `"divide"`, `"subtract"`, `"softdivide"`, or `"asinh"`.
#'@param scale Character. Local scale estimator used by the hybrid operators:
#' `"sd"`, `"mad"`, or `"none"`.
#'@param lambda Numeric. Weight assigned to the adaptive level term inside the
#' hybrid reference scale.
#'@param epsilon Numeric. Positive floor used to stabilize near-zero
#' denominators and local scales.
#'@return A `ts_norm_an` object.
#'
#'@details
#' `ts_norm_an()` supports a family of adaptive window-wise transformations:
#'
#' - `"divide"` rescales a window by its adaptive reference level.
#' - `"subtract"` recenters the window by subtracting the adaptive reference
#'   level.
#' - `"softdivide"` computes a stabilized relative deviation:
#'   \eqn{(x - \mu) / \sqrt{s^2 + (\lambda \mu)^2 + \epsilon^2}}.
#' - `"asinh"` applies an inverse-hyperbolic-sine contrast around the adaptive
#'   reference level using the same stabilized scale.
#'
#' The concrete operators are implemented in `tsanutils()`, while
#' `ts_norm_an()` focuses on estimating the adaptive references and applying
#' the chosen transformation consistently during fit, transform, and inverse
#' transform.
#'
#' The adaptive reference \eqn{\mu} is estimated either by a simple mean or by an
#' exponentially weighted mean (`average = "ema"`). The hybrid operators
#' additionally use a local scale estimate `s` based on either the standard
#' deviation or the MAD.
#'
#'@references
#' Ogasawara, E., Martinez, L. C., De Oliveira, D., Zimbrão, G., Pappa, G. L.,
#' Mattoso, M. (2010). Adaptive Normalization: A novel data normalization
#' approach for non-stationary time series. Proceedings of the International
#' Joint Conference on Neural Networks (IJCNN). doi:10.1109/IJCNN.2010.5596746
#'
#' Huber PJ (1964). Robust Estimation of a Location Parameter. Annals of
#' Mathematical Statistics, 35(1), 73-101. doi:10.1214/aoms/1177703732
#'
#' Burbidge JB, Magee L, Robb AL (1988). Alternative Transformations to Handle
#' Extreme Values of the Dependent Variable. Journal of the American
#' Statistical Association, 83(401), 123-127.
#'
#' Bellemare MF, Wichman CJ (2020). Elasticities and the Inverse Hyperbolic
#' Sine Transformation. Oxford Bulletin of Economics and Statistics, 82(1),
#' 50-61. doi:10.1111/obes.12325
#'@examples
#'# time series to normalize
#'library(daltoolbox)
#'library(tspredit)
#'data(tsd)
#'
#'# convert to sliding windows
#'ts <- ts_data(tsd$y, 10)
#'ts_head(ts, 3)
#'summary(ts[,10])
#'
#'# divisive adaptive normalization (default)
#'preproc <- ts_norm_an()
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'
#'# subtractive adaptive normalization
#'preproc <- ts_norm_an(operation = "subtract")
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'
#'# EMA-based soft division
#'preproc <- ts_norm_an(average = "ema", operation = "softdivide", scale = "mad")
#'preproc <- fit(preproc, ts)
#'tst <- transform(preproc, ts)
#'ts_head(tst, 3)
#'@importFrom daltoolbox outliers_boxplot
#'@export
ts_norm_an <- function(
  outliers = outliers_boxplot(),
  nw = 0,
  average = c("mean", "ema"),
  operation = c("divide", "subtract", "softdivide", "asinh"),
  scale = c("sd", "mad", "none"),
  lambda = 1,
  epsilon = 1e-8
) {
  average <- match.arg(average)
  operation <- match.arg(operation)
  scale <- match.arg(scale)
  utils <- tsanutils()

  emean <- function(data, na.rm = FALSE) {
    n <- length(data)
    weights <- rep(0, n)
    alpha <- 1 - 2.0 / (n + 1)

    for (i in 0:(n - 1)) {
      weights[n - i] <- alpha^i
    }

    sum(weights * data, na.rm = na.rm) / sum(weights, na.rm = na.rm)
  }

  subset_recent_window <- function(obj, data) {
    if (obj$nw <= 0 || obj$nw >= ncol(data)) {
      return(data)
    }

    cols <- (ncol(data) - obj$nw + 1):ncol(data)
    data[, cols, drop = FALSE]
  }

  compute_row_stat <- function(data, fun) {
    values <- apply(data, 1, fun, na.rm = TRUE)
    values[!is.finite(values)] <- 0
    values
  }

  obj <- dal_transform()
  obj$outliers <- outliers
  obj$nw <- nw
  obj$average <- average
  obj$operation <- operation
  obj$scale <- scale
  obj$lambda <- lambda
  obj$epsilon <- epsilon
  obj$utils <- utils
  obj$subset_recent_window <- subset_recent_window
  obj$compute_row_stat <- compute_row_stat
  obj$center_fun <- switch(
    average,
    mean = mean,
    ema = emean
  )
  obj$scale_fun <- switch(
    scale,
    sd = stats::sd,
    mad = stats::mad,
    none = function(data, na.rm = FALSE) 0
  )
  obj$operators <- list(
    divide = list(
      forward = utils$an_divide,
      inverse = utils$an_divide_inverse
    ),
    subtract = list(
      forward = utils$an_subtract,
      inverse = utils$an_subtract_inverse
    ),
    softdivide = list(
      forward = utils$an_softdivide,
      inverse = utils$an_softdivide_inverse
    ),
    asinh = list(
      forward = utils$an_asinh,
      inverse = utils$an_asinh_inverse
    )
  )
  class(obj) <- append("ts_norm_an", class(obj))
  obj
}

compute_adaptive_reference <- function(obj, data) {
  window_data <- obj$subset_recent_window(obj, data)
  center <- obj$compute_row_stat(window_data, obj$center_fun)
  scale_value <- obj$compute_row_stat(window_data, obj$scale_fun)

  list(center = center, scale = scale_value)
}

apply_adaptive_operation <- function(obj, data, center, scale_value) {
  obj$operators[[obj$operation]]$forward(obj, data, center, scale_value)
}

reverse_adaptive_operation <- function(obj, data, center, scale_value) {
  obj$operators[[obj$operation]]$inverse(obj, data, center, scale_value)
}

#'@exportS3Method fit ts_norm_an
fit.ts_norm_an <- function(obj, data, ...) {
  # Estimate adaptive references from the lagged inputs only, then apply
  # the same transformation to the full supervised window, including target.
  input <- data[, 1:(ncol(data) - 1), drop = FALSE]
  reference <- compute_adaptive_reference(obj, input)
  data <- apply_adaptive_operation(obj, data, reference$center, reference$scale)

  if (!is.null(obj$outliers)) {
    out <- obj$outliers
    out <- fit(out, data)
    data <- transform(out, data)
  }

  obj$gmin <- min(data)
  obj$gmax <- max(data)
  obj$grange <- if (abs(obj$gmax - obj$gmin) < obj$epsilon) 1 else obj$gmax - obj$gmin

  obj
}

#'@importFrom daltoolbox transform
#'@exportS3Method transform ts_norm_an
transform.ts_norm_an <- function(obj, data, x = NULL, ...) {
  if (!is.null(x)) {
    # Reuse the references computed for the corresponding input windows
    # when transforming aligned targets or forecasts.
    center <- attr(data, "an_center")
    scale_value <- attr(data, "an_scale")
    x <- apply_adaptive_operation(obj, x, center, scale_value)
    x <- (x - obj$gmin) / obj$grange
    return(x)
  }

  reference <- compute_adaptive_reference(obj, data)
  data <- apply_adaptive_operation(obj, data, reference$center, reference$scale)
  data <- (data - obj$gmin) / obj$grange
  attr(data, "an") <- reference$center
  attr(data, "an_center") <- reference$center
  attr(data, "an_scale") <- reference$scale
  data
}

#'@importFrom daltoolbox inverse_transform
#'@exportS3Method inverse_transform ts_norm_an
inverse_transform.ts_norm_an <- function(obj, data, x = NULL, ...) {
  center <- attr(data, "an_center")
  scale_value <- attr(data, "an_scale")

  if (!is.null(x)) {
    x <- x * obj$grange + obj$gmin
    return(reverse_adaptive_operation(obj, x, center, scale_value))
  }

  data <- data * obj$grange + obj$gmin
  data <- reverse_adaptive_operation(obj, data, center, scale_value)
  attr(data, "an") <- center
  attr(data, "an_center") <- center
  attr(data, "an_scale") <- scale_value
  data
}
