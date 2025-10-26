#'@title Winsorization of Time Series
#'@description Apply Winsorization to limit extreme values by replacing them
#' with nearer order statistics, reducing the influence of outliers.
#'@return A `ts_fil_winsor` object.
#'
#'@references
#' - J. W. Tukey (1962). The future of data analysis. Annals of Mathematical
#'   Statistics. (Winsorization discussed in robust summaries.)
#'@examples
#'# Winsorization: cap extreme values to reduce outlier impact
#' # Load package and example data
#' library(daltoolbox)
#' data(tsd)
#' tsd$y[9] <- 2 * tsd$y[9]  # inject an outlier
#'
#' # Fit Winsor filter and transform series
#' filter <- ts_fil_winsor()
#' filter <- fit(filter, tsd$y)
#' y <- transform(filter, tsd$y)
#'
#' # Plot original vs Winsorized series
#' plot_ts_pred(y = tsd$y, yadj = y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_winsor <- function() {
  obj <- dal_transform()
  class(obj) <- append("ts_fil_winsor", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom DescTools Winsorize
#'@importFrom stats quantile
#'@exportS3Method transform ts_fil_winsor
transform.ts_fil_winsor <- function(obj, data, ...) {
  adjust <-DescTools::Winsorize(data)
  result <- as.vector(adjust)
  return(result)
}

