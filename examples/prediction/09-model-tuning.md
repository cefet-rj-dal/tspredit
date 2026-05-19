## Model Tuning

About the technique
- Tuning searches over hyperparameters such as input size and learner-specific settings.
- In forecasting, this matters because the best model often depends as much on representation choices as on the learner family itself.

Didactic goal: show how hyperparameter search can be added without changing the rest of the `tspredit` workflow.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Installing the package (if needed)
#install.packages("tspredit")
```

We start by loading the packages used throughout this example.


``` r
# Loading the packages
library(daltoolbox)
library(tspredit) 
```


We load the example series that will be used throughout the demonstration.


``` r
# Cosine series for study

i <- seq(0, 25, 0.25)
x <- cos(i)
```

Before moving on, we visualize the series so the effect of the next transformation can be compared against the original signal.


``` r
# Plot the series

plot_ts(x=i, y=x) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-4](fig/09-model-tuning/unnamed-chunk-4-1.png)

The next step organizes the series into sliding windows, which is the tabular representation used by the later transformations and models.


``` r
# Sliding windows
# Create a matrix of windows (t9..t0) from the series for training.

sw_size <- 10
ts <- ts_data(x, sw_size)
ts_head(ts, 3)
```

```
##             t9        t8        t7        t6        t5         t4         t3         t2         t1         t0
## [1,] 1.0000000 0.9689124 0.8775826 0.7316889 0.5403023  0.3153224  0.0707372 -0.1782461 -0.4161468 -0.6281736
## [2,] 0.9689124 0.8775826 0.7316889 0.5403023 0.3153224  0.0707372 -0.1782461 -0.4161468 -0.6281736 -0.8011436
## [3,] 0.8775826 0.7316889 0.5403023 0.3153224 0.0707372 -0.1782461 -0.4161468 -0.6281736 -0.8011436 -0.9243024
```

This chunk sampling (train and test) split the data into train and test.


``` r
# Sampling (train and test)
# Split the data into train and test.

test_size <- 1
samp <- ts_sample(ts, test_size)
ts_head(samp$train, 3)
```

```
##             t9        t8        t7        t6        t5         t4         t3         t2         t1         t0
## [1,] 1.0000000 0.9689124 0.8775826 0.7316889 0.5403023  0.3153224  0.0707372 -0.1782461 -0.4161468 -0.6281736
## [2,] 0.9689124 0.8775826 0.7316889 0.5403023 0.3153224  0.0707372 -0.1782461 -0.4161468 -0.6281736 -0.8011436
## [3,] 0.8775826 0.7316889 0.5403023 0.3153224 0.0707372 -0.1782461 -0.4161468 -0.6281736 -0.8011436 -0.9243024
```

``` r
ts_head(samp$test)
```

```
##              t9        t8         t7          t6        t5       t4       t3        t2        t1        t0
## [1,] -0.7256268 -0.532833 -0.3069103 -0.06190529 0.1869486 0.424179 0.635036 0.8064095 0.9276444 0.9912028
```

This chunk hyperparameter tuning ts_tune optimizes base model hyperparameters. in this example, we use elm with ranges for nhid and activation function.


``` r
# Hyperparameter tuning
# ts_tune optimizes base model hyperparameters.
# In this example, we use ELM with ranges for nhid and activation function.

tune <- ts_tune(
  input_size = c(3:5),
  base_model = ts_elm(ts_norm_gminmax()),
  ranges = list(
    nhid = 1:10,
    actfun = c("sig", "radbas", "relu", "purelin")
  )
)
```

```
## Warning: internal error 1 in R_decompress1 with libdeflate
```

```
## Error:
## ! lazy-load database 'C:/R/R-4.5.0/library/tspredit/R/tspredit.rdb' is corrupt
```



This chunk train projection and fit the best model.


``` r
# Train projection and fit the best model

io_train <- ts_projection(samp$train)

# Generic fit of the chosen model
set_example_seed()
model <- fit(tune, x=io_train$input, y=io_train$output)
```

