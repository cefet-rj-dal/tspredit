#' @name EUNITE.Loads
#' @title EUNITE Competition – Half-Hourly Electrical Loads
#' @description
#' Half-hourly electrical load time series from the EUNITE forecasting competition.
#' Data Type: Electrical load measurements. Category: Benchmark. Observations: 730 days, 48 intervals per day.
#' This dataset contains univariate time series with half-hour resolution covering 1997–1998. It was used to forecast daily maximum loads in January 1999.
#' Competitors were evaluated using MAPE and MAXIMAL prediction errors. Regressors such as temperature and calendar variables were also provided.
#' @docType data
#' @usage data(EUNITE.Loads)
#' @format A data frame with 730 rows and 48 numeric columns. Each column corresponds to one half-hour interval, from 00:00 to 24:00.
#' @keywords datasets benchmark
#' @references
#' Chen, B.-J., Chang, M.-W., & Lin, C.-J. (2004). *Load forecasting using support vector machines: a study on EUNITE competition 2001*. IEEE Transactions on Power Systems, 19(4), 1821-1830.
#' @source EUNITE Competition 2001 dataset (original competition website currently unavailable).
#' @import daltoolbox
#' @details
#' The EUNITE competition focused on forecasting maximum daily electrical loads for January 1999 using
#' half-hourly load profiles and auxiliary regressors. Series are provided in a wide format with 48
#' half-hour intervals as columns.
#'
#' @examples
#' # Load the dataset
#' data(EUNITE.Loads)
#' # EUNITE.Loads <- loadfulldata(EUNITE.Loads)
#'
#' # Inspect the first few half-hourly columns (00:00 to 24:00 by 30 minutes)
#' head(names(EUNITE.Loads))
#'
#' # Plot a single half-hour interval across days
#' ts.plot(EUNITE.Loads[["X24.00"]], ylab = "Load (MW)", xlab = "Day",
#'         main = "EUNITE: Half-hour interval 24:00")
"EUNITE.Loads"


#' @name EUNITE.Reg
#' @title EUNITE Competition – Regressors for Load Forecasting
#' @description
#' Daily holiday and weekday indicators used as regressors in the EUNITE load forecasting competition.
#' Data Type: Categorical indicators. Category: Benchmark. Observations: 730 (1997–1998).
#' This dataset provides binary holiday flags and weekday identifiers to support the prediction of daily maximum electrical loads.
#' It complements the datasets \code{\link{EUNITE.Loads}} and \code{\link{EUNITE.Temp}}.
#' A test set with corresponding regressors for January 1999 is available.
#' @docType data
#' @usage data(EUNITE.Reg)
#' @format A data frame with 730 rows and 3 columns:
#' \describe{
#'   \item{Holiday}{Binary indicator (1 = holiday, 0 = regular day).}
#'   \item{Weekday}{Integer encoding (1 = Sunday, ..., 7 = Saturday).}
#'   \item{split}{Split into train and test}
#' }
#' @keywords datasets benchmark
#' @references
#' Chen, B.-J., Chang, M.-W., & Lin, C.-J. (2004). *Load forecasting using support vector machines: a study on EUNITE competition 2001*. IEEE Transactions on Power Systems, 19(4), 1821-1830.
#' @source EUNITE Competition 2001 dataset (original competition website currently unavailable).
#' @import daltoolbox
#' @details
#' Regressors complement the load profiles by providing daily-level covariates (e.g., holidays and weekdays),
#' which are known to improve forecast accuracy when used with temperature.
#'
#' @examples
#' # Load EUNITE regressors
#' data(EUNITE.Reg)
#' # EUNITE.Reg <- loadfulldata(EUNITE.Reg)
#'
#' # Peek at the first rows
#' head(EUNITE.Reg)
"EUNITE.Reg"


