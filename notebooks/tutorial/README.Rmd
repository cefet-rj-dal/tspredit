# Tutorials

This folder organizes a guided learning path through the most typical use cases of `tspredit`. The sequence is intentional: it begins with ARIMA forecasting protocols, then builds the MLP pipeline step by step, and closes with model comparison and integrated tuning.

## ARIMA Forecasting Protocols

- [01-arima-one-step.md](/examples/tutorial/01-arima-one-step.md) — forecast a single future observation with ARIMA.
- [02-arima-rolling-origin.md](/examples/tutorial/02-arima-rolling-origin.md) — evaluate ARIMA in rolling-origin mode, one step at a time.
- [03-arima-steps-ahead.md](/examples/tutorial/03-arima-steps-ahead.md) — produce multiple future values ahead with ARIMA.

## Building The MLP Pipeline

- [04-mlp-baseline.md](/examples/tutorial/04-mlp-baseline.md) — build the baseline MLP pipeline with sliding windows.
- [05-mlp-normalization-comparison.md](/examples/tutorial/05-mlp-normalization-comparison.md) — compare global and adaptive normalization for the same MLP.
- [06-mlp-with-filter.md](/examples/tutorial/06-mlp-with-filter.md) — apply a filter before training the MLP pipeline.
- [07-mlp-with-augmentation.md](/examples/tutorial/07-mlp-with-augmentation.md) — augment the training windows before fitting the MLP.
- [08-mlp-complete-pipeline.md](/examples/tutorial/08-mlp-complete-pipeline.md) — combine filtering, augmentation, and normalization in a single workflow.

## Comparing And Tuning Workflows

- [09-model-comparison.md](/examples/tutorial/09-model-comparison.md) — compare ARIMA and MLP under one-step, rolling-origin, and multi-step protocols.
- [10-integrated-tuning.md](/examples/tutorial/10-integrated-tuning.md) — automate the choice of input size, preprocessing, augmentation, and model hyperparameters.

If you are new to the package, start at `01` and follow the sequence. If you already know the forecasting protocols and only want to understand the machine-learning workflow, start at `04`.

## Reading The Metrics

Most tutorials report the same three evaluation metrics:

- `mse`: mean squared error, which penalizes large forecast misses more heavily.
- `smape`: symmetric mean absolute percentage error, useful for scale-aware relative comparison.
- `R2`: coefficient of determination, computed as `1 - SSE/SST`.

As a quick rule of thumb, lower `mse` and `smape` are better, while higher `R2` is better. `R2 = 1` is perfect, `R2 = 0` matches the constant-mean baseline, and `R2 < 0` means the model is worse than predicting the mean of the observed values.

