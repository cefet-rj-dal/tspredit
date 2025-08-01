% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ts_fil_emd.R
\name{ts_fil_emd}
\alias{ts_fil_emd}
\title{EMD Filter}
\usage{
ts_fil_emd(noise = 0.1, trials = 5)
}
\arguments{
\item{noise}{noise}

\item{trials}{trials}
}
\value{
a \code{ts_fil_emd} object.
}
\description{
EMD Filter
}
\examples{
# time series with noise
library(daltoolbox)
data(tsd)
tsd$y[9] <- 2*tsd$y[9]

# filter
filter <- ts_fil_emd()
filter <- fit(filter, tsd$y)
y <- transform(filter, tsd$y)

# plot
plot_ts_pred(y=tsd$y, yadj=y)
}
