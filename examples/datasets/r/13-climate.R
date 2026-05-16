source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(climate)
climate <- expand_dataset(climate)
cat("Dataset: climate\n")
cat("Series available:", length(climate), "\n")
head(names(climate))
head(climate[[1]])

ts.plot(climate[[1]], ylab = "Temperature change", xlab = "Year", main = names(climate)[1])
