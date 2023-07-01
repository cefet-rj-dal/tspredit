#'@title Class Balance Subsampling
#'@description The R class BalanceSubsampling represents a method to balance the class distribution of a dataset by subsampling the majority class. It can be used to reduce the representation of the majority class in the data used for modeling or analysis.
#'@details The BalanceSubsampling class has the following properties:
#'data: the subsampled data frame;
#'seed: the random seed used for reproducibility.
#'The BalanceSubsampling class has the following methods:
#'summary(): provides a summary of the subsampled dataset, including the class distribution before and after subsampling;
#'plot(): produces a plot of the class distribution before and after subsampling.
#'
#'@param attribute The attribute to be balanced through subsampling.
#'@return An instance of the BalanceSubsampling class.
#'@examples
#'@import daltoolbox
#'@export
bal_subsampling <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("bal_subsampling", class(obj))
  return(obj)
}

#'@export
transform.bal_subsampling <- function(obj, data, ...) {
  data <- data
  attribute <- obj$attribute
  x <- sort((table(data[,attribute])))
  qminor = as.integer(x[1])
  newdata = NULL
  for (i in 1:length(x)) {
    curdata = data[data[,attribute]==(names(x)[i]),]
    idx = sample(1:nrow(curdata),qminor)
    curdata = curdata[idx,]
    newdata = rbind(newdata, curdata)
  }
  data <- newdata
  return(data)
}
