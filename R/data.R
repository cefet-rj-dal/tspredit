#' Fertilizers (Regression)
#' @description List of Brazilian fertilizers consumption of N, P2O5, K2O.
#' \itemize{
#' \item brazil_n: nitrogen consumption from 1961 to 2020.
#' \item brazil_p2o5: phosphate consumption from 1961 to 2020.
#' \item brazil_k2o: potash consumption from 1961 to 2020.
#' }
#'
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
