source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(EUNITE.Temp)
EUNITE.Temp <- expand_dataset(EUNITE.Temp)
cat("Dataset: EUNITE.Temp\n")
cat("Rows:", nrow(EUNITE.Temp), "\n")
cat("Columns:", paste(names(EUNITE.Temp), collapse = ", "), "\n")
head(EUNITE.Temp)

ts.plot(EUNITE.Temp[[1]], ylab = "Temperature", xlab = "Day", main = "EUNITE temperature")
