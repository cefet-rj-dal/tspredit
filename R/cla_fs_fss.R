#'@title Forward Stepwise Selection
#'@description Forward stepwise selection is a technique for feature selection in which attributes are added to a model one at a time based on their ability to improve the model's performance. It stops adding once the candidate addition does not significantly improve model adjustment.
#' It wraps the leaps library.
#'@param attribute The target variable.
#'@return A `cla_fs_fss` object.
#'@examples
#'data(iris)
#'myfeature <- daltoolbox::fit(cla_fs_fss("Species"), iris)
#'data <- daltoolbox::transform(myfeature, iris)
#'head(data)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
cla_fs_fss <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_fss", class(obj))
  return(obj)
}

#'@importFrom daltoolbox fit
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


