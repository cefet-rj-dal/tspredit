#'@title Wavelet Filter
#'@description Wavelet Filter
#'@param filter Availables wavelet filters: haar, d4, la8, bl14, c6
#'@param dim Dimensions to be used. When dim equals 0, dim is optimized.
#'@return a `ts_fil_wavelet_bkp` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_wavelet_bkp()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_wavelet_bkp <- function(filter = "haar") {
  obj <- dal_transform()
  obj$filter <- filter
  class(obj) <- append("ts_fil_wavelet_bkp", class(obj))
  return(obj)
}


#'@importFrom daltoolbox fit
#'@importFrom daltoolbox R2.ts
#'@importFrom wavelets modwt
#'@export
fit.ts_fil_wavelet_bkp_bkp <- function(obj, data, ...) {
  sel_filter <- ""
  bestr2 <- -.Machine$double.xmax

  id <- 1:length(data)

  for (f in obj$filter) {
    wt <- wavelets::modwt(data, filter = f, boundary = "periodic")

    W <- as.data.frame(wt@W)
    W <- W[, 1, drop = FALSE]

    noise <- apply(W, 1, sum)

    r2 <- R2.ts(data, data - noise)

    if (r2 > bestr2) {
      sel_filter <- f
      bestr2 <- r2
    }
  }

  obj$filter <- sel_filter
  return(obj)
}


#'@importFrom daltoolbox transform
#'@importFrom wavelets modwt
#'@export
transform.ts_fil_wavelet_bkp <- function(obj, data, ...) {
  id <- 1:length(data)

  wt <- wavelets::modwt(data, filter = obj$filter, boundary = "periodic")

  W <- as.data.frame(wt@W)
  W <- W[, 1, drop = FALSE]
  noise <- apply(W, 1, sum)

  result <- data - noise

  return(result)
}
