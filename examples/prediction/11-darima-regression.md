## DARIMA Regression

About the method
- `ts_darima()` is a delegated-differencing ARIMA-like regressor in the `ts_regsw` lineage.
- Instead of embedding the integration order inside the model, it delegates that role to the preprocessing pipeline.

Didactic goal: show how an ARIMA-inspired learner can live naturally in the sliding-window workflow of `tspredit`.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Time Series Regression - DARIMA

# Installing the package (if needed)
#install.packages("tspredit")
```

We start by loading the packages used throughout this example.


``` r
# Loading the packages
library(daltoolbox)
library(tspredit)
```

We load the same didactic series used by the other prediction examples and
materialize lagged windows.


``` r
# Series for study (generates sliding windows t9..t0)

data(tsd)
ts <- ts_data(tsd$y, 10)
ts_head(ts, 3)
```

```
##             t9        t8        t7        t6        t5        t4        t3
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950 0.9839859 0.9092974
##             t2        t1        t0
## [1,] 0.9839859 0.9092974 0.7780732
## [2,] 0.9092974 0.7780732 0.5984721
## [3,] 0.7780732 0.5984721 0.3816610
```

Before moving on, we visualize the original series so the effect of delegated
differencing can be interpreted later in the pipeline.


``` r
# Original series visualization
library(ggplot2)
plot_ts(x = tsd$x, y = tsd$y) + theme(text = element_text(size = 16))
```

![plot of chunk unnamed-chunk-4](fig/11-darima-regression/unnamed-chunk-4-1.png)

We now preserve the time order, split the data into train and test partitions,
and project the windows into inputs and targets.


``` r
# Train-test split and projection (X, y)

samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)
```

In this model, the integration logic is delegated to preprocessing. We therefore
use `ts_norm_diff()` to express the differencing step explicitly in the
pipeline.


``` r
# Delegated differencing through preprocessing

preproc <- ts_norm_diff()
```

We now train the DARIMA model on the prepared training data.


``` r
# Training the DARIMA model

model <- ts_darima(ts_norm_diff(), input_size = 4)
set_example_seed()
model <- fit(model, x = io_train$input, y = io_train$output)
```

We first evaluate the in-sample fit so the adjustment can be compared with the
later recursive forecast.


``` r
# Fit evaluation (train)

adjust <- predict(model, io_train$input)
adjust <- as.vector(adjust)
output <- as.vector(io_train$output)
ev_adjust <- evaluate(model, output, adjust)
ev_adjust$mse
```

```
## [1] 6.636612e-32
```

We now generate a five-step forecast on the test segment and compare it with the
observed values.


``` r
# Forecast on test set (5 steps ahead)

prediction <- predict(model, x = io_test$input[1,], steps_ahead = 5)
prediction <- as.vector(prediction)
output <- as.vector(io_test$output)
ev_test <- evaluate(model, output, prediction)
ev_test
```

```
## $values
## [1]  0.41211849  0.17388949 -0.07515112 -0.31951919 -0.54402111
## 
## $prediction
## [1]  0.41211849  0.17388949 -0.07515112 -0.31951919 -0.54402111
## 
## $smape
## [1] 1.578894e-15
## 
## $mse
## [1] 1.556151e-31
## 
## $R2
## [1] 1
## 
## $metrics
##            mse        smape R2
## 1 1.556151e-31 1.578894e-15  1
```

The final plot compares the observed series, the training adjustment, and the
forecasted test horizon.


``` r
# Plot comparing actual vs fit (train) and forecast (test)

yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y = yvalues, yadj = adjust, ypre = prediction, color_prediction = "orange") + theme(text = element_text(size = 16))
```

![plot of chunk unnamed-chunk-10](fig/11-darima-regression/unnamed-chunk-10-1.png)

What this example highlights
- `ts_darima()` lives in the same sliding-window world as the machine-learning regressors.
- The differencing logic is explicit in the pipeline through `ts_norm_diff()`.
- This makes the model a natural univariate support block for target-centered multivariate forecasting.

References
- G. E. P. Box, G. M. Jenkins, G. C. Reinsel, and G. M. Ljung (2015). Time Series Analysis: Forecasting and Control. Wiley.
- R. J. Hyndman and G. Athanasopoulos (2021). Forecasting: Principles and Practice. Third Edition. OTexts. https://otexts.com/fpp3/

