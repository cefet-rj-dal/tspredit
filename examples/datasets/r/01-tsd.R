source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
library(tspredit)
library(ggplot2)

data(tsd)
cat("Dataset: tsd\n")
cat("Rows:", nrow(tsd), "\n")
cat("Columns:", paste(names(tsd), collapse = ", "), "\n")
head(tsd)

summary(tsd)

plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))
