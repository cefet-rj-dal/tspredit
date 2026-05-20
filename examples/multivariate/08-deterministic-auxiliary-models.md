## Deterministic Auxiliary Models

About the concept
- In a target-centered multivariate workflow, not every auxiliary variable needs a generic learner.
- Some variables follow an explicit law of formation, so the correct object is a deterministic predictor rather than a statistical model.

Didactic goal: show how the `ts_deterministic()` family fits naturally inside the multivariate architecture as the pipeline for structured auxiliary variables.


``` r
source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Deterministic auxiliary models in multivariate forecasting

# Installing the package (if needed)
# install.packages("tspredit")
```


``` r
library(daltoolbox)
library(tspredit)
```

We use the same multivariate benchmark structure adopted throughout this
section:

- `y`: daily maximum load
- `x1`: weekday code
- `x2`: weekend indicator


``` r
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
```

The point here is not yet the full forecasting experiment. The point is to
decide what kind of univariate object makes sense for each auxiliary variable.

`x1` is a periodic calendar code. It is more coherent to model it with a
deterministic periodic rule than with a neural network or a random forest.


``` r
model_x1 <- ts_mv_spec(
  ts_deterministic("periodic", period = 7)
)

class(model_x1$model)
```

```
## [1] "ts_deterministic" "ts_reg"           "predictor"        "dal_learner"      "dal_base"
```

`x2` is a binary weekend flag. It also follows a periodic law of formation, so
it can use the same deterministic family.


``` r
model_x2 <- ts_mv_spec(
  ts_periodic(7)
)

class(model_x2$model)
```

```
## [1] "ts_periodic"      "ts_deterministic" "ts_reg"           "predictor"        "dal_learner"      "dal_base"
```

For slowly changing or operationally fixed auxiliary variables, persistence is
often enough.


``` r
model_persist <- ts_mv_spec(
  ts_persist()
)

class(model_persist$model)
```

```
## [1] "ts_persist"       "ts_deterministic" "ts_reg"           "predictor"        "dal_learner"      "dal_base"
```

These objects are regular multivariate specifications. They plug into the same
contract as any other auxiliary learner.


``` r
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
```

```
## [1] "ts_regsw_mv" "ts_reg"      "predictor"   "dal_learner" "dal_base"
```

We can already fit the composed object and inspect the auxiliary recursive path.


``` r
set_example_seed()
model <- fit(model, samp$train)
pred_all <- predict(model, steps_ahead = 5)
pred_all
```

```
## [1] 799.6532 793.5090 786.3970 755.8103 716.0628
## attr(,"y_name")
## [1] "y"
## attr(,"x_names")
## [1] "x1" "x2"
## attr(,"variables")
## [1] "y"  "x1" "x2"
## attr(,"steps_ahead")
## [1] 5
## attr(,"prediction_x")
## attr(,"prediction_x")$x1
## [1] 4 5 6 7 1
## 
## attr(,"prediction_x")$x2
## [1] 0 0 0 1 1
## 
## attr(,"system")
##          y x1 x2
## 1 799.6532  4  0
## 2 793.5090  5  0
## 3 786.3970  6  0
## 4 755.8103  7  1
## 5 716.0628  1  1
## attr(,"class")
## [1] "ts_mv_prediction" "numeric"
```


``` r
attr(pred_all, "system")
```

```
##          y x1 x2
## 1 799.6532  4  0
## 2 793.5090  5  0
## 3 786.3970  6  0
## 4 755.8103  7  1
## 5 716.0628  1  1
```


``` r
attr(pred_all, "prediction_x")
```

```
## $x1
## [1] 4 5 6 7 1
## 
## $x2
## [1] 0 0 0 1 1
```

What this example shows
- `ts_deterministic()` is not a separate multivariate subsystem. It is a family of univariate objects that plugs into the multivariate orchestration.
- `ts_periodic()` and `ts_persist()` remain useful wrappers when the intent should be explicit.
- Deterministic auxiliary variables should usually be modeled by their law of formation, not by generic learners.
- This choice is best taught inside the multivariate workflow, because that is where these auxiliary variables become operationally important.
