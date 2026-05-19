# Tutorial 10 - Integrated Tuning

The previous tutorials changed one component at a time so that the role of each design choice would stay clear.

Now that the pieces are familiar, we can let the package search over several of them automatically.

## Goal

Use `ts_integtune()` to tune:

- input size;
- normalization strategy;
- augmentation strategy;
- MLP hyperparameters.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Load packages and the example dataset.
library(daltoolbox)
library(tspredit)
library(ggplot2)

set_example_seed(123L)
data(tsd)
```

We begin with the same windowed forecasting dataset used in the MLP tutorials.


``` r
# Create sliding windows and preserve time order in the split.
ts <- ts_data(tsd$y, 10)
samp <- ts_sample(ts, test_size = 5)

io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)
```

Before fitting the tuner, we define the search space. The goal is not to search everything possible, but to compare a small set of meaningful alternatives.


``` r
# Define the integrated search space.
tune <- ts_integtune(
  input_size = 3:5,
  base_model = ts_mlp(),
  folds = 3,
  preprocess = list(ts_norm_gminmax(), ts_norm_an()),
  augment = list(ts_aug_none(), ts_aug_jitter()),
  ranges = list(
    size = 2:4,
    decay = c(0, 0.01),
    maxit = c(500)
  )
)
```

```
## Warning: reiniciando promessa interrompida de avaliação
```

```
## Warning: internal error 1 in R_decompress1 with libdeflate
```

```
## Error:
## ! lazy-load database 'C:/R/R-4.5.0/library/tspredit/R/tspredit.rdb' is corrupt
```

Now we fit the integrated tuner on the training data. Internally, it evaluates combinations of input size, normalization, augmentation, and model hyperparameters.


``` r
# Fit the integrated tuning process.
set_example_seed()
model <- fit(tune, x = io_train$input, y = io_train$output)
```

```
## Error:
## ! objeto 'tune' não encontrado
```

After tuning, the fitted model stores the best configuration that was selected.


``` r
# Inspect the best configuration found by the tuner.
attr(model, "params")
```

```
## Error:
## ! objeto 'model' não encontrado
```

The next object records the evaluated combinations and their errors.


``` r
# Inspect the tuning table generated during the search.
head(attr(model, "hyperparameters"))
```

```
## Error:
## ! objeto 'model' não encontrado
```

Once the tuned pipeline has been selected, we forecast the held-out horizon exactly as in the earlier MLP tutorials.


``` r
# Forecast the final five-step horizon with the tuned pipeline.
prediction <- as.vector(predict(model, x = io_test$input[1:1, ], steps_ahead = 5))
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
output <- as.vector(io_test$output)

ev_test <- evaluate(model, output, prediction)
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
ev_test
```

```
## Error:
## ! objeto 'ev_test' não encontrado
```

We also inspect the in-sample adjustment, because a tuned model should still produce a coherent fit on the training data.


``` r
# Evaluate the tuned model on the training data.
adjust <- as.vector(predict(model, io_train$input))
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
ev_adjust <- evaluate(model, as.vector(io_train$output), adjust)
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
ev_adjust$metrics
```

```
## Error:
## ! objeto 'ev_adjust' não encontrado
```

The final plot connects the selected pipeline to the resulting forecast trajectory.


``` r
# Plot the tuned fit and forecast.
yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") +
  theme(text = element_text(size = 16))
```

```
## Error:
## ! objeto 'adjust' não encontrado
```

## Interpretation

Integrated tuning is useful when manual comparison becomes repetitive or too large to manage consistently.

It is best used after understanding the components individually, because then the search space becomes easier to define and interpret.

One important detail is that the current integrated tuner focuses on:

- preprocessing;
- augmentation;
- input size;
- model hyperparameters.

If you also want filtering, the filter should still be applied upstream as a separate preprocessing decision before the tuning stage.

