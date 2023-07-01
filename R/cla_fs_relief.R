# relief
#' @title Relief
#' @description The Relief algorithm is a feature selection technique used in machine learning to determine the relevance of a feature to the target variable. It calculates the relevance of a feature by considering the difference in feature values between nearest neighbors of the same and different classes.
#' @details The relief function has the following parameters: data: the data frame containing the features and target variable; target: the name of the target variable in the data frame; nn: the number of nearest neighbors to consider (optional); sample.size: the number of samples to use in the estimation of the feature distribution (optional). The relief function returns a named numeric vector of Relief scores for each feature in the data frame.
#'
#'@param attribute The target variable.
#'@return
#'@examples
#'@export
cla_fs_relief <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_relief", class(obj))
  return(obj)
}

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
