# information gain
#'@title Information Gain
#'@description Information Gain is a feature selection technique used in machine learning to determine the relevance of a feature to the target variable. It measures the amount of information obtained for the target variable by knowing the presence or absence of a feature.
#'@details The InformationGain function has the following parameters: data: the data frame containing the features and target variable; target: the name of the target variable in the data frame; threshold: a threshold value for selecting features (optional). The InformationGain function returns a named numeric vector of Information Gain scores for each feature in the data frame.
#'
#'@param attribute The target variable.
#'@return
#'@examples
#'@export
cla_fs_ig <- function(attribute) {
  obj <- cla_fs(attribute)
  class(obj) <- append("cla_fs_ig", class(obj))
  return(obj)
}

#'@importFrom FSelector information.gain
#'@importFrom doBy orderBy
#'@import daltoolbox
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

