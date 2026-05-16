#' Time series for forecasting examples
#' @description A synthetic univariate time series used throughout the introductory
#'   `tspredit` examples.
#' \itemize{
#' \item `x`: regular time index from 0 to 10.
#' \item `y`: smooth sine-based signal used as the forecasting target.
#' }
#' @docType data
#' @usage data(tsd)
#' @format A data frame with 100 rows and 2 columns:
#' \describe{
#'   \item{x}{Numeric time index.}
#'   \item{y}{Numeric response series used in forecasting demonstrations.}
#' }
#' @keywords datasets
#' @source Generated for package documentation and examples.
#' @details
#' `tsd` is the smallest dataset distributed with `tspredit` and acts as the
#' didactic entry point for the package. It is intentionally simple so the reader
#' can focus on the mechanics of sliding windows, train/test splitting,
#' preprocessing, and prediction workflows before moving to larger benchmark
#' collections documented in `R/tspredbench.R`, including `EUNITE.Loads`,
#' `EUNITE.Reg`, `EUNITE.Temp`, `ipeadata.d`, `ipeadata.m`, `NN3`, `NN5`,
#' `CATS`, `SantaFe.A`, `SantaFe.D`, `bioenergy`, `climate`, `emissions`,
#' `fertilizers`, `gdp`, `m1`, `m3`, `m4`, `pesticides`, and `stocks`.
#' @examples
#' # Load dataset and inspect the first rows
#' data(tsd)
#' head(tsd)
#'
#' # Plot the target series used in the examples
#' ts.plot(tsd$y, ylab = "Value", xlab = "Index", main = "Synthetic example series")
"tsd"

