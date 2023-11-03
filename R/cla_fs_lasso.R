#'@title Feature Selection using Lasso
#'@description Feature selection using Lasso regression is a technique for selecting a subset of relevant features.
#' It wraps the glmnet library.
#'@param attribute The target variable.
#'@return A `cla_fs_lasso` object.
#'@examples
#'data(iris)
#'myfeature <- daltoolbox::fit(cla_fs_lasso("Species"), iris)
#'data <- daltoolbox::transform(myfeature, iris)
#'head(data)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
cla_fs_lasso <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_lasso", class(obj))
  return(obj)
}


#'@importFrom daltoolbox fit
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

