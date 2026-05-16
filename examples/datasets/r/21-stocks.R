source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(stocks)
stocks <- expand_dataset(stocks)
cat("Dataset: stocks\n")
cat("Tickers available:", length(stocks), "\n")
head(names(stocks))
first_ticker <- names(stocks)[1]
first_series <- stocks[[first_ticker]]
head(first_series)

ts.plot(first_series$close, ylab = "Close", xlab = "Index", main = paste(first_ticker, "close"))