#' @name EUNITE.Temp
#' @title EUNITE Competition – Average Daily Temperatures
#' @description
#' Average daily temperatures collected for the EUNITE load-forecasting competition.
#' Data Type: Meteorological measurements. Category: Benchmark. Observations: 1,461.
#' The series covers 1995-1998 and was used as an exogenous regressor for predicting maximum daily electrical loads.
#' Participants were asked to forecast January 1999 values.
#' @docType data
#' @usage data(EUNITE.Temp)
#' @format A data frame with one numeric column and 1,461 rows (average daily temperature).
#' @keywords datasets benchmark
#' @references
#' Chen, B.-J., Chang, M.-W., & Lin, C.-J. (2004). *Load forecasting using support vector machines: a study on EUNITE competition 2001*. IEEE Transactions on Power Systems, 19(4), 1821-1830.
#' @source EUNITE Competition 2001 dataset (original competition website currently unavailable).
#' @import daltoolbox
#' @details
#' Daily temperatures are commonly used as exogenous variables for load forecasting due to strong weather dependence.
#' This series aligns with the period covered by EUNITE.Loads.
#'
#' @examples
#' # Load daily temperature series
#' data(EUNITE.Temp)
#' # EUNITE.Temp <- loadfulldata(EUNITE.Temp)
#'
#' # Plot temperature over time
#' ts.plot(EUNITE.Temp$Temperature, ylab = "Temperature (°C)", xlab = "Day",
#'         main = "EUNITE: Daily Temperature")
"EUNITE.Temp"


#' @name ipeadata.d
#' @title Ipea Daily Macroeconomic Dataset
#' @description
#' Daily economic time series from Ipea (Institute for Applied Economic Research, Brazil).
#' Data Type: Macroeconomic indicators. Category: Public data. Observations: 901 to 8,154 per series, 12 series.
#' This dataset contains the most requested time series provided by Ipea with daily frequency, including exchange rates, stock index, interest rates, imports and exports.
#' The series span from 1962 to September 2017. Missing values were removed using \code{na.omit}.
#' The last 30 observations are for test set.
#' @docType data
#' @usage data(ipeadata.d)
#' @format A data frame with up to 8,154 rows and 12 columns. Each column corresponds to a different univariate daily time series.
#' @keywords datasets benchmark economics brazil
#' @references
#' Ipea (2017). *Ipeadata – Macroeconomic and Regional Data*. Technical Report. \url{http://www.ipeadata.gov.br}
#' @source \href{http://www.ipeadata.gov.br}{Ipea - Ipeadata Portal}, section "Most Requested Series", filtered by frequency "Daily".
#' @import daltoolbox
#' @details
#' Contains daily macroeconomic indicators frequently used in empirical forecasting. Series are cleaned with `na.omit`.
#'
#' @examples
#' # Load Ipea daily dataset and plot the first series
#' data(ipeadata.d)
#' # ipeadata.d <- loadfulldata(ipeadata.d)
#' series <- ipeadata.d[[1]]
#' ts.plot(series, ylab = "Value", xlab = "Day", main = "Ipea daily example")
"ipeadata.d"


#' @name ipeadata.m
#' @title Ipea Monthly Macroeconomic Dataset
#' @description
#' Monthly economic time series from Ipea (Institute for Applied Economic Research, Brazil).
#' Data Type: Macroeconomic indicators. Category: Public data. Observations: 156 to 1019 per series, 23 series.
#' This dataset contains the most requested time series provided by Ipea, including exchange rates, inflation indices, unemployment rates, interest rates, minimum wage, and GDP.
#' The series span from 1930 to September 2017. Missing values were removed using \code{na.omit}.
#' The last 12 observations are for testing set.
#' @docType data
#' @usage data(ipeadata.m)
#' @format A data frame with up to 1019 rows and 23 columns. Each column corresponds to a different univariate monthly time series.
#' @keywords datasets benchmark economics brazil
#' @references
#' Ipea (2017). *Ipeadata – Macroeconomic and Regional Data*. Technical Report. \url{http://www.ipeadata.gov.br}
#' @source \href{http://www.ipeadata.gov.br}{Ipea - Ipeadata Portal}, section "Most Requested Series", filtered by frequency "Monthly".
#' @import daltoolbox
#' @details
#' Contains monthly macroeconomic indicators; the last 12 observations are intended as a test set.
#'
#' @examples
#' # Load Ipea monthly dataset and plot the first series
#' data(ipeadata.m)
#' # ipeadata.m <- loadfulldata(ipeadata.m)
#' series <- ipeadata.m[[1]]
#' ts.plot(series, ylab = "Value", xlab = "Month", main = "Ipea monthly example")
"ipeadata.m"

