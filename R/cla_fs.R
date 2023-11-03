#'@title Feature Selection
#'@description Feature selection is a process of selecting a subset of relevant features from a larger set of features in a dataset for use in model training. The FeatureSelection class in R provides a framework for performing feature selection.
#'@param attribute The target variable.
#'@return An instance of the FeatureSelection class.
#'@examples
#'#See ?cla_fs_fss for an example of feature selection
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
cla_fs <- function(attribute) {
  obj <- daltoolbox::dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("cla_fs", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@export
transform.cla_fs <- function(obj, data, ...) {
  data <- data[, c(obj$features, obj$attribute)]
  return(data)
}


