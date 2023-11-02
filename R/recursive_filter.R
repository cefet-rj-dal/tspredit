#'@title Filtro Recursivo
#'@description Aplica filtragem linear a uma série temporal univariada ou a cada série pertencente a uma série temporal multivariada. É útil na detecção de outliers, o cálculo é feito de modo recursivo, este cálculo possui o efeito de diminuir a autocorrelação entre as observações, de modo que a cada outlier detectado, o filtro é recalculado até que não hajam mais outliers nos resíduos. 
#'@param x uma série temporal univariada ou multivariada.
#'@param filter parâmetro de suavização. Quanto maior for o valor, maior será a suavização. Quanto menor o valor, menor será a suavização e a conformação da série resultante fica semelhante à conformação da série original.
#'@param method `convolution` ou `recursive` (pode ser abreviado).
#'       Se for `convolução`, será feito cálculo de média móvel; se for `recursive`, uma será usada uma auto-regressão.
#'
#'@return a `ts_fil_rf` object.
#'@examples
#'filter
#'
#'filter <- 0.05
#'method <- "recursive"
#'
#'filter <- ts_fil_rf(x = ts_inicial, filter = filter, method=method)
#'filter <- fit(filter, ts_inicial)
#'ts_final <- transform(filter, ts_inicial)

#plot
#'plot_ts_pred(y=ts_inicial, yadj=ts_final)
#'@export

library(tspredit)
library(daltoolbox)

#----- 1. Geração da série temporal com ruído aleatório -----#

#set.seed(123)
#ts_inicial <- rnorm(1000, mean = 0, sd = 1)
#head(ts_inicial)

data(sin_data)
ts_inicial <- sin_data$y + 2
ts_inicial[9] <- 2*ts_inicial[9]

#----- 2. Aplicação do método de filtro recursivo -----#

# Biblioteca
library(stats)

# Parâmetros (coeficientes do filtro a ser aplicado à série temporal)
filter <- 0.05
method <- "recursive"

# Mètodo
#ts_final <- filter(ts_inicial, filter = param, method = "recursive")
#head(ts_final)

#Convertendo para S3:
ts_fil_rf <- function(x, filter,  method = c("convolution", "recursive")){
  obj <- dal_transform()
  obj$filter = filter
  obj$x = x
  obj$method = method
  class(obj) <- append("ts_fil_rf",class(obj))
  return(obj)
}

transform.ts_fil_rf <- function(obj, data, ...){
  # Biblioteca
  library(stats)
  
  # Método
  ts_final <- filter(x = obj$x, filter = obj$filter, method = obj$method)
  return(ts_final)
}

#filter
filter <- ts_fil_rf(x = ts_inicial, filter = filter, method=method)
filter <- fit(filter, ts_inicial)
ts_final <- transform(filter, ts_inicial)

#plot
plot_ts_pred(y=ts_inicial, yadj=ts_final)
