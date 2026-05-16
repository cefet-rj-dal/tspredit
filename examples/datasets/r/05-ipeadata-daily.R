source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(ipeadata.d)
ipeadata.d <- expand_dataset(ipeadata.d)
cat("Dataset: ipeadata.d\n")
cat("Rows:", nrow(ipeadata.d), "\n")
cat("Columns:", ncol(ipeadata.d), "\n")
head(names(ipeadata.d))
head(ipeadata.d[, 1:4])

ts.plot(ipeadata.d[[1]], ylab = "Value", xlab = "Day", main = names(ipeadata.d)[1])
