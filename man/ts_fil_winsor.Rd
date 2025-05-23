% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ts_fil_winsor.R
\name{ts_fil_winsor}
\alias{ts_fil_winsor}
\title{Winsorization of Time Series}
\usage{
ts_fil_winsor()
}
\value{
a \code{ts_fil_winsor} obj.
}
\description{
This code implements the Winsorization technique on a time series.
Winsorization is a statistical method used to handle extreme values in a time series
by replacing them with values closer to the center of the distribution.
}
\examples{
# time series with noise
library(daltoolbox)
data(sin_data)
sin_data$y[9] <- 2*sin_data$y[9]

# filter
filter <- ts_fil_winsor()
filter <- fit(filter, sin_data$y)
y <- transform(filter, sin_data$y)

# plot
plot_ts_pred(y=sin_data$y, yadj=y)
}
