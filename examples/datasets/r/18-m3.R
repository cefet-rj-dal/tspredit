source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(m3)
m3 <- expand_dataset(m3)
cat("Dataset: m3\n")
cat("Frequency groups:", paste(names(m3), collapse = ", "), "\n")
first_group <- names(m3)[1]
first_name <- names(m3[[first_group]])[1]
first_series <- m3[[first_group]][[first_name]]
head(first_series)

ts.plot(first_series, ylab = "Value", xlab = "Index", main = paste("m3", first_group, first_name))
