source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Materialize multivariate windows

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

windows_full <- ts_window_mv(mv, window_size = 7)
ts_head(windows_full, 3)

colnames(windows_full)

windows_selected <- ts_window_mv(
  mv,
  window_size = 7,
  lags = list(
    y = c(6, 3, 0),
    x1 = c(1, 0),
    x2 = c(6, 0)
  )
)

ts_head(windows_selected, 3)

windows_transformed <- ts_window_mv(
  mv,
  window_size = 7,
  transforms = list(y = ts_fil_ma(3))
)

ts_head(windows_transformed, 3)
