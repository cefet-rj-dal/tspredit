
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src='https://raw.githubusercontent.com/cefet-rj-dal/tspredit/master/inst/logo.png' align='centre' height='125' width='125'/> TSPredIT

<!-- badges: start -->

![GitHub Repo
stars](https://img.shields.io/github/stars/cefet-rj-dal/tspredit?logo=Github)
<!-- badges: end -->

The Time Series Prediction with Integrated Tuning (TSPredIT) is based on
DAL Toolbox with integrated hyperparameter optimization combining
machine learning and data preprocessing. It also contains time series
outliers removal, data augmentation, ensemble models, and a more
flexible workflow design for Data Analytics tasks.

## Installation

The latest version of TSPredIT at CRAN is available at:
<https://CRAN.R-project.org/package=tspredit>

You can install the stable version of TSPredIT from CRAN with:

``` r
install.packages("harbinger")
```

You can install the development version of TSPredIT from
[GitHub](https://github.com/) with:

``` r
library(devtools)
devtools::install_github("cefet-rj-dal/tspredit", force=TRUE, upgrade="never")
```

## Examples

The TSPredIT examples are made available at:
<https://nbviewer.org/github/cefet-rj-dal/tspredit-examples/tree/main/>

The TSPredIT is built on top of DAL Toolbox. Documentation of DAL
Toolbox is made available at:
<https://cefet-rj-dal.github.io/daltoolbox/>

``` r
library(tspredit)
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo
```
