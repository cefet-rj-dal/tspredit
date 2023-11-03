#'@title Oversampling
#'@description Oversampling balances the class distribution of a dataset by increasing the representation of the minority class in the dataset.
#' It wraps the smotefamily library.
#'@param attribute The class attribute to target balancing using oversampling.
#'@return A `bal_oversampling` object.
#'@examples
#'data(iris)
#'mod_iris <- iris[c(1:50,51:71,101:111),]
#'
#'bal <- bal_oversampling('Species')
#'bal <- daltoolbox::fit(bal, mod_iris)
#'adjust_iris <- daltoolbox::transform(bal, mod_iris)
#'table(adjust_iris$Species)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
bal_oversampling <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("bal_oversampling", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
#'@importFrom smotefamily SMOTE
#'@export
transform.bal_oversampling <- function(obj, data, ...) {
  j <- match(obj$attribute, colnames(data))
  x <- sort((table(data[,obj$attribute])))
  result <- data[data[obj$attribute]==names(x)[length(x)],]

  for (i in 1:(length(x)-1)) {
    small_name <- names(x)[i]
    large_name <- names(x)[length(x)]
    small <- data[,obj$attribute]==small_name
    large <- data[,obj$attribute]==large_name
    data_smote <- data[small | large,]
    output <- data_smote[,j] == large_name
    data_smote <- data_smote[,-j]
    syn_data <- smotefamily::SMOTE(data_smote, output)
    syn_data <- syn_data$syn_data
    if (nrow(syn_data) > 0) {
      syn_data$class <- NULL
      syn_data[obj$attribute] <- data[small, j][1]
      result <- rbind(result, data[small,])
      result <- rbind(result, syn_data)
    }
  }
  return(result)
}

