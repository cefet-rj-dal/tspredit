source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Train and test splits for multivariate data

# Installing the package (if needed)
# install.packages("tspredit")

library(daltoolbox)
library(tspredit)

data(EUNITE.Loads)
data(EUNITE.Reg)

if (!is.null(attr(EUNITE.Loads, "url"))) {
  EUNITE.Loads <- loadfulldata(EUNITE.Loads)
}
if (!is.null(attr(EUNITE.Reg, "url"))) {
  EUNITE.Reg <- loadfulldata(EUNITE.Reg)
}

load_cols <- setdiff(names(EUNITE.Loads), "split")
y <- apply(EUNITE.Loads[, load_cols, drop = FALSE], 1, max)
x1 <- as.numeric(EUNITE.Reg$Weekday)
x2 <- as.numeric(EUNITE.Reg$Weekday %in% c(1, 7))

mv <- ts_data_mv(
  data.frame(y = y, x1 = x1, x2 = x2),
  y = "y"
)

windows <- ts_data_mv(mv, sw = 7)

ts_head(windows, 3)

samp <- ts_sample(windows, test_size = 10)

ts_head(samp$train, 3)
ts_head(samp$test, 3)
