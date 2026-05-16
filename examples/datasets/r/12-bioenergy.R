source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(bioenergy)
bioenergy <- expand_dataset(bioenergy)
cat("Dataset: bioenergy\n")
cat("Series available:", length(bioenergy), "\n")
head(names(bioenergy))
head(bioenergy[[1]])

ts.plot(bioenergy[[1]], ylab = "Value", xlab = "Year", main = names(bioenergy)[1])
