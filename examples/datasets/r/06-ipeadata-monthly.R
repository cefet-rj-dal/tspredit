source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(ipeadata.m)
ipeadata.m <- expand_dataset(ipeadata.m)
cat("Dataset: ipeadata.m\n")
cat("Rows:", nrow(ipeadata.m), "\n")
cat("Columns:", ncol(ipeadata.m), "\n")
head(names(ipeadata.m))
head(ipeadata.m[, 1:4])

ts.plot(ipeadata.m[[1]], ylab = "Value", xlab = "Month", main = names(ipeadata.m)[1])
