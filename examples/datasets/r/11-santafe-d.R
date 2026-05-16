source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(SantaFe.D)
SantaFe.D <- expand_dataset(SantaFe.D)
cat("Dataset: SantaFe.D\n")
cat("Rows:", nrow(SantaFe.D), "\n")
cat("Columns:", paste(names(SantaFe.D), collapse = ", "), "\n")
head(SantaFe.D)

ts.plot(SantaFe.D[[1]][1:2000], ylab = "Value", xlab = "Index", main = "SantaFe.D (first 2000)")
