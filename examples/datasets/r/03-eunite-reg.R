source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(EUNITE.Reg)
EUNITE.Reg <- expand_dataset(EUNITE.Reg)
cat("Dataset: EUNITE.Reg\n")
cat("Rows:", nrow(EUNITE.Reg), "\n")
cat("Columns:", paste(names(EUNITE.Reg), collapse = ", "), "\n")
head(EUNITE.Reg)

summary(EUNITE.Reg)
