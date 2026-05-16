source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(CATS)
CATS <- expand_dataset(CATS)
cat("Dataset: CATS\n")
cat("Rows:", nrow(CATS), "\n")
cat("Columns:", ncol(CATS), "\n")
head(CATS)

ts.plot(CATS[[1]], ylab = "Value", xlab = "Index", main = names(CATS)[1])
