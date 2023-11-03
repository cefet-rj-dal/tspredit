#'@title Subsampling
#'@description Subsampling balances the class distribution of a dataset by reducing the representation of the majority class in the dataset.
#'@param attribute The class attribute to target balancing using subsampling
#'@return A `bal_subsampling` object.
#'@examples
#'data(iris)
#'mod_iris <- iris[c(1:50,51:71,101:111),]
#'
#'bal <- bal_subsampling('Species')
#'bal <- daltoolbox::fit(bal, mod_iris)
#'adjust_iris <- daltoolbox::transform(bal, mod_iris)
#'table(adjust_iris$Species)
#'@importFrom daltoolbox dal_transform
#'@importFrom daltoolbox fit
#'@importFrom daltoolbox transform
#'@export
bal_subsampling <- function(attribute) {
  obj <- dal_transform()
  obj$attribute <- attribute
  class(obj) <- append("bal_subsampling", class(obj))
  return(obj)
}

#'@importFrom daltoolbox transform
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
