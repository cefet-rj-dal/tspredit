source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(gdp)
gdp <- expand_dataset(gdp)
cat("Dataset: gdp\n")
cat("Series available:", length(gdp), "\n")
head(names(gdp))
head(gdp[[1]])

ts.plot(gdp[[1]], ylab = "Value", xlab = "Year", main = names(gdp)[1])
