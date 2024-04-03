library(readr)
library(dplyr)
library(daltoolbox)
library(tspredit)
source("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/R/ts_fil_wavelet.R")
source("https://raw.githubusercontent.com/cefet-rj-dal/tspredit/main/R/ts_fil_wavelet_backup.R")

data <- read_delim("develop/Etanol_df.csv",
                   delim = ";",
                   escape_double = FALSE,
                   locale = locale(decimal_mark = ",",  grouping_mark = "."), trim_ws = TRUE)

ts <- data |>
  dplyr::filter(Estado_Sigla == "SP") |>
  select(Data, PROD_ETANOL_ANIDRO, PROD_ETANOL_HIDRATADO) |>
  arrange(Data) |>
  select(Data, series = PROD_ETANOL_HIDRATADO)

filter <- ts_fil_wavelet()
filter <- fit(filter, ts$series)
y <- transform(filter, ts$series)
plot(plot_ts_pred(y=ts$series, yadj=y))

filter <- ts_fil_wavelet(filter = c("haar", "d4", "la8", "bl14", "c6"))
filter <- fit(filter, ts$series)
y <- transform(filter, ts$series)
plot(plot_ts_pred(y=ts$series, yadj=y))

filter <- ts_fil_wavelet_bpk()
filter <- fit(filter, ts$series)
y <- transform(filter, ts$series)
plot(plot_ts_pred(y=ts$series, yadj=y))

filter <- ts_fil_wavelet_bpk(filter = c("haar", "d4", "la8", "bl14", "c6"))
filter <- fit(filter, ts$series)
y <- transform(filter, ts$series)
plot(plot_ts_pred(y=ts$series, yadj=y))

