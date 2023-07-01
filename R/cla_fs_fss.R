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
cla_fs_fss <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_fss", class(obj))
  return(obj)
}

#'@importFrom stats coef
#'@export
fit.cla_fs_fss <- function(obj, data, ...) {
  data = data.frame(data)
  if (!is.numeric(data[, obj$attribute]))
    data[, obj$attribute] = as.numeric(data[, obj$attribute])

  nums = unlist(lapply(data, is.numeric))
  data = data[, nums]

  predictors_name = setdiff(colnames(data), obj$attribute)
  predictors = as.matrix(data[, predictors_name])
  predictand = data[, obj$attribute]

  regfit.fwd = leaps::regsubsets(predictors, predictand, nvmax = ncol(data) - 1, method = "forward")
  reg.summaryfwd = summary(regfit.fwd)
  b1 = which.max(reg.summaryfwd$adjr2)
  t = stats::coef(regfit.fwd, b1)
  vec = names(t)[-1]

  obj$features <- vec

  return(obj)
}


