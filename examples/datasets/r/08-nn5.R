source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(NN5)
NN5 <- expand_dataset(NN5)
NN5 <- tail(NN5, 1000)
cat("Dataset: NN5\n")
cat("Rows:", nrow(NN5), "\n")
cat("Columns:", ncol(NN5), "\n")
head(names(NN5))
head(NN5[, 1:4])

ts.plot(NN5[[1]], ylab = "Withdrawals", xlab = "Day", main = names(NN5)[1])
