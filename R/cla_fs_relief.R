#'@title Relief
#'@description Feature selection using Relief is a technique for selecting a subset of relevant features. It calculates the relevance of a feature by considering the difference in feature values between nearest neighbors of the same and different classes.
#' It wraps the FSelector library.
#'@param attribute The target variable.
#'@return A `cla_fs_relief` object.
#'@examples
#'data(iris)
#'myfeature <- daltoolbox::fit(cla_fs_relief("Species"), iris)
#'data <- daltoolbox::transform(myfeature, iris)
#'head(data)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
cla_fs_relief <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_relief", class(obj))
  return(obj)
}

#'@importFrom daltoolbox fit
#'@importFrom FSelector relief
#'@importFrom doBy orderBy
#'@importFrom stats coef formula predict
#'@export
fit.cla_fs_relief <- function(obj, data, ...) {
  data <- data.frame(data)
  data[, obj$attribute] <- as.factor(data[, obj$attribute])

  class_formula <- stats::formula(paste(obj$attribute, "  ~ ."))
  weights <-FSelector::relief(class_formula, data)

  tab <- data.frame(weights)
  tab <- doBy::orderBy(~-attr_importance, data = tab)
  tab$i <- row(tab)
  tab$import_acum <- cumsum(tab$attr_importance)
  myfit <- daltoolbox::fit_curvature_min()
  res <- daltoolbox::transform(myfit, tab$import_acum)
  tab <- tab[tab$import_acum <= res$y, ]
  vec <- rownames(tab)

  obj$features <- vec

  return(obj)
}
