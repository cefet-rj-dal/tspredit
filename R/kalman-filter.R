#'@title Filtro de Kalman
#'@description O filtro de Kalman é um algoritmo de estimativa, que produz estimativas de algumas variáveis baseadas em medições imprecisas, para fornecer uma predição do estado futuro do sistema.
#'@param q variância ou matriz de covarância do ruído do processo. Esse ruído possui uma distribuição gaussiana de média zero. Ele é adicionado à equação para contabilizar incertezas ou perturbações não modeladas na evolução dos estados. Quanto maior for esse valor, maior será a incerteza no processo de transição dos estados. 
#'@param H variância ou matriz de covariância do ruído de medição. Este ruído se refere a relação entre o verdadeiro estado do sistema e as observações reais. O ruído de medição é adicionado à equação de medição para contabilizar incertezas ou erros associados às observações reais. Quanto maior for esse valor, maior é o grau de incerteza das observações.
#'@param x A série temporal a ser suavizada.
#'@return a `ts_kalman_filter` object.
#'@examples
#'filter <- ts_kalman_filter(x = ts_inicial, H = param, q = q)
#'filter <- fit(filter, ts_inicial)
#'ts_final <- transform(filter, ts_inicial)

#'plot_ts_pred(y=ts_inicial, yadj=ts_final)
#'@export

library(tspredit)
library(daltoolbox)

#----- 1. Geração da série temporal com ruído aleatório -----#
data(sin_data)
ts_inicial <- sin_data$y + 2
ts_inicial[9] <- 2*ts_inicial[9]

#----- 2. Aplicação do método de filtro de kalman -----#

# Parâmetro (parâmetro de suavização)
param = 0.01
q = 0.01

# Método
#logmodel <- SSModel(ts_inicial ~ SSMtrend(1, Q = 0.01), H = param)
#ajuste <- KFS(logmodel)
#ts_final <- exp(ajuste$att)
#head(ts_final)

#Convertendo para S3:
ts_kalman_filter <- function(x, H = param, q = q){
  obj <- dal_transform()
  obj$x = x 
  obj$H = param
  obj$Q = q
  class(obj) <- append("ts_kalman_filter",class(obj))
  return(obj)
}

transform.ts_kalman_filter <- function(obj, data, ...){
  library(KFAS)
  logmodel <- SSModel(formula = obj$x ~ SSMtrend(1, Q = obj$Q), H = obj$H)
  ajuste <- KFS(logmodel)
  ts_final <- as.vector(ajuste$att)
  return(ts_final)
}

#filter
filter <- ts_kalman_filter(x = ts_inicial, H = param, q = q)
filter <- fit(filter, ts_inicial)
ts_final <- transform(filter, ts_inicial)

#plot
plot_ts_pred(y=ts_inicial, yadj=ts_final)
