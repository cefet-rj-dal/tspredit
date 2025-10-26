#'@title Time Series Tune
#'@description Create a `ts_tune` object for hyperparameter tuning of a
#' time series model.
#'
#' Sets up a cross-validated search over hyperparameter ranges and input sizes
#' for a base model. Results include the evaluated configurations and the
#' selected best configuration.
#'
#'@param input_size Integer vector. Candidate input window sizes.
#'@param base_model Base model object to tune (e.g., `ts_mlp()`).
#'@param folds Integer. Number of cross-validation folds.
#'@param ranges Named list of hyperparameter ranges to explore.
#'@return A `ts_tune` object.
#'
#'@references
#' - R. Kohavi (1995). A study of cross-validation and bootstrap for accuracy
#'   estimation and model selection. IJCAI.
#' - Salles, R., Pacitti, E., Bezerra, E., Marques, C., Pacheco, C., Oliveira,
#'   C., Porto, F., Ogasawara, E. (2023). TSPredIT: Integrated Tuning of Data
#'   Preprocessing and Time Series Prediction Models. Lecture Notes in Computer
#'   Science.
#'@examples
#'# Example: grid search over input_size and ELM hyperparameters
#' # Load library and example data
#' library(daltoolbox)
#' data(tsd)
#'
#' # Prepare 10-lag windows and split into train/test
#' ts <- ts_data(tsd$y, 10)
#' ts_head(ts, 3)
#' samp <- ts_sample(ts, test_size = 5)
#' io_train <- ts_projection(samp$train)
#' io_test <- ts_projection(samp$test)
#'
#' # Define tuning: vary input_size and ELM hyperparameters (nhid, actfun)
#' tune <- ts_tune(
#'   input_size = 3:5,
#'   base_model = ts_elm(ts_norm_gminmax()),
#'   ranges = list(nhid = 1:5, actfun = c('purelin'))
#' )
#'
#' # Run CV-based search and get the best fitted model
#' model <- fit(tune, x = io_train$input, y = io_train$output)
#'
#' # Forecast and evaluate on the held-out horizon
#' prediction <- predict(model, x = io_test$input[1,], steps_ahead = 5)
#' prediction <- as.vector(prediction)
#' output <- as.vector(io_test$output)
#'
#' ev_test <- evaluate(model, output, prediction)
#' ev_test
#'@export
ts_tune <- function(input_size, base_model, folds=10, ranges=NULL) {
  obj <- dal_tune(base_model, folds, ranges)
  obj$input_size <- input_size
  obj$name <- ""
  class(obj) <- append("ts_tune", class(obj))
  return(obj)
}

#'@importFrom stats predict
#'@export
fit.ts_tune <- function(obj, x, y, ...) {

  build_model <- function(obj, ranges, x, y) {
    model <- obj$base_model
    model$input_size <- ranges$input_size
    model <- set_params(model, ranges)
    # Fit candidate model on training split
    model <- fit(model, x, y)
    return(model)
  }

  prepare_ranges <- function(input_size, ranges) {
    ranges <- append(list(input_size = input_size), ranges)
    ranges <- expand.grid(ranges)
    ranges$key <- 1:nrow(ranges)
    return(ranges)
  }

  evaluate_error <- function(model, i, x, y) {
    # Compute MSE on held-out fold indices
    x <- x[i,]
    y <- as.vector(y[i,])
    prediction <- as.vector(stats::predict(model, x))
    error <- evaluate(model, y, prediction)$mse
    return(error)
  }


  ranges <- prepare_ranges(obj$input_size, obj$ranges)

  n <- nrow(ranges)
  i <- 1
  hyperparameters <- NULL
  if (n > 1) {
    data <- data.frame(i = 1:nrow(x), idx = 1:nrow(x))
    folds <- k_fold(sample_random(), data, obj$folds)
    nfolds <- length(folds)
    for (j in 1:nfolds) {
      tt <- train_test_from_folds(folds, j)
      error <- rep(0, n)
      msg <- rep("", n)
      for (i in 1:n) {
        err <- tryCatch(
          {
            # Fit and evaluate one configuration
            model <- build_model(obj, ranges[i,], x[tt$train$i,], y[tt$train$i,])
            error[i] <- evaluate_error(model, tt$test$i, x, y)
            ""
          },
          error = function(cond) {
            err <- sprintf("tune: %s", as.character(cond))
          }
        )
        if (err != "") {
          msg[i] <- err
        }
      }
      hyperparameters <- rbind(hyperparameters, cbind(ranges, error, msg))
    }
    hyperparameters$error[hyperparameters$msg != ""] <- NA
    i <- select_hyper(obj, hyperparameters)
  }

  model <- build_model(obj, ranges[i,], x, y)
  if (n == 1) {
    prediction <- stats::predict(model, x)
    error <- evaluate(model, y, prediction)$mse
    hyperparameters <- cbind(ranges, error)
  }

  attr(model, "params") <- as.list(ranges[i,])
  attr(model, "hyperparameters") <- hyperparameters

  return(model)
}

#'@title Select Optimal Hyperparameters for Time Series Models
#'@description Identifies the optimal hyperparameters by minimizing the error from a dataset of hyperparameters.
#' The function selects the hyperparameter configuration that results in the lowest average error.
#' It wraps the dplyr library.
#'@param obj a `ts_tune` object containing the model and tuning settings
#'@param hyperparameters hyperparameters dataset
#'@return returns the optimized key number of hyperparameters
#'@importFrom dplyr filter
#'@importFrom dplyr summarise
#'@importFrom dplyr group_by
#'@exportS3Method select_hyper ts_tune
select_hyper.ts_tune <- function(obj, hyperparameters) {
  msg <- error <- 0
  hyper_summary <- hyperparameters |> dplyr::filter(msg == "") |>
    dplyr::group_by(key) |> dplyr::summarise(error = mean(error, na.rm=TRUE))

  mim_error <- hyper_summary |> dplyr::summarise(error = min(error, na.rm=TRUE))

  key <- which(hyper_summary$error == mim_error$error)
  i <- min(hyper_summary$key[key])
  return(i)
}
