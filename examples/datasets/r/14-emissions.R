source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(emissions)
emissions <- expand_dataset(emissions)
cat("Dataset: emissions\n")
cat("Series available:", length(emissions), "\n")
head(names(emissions))
head(emissions[[1]])

ts.plot(emissions[[1]], ylab = "Emissions", xlab = "Year", main = names(emissions)[1])
