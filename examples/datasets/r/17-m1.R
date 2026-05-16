source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(m1)
m1 <- expand_dataset(m1)
cat("Dataset: m1\n")
cat("Frequency groups:", paste(names(m1), collapse = ", "), "\n")
first_group <- names(m1)[1]
first_series <- m1[[first_group]][[1]]
head(first_series)

ts.plot(first_series, ylab = "Value", xlab = "Index", main = paste("m1", first_group))
