source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Stock closing-price forecasting with non-deterministic auxiliaries

# Installing the package (if needed)
# install.packages("tspredit")

library(daltoolbox)
library(tspredit)

data(stocks)

if (!is.null(attr(stocks, "url"))) {
  stocks <- loadfulldata(stocks)
}

ticker_name <- if ("VALE3" %in% names(stocks)) "VALE3" else names(stocks)[1]
ticker <- stocks[[ticker_name]]
ticker <- ticker[, c("date", "open", "high", "low", "close", "volume")]
ticker <- stats::na.omit(ticker)
ticker <- subset(ticker, open > 0 & high > 0 & low > 0 & volume > 0)
cutoff_date <- max(ticker$date) - 365 * 2
ticker <- ticker[ticker$date > cutoff_date, ]

mv <- ts_data_mv(
  ticker[, c("open", "high", "low", "close", "volume")],
  y = "close",
  x = c("open", "high", "low", "volume")
)

ts_head(mv, 3)

samp <- ts_sample(mv, test_size = 5)

close_ts <- ts_data(ticker$close, 1)
close_samp <- ts_sample(close_ts, test_size = 5)

arima_baseline <- ts_arima()
arima_baseline <- fit(arima_baseline, x = close_samp$train)

pred_arima <- predict(arima_baseline, x = close_samp$test[1,], steps_ahead = 5)
pred_arima <- as.vector(pred_arima)
ev_arima <- evaluate(arima_baseline, as.vector(close_samp$test), pred_arima)
ev_arima$metrics

model <- ts_regsw_mv(
  model_y = ts_mv_spec(
    ts_rf(ts_norm_gminmax(), input_size = 4),
    variables = c("close", "open", "high", "low")
  ),
  models_x = list(
    open = ts_mv_spec(
      ts_elm(ts_norm_gminmax(), input_size = 3, nhid = 3, actfun = "purelin"),
      variables = c("open", "close", "high")
    ),
    high = ts_mv_spec(
      ts_darima(ts_norm_diff(), input_size = 3),
      variables = c("high", "close", "open")
    ),
    low = ts_mv_spec(
      ts_mlp(ts_norm_gminmax(), input_size = 3, size = 2, decay = 0.1),
      variables = c("low", "close", "open")
    ),
    volume = ts_mv_spec(
      ts_warma(input_size = 3, steps = 1),
      variables = c("volume")
    )
  ),
  window_size = 5
)

set_example_seed()
model <- fit(model, samp$train)

pred_1 <- predict(model, steps_ahead = 1)
pred_1

pred_5 <- predict(model, steps_ahead = 5)
pred_5

attr(pred_5, "system")

plot_ts_pred_mv(samp$train, samp$test, pred_5, variable = "close")

output <- tail(samp$test$close, 5)
ev_test <- evaluate(model, output, pred_5)
ev_test$metrics

rbind(
  ARIMA_close = ev_arima$metrics,
  MV_mixed = ev_test$metrics
)