```
## Error:
## ! objeto 'tune' não encontrado
```

We first evaluate the in-sample fit so the model adjustment can be compared with the later forecast.


``` r
# Fit evaluation (train)

adjust <- predict(model, io_train$input)
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
ev_adjust <- evaluate(model, io_train$output, adjust)
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
print(head(ev_adjust$metrics))
```

```
## Error:
## ! objeto 'ev_adjust' não encontrado
```

We now forecast the test set and compare the predicted values with the observed ones.


``` r
# Forecast on test set

steps_ahead <- 1
io_test <- ts_projection(samp$test)
prediction <- predict(model, x=io_test$input, steps_ahead=steps_ahead)
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
prediction <- as.vector(prediction)
```

```
## Error:
## ! objeto 'prediction' não encontrado
```

``` r
output <- as.vector(io_test$output)
if (steps_ahead > 1)
    output <- output[1:steps_ahead]

print(sprintf("%.2f, %.2f", output, prediction))
```

```
## Error:
## ! objeto 'prediction' não encontrado
```

This chunk evaluates the custom component on the held-out test segment.


``` r
# Test evaluation

ev_test <- evaluate(model, output, prediction)
```

```
## Error:
## ! objeto 'model' não encontrado
```

``` r
print(head(ev_test$metrics))
```

```
## Error:
## ! objeto 'ev_test' não encontrado
```

``` r
print(sprintf("smape: %.2f", 100*ev_test$metrics$smape))
```

```
## Error:
## ! objeto 'ev_test' não encontrado
```

This final plot summarizes the result of the transformation so the effect can be interpreted visually.


``` r
# Plot results

yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y=yvalues, yadj=adjust, ypre=prediction, color_prediction=if (steps_ahead == 1) "green" else "orange") + theme(text = element_text(size=16))
```

```
## Error:
## ! objeto 'adjust' não encontrado
```

This chunk options of hyperparameter ranges by model ranges for elm.


``` r
# Options of hyperparameter ranges by model

# Ranges for ELM
ranges_elm <- list(
  nhid = 1:10,
  actfun = c("sig", "radbas", "relu", "purelin")
)

# Ranges for MLP
ranges_mlp <- list(
  size = 1:8,
  decay = c(0, 1e-4, 1e-3, 1e-2, 1e-1),
  maxit = c(500, 1000, 2000)
)

# Ranges for RF
ranges_rf <- list(
  nodesize = c(1, 3, 5),
  ntree = c(50, 100, 200),
  mtry = 1:3
)

# Ranges for SVM
ranges_svm <- list(
  kernel = c("radial", "linear", "polynomial", "sigmoid"),
  epsilon = c(0, 0.01, 0.05, 0.1, 0.2),
  cost = c(1, 5, 10, 20, 50)
)

# Ranges for LSTM
ranges_lstm <- list(hidden_size = c(4L, 8L, 16L), epochs = c(50L, 100L, 200L))

# Ranges for CNN
ranges_cnn <- list(conv_channels = c(16L, 32L, 64L), epochs = c(50L, 100L, 200L))
```

These ranges are meant as practical starting points rather than exhaustive searches:

- for `ELM`, hidden sizes up to about `10` are already enough to show the effect of model capacity in this small example;
- for `MLP`, a coarse decay grid is usually more useful than sweeping every value between `0` and `1`;
- for `RF`, very small forests tend to be unstable in recursive forecasting, so `ntree` should usually start at `50` or more;
- for `SVM`, the kernel name must be `"polynomial"` instead of `"poly"`, and it is safer to search a compact `cost`/`epsilon` grid first;
- for `LSTM` and `CNN`, short epoch grids are more realistic for tutorials than huge values like `10000`.

The random-forest `mtry` range is capped at `1:3` here because this example tunes `input_size` over `3:5`, and `mtry` must never exceed the number of lagged attributes used by the model.

References
- J. Bergstra and Y. Bengio (2012). Random search for hyper-parameter optimization. Journal of Machine Learning Research, 13, 281–305.

