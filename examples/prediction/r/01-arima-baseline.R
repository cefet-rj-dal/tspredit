source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
#install.packages("tspredit")

# Loading the package
library(tspredit) 

# Series for study (no sliding window)

data(tsd)
ts <- ts_data(tsd$y, 1)
ts_head(ts, 3)

# Series visualization
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))

# Train-test split on the ordered series

samp <- ts_sample(ts, test_size = 5)
ts_head(samp$train, 3)
ts_head(samp$test, 3)

# Training the ARIMA model (orders selected automatically)

model <- ts_arima(p = 5, d = 0, q = 0)
set_example_seed()
model <- fit(model, x = samp$train)

# Fit evaluation (train)

adjust <- predict(model, samp$train)
adjust <- as.vector(adjust)
output <- as.vector(samp$train)
ev_adjust <- evaluate(model, output, adjust)
ev_adjust$mse

# Forecast on test set (5 steps ahead)

prediction <- predict(model, x = samp$test[1,], steps_ahead = 5)
prediction <- as.vector(prediction)
output <- as.vector(samp$test)
ev_test <- evaluate(model, output, prediction)
ev_test

# Plot comparing actual vs fit (train) and forecast (test)

yvalues <- c(samp$train, samp$test)
plot_ts_pred(y=yvalues, yadj=adjust, ypre=prediction, color_prediction="orange") + theme(text = element_text(size=16))
