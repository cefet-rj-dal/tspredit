#'@title Suavização de Splines
#'@description Ajusta uma spline de suavização cúbica aos dados fornecidos.
#'
#'@param x um vetor fornecendo os valores da variável 
#'preditora ou uma lista ou matriz de duas colunas especificando x e y.
#'
#'
#'@param spar parâmetro de suavização. Quando spar é especificado, o coeficiente
#'            da integral da segunda derivada ao quadrado no critério de ajuste (log verossimilhança penalizada)
#'            é uma função monótona de spar.
#'            
#'
#'@return a `ts_fil_splines` object.
#'@examples
#filter
#'filter <- ts_fil_splines(param = param)
#'filter <- fit(filter, ts_inicial)
#'ts_final <- transform(filter, ts_inicial)

#plot
#'plot_ts_pred(y=ts_inicial, yadj=ts_final)
#'@export

#----- 1. Geração da série temporal com ruído aleatório -----#

library(tspredit)
library(daltoolbox)

data(sin_data)
ts_inicial <- sin_data$y + 2
ts_inicial[9] <- 2*ts_inicial[9]

#----- 2. Aplicação do método de smoothing splines -----#

# Biblioteca
library(forecast)

# Parâmetros (valor de suavização (smoothing parameter) que controla o grau de suavização aplicado à curva ajustada)
param <- 0.5

# Mètodo
#ts_final <- smooth.spline(ts_inicial, spar = param)$y
#head(ts_final)


#convertendo para classe S3:
ts_fil_splines <- function(x = x, spar = NULL) {
  obj <- dal_transform()
  obj$spar <- spar
  obj$x <- x
  class(obj) <- append("ts_fil_splines", class(obj))
  return(obj)
}

transform.ts_fil_splines <- function(obj, data, ...) {
  ts_final <- smooth.spline(x = obj$x, spar = obj$spar)$y
  result <- ts_final
  return(result)
}

# filter
filter <- ts_fil_splines(x = ts_inicial, spar = 0.5)
filter <- fit(filter, ts_inicial)
ts_final <- transform(filter, ts_inicial)

# plot
plot_ts_pred(y=ts_inicial, yadj=ts_final)


