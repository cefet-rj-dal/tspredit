source(url("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/examples/seed.R"))
# Filter - FFT

# Installing the package (if needed)
#install.packages("tspredit")

# Loading the packages
library(daltoolbox)
library(tspredit) 

# Series for study with high-frequency oscillatory noise
x <- seq(0, 4 * pi, length.out = 128)
signal <- sin(x)
hf_noise <- 0.25 * sin(12 * x)
y <- signal + hf_noise

# Noisy series visualization
library(ggplot2)
plot_ts(x = x, y = y) + theme(text = element_text(size=16))

# Applying the FFT filter

filter <- ts_fil_fft()
set_example_seed()
filter <- fit(filter, y)
yhat <- transform(filter, y)
plot_ts_pred(x = x, y = y, yadj = yhat) + theme(text = element_text(size=16))
