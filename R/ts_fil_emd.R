#'@title EMD Filter
#'@description EMD Filter
#'@param noise noise
#'@param trials trials
#'@return a `ts_fil_emd` object.
#'@examples
#'# time series with noise
#'library(daltoolbox)
#'data(tsd)
#'tsd$y[9] <- 2*tsd$y[9]
#'
#'# filter
#'filter <- ts_fil_emd()
#'filter <- fit(filter, tsd$y)
#'y <- transform(filter, tsd$y)
#'
#'# plot
#'plot_ts_pred(y=tsd$y, yadj=y)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
ts_fil_emd <- function(noise = 0.1, trials = 5) {
  obj <- dal_transform()
  obj$noise <- noise
  obj$trials <- trials
  class(obj) <- append("ts_fil_emd", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom hht CEEMD
#'@exportS3Method transform ts_fil_emd
transform.ts_fil_emd <- function(obj, data, ...) {

  id <- 1:length(data)

  suppressWarnings(ceemd.result <- hht::CEEMD(data, id, verbose = FALSE, obj$noise, obj$trials))

  obj$model <- ceemd.result


  noise <- obj$model[["imf"]][,1]

  result <- data - noise

  return(result)
}

