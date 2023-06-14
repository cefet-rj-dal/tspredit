i <- seq(0, 2*pi+8*pi/50, pi/50)
x <- cos(i)
noise <- rnorm(length(x), 0, sd(x)/10)

x <- x + noise
x[30] <-rnorm(1, 0, sd(x))

x[60] <-rnorm(1, 0, sd(x))

x[90] <-rnorm(1, 0, sd(x))

library(ggplot2)
ts_plot(x=i, y=x) + theme(text = element_text(size=16))

filter <- tsfil_smooth()
filter <- fit(filter, x)
y <- transform(filter, x)

ts_plot_pred(y=x, yadj=y) + theme(text = element_text(size=16))

filter <- tsfil_ma(3)
filter <- fit(filter, x)
y <- transform(filter, x)

plot(x = i, y = x, main = "cosine")
lines(x = i, y = x, col="black")
lines(x = i, y = y, col="green")

filter <- tsfil_ema(3)
filter <- fit(filter, x)
y <- transform(filter, x)

plot(x = i, y = x, main = "cosine")
lines(x = i, y = x, col="black")
lines(x = i, y = y, col="green")




#  Gráficos em séries temporais
#  Harbinger retestar
#  Repositorio DAL Extended ToolBox
#  Documentação do DAL