#' @name NN3
#' @title NN3 Time Series Competition - Dataset A
#' @description
#' Monthly time series from the NN3 forecasting competition.
#' Data Type: Empirical business time series. Category: Benchmark. Observations: 50 to 126 per series, 111 series.
#' The dataset contains 111 univariate monthly time series from real business processes.
#' Each series has between 50 and 126 observations. Participants were asked to forecast the next 18 values, and performance was evaluated using the mean sMAPE across all series.
#' @docType data
#' @usage data(NN3)
#' @format A data frame with up to 126 rows and 111 columns. Each column corresponds to a different univariate monthly time series.
#' @keywords datasets benchmark
#' @references
#' Crone, S.F., Hibon, M., & Nikolopoulos, K. (2011). *Advances in forecasting with neural networks? Empirical evidence from the NN3 competition on time series prediction*. International Journal of Forecasting, 27(3), 635–660.
#' NN3 Competition (2007). \url{http://www.neural-forecasting-competition.com/NN3/index.htm}
#' @source \href{http://www.neural-forecasting-competition.com/NN3/index.htm}{NN3 Time Series Forecasting Competition}
#' @import daltoolbox
#' @details
#' NN3 comprises monthly business time series with varying lengths. Forecast accuracy is typically
#' evaluated using sMAPE across a fixed holdout horizon.
#'
#' @examples
#' # Load NN3 dataset
#' data(NN3)
#' # NN3 <- loadfulldata(NN3)
#'
#' # Select one series by name and plot
#' series <- NN3[["NN3_111"]]
#' ts.plot(series, ylab = "Value", xlab = "Month", main = "NN3 example series")
"NN3"


#' @name NN5
#' @title NN5 Time Series Competition
#' @description
#' Daily time series from the NN5 forecasting competition.
#' Data Type: ATM withdrawal amounts. Category: Benchmark. Observations: 735 per series, 111 series.
#' The dataset contains 111 univariate time series representing daily cash withdrawals from ATMs in England.
#' Each series includes 735 observations and may contain missing values and multiple seasonal patterns.
#' Participants were asked to forecast the next 56 values for each series, and performance was evaluated using the mean sMAPE across all series.
#' @docType data
#' @usage data(NN5)
#' @format A data frame with 735 rows and 111 columns. Each column corresponds to a different univariate daily time series.
#' @keywords datasets benchmark
#' @references
#' Crone, S.F. (2008). *Results of the NN5 Time Series Forecasting Competition*. IEEE WCCI 2008, Hong Kong.
#' NN5 Competition (2008). \url{http://www.neural-forecasting-competition.com/NN5/index.htm}
#' @source \href{http://www.neural-forecasting-competition.com/NN5/index.htm}{NN5 Time Series Forecasting Competition}
#' @import daltoolbox
#' @details
#' NN5 consists of daily ATM withdrawal amounts with complex multiple seasonalities and occasional
#' missing values. Forecasts are evaluated via sMAPE on a 56-day horizon.
#'
#' @examples
#' # Load NN5 dataset
#' data(NN5)
#' # NN5 <- loadfulldata(NN5)
#'
#' # Select one series and plot
#' series <- NN5[["NN5.111"]]
#' ts.plot(series, ylab = "Withdrawals", xlab = "Day", main = "NN5 example series")
"NN5"


