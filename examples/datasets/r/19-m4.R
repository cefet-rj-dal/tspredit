source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)

expand_dataset <- function(x) {
  url <- attr(x, "url")
  if (is.null(url) || !nzchar(url)) x else loadfulldata(x)
}

data(m4)
m4 <- expand_dataset(m4)
cat("Dataset: m4\n")
cat("Frequency groups:", paste(names(m4), collapse = ", "), "\n")
first_group <- names(m4)[1]
first_name <- names(m4[[first_group]])[1]
first_series <- m4[[first_group]][[first_name]]
head(first_series)

ts.plot(first_series, ylab = "Value", xlab = "Index", main = paste("m4", first_group, first_name))
