#'@title Filtro Hodrick-Prescott
#'@description Esse filtro elimina o componente cíclico da série, realiza uma suavização na mesma, tornando-a mais sensível a flutuações de longo prazo. Cada observação é decomposta em componente cíclico e de crescimento.
#'@param x  uma série temporal regular
#'@param type caractere, indicando o tipo de filtro, `"lambda"`, para o filtro que utiliza o parâmetro de penalidade de suavidade do filtro Hodrick-Prescott (padrão), `"frequência"`, para o filtro que utiliza um filtro Hodrick-Prescott do tipo corte de frequência.
#'@param freq Consiste um parâmetro de frequência das observações da série, possui um conjunto de valores de lambda associados de acordo com este valor. Se `type="lambda"`então `freq` é o parâmetro de suavização (lambda) do filtro Hodrick-Prescott, se `type="frequency"` então `freq` é a frequência de corte do filtro Hodrick-Prescott. conforme os exemplos abaixo. \n lambda = 100      - Anual      => frequency = 1 \n lambda = 1600     - trimestral => frequency = 4 \n lambda = 14400    - mensal     => frequency = 12 \n lambda = 270400   - semanal    => frequency = 52 \n lambda = 13322500 (diário - 7 dias por semana) => frequency = 365 \n lambda = 6812100  (diário - 5 dias por semana) => frequency = 252 \n
#'@return a `ts_fil_hp` object.
#'@examples
#'filter <- ts_fil_hp(param = param, alpha = alpha)
#'filter <- fit(filter, ts_inicial)
#'ts_final <- transform(filter, ts_inicial)
#'plot
#'plot_ts_pred(y=ts_inicial, yadj=ts_final)
#'
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

#----- 2. Aplicação do método de filtro hp -----#

# Biblioteca
#library(mFilter)

# Parâmetros (valor do lambda)
freq <- 6812100
alpha <- 0.9
# freq = valor do lambda
# Lambda = 100*(frequency)^2
# annual => frequency = 1 // lambda = 100
# quarterly => frequency = 4 // lambda = 1600
# monthly => frequency = 12 // lambda = 14400
# weekly => frequency = 52 // lambda = 270400
# daily => frequency = 365 // lambda = 13322500 (7 dias por semana)
# daily => frequency = 252 // lambda = 6812100 (5 dias por semana)

# Mètodo
#ts_final <- ts_inicial - hpfilter(ts_inicial, type = "lambda", freq = param)$trend
#head(ts_final)

#Convertendo para S3:
ts_fil_hp <- function(x, freq = NULL, type=c("lambda","frequency"), alpha = 0.9) {
  obj <- dal_transform()
  obj$x <- x
  obj$freq <- freq
  obj$type <- type
  obj$alpha <- alpha
  class(obj) <- append("ts_fil_hp", class(obj))
  return(obj)
}

transform.ts_fil_hp <- function(obj, data, ...) {
  library(mFilter)
  ts_filter <- hpfilter(obj$x, freq = obj$freq, type = obj$type)$trend
  result = as.vector(obj$alpha * obj$x + (1 - obj$alpha) * ts_filter)
  return(result)
}

# filter
filter <- ts_fil_hp(x = ts_inicial, freq = freq,  type = "lambda", alpha = alpha)
filter <- fit(filter, ts_inicial)
ts_final <- transform(filter, ts_inicial)

# plot
plot_ts_pred(y=ts_inicial, yadj=ts_final)