#' @name CATS
#' @title CATS Time Series Competition
#' @description
#' Univariate time series from the CATS (Competition on Artificial Time Series) benchmark.
#' Data Type: Artificial time series with missing blocks. Category: Benchmark. Observations: 5,000 (4,900 known, 100 missing).
#' The dataset contains five non-consecutive blocks of 20 missing values each. Competitors were asked to predict these 100 unknown points, and performance was evaluated using MSE (E1 for all unknowns and E2 for the first 80 points).
#' @docType data
#' @usage data(CATS)
#' @format A data frame with five columns and 980 rows. Each column represents a known segment of the time series.
#' @keywords datasets benchmark
#' @references
#' Lendasse, A., Oja, E., Simula, O., Verleysen, M., et al. (2004). *Time Series Prediction Competition: The CATS Benchmark*. In IJCNN'2004 - International Joint Conference on Neural Networks.
#' Lendasse, A., Oja, E., Simula, O., Verleysen, M. (2007). *Time Series Prediction Competition: The CATS Benchmark*. Neurocomputing, 70(13-15), 2325–2329.
#' @source \href{https://archive.ics.uci.edu/dataset/204/cats}{CATS Time Series Competition}
#' @import daltoolbox
#' @details
#' The CATS benchmark contains artificial series with five nonconsecutive missing blocks of 20 points each.
#' Models must impute or forecast the missing blocks; evaluation typically uses MSE over all missing points.
#'
#' @examples
#' # Load CATS dataset
#' data(CATS)
#' # CATS <- loadfulldata(CATS)
"CATS"

#' @name SantaFe.A
#' @title Santa Fe Time Series Competition - Series A
#' @description
#' Univariate time series A from the Santa Fe Time Series Competition.
#' Data Type: Laser-generated nonlinear time series. Category: Benchmark. Observations: 1,100.
#' This benchmark dataset consists of a low-dimensional nonlinear and stationary series recorded from a Far-Infrared-Laser in a chaotic regime.
#' Competitors were asked to predict the last 100 observations, and performance was evaluated using NMSE.
#' @docType data
#' @usage data(SantaFe.A)
#' @format A data frame with one column and 1,100 rows, containing numeric time series values.
#' @keywords datasets benchmark
#' @references
#' Weigend, A.S. (1993). *Time Series Prediction: Forecasting the Future and Understanding the Past*. Reading, MA: Westview Press.
#' @source Santa Fe Time Series Competition dataset (original archive URL unavailable).
#' @import daltoolbox
#' @details
#' Series A is a classic nonlinear laser dataset used to assess forecasting methods under chaotic dynamics.
#'
#' @examples
#' # Load Santa Fe A series and plot
#' data(SantaFe.A)
#' # SantaFe.A <- loadfulldata(SantaFe.A)
#' series <- SantaFe.A$V1
#' ts.plot(series, ylab = "Value", xlab = "Index", main = "Santa Fe A")
"SantaFe.A"


#' @name SantaFe.D
#' @title Santa Fe Time Series Competition - Series D
#' @description
#' Univariate time series D from the Santa Fe Time Series Competition.
#' Data Type: Simulated nonlinear time series. Category: Benchmark. Observations: 100,500.
#' This benchmark dataset is composed of a four-dimensional nonlinear and non-stationary series.
#' Competitors were asked to predict the last 500 observations, and performance was evaluated using NMSE.
#' @docType data
#' @usage data(SantaFe.D)
#' @format A data frame with one column and 100,500 rows, containing numeric time series values.
#' @keywords datasets benchmark
#' @references
#' Weigend, A.S. (1993). *Time Series Prediction: Forecasting the Future and Understanding the Past*. Reading, MA: Westview Press.
#' @source Santa Fe Time Series Competition dataset (original archive URL unavailable).
#' @import daltoolbox
#' @examples
#' # Load Santa Fe D series and plot a subset
#' data(SantaFe.D)
#' # SantaFe.D <- loadfulldata(SantaFe.D)
#' series <- SantaFe.D$V1
#' ts.plot(series[1:2000], ylab = "Value", xlab = "Index", main = "Santa Fe D (first 2000)")
"SantaFe.D"

