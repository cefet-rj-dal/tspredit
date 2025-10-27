Objetivo: Ajustar e avaliar um modelo ARIMA (AutoRegressive Integrated Moving Average) para previsão de séries temporais, realizando a separação treino-teste, o ajuste com seleção automática de ordens e a avaliação com métricas e visualização.


``` r
install.packages("tspredit")

# Carregando o pacote
library(tspredit) 
```


``` r
# Série para estudo (sem janela deslizante)

data(tsd)
ts <- ts_data(tsd$y, 0)
ts_head(ts, 3)
```

```
##             t0
## [1,] 0.0000000
## [2,] 0.2474040
## [3,] 0.4794255
```


``` r
# Visualização da série
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-3](fig/ts_arima/unnamed-chunk-3-1.png)


``` r
# Separação treino-teste e projeção (X, y)

samp <- ts_sample(ts, test_size = 5)
io_train <- ts_projection(samp$train)
io_test <- ts_projection(samp$test)
```


``` r
# Treinando o modelo ARIMA (ordens selecionadas automaticamente)

model <- ts_arima()
model <- fit(model, x=io_train$input, y=io_train$output)
```


``` r
# Avaliação do ajuste (treino)

adjust <- predict(model, io_train$input)
adjust <- as.vector(adjust)
output <- as.vector(io_train$output)
ev_adjust <- evaluate(model, output, adjust)
ev_adjust$mse
```

```
## [1] 0.02857686
```


``` r
# Previsão no conjunto de teste (5 passos à frente)

prediction <- predict(model, x=io_test$input[1,], steps_ahead=5)
prediction <- as.vector(prediction)
output <- as.vector(io_test$output)
ev_test <- evaluate(model, output, prediction)
ev_test
```

```
## $values
## [1]  0.41211849  0.17388949 -0.07515112 -0.31951919 -0.54402111
## 
## $prediction
## [1] 0.6011374 0.5784414 0.5566023 0.5355877 0.5153665
## 
## $smape
## [1] 1.489711
## 
## $mse
## [1] 0.4904025
## 
## $R2
## [1] -3.235632
## 
## $metrics
##         mse    smape        R2
## 1 0.4904025 1.489711 -3.235632
```


``` r
# Gráfico comparando real vs ajuste (treino) e previsão (teste)

yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y=yvalues, yadj=adjust, ypre=prediction) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-8](fig/ts_arima/unnamed-chunk-8-1.png)

