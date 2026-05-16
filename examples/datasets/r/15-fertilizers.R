source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(fertilizers)
fertilizers <- expand_dataset(fertilizers)
cat("Dataset: fertilizers\n")
cat("Series available:", length(fertilizers), "\n")
head(names(fertilizers))
head(fertilizers[[1]])

ts.plot(fertilizers[[1]], ylab = "Value", xlab = "Year", main = names(fertilizers)[1])