#' @name bioenergy
#' @title FAOSTAT Bioenergy Database
#' @description
#' Bioenergy data from FAOSTAT.
#' Data Type:	Bioenergy consumption and production. Category:	Environment. Creation Date	2024.
#' @docType data
#' @usage data(bioenergy)
#' @format A list of time series.
#' @keywords datasets
#' @references
#' FAO 2024. FAOSTAT Bioenergy, FAO, Rome, Italy.  ; United Nations Statistics Division (UNSD), 2011; International Recommendations for Energy Statistics (IRES).
#' @source \href{https://www.fao.org/faostat/en/#data/BE}{FAOSTAT Bioenergy Database}
#' @import daltoolbox
#' @details
#' Series are named as `<country>_<bio_consumption|bio_production>` and contain annual values.
#'
#' @examples
#' # Load bioenergy list and plot one series
#' data(bioenergy)
#' # bioenergy <- loadfulldata(bioenergy)
#' series <- bioenergy[[1]]
#' ts.plot(series, ylab = "TJ", xlab = "Year", main = "Bioenergy example")
"bioenergy"

#' @name climate
#' @title FAOSTAT Temperature Change on Land
#' @description
#' Statistics of surface temperature anomalies on land, based on NASA-GISS GISTEMP data.
#' Data Type:	Temperature Anomalies. Category:	Environment. Creation Date	2024.
#' @docType data
#' @usage data(climate)
#' @format A list of time series.
#' @keywords datasets
#' @references
#' FAO, 2024. FAOSTAT Land, Inputs and Sustainability; Climate Change Indicators;
#' Temperature change on land.
#' GISTEMP Team, 2024: GISS Surface Temperature Analysis. NASA Goddard Institute for Space Studies.
#' Hansen, J. et al., 1981–2019: Multiple foundational studies on global temperature analysis.
#' @source \href{https://data.giss.nasa.gov/gistemp/}{NASA-GISS GISTEMP}
#' @import daltoolbox
#' @examples
#' # Load climate list and plot one series
#' data(climate)
#' # climate <- loadfulldata(climate)
#' series <- climate[[1]]
#' ts.plot(series, ylab = "Temperature change (°C)", xlab = "Year",
#'         main = "Temperature change on land")
"climate"

#' @name emissions
#' @title FAOSTAT Emissions Totals
#' @description
#' National and global estimates of greenhouse gas (GHG) emissions.
#' Data Type:	Greenhouse gas emissions. Category:	Environment. Creation Date	2023.
#' @docType data
#' @usage data(emissions)
#' @format A list of time series.
#' @keywords datasets
#' @references
#' FAO, 2023. FAOSTAT Climate Change: Agrifood systems emissions, Emissions Totals.
#' IPCC Guidelines and Reports: 1996, 2000, 2006, 2014, 2019.
#' PRIMAP-hist dataset v2.4.2: Gütschow et al., 2023.
#' @source
#' \href{https://www.fao.org/faostat/en/#data/GT}{FAOSTAT Emissions Totals}.
#' @import daltoolbox
#' @examples
#' # Load emissions list and plot one series
#' data(emissions)
#' # emissions <- loadfulldata(emissions)
#' series <- emissions[[1]]
#' ts.plot(series, ylab = "kt CO2e", xlab = "Year", main = "Emissions example (CH4/N2O)")
"emissions"

