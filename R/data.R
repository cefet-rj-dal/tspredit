#' Fertilizers (Regression)
#' @description List of Brazilian fertilizers consumption of N, P2O5, K2O.
#' \itemize{
#' \item brazil_n: nitrogen consumption from 1961 to 2020.
#' \item brazil_p2o5: phosphate consumption from 1961 to 2020.
#' \item brazil_k2o: potash consumption from 1961 to 2020.
#' }
#' @docType data
#' @usage data(fertilizers)
#' @format list of fertilizers' time series.
#' @keywords datasets
#' @references International Fertilizer Association (IFA): http://www.fertilizer.org.
#' @source This dataset was obtained from the MASS library.
#' @examples
#' data(fertilizers)
#' head(fertilizers$brazil_n)
"fertilizers"

#' Time series example dataset
#' @description Synthetic dataset of sine function.
#' \itemize{
#' \item x: correspond time from 0 to 10.
#' \item y: dependent variable for time series modeling.
#' }
#' @docType data
#' @usage data(tsd)
#' @format `data.frame`.
#' @keywords datasets
#' @source This dataset was generated for examples.
#' @examples
#' data(tsd)
#' head(tsd)
"tsd"

