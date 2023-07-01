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
cla_fs <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("cla_fs", class(obj))
  return(obj)
}

#'@export
transform.cla_fs <- function(obj, data, ...) {
  data <- data[, c(obj$selected, obj$attribute)]
  return(data)
}


