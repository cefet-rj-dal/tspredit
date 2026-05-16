source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(EUNITE.Loads)
EUNITE.Loads <- expand_dataset(EUNITE.Loads)
cat("Dataset: EUNITE.Loads\n")
cat("Rows:", nrow(EUNITE.Loads), "\n")
cat("Columns:", ncol(EUNITE.Loads), "\n")
head(names(EUNITE.Loads))
head(EUNITE.Loads[, 1:6])

ts.plot(EUNITE.Loads[[1]], ylab = "Load", xlab = "Day", main = names(EUNITE.Loads)[1])
