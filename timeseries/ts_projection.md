Objetivo: Projetar um objeto ts_data nas componentes de entrada (X) e saída (y), separando as colunas de atributos e o alvo para modelagem.


``` r
install.packages("tspredit")

# Carregando o pacote
library(tspredit) 
```


``` r
# Série para estudo

data(tsd)
```


``` r
# Visualização da série
library(ggplot2)
plot_ts(x=tsd$x, y=tsd$y) + theme(text = element_text(size=16))
```

![plot of chunk unnamed-chunk-3](fig/ts_projection/unnamed-chunk-3-1.png)


``` r
# Janelas deslizantes

sw_size <- 5
ts <- ts_data(tsd$y, sw_size)
ts_head(ts, 3)
```

```
##             t4        t3        t2        t1        t0
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388 0.8414710
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710 0.9489846
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846 0.9974950
```


``` r
# Projeção (X, y)

io <- ts_projection(ts)
```


``` r
# Dados de entrada (X)
ts_head(io$input)
```

```
##             t4        t3        t2        t1
## [1,] 0.0000000 0.2474040 0.4794255 0.6816388
## [2,] 0.2474040 0.4794255 0.6816388 0.8414710
## [3,] 0.4794255 0.6816388 0.8414710 0.9489846
## [4,] 0.6816388 0.8414710 0.9489846 0.9974950
## [5,] 0.8414710 0.9489846 0.9974950 0.9839859
## [6,] 0.9489846 0.9974950 0.9839859 0.9092974
```


``` r
# Dados de saída (y)
ts_head(io$output)
```

```
##             t0
## [1,] 0.8414710
## [2,] 0.9489846
## [3,] 0.9974950
## [4,] 0.9839859
## [5,] 0.9092974
## [6,] 0.7780732
```

