#'@title Feature Selection
#'@description Feature selection is a process of selecting a subset of relevant features from a larger set of features in a dataset for use in model training. The FeatureSelection class in R provides a framework for performing feature selection.
#'@details The FeatureSelection class has the following properties:
#'data: the data frame containing the features and target variable;
#'target: the name of the target variable in the data frame;
#'selected: a logical vector indicating which features have been selected.
#'The FeatureSelection class has the following methods:
#'filter(method): applies a filtering method to the data to select the most relevant features;
#'wrapper(method): applies a wrapper method to the data to select the most relevant features;
#'embedded(method): applies an embedded method to the data to select the most relevant features;
#'summary(): provides a summary of the selected features.
#'@param attribute The target variable.
#'@return An instance of the FeatureSelection class.
#'@examples
#'@import daltoolbox
#'@export
feature_selection <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("feature_selection", class(obj))
  return(obj)
}

#'@export
transform.feature_selection <- function(obj, data) {
  data <- data[, c(obj$selected, obj$attribute)]
  return(data)
}


#'@title Feature Selection using Lasso regression
#'@description Feature selection using Lasso regression is a technique for selecting a subset of relevant features from a larger set of features in a dataset for use in model training. The FeatureSelectionLasso class in R provides a framework for performing feature selection using Lasso regression.
#'@details The FeatureSelectionLasso class has the following properties:
#'data: the data frame containing the features and target variable;
#'target: the name of the target variable in the data frame;
#'selected: a logical vector indicating which features have been selected;
#'lambda: the regularization parameter lambda used in Lasso regression;
#'coef: the coefficients of the Lasso regression model.
#'The FeatureSelectionLasso class has the following methods:
#'fit(): fits a Lasso regression model to the data and selects the most relevant features;
#'summary(): provides a summary of the selected features and the Lasso regression model.
#'
#'@param attribute The target variable.
#'@return An instance of the FeatureSelectionLasso class.
#'@examples
#'@export
feature_selection_lasso <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_lasso", class(obj))
  return(obj)
}


#'@import glmnet
#'@export
fit.feature_selection_lasso <- function(obj, data, ...) {
  data = data.frame(data)
  if (!is.numeric(data[,obj$attribute]))
    data[,obj$attribute] =  as.numeric(data[,obj$attribute])

  nums = unlist(lapply(data, is.numeric))
  data = data[ , nums]

  predictors_name  = setdiff(colnames(data), obj$attribute)
  predictors = as.matrix(data[,predictors_name])
  predictand = data[,obj$attribute]
  grid = 10^seq(10, -2, length = 100)
  cv.out = glmnet::cv.glmnet(predictors, predictand, alpha = 1)
  bestlam = cv.out$lambda.min
  out = glmnet::glmnet(predictors, predictand, alpha = 1, lambda = grid)
  lasso.coef = predict(out,type = "coefficients", s = bestlam)
  l = lasso.coef[(lasso.coef[,1]) != 0,0]
  vec = rownames(l)[-1]

  obj$features <- vec

  return(obj)
}

# forward stepwise selection
#'@title Forward Stepwise Selection
#'@description Forward stepwise selection is a technique for feature selection in which features are added to a model one at a time, based on their ability to improve the performance of the model. The ForwardStepwiseSelection class in R provides a framework for performing forward stepwise selection.
#'@details The ForwardStepwiseSelection class has the following properties:
#'data: the data frame containing the features and target variable;
#'target: the name of the target variable in the data frame;
#'selected: a logical vector indicating which features have been selected;
#'model: the model object containing the selected features;
#'performance: the performance metric of the selected model.
#'The ForwardStepwiseSelection class has the following methods:
#'fit(): fits a model using forward stepwise selection and selects the most relevant features;
#'summary(): provides a summary of the selected features and the model.
#'
#'@param attribute The target variable.
#'@return An instance of the ForwardStepwiseSelection class.
#'@examples
#'@export
feature_selection_fss <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_fss", class(obj))
  return(obj)
}

#'@export
fit.feature_selection_fss <- function(obj, data, ...) {
  data = data.frame(data)
  if (!is.numeric(data[, obj$attribute]))
    data[, obj$attribute] = as.numeric(data[, obj$attribute])

  nums = unlist(lapply(data, is.numeric))
  data = data[, nums]

  predictors_name = setdiff(colnames(data), obj$attribute)
  predictors = as.matrix(data[, predictors_name])
  predictand = data[, obj$attribute]

  regfit.fwd = regsubsets(predictors, predictand, nvmax = ncol(data) - 1, method = "forward")
  reg.summaryfwd = summary(regfit.fwd)
  b1 = which.max(reg.summaryfwd$adjr2)
  t = coef(regfit.fwd, b1)
  vec = names(t)[-1]

  obj$features <- vec

  return(obj)
}


# information gain
#'@title Information Gain
#'@description Information Gain is a feature selection technique used in machine learning to determine the relevance of a feature to the target variable. It measures the amount of information obtained for the target variable by knowing the presence or absence of a feature.
#'@details The InformationGain function has the following parameters: data: the data frame containing the features and target variable; target: the name of the target variable in the data frame; threshold: a threshold value for selecting features (optional). The InformationGain function returns a named numeric vector of Information Gain scores for each feature in the data frame.
#'
#'@param attribute
#'@return
#'@examples
#'@export
feature_selection_ig <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_ig", class(obj))
  return(obj)
}

#'@export
fit.feature_selection_ig <- function(obj, data, ...) {
  data <- data.frame(data)
  data[,obj$attribute] = as.factor(data[, obj$attribute])

  class_formula <- formula(paste(obj$attribute, "  ~ ."))
  weights <- information.gain(class_formula, data)

  tab <- data.frame(weights)
  tab <- orderBy(~-attr_importance, data=tab)
  tab$i <- row(tab)
  tab$import_acum <- cumsum(tab$attr_importance)
  myfit <- fit_curvature_min()
  res <- transform(myfit, tab$import_acum)
  tab <- tab[tab$import_acum <= res$y, ]
  vec <- rownames(tab)

  obj$features <- vec

  return(obj)
}

# relief
#' @title Relief
#' @description The Relief algorithm is a feature selection technique used in machine learning to determine the relevance of a feature to the target variable. It calculates the relevance of a feature by considering the difference in feature values between nearest neighbors of the same and different classes.
#' @details The relief function has the following parameters: data: the data frame containing the features and target variable; target: the name of the target variable in the data frame; nn: the number of nearest neighbors to consider (optional); sample.size: the number of samples to use in the estimation of the feature distribution (optional). The relief function returns a named numeric vector of Relief scores for each feature in the data frame.
#'
#'@param attribute
#'@return
#'@examples
#'@export
feature_selection_relief <- function(attribute) {
  obj <- feature_selection(attribute)
  class(obj) <- append("feature_selection_relief", class(obj))
  return(obj)
}

#' @export
fit.feature_selection_relief <- function(obj, data, ...) {
  data <- data.frame(data)
  data[, obj$attribute] <- as.factor(data[, obj$attribute])

  class_formula <- formula(paste(obj$attribute, "  ~ ."))
  weights <- relief(class_formula, data)

  tab <- data.frame(weights)
  tab <- orderBy(~-attr_importance, data = tab)
  tab$i <- row(tab)
  tab$import_acum <- cumsum(tab$attr_importance)
  myfit <- fit_curvature_min()
  res <- transform(myfit, tab$import_acum)
  tab <- tab[tab$import_acum <= res$y, ]
  vec <- rownames(tab)

  obj$features <- vec

  return(obj)
}
