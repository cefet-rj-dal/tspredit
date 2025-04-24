
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src='https://raw.githubusercontent.com/cefet-rj-dal/tspredit/master/inst/logo.png' alt='Logo do pacote TSPredIT' align='centre' height='125' width='125'/> TSPredIT

<!-- badges: start -->

![GitHub
Stars](https://img.shields.io/github/stars/cefet-rj-dal/tspredit?logo=Github)
![CRAN Downloads](https://cranlogs.r-pkg.org/badges/tspredit)
<!-- badges: end -->

**TSPredIT** (Time Series Prediction with Integrated Tuning) is a
framework for time series prediction with automatic preprocessing and
hyperparameter optimization. It is built on top of the [DAL
Toolbox](https://github.com/cefet-rj-dal/daltoolbox) and enhances its
capabilities by integrating several advanced functionalities:

- Automatic hyperparameter tuning for models and preprocessing
- Outlier detection and removal
- Time series data augmentation
- Filtering techniques for noise reduction
- Ensemble learning support
- Modular and extensible workflow for predictive modeling

TSPredIT is designed to provide a **more flexible and customizable
pipeline** for building predictive models on time series data, making it
easier to compare alternatives and automate repetitive tasks.

------------------------------------------------------------------------

## Installation

The latest version of TSPredIT is available on CRAN:

``` r
install.packages("tspredit")
```

You can install the development version from GitHub:

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("cefet-rj-dal/tspredit", force = TRUE, upgrade = "never")
```

------------------------------------------------------------------------

## Examples

Examples of TSPredIT usage are available in the official GitHub
repository:

- [Example
  scripts](https://github.com/cefet-rj-dal/tspredit/tree/main/examples)

Additional documentation and tutorials for the underlying DAL Toolbox
can be found at:

- [DAL Toolbox
  documentation](https://cefet-rj-dal.github.io/daltoolbox/)

``` r
library(tspredit)
#> Registered S3 method overwritten by 'quantmod':
#>   method            from
#>   as.zoo.data.frame zoo
#> Registered S3 methods overwritten by 'forecast':
#>   method  from 
#>   head.ts stats
#>   tail.ts stats

# Example usage (basic)
# Load a model and apply to example data (to be defined by user)
```

------------------------------------------------------------------------

## Bug reports and feature requests

To report issues or suggest improvements, please open a ticket here:

<https://github.com/cefet-rj-dal/tspredit/issues>
