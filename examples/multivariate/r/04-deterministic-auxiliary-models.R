## -----------------------------------------------------------------------------
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Deterministic auxiliary models in multivariate forecasting

# Installing the package (if needed)
# install.packages("tspredit")


## -----------------------------------------------------------------------------
library(daltoolbox)
library(tspredit)


## -----------------------------------------------------------------------------
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

samp <- ts_sample(mv, test_size = 5)


## -----------------------------------------------------------------------------
model_x1 <- ts_mv_spec(
  ts_deterministic("periodic", period = 7)
)

class(model_x1$model)


## -----------------------------------------------------------------------------
model_x2 <- ts_mv_spec(
  ts_periodic(7)
)

class(model_x2$model)


## -----------------------------------------------------------------------------
model_persist <- ts_mv_spec(
  ts_persist()
)

class(model_persist$model)


## -----------------------------------------------------------------------------
model <- ts_regsw_mv(
  model_y = ts_mv_spec(
    ts_mlp(ts_norm_an(), input_size = 4, size = 4, decay = 0),
    variables = c("y", "x1", "x2")
  ),
  models_x = list(
    x1 = model_x1,
    x2 = model_x2
  ),
  window_size = 7
)

class(model)


## -----------------------------------------------------------------------------
set_example_seed()
model <- fit(model, samp$train)
pred_all <- predict(model, steps_ahead = 5, return_all = TRUE)

pred_all$x

