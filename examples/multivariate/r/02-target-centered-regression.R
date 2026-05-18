source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Target-centered multivariate forecasting

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
x1 <- as.numeric(EUNITE.Reg$Holiday)
x2 <- as.numeric(EUNITE.Reg$Weekday)

mv <- ts_data_mv(
  data.frame(
    y = y,
    x1 = x1,
    x2 = x2
  ),
  y = "y"
)

ts_head(mv, 3)

samp <- ts_sample(mv, test_size = 5)

model <- ts_regsw_mv(
  model_y = ts_mv_spec(
    ts_mlp(ts_norm_an(), input_size = 4, size = 4, decay = 0),
    variables = c("y", "x1", "x2"),
    transforms = list(y = ts_fil_ma(3))
  ),
  models_x = list(
    x1 = ts_mv_spec(ts_arima()),
    x2 = ts_mv_spec(
      ts_rf(ts_norm_gminmax(), input_size = 4, ntree = 20),
      variables = c("x2", "y"),
      transforms = list(y = ts_fil_ma(3))
    )
  ),
  window_size = 7
)

set_example_seed()
model <- fit(model, samp$train)

pred_1 <- predict(model, steps_ahead = 1)
pred_1

pred_5 <- predict(model, steps_ahead = 5)
pred_5

pred_all <- predict(model, steps_ahead = 5, return_all = TRUE)
pred_all

plots <- plot_ts_pred_mv(samp$train, samp$test, pred_all)

plots$y

plots$x1

plots$x2

output <- tail(samp$test$y, 5)
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics
