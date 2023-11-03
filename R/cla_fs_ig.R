#'@title Information Gain
#'@description Information Gain is a feature selection technique based on information theory. It measures the information obtained for the target variable by knowing the presence or absence of a feature.
#' It wraps the FSelector library.
#'@param attribute The target variable.
#'@return A `cla_fs_ig` object.
#'@examples
#'data(iris)
#'myfeature <- daltoolbox::fit(cla_fs_ig("Species"), iris)
#'data <- daltoolbox::transform(myfeature, iris)
#'head(data)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
cla_fs_ig <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_ig", class(obj))
  return(obj)
}

#'@importFrom FSelector information.gain
#'@importFrom doBy orderBy
#'@importFrom daltoolbox fit
#'@export
fit.cla_fs_ig <- function(obj, data, ...) {
  data <- data.frame(data)
  data[,obj$attribute] = as.factor(data[, obj$attribute])

  class_formula <- formula(paste(obj$attribute, "  ~ ."))
  weights <- FSelector::information.gain(class_formula, data)

  tab <- data.frame(weights)
  tab <- doBy::orderBy(~-attr_importance, data=tab)
  tab$i <- row(tab)
  tab$import_acum <- cumsum(tab$attr_importance)
  myfit <- daltoolbox::fit_curvature_min()
  res <- daltoolbox::transform(myfit, tab$import_acum)
  tab <- tab[tab$import_acum <= res$y, ]
  vec <- rownames(tab)

  obj$features <- vec

  return(obj)
}

