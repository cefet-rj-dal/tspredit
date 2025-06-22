#'@title Time Series Tune
#'@description Time Series Tune
#'@param input_size input size for machine learning model
#'@param base_model base model for tuning
#'@param folds number of folds for cross-validation
#'@param preprocess list of preprocessing methods
#'@param augment data augmentation method
#'@return a `ts_maintune` object.
#'@examples
#'library(daltoolbox)
#'data(tsd)
#'ts <- ts_data(tsd$y, 10)
#'
#'samp <- ts_sample(ts, test_size = 5)
#'io_train <- ts_projection(samp$train)
#'io_test <- ts_projection(samp$test)
#'
#'tune <- ts_maintune(input_size=c(3:5), base_model = ts_elm(), preprocess = list(ts_norm_gminmax()))
#'ranges <- list(nhid = 1:5, actfun=c('purelin'))
#'
#'# Generic model tunning
#'model <- fit(tune, x=io_train$input, y=io_train$output, ranges)
#'
#'prediction <- predict(model, x=io_test$input[1,], steps_ahead=5)
#'prediction <- as.vector(prediction)
#'output <- as.vector(io_test$output)
#'
#'ev_test <- evaluate(model, output, prediction)
#'ev_test
#'@importFrom daltoolbox dal_tune
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox select_hyper
#'@export
ts_maintune <- function(input_size, base_model, folds=10, preprocess = list(ts_norm_gminmax()), augment = list(ts_aug_none())) {
  obj <- dal_tune(base_model, folds)
  obj$input_size <- input_size
  obj$preprocess <- preprocess
  obj$augment <- augment
  obj$name <- ""
  class(obj) <- append("ts_maintune", class(obj))
  return(obj)
}


#'@importFrom daltoolbox fit
#'@importFrom daltoolbox k_fold
#'@importFrom daltoolbox evaluate
#'@importFrom daltoolbox sample_random
#'@importFrom daltoolbox train_test_from_folds
#'@exportS3Method fit ts_maintune
fit.ts_maintune <- function(obj, x, y, ranges, ...) {
  obj <- prepare_ranges(obj, ranges)
  ranges <- obj$ranges

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
#'@exportS3Method select_hyper ts_maintune
select_hyper.ts_maintune <- function(obj, hyperparameters) {
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
  error <- daltoolbox::evaluate(model, y, prediction)$mse
  return(error)
}
