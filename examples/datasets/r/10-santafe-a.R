source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(SantaFe.A)
SantaFe.A <- expand_dataset(SantaFe.A)
cat("Dataset: SantaFe.A\n")
cat("Rows:", nrow(SantaFe.A), "\n")
cat("Columns:", paste(names(SantaFe.A), collapse = ", "), "\n")
head(SantaFe.A)

ts.plot(SantaFe.A[[1]], ylab = "Value", xlab = "Index", main = "SantaFe.A")
