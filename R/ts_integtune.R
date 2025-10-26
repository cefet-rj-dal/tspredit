#'@title Time Series Integrated Tune
#'@description Integrated tuning over input sizes, preprocessing, augmentation,
#' and model hyperparameters for time series.
#'
#'@param input_size Integer vector. Candidate input window sizes.
#'@param base_model Base model object for tuning.
#'@param folds Integer. Number of cross-validation folds.
#'@param ranges Named list of hyperparameter ranges to explore.
#'@param preprocess List of preprocessing objects to compare.
#'@param augment List of augmentation objects to apply during training.
#'@return A `ts_integtune` object.
#'
#'@references
#' Salles, R., Pacitti, E., Bezerra, E., Marques, C., Pacheco, C., Oliveira,
#' C., Porto, F., Ogasawara, E. (2023). TSPredIT: Integrated Tuning of Data
#' Preprocessing and Time Series Prediction Models. Lecture Notes in Computer
#' Science.
#'@examples
#' # Integrated search over input size, preprocessing and model hyperparameters
#' library(daltoolbox)
#' data(tsd)
#'
#' # Build windows and split into train/test, then project to (X, y)
#' ts <- ts_data(tsd$y, 10)
#' samp <- ts_sample(ts, test_size = 5)
#' io_train <- ts_projection(samp$train)
#' io_test <- ts_projection(samp$test)
#'
#' # Configure integrated tuning: ranges for input_size, ELM (nhid, actfun), and preprocessors
#' tune <- ts_integtune(
#'   input_size = 3:5,
#'   base_model = ts_elm(),
#'   ranges = list(nhid = 1:5, actfun = c('purelin')),
#'   preprocess = list(ts_norm_gminmax())
#' )
#'
#' # Run search; augmentation (if provided) is applied during training internally
#' model <- fit(tune, x = io_train$input, y = io_train$output)
#'
#' # Forecast and evaluate on the held-out window
#' prediction <- predict(model, x = io_test$input[1,], steps_ahead = 5)
#' prediction <- as.vector(prediction)
#' output <- as.vector(io_test$output)
#'
#' ev_test <- evaluate(model, output, prediction)
#' ev_test
#'@importFrom daltoolbox dal_tune
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox select_hyper
#'@export
ts_integtune <- function(input_size, base_model, folds=10, ranges = NULL, preprocess = list(ts_norm_gminmax()), augment = list(ts_aug_none())) {
  obj <- dal_tune(base_model, folds, ranges)
  obj$input_size <- input_size
  obj$preprocess <- preprocess
  obj$augment <- augment
  obj$name <- ""
  class(obj) <- append("ts_integtune", class(obj))
  return(obj)
}


#'@importFrom daltoolbox fit
#'@importFrom daltoolbox k_fold
#'@importFrom daltoolbox evaluate
#'@importFrom daltoolbox sample_random
#'@importFrom daltoolbox train_test_from_folds
#'@exportS3Method fit ts_integtune
fit.ts_integtune <- function(obj, x, y, ...) {
  obj <- prepare_ranges(obj, obj$ranges)
  ranges <- obj$ranges

  # Pre-fit augmentation operators on full data for reproducibility
  obj <- fit_augment(obj, x, y)

  n <- nrow(ranges)
  i <- 1
  hyperparameters <- NULL
  if (n > 1) {
    data <- data.frame(i = 1:nrow(x), idx = 1:nrow(x))
    folds <- daltoolbox::k_fold(daltoolbox::sample_random(), data, obj$folds)
    nfolds <- length(folds)
    for (j in 1:nfolds) {
      tt <- daltoolbox::train_test_from_folds(folds, j)
      error <- rep(0, n)
      msg <- rep("", n)
      for (i in 1:n) {
        err <- tryCatch(
          {
            # Build, fit, and score an integrated pipeline (preprocess + augment + model)
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
    prediction <- predict(model, x)
    error <- daltoolbox::evaluate(model, y, prediction)$mse
    hyperparameters <- cbind(ranges, error)
  }

  attr(model, "params") <- as.list(ranges[i,])
  attr(model, "hyperparameters") <- hyperparameters
  augment <- attr(model, "augment")

  return(model)
}

#'@importFrom dplyr group_by
#'@importFrom dplyr summarise
#'@importFrom daltoolbox select_hyper
#'@exportS3Method select_hyper ts_integtune
select_hyper.ts_integtune <- function(obj, hyperparameters) {
  key <- msg <- error <- ""
  hyper_summary <- hyperparameters[msg == "",] |>
    dplyr::group_by(key) |> dplyr::summarise(error = mean(error, na.rm=TRUE))

  mim_error <- hyper_summary |> dplyr::summarise(error = min(error))

  key <- which(hyper_summary$error == mim_error$error)
  i <- min(hyper_summary$key[key])
  return(i)
}


get_preprocess <- function(obj, name) {
  i <- which(obj$names_preprocess == name)
  return(obj$preprocess[[i]])
}

get_augment <- function(obj, name) {
  i <- which(obj$names_augment == name)
  return(obj$augment[[i]])
}

fit_augment <- function(obj, x, y) {
  data <- cbind(x, y)
  data <-  adjust_ts_data(data)
  for (i in 1:length(obj$augment)) {
    augment <- obj$augment[[i]]
    obj$augment[[i]] <- fit(augment, data)
  }
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom daltoolbox set_params
build_model <- function(obj, ranges, x, y) {
  augment_data <- function(augment, x, y) {
    data <- cbind(x, y)
    data <-  adjust_ts_data(data)
    data <- daltoolbox::transform(augment, data)
    data <-  adjust_ts_data(data)

    io <- ts_projection(data)

    return(list(x=io$input, y=io$output))
  }

  model <- obj$base_model
  model$input_size <- ranges$input_size
  model <- daltoolbox::set_params(model, ranges)
  model$preprocess <- get_preprocess(obj, ranges$preprocess)
  augment <- get_augment(obj, ranges$augment)
  # Augment training data before fitting model
  data <- augment_data(augment, x, y)
  model <- fit(model, data$x, data$y)
  attr(model, "augment") <- augment

  return(model)
}

prepare_ranges <- function(obj, ranges) {
  obj$names_preprocess <- sapply(obj$preprocess, function(x) { as.character(class(x)[1]) })
  obj$names_augment <- sapply(obj$augment, function(x) { as.character(class(x)[1]) })

  ranges <- append(list(input_size = obj$input_size, preprocess = obj$names_preprocess, augment = obj$names_augment), ranges)
  ranges <- expand.grid(ranges)
  ranges$preprocess <- as.character(ranges$preprocess)
  ranges$augment <- as.character(ranges$augment)
  ranges$key <- 1:nrow(ranges)

  obj$ranges <- ranges
  return(obj)
}

#'@importFrom daltoolbox evaluate
#'@importFrom stats predict
evaluate_error <- function(model, i, x, y) {
  x <- x[i,]
  y <- as.vector(y[i,])
  prediction <- as.vector(stats::predict(model, x))
  # Score MSE on held-out fold
  error <- daltoolbox::evaluate(model, y, prediction)$mse
  return(error)
}
