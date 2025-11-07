Time series tuning: Hyperparameter optimization explores a predefined search space to identify configurations that generalize well, typically assessed via cross-validation on the training segment without leaking future information. Searching can be grid- or random-based; for many problems, random search is competitive and simpler. Here, tuning spans both the input window length and the base learner’s key parameters.

Objective: Perform hyperparameter search (window size and base model parameters) with cross-validation to improve time-series forecasting, and evaluate the result.


``` r
# Installing the package (if needed)
#install.packages("tspredit")
```


``` r
# Loading the packages
library(daltoolbox)
library(tspredit) 
```



``` r
# Cosine series for study

i <- seq(0, 25, 0.25)
x <- cos(i)
```


``` r
# Plot the series

plot_ts(x=i, y=x) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-4](fig/ts_tune/unnamed-chunk-4-1.png)


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


``` r
# Hyperparameter tuning
# ts_tune optimizes base model hyperparameters.
# In this example, we use ELM with ranges for nhid and activation function.

tune <- ts_tune(input_size=c(3:5), base_model = ts_elm(ts_norm_gminmax()), 
                ranges = list(nhid = 1:5, actfun=c('sig', 'radbas', 'tribas', 'relu', 'purelin')))
```




``` r
# Train projection and fit the best model

io_train <- ts_projection(samp$train)

# Generic fit of the chosen model
model <- fit(tune, x=io_train$input, y=io_train$output)
```


``` r
# Fit evaluation (train)

adjust <- predict(model, io_train$input)
ev_adjust <- evaluate(model, io_train$output, adjust)
print(head(ev_adjust$metrics))
```

```
##            mse        smape R2
## 1 3.235577e-30 7.125308e-15  1
```


``` r
# Forecast on test set

steps_ahead <- 1
io_test <- ts_projection(samp$test)
prediction <- predict(model, x=io_test$input, steps_ahead=steps_ahead)
prediction <- as.vector(prediction)

output <- as.vector(io_test$output)
if (steps_ahead > 1)
    output <- output[1:steps_ahead]

print(sprintf("%.2f, %.2f", output, prediction))
```

```
## [1] "0.99, 0.99"
```


``` r
# Test evaluation

ev_test <- evaluate(model, output, prediction)
print(head(ev_test$metrics))
```

```
##           mse        smape   R2
## 1 1.49144e-30 1.232084e-15 -Inf
```

``` r
print(sprintf("smape: %.2f", 100*ev_test$metrics$smape))
```

```
## [1] "smape: 0.00"
```


``` r
# Plot results

yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y=yvalues, yadj=adjust, ypre=prediction) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-12](fig/ts_tune/unnamed-chunk-12-1.png)


``` r
# Options of hyperparameter ranges by model

# Ranges for ELM
ranges_elm <- list(nhid = 1:20, actfun=c('sig', 'radbas', 'tribas', 'relu', 'purelin'))

# Ranges for MLP
ranges_mlp <- list(size = 1:10, decay = seq(0, 1, 1/9), maxit=10000)

# Ranges for RF
ranges_rf <- list(nodesize=1:10, ntree=1:10)

# Ranges for SVM
ranges_svm <- list(kernel=c("radial", "poly", "linear", "sigmoid"), epsilon=seq(0, 1, 0.1), cost=seq(20, 100, 20))

# Ranges for LSTM
ranges_lstm <- list(input_size = 1:10, epochs=10000)

# Ranges for CNN
ranges_cnn <- list(input_size = 1:10, epochs=10000)
```

References
- J. Bergstra and Y. Bengio (2012). Random search for hyper-parameter optimization. Journal of Machine Learning Research, 13, 281–305.
