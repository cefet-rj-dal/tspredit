#' @title Adaptive Normalization Utilities
#' @description
#' Utility object that groups helper functions used by the adaptive
#' normalization family implemented in `ts_norm_an()`.
#'
#' @details
#' These helpers separate the mathematical operators from the training flow of
#' the preprocessor itself.
#'
#' \strong{Stabilization helpers}
#'
#' - `an_stabilize_level()` avoids unstable divisive normalization when the
#'   adaptive reference is close to zero.
#' - `an_reference_scale()` blends local dispersion and local level to create
#'   a smooth transition between additive and relative normalization regimes.
#'
#' \strong{Adaptive normalization operators}
#'
#' - `an_divide()` and `an_divide_inverse()` implement divisive adaptive
#'   normalization.
#' - `an_subtract()` and `an_subtract_inverse()` implement subtractive adaptive
#'   normalization.
#' - `an_softdivide()` and `an_softdivide_inverse()` implement the stabilized
#'   hybrid operator based on a blended reference scale.
#' - `an_asinh()` and `an_asinh_inverse()` implement the inverse-hyperbolic-sine
#'   adaptive contrast around the local reference level.
#'
#' This organization makes it easier to keep `ts_norm_an()` readable and to
#' compare operators as explicit members of the same adaptive-normalization
#' family.
#'
#' @return A `tsanutils` object exposing the helper functions.
#'
#' @examples
#' utils <- tsanutils()
#'
#' center <- c(0.1, 2)
#' scale_value <- c(0.2, 0.5)
#' values <- c(0.15, 2.3)
#'
#' utils$an_divide(list(epsilon = 1e-8), values, center, scale_value)
#' utils$an_softdivide(list(lambda = 1, epsilon = 1e-8), values, center, scale_value)
#'
#' @references
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
#'
#' @importFrom daltoolbox dal_base
#' @export
tsanutils <- function() {
  obj <- dal_base()
  class(obj) <- append("tsanutils", class(obj))

  obj$an_stabilize_level <- an_stabilize_level
  obj$an_reference_scale <- an_reference_scale
  obj$an_divide <- an_divide
  obj$an_divide_inverse <- an_divide_inverse
  obj$an_subtract <- an_subtract
  obj$an_subtract_inverse <- an_subtract_inverse
  obj$an_softdivide <- an_softdivide
  obj$an_softdivide_inverse <- an_softdivide_inverse
  obj$an_asinh <- an_asinh
  obj$an_asinh_inverse <- an_asinh_inverse

  obj
}

an_stabilize_level <- function(obj, center) {
  sign_center <- sign(center)
  sign_center[sign_center == 0] <- 1
  sign_center * pmax(abs(center), obj$epsilon)
}

an_reference_scale <- function(obj, center, scale_value) {
  # Blend local dispersion and local level to transition smoothly
  # between additive and relative normalization regimes.
  sqrt(scale_value^2 + (obj$lambda * center)^2 + obj$epsilon^2)
}

an_divide <- function(obj, data, center, scale_value) {
  center <- an_stabilize_level(obj, center)
  data / center
}

an_divide_inverse <- function(obj, data, center, scale_value) {
  center <- an_stabilize_level(obj, center)
  data * center
}

an_subtract <- function(obj, data, center, scale_value) {
  data - center
}

an_subtract_inverse <- function(obj, data, center, scale_value) {
  data + center
}

an_softdivide <- function(obj, data, center, scale_value) {
  reference_scale <- an_reference_scale(obj, center, scale_value)
  (data - center) / reference_scale
}

an_softdivide_inverse <- function(obj, data, center, scale_value) {
  reference_scale <- an_reference_scale(obj, center, scale_value)
  center + data * reference_scale
}

an_asinh <- function(obj, data, center, scale_value) {
  reference_scale <- an_reference_scale(obj, center, scale_value)
  asinh(data / reference_scale) - asinh(center / reference_scale)
}

an_asinh_inverse <- function(obj, data, center, scale_value) {
  reference_scale <- an_reference_scale(obj, center, scale_value)
  reference_scale * sinh(data + asinh(center / reference_scale))
}

