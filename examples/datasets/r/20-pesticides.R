source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(pesticides)
pesticides <- expand_dataset(pesticides)
cat("Dataset: pesticides\n")
cat("Series available:", length(pesticides), "\n")
head(names(pesticides))
head(pesticides[[1]])

ts.plot(pesticides[[1]], ylab = "Value", xlab = "Year", main = names(pesticides)[1])
