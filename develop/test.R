# time series with noise
library(daltoolbox)
data(sin_data)
sin_data$y[9] <- 2*sin_data$y[9]

# filter
filter <- ts_fil_ma(3)
filter <- ts_fil_emd()
filter <- ts_fil_remd()
filter <- ts_fil_wavelet()
#filter <- ts_fil_fft()
filter <- fit(filter, sin_data$y)
y <- transform(filter, sin_data$y)

# plot
plot(plot_ts_pred(y=sin_data$y, yadj=y))
