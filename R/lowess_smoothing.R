#'@title Suavização Lowess
#'@description É um método de suavização que preserva a tendência primária das observações originais e serve para remover ruídos e picos, de um modo que permite a reconstrução e suavização dos dados.
#'@param x  coordenada x do ponto no gráfico de dispersão.
#'@param y  coordenada y do ponto no gráfico de dispersão.
#'@param 
#'@param f parâmetro de suavização. Quanto maior for este valor, mais suavizada será a série.
#'         Isso fornece a proporção de pontos no gráfico que influenciam a suavização.
#'@param col.lowess cpr do gráfico
#'@param lty.lowess tipo de linha para o gráfico
#'@param ... parametros adicionais
#'@return a `ts_fil_lw` object.
#'@examples
#filter
#'filter <- ts_fil_lw(param = param)
#'filter <- fit(filter, ts_inicial)
#'ts_final <- transform(filter, ts_inicial)


library(tspredit)
library(daltoolbox)

#plot
#'plot_ts_pred(y=ts_inicial, yadj=ts_final)
#'@export
#----- 1. Geração da série temporal com ruído aleatório -----#

#set.seed(123)
#ts_inicial <- rnorm(1000, mean = 0, sd = 1)
#head(ts_inicial)

data(sin_data)
ts_inicial <- sin_data$y + 2
ts_inicial[9] <- 2*ts_inicial[9]

#----- 2. Aplicação do método de lowess smoothing -----#

# Parâmetros (intervalo de suavização)
f = 0.2

# Mètodo
#ts_final <- lowess(ts_inicial, f = param)$y
#head(ts_final)

#Convertendo para S3:
ts_fil_lw <- function(x, y=NULL, f = f){
  obj <- dal_transform()
  obj$f = f
  obj$x = x
  obj$y = y
  class(obj) <- append("ts_fil_lw",class(obj))
  return(obj)
}

transform.ts_fil_lw <- function(obj, data, ...){
  ts_final <- lowess(x=obj$x,  y = obj$y, f = obj$f)$y
  return(ts_final)
}

#filter
filter <- ts_fil_lw(x = ts_inicial, f = f)
filter <- fit(filter, ts_inicial)
ts_final <- transform(filter, ts_inicial)

#plot
plot_ts_pred(y=ts_inicial, yadj=ts_final)


