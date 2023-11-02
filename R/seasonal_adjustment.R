#'@title Ajustamento Sazonal
#'@description Remove a componente sazonal da série, sem afetar os demais componentes.
#'@param y A série temporal a ser prevista ou suavizada. Pode ser `numeric`, `msts` ou `ts`. Somente séries temporais univariadas são suportadas.
#'@return a `ts_seas_adj` object.
#'@examples
#'filter <- ts_seas_adj()
#'filter <- fit(filter, ts_inicial)
#'ts_final <- transform(filter, ts_inicial)

#plot
#'plot_ts_pred(y=ts_inicial, yadj=ts_final)
#'@export
#'

# Biblioteca
library(forecast)
library(tspredit)
library(daltoolbox)

#----- 1. Geração da série temporal com ruído aleatório -----#

#Série de seno
data(sin_data)
ts_inicial <- sin_data$y + 2
ts_inicial[9] <- 2*ts_inicial[9]

#----- 2. Aplicação do método de ajustamento sazonal na forma bruta -----#


#Convertendo para S3:

#'@export
ts_seas_adj <- function(y){
  obj <- dal_transform()
  obj$y <- y
  class(obj) <- append("ts_seas_adj",class(obj))
  return(obj)
}

#'@export
transform.ts_seas_adj <- function(obj, data, ...){
  library(seasonal)
  ts_adj <- bats(obj$y)
  result <- as.vector(fitted(ts_adj))
  return(result)
}

#filter
filter <- ts_seas_adj(y = ts_inicial)
filter <- fit(filter, ts_inicial)
ts_final <- transform(filter, ts_inicial)

#plot
plot_ts_pred(y=ts_inicial, yadj=ts_final)


