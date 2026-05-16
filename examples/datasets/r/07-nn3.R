source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(NN3)
NN3 <- expand_dataset(NN3)
cat("Dataset: NN3\n")
cat("Rows:", nrow(NN3), "\n")
cat("Columns:", ncol(NN3), "\n")
head(names(NN3))
head(NN3[, 1:4])

ts.plot(NN3[[1]], ylab = "Value", xlab = "Month", main = names(NN3)[1])