#' @name fertilizers
#' @title FAOSTAT Fertilizers by Nutrient
#' @description
#' Statistics on agricultural use, production, and trade of chemical and mineral fertilizers.
#' Data Type:	Fertilizers use, production and trade. Category:	Environment. Creation Date	2024.
#' @docType data
#' @usage data(fertilizers)
#' @format A list of time series.
#' @keywords datasets
#' @references
#' FAO, 2024. FAOSTAT: Fertilizers by Nutrient.
#' FAO & UNSD (2017). System of Environmental-Economic Accounting for Agriculture, Forestry and Fisheries (SEEA AFF).
#' UNSD (2017). Framework for the Development of Environment Statistics (FDES).
#' @source \href{https://www.fao.org/faostat/en/#data/RFN}{FAOSTAT Fertilizers by Nutrient}.
#' @import daltoolbox
#' @examples
#' # Load fertilizers list and plot one series
#' data(fertilizers)
#' # fertilizers <- loadfulldata(fertilizers)
#' series <- fertilizers[[1]]
#' ts.plot(series, ylab = "tonnes", xlab = "Year", main = "Fertilizers example")
"fertilizers"

#' @name gdp
#' @title Gross Domestic Product and Agriculture Value Added
#' @description
#' Summary of global and regional trends in GDP and agriculture value.
#' Data Type: macroeconomic indicators. Category:	Economy. Creation Date	2024.
#' @docType data
#' @usage data(gdp)
#' @format list of time series.
#' @keywords datasets
#' @references
#' FAO. 2024. Gross domestic product and agriculture value added 2013–2022 – Global and regional trends.
#' FAOSTAT Analytical Briefs, No. 85. Rome. \doi{10.4060/cd0763en}
#' @source \href{https://www.fao.org/faostat/en/#data/MK}{FAOSTAT Macro Indicators Database}
#' @import daltoolbox
#' @examples
#' # Load GDP list and plot one series
#' data(gdp)
#' # gdp <- loadfulldata(gdp)
#' series <- gdp[[1]]
#' ts.plot(series, ylab = "US$", xlab = "Year", main = "GDP example")
"gdp"

 #' @name m1
 #' @title M1 Competition Time Series
 #' @description
 #' Time series data from the first Makridakis forecasting competition (M1), held in 1982.
 #' Data Type: Forecasting benchmark dataset. Category: Forecasting. Creation Date: 1982.
 #' @docType data
 #' @usage data(m1)
 #' @format A list of dataframes containing time series.
 #' @keywords datasets
 #' @references
 #' Makridakis et al. (1982). The accuracy of extrapolation (time series) methods: Results of a forecasting competition. Journal of Forecasting, 1(2), 111–153.
 #' @source \href{https://onlinelibrary.wiley.com/doi/10.1002/for.3980010202}{The accuracy of extrapolation (time series) methods: Results of a forecasting competition}
 #' @import daltoolbox
 #' @details
 #' Consolidated list with frequencies as keys (e.g., `monthly`, `quarterly`, `yearly`). Each element is a list of series.
 #' See Makridakis et al. (1982) for competition design and evaluation.
 #'
 #' @examples
 #' # Load consolidated M1 list
 #' data(m1)
#' # m1 <- loadfulldata(m1)
 #'
 #' # List available frequency keys
 #' names(m1)
 #'
 #' # Plot one series from a frequency bucket
 #' series <- m1$monthly[[1]]
 #' ts.plot(series, main = "M1 monthly series")
 "m1"

 #' @name m3
 #' @title M3 Competition Time Series
 #' @description
 #' Time series data from the third Makridakis forecasting competition (M3), held in 2000.
 #' Data Type: Forecasting benchmark dataset. Category: Forecasting. Creation Date: 2000.
 #' @docType data
 #' @usage data(m3)
 #' @format A list of lists containing time series.
 #' @keywords datasets
 #' @references
 #' Makridakis and Hibon (2000). The M3-Competition: Results, conclusions and implications. International Journal of Forecasting, 16(4), 451–476.
 #' @source \doi{10.1016/S0169-2070(00)00057-1}
 #' @import daltoolbox
 #' @details
 #' Consolidated list keyed by frequency (e.g., `monthly`, `other`, `quarterly`, `yearly`). Each holds a list of numeric vectors.
 #' See Makridakis & Hibon (2000) for competition results and implications.
 #'
 #' @examples
 #' # Load consolidated M3 list and plot one monthly series
 #' data(m3)
