Objetivo: Suavizar a série por meio de um modelo em espaço de estados com Filtro de Kalman, controlando ruído de observação (H) e de processo (Q).


``` r
# Filtro - Kalman

# Instalando o pacote (se necessário)
install.packages("tspredit")
```


``` r
# Carregando os pacotes
library(daltoolbox)
library(tspredit) 
```



``` r
# Série para estudo com ruído artificial e picos

data(tsd)
y <- tsd$y
noise <- rnorm(length(y), 0, sd(y)/10)
spike <- rnorm(1, 0, sd(y))
tsd$y <- tsd$y + noise
tsd$y[10] <- tsd$y[10] + spike
tsd$y[20] <- tsd$y[20] + spike
tsd$y[30] <- tsd$y[30] + spike
```


``` r
library(ggplot2)
# Visualização da série ruidosa
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-4](fig/ts_fil_kalman/unnamed-chunk-4-1.png)


``` r
# Aplicando o filtro Kalman

filter <- ts_fil_kalman(H = 0.1, Q = 1)
filter <- fit(filter, tsd$y)
y <- transform(filter, tsd$y)
plot_ts_pred(y=tsd$y, yadj=y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-5](fig/ts_fil_kalman/unnamed-chunk-5-1.png)
