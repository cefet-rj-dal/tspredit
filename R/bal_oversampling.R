#'@title Class Balance Oversampling
#'@description The R class BalanceOversampling represents a method to balance the class distribution of a dataset by oversampling the minority class. It can be used to increase the representation of the minority class in the data used for modeling or analysis.
#'@details The BalanceOversampling class has the following properties:
#'data: the oversampled data frame;
#'seed: the random seed used for reproducibility.
#'The BalanceOversampling class has the following methods:
#'summary(): provides a summary of the oversampled dataset, including the class distribution before and after oversampling;
#'plot(): produces a plot of the class distribution before and after oversampling.
#'
#'@param attribute The attribute to be balanced through oversampling.
#'@return An instance of the BalanceOversampling class.
#'@examples
#'@import daltoolbox
#'@export
bal_oversampling <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("bal_oversampling", class(obj))
  return(obj)
}

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

