source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load package and example data.
library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed(123L)
data(tsd)

# Build sliding windows and preserve time order in the split.
ts <- ts_data(tsd$y, 10)
samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)

# Fit the same MLP pipeline with a chosen normalization strategy.
run_mlp <- function(preprocess, label) {
  model <- ts_mlp(
    preprocess = preprocess,
    input_size = 4,
    size = 4,
    decay = 0,
    maxit = 1000
  )

set_example_seed()
  model <- fit(model, x = io_train$input, y = io_train$output)

  adjust <- as.vector(predict(model, io_train$input))
  prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))

  list(
    label = label,
    model = model,
    adjust = adjust,
    prediction = prediction,
    train_metrics = evaluate(model, as.vector(io_train$output), adjust)$metrics,
    test_metrics = evaluate(model, as.vector(io_test$output), prediction)$metrics
  )
}

# Train the model with global min-max normalization.
res_gminmax <- run_mlp(ts_norm_gminmax(), "global min-max")
res_gminmax$test_metrics

# Train the same model with adaptive normalization.
res_an <- run_mlp(ts_norm_an(), "adaptive normalization")
res_an$test_metrics

# Compare the test metrics for the two normalization choices.
rbind(
  cbind(model = res_gminmax$label, res_gminmax$test_metrics),
  cbind(model = res_an$label, res_an$test_metrics)
)

# Compare the two forecast trajectories against the observed horizon.
data.frame(
  step = 1:5,
  observed = as.vector(io_test$output),
  pred_gminmax = res_gminmax$prediction,
  pred_an = res_an$prediction
)

# Plot one of the compared forecasts to inspect the trajectory.
yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y = yvalues, yadj = res_an$adjust, ypre = res_an$prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
