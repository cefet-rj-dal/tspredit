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
cla_fs_lasso <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_lasso", class(obj))
  return(obj)
}


#'@importFrom glmnet cv.glmnet
#'@importFrom glmnet glmnet
#'@export
fit.cla_fs_lasso <- function(obj, data, ...) {
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