#' # m3 <- loadfulldata(m3)
 #' series <- m3$monthly$M1
 #' ts.plot(series, main = "M3 monthly series: M1")
 "m3"

 #' @name m4
 #' @title M4 Competition Time Series
 #' @description
 #' Time series data from the fourth Makridakis forecasting competition (M4), held in 2018.
 #' Data Type: Forecasting benchmark dataset. Category: Forecasting. Creation Date: 2018.
 #' @docType data
 #' @usage data(m4)
 #' @format A list of lists containing time series.
 #' @keywords datasets
 #' @references
 #' Makridakis et al. (2020). The M4 Competition: Results, findings, conclusion and way forward. International Journal of Forecasting, 36(1), 54–74.
 #' @source \href{https://github.com/Mcompetitions/M4-methods}{M4 Competition - GitHub}
 #' @import daltoolbox
 #' @details
 #' Consolidated list keyed by frequency (e.g., `daily`, `hourly`, `monthly`, ...). Each holds a list of numeric vectors.
 #' See Makridakis et al. (2020) for an overview of M4 findings.
 #'
 #' @examples
 #' # Load consolidated M4 list and plot one available series
 #' data(m4)
#' # m4 <- loadfulldata(m4)
 #' freq_name <- names(m4)[1]
 #' series_name <- names(m4[[freq_name]])[1]
 #' series <- m4[[freq_name]][[series_name]]
 #' ts.plot(series, main = paste("M4", freq_name, "series:", series_name))
 "m4"

#' @name pesticides
#' @title Pesticides Use Statistics
#' @description
#' Statistics on the use of major pesticide groups and relevant chemical families.
#' Data Type: pesticides use. Category:	Environments. Creation Date	2024.
#' @docType data
#' @usage data(pesticides)
#' @format A list of time series.
#' @keywords datasets
#' @references
#' FAO. 2024. FAOSTAT: Pesticides Use. RP_e_README_Domain_Information_2024.
#' \href{https://www.fao.org/faostat/en/#data/RP}{FAOSTAT Pesticides Use Database}
#' @source \href{https://www.fao.org/faostat/en/#data/RP}{Pesticides Use Database}
#' @import daltoolbox
#' @details
#' Series are named by country with `_pesticides` suffix; values are annual usage amounts.
#'
#' @examples
#' # Load pesticides list and plot one series
#' data(pesticides)
#' # pesticides <- loadfulldata(pesticides)
#' series <- pesticides[[1]]
#' ts.plot(series, ylab = "tonnes", xlab = "Year", main = "Pesticides example")
"pesticides"

#' @name stocks
#' @title IBOVESPA's 50 Most Traded Stocks
#' @description
#' Historical daily data for the 50 most traded stocks in B3 (IBOVESPA),
#' including opening, high, low, and closing prices, as well as trading volume.
#' Data Type: Financial Time Series. Category: Finance. Creation Date: 2025.
#' @docType data
#' @usage data(stocks)
#' @format A list of dataframes containing time series.
#' @keywords datasets
#' @references
#' B3 - Brasil, Bolsa, Balcão. 2025. Historical stock trading data.
#' \href{https://www.b3.com.br}{B3 Official Website}
#' @source \href{https://www.b3.com.br}{B3}
#' @import daltoolbox
#' @details
#' Each entry is a data frame with columns `date`, `open`, `high`, `low`, `close`, and `volume`.
#'
#' @examples
#' # Load stocks list and plot closing prices for a ticker (if present)
#' data(stocks)
#' # stocks <- loadfulldata(stocks)
#' if ("VALE3" %in% names(stocks)) {
#'   series <- stocks$VALE3$close
#'   ts.plot(series, ylab = "Close", xlab = "Index", main = "VALE3 close price")
#' }
"stocks"

