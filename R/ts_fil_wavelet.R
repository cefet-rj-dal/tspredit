#'@title Wavelet Filter
#'@description Wavelet Filter
#'@param filter Availables wavelet filters: haar, d4, la8, bl14, c6
#'@return a `ts_fil_wavelet` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(sin_data)
#'sin_data$y[9] <- 2*sin_data$y[9]
#'
#'# filter
#'filter <- ts_fil_wavelet()
#'filter <- fit(filter, sin_data$y)
#'y <- transform(filter, sin_data$y)
#'
#'# plot
#'plot_ts_pred(y=sin_data$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_wavelet <- function(filter = "haar") {
  obj <- dal_transform()
  obj$filter <- filter
  class(obj) <- append("ts_fil_wavelet", class(obj))
  return(obj)
}

#'@importFrom daltoolbox fit
#'@importFrom daltoolbox R2.ts
#'@importFrom wavelets modwt
#'@importFrom wavelets imodwt
#'@export
fit.ts_fil_wavelet <- function(obj, data, ...) {
  if (length(obj$filter) > 1) {
    sel_filter <- ""
    bestr2 <- -.Machine$double.xmax

    id <- 1:length(data)

    for (f in obj$filter) {
      wt <- wavelets::modwt(data, filter = f, boundary = "periodic")
      wt@W[[1]] <- as.matrix(rep(0, length(wt@W[[1]])), ncol=1)
      yhatV <- wavelets::imodwt(wt)
      r2 <- R2.ts(data, yhatV)

      if (r2 > bestr2) {
        sel_filter <- f
        bestr2 <- r2
      }
    }
    obj$filter <- sel_filter
  }

  return(obj)
}


#'@importFrom daltoolbox transform
#'@importFrom wavelets modwt
#'@importFrom wavelets imodwt
#'@export
transform.ts_fil_wavelet <- function(obj, data, ...) {
  id <- 1:length(data)

  wt <- wavelets::modwt(data, filter = obj$filter, boundary = "periodic")
  wt@W[[1]] <- as.matrix(rep(0, length(wt@W[[1]])), ncol=1)
  result <- wavelets::imodwt(wt)
  return(result)
}
