
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src='https://raw.githubusercontent.com/cefet-rj-dal/tspredit/master/inst/logo.png' alt='TSPredIT package logo' align='centre' height='125' width='125'/> TSPredIT

<!-- badges: start -->

![GitHub
Stars](https://img.shields.io/github/stars/cefet-rj-dal/tspredit?logo=Github)
![CRAN Downloads](https://cranlogs.r-pkg.org/badges/tspredit)
<!-- badges: end -->

**TSPredIT** (Time Series Prediction with Integrated Tuning) is an R
framework for time series forecasting workflows. Built on top of [DAL
Toolbox](https://github.com/cefet-rj-dal/daltoolbox), it helps users
move from a raw series to complete and reproducible forecasting
pipelines.

The package treats forecasting as a sequence of explicit decisions: how
to represent a series, how to split it while preserving temporal order,
whether to filter noise, whether to augment training windows, how to
normalize values, which predictor to use, and how to compare forecasting
protocols. This makes the package useful for teaching, experimentation,
benchmark studies, and applied time series projects.

Current package version in this repository: `2.0.707`.

------------------------------------------------------------------------

## Installation

The stable version is available on CRAN:

<https://CRAN.R-project.org/package=tspredit>

``` r
install.packages("tspredit")
```

The development version is available on GitHub:

<https://github.com/cefet-rj-dal/tspredit>

``` r
library(devtools)
devtools::install_github("cefet-rj-dal/tspredit", force = TRUE, upgrade = "never")
```

------------------------------------------------------------------------

## Documentation

Documentation and examples are available in the package site and in the
repository:

- [Package website](https://cefet-rj-dal.github.io/tspredit/)
- [Function
  reference](https://cefet-rj-dal.github.io/tspredit/reference/)
- [Articles](https://cefet-rj-dal.github.io/tspredit/articles/)
- [GitHub repository](https://github.com/cefet-rj-dal/tspredit)
- [Examples](https://github.com/cefet-rj-dal/tspredit/tree/main/examples)

The documentation is organized around two complementary entry points:

- a guided tutorial track for readers who want to learn the forecasting
  workflow step by step
- thematic example collections for readers who want to inspect one stage
  of the forecasting pipeline at a time

If you are new to `tspredit`, start with the tutorials. If you already
know the package structure, the thematic collections provide focused
examples by pipeline stage.

------------------------------------------------------------------------

## Guided Tutorial Track

- [Tutorials](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/tutorial/) -
  a 10-part sequence that starts with ARIMA forecasting protocols, then
  builds the sliding-window MLP pipeline piece by piece, and ends with
  model comparison and integrated tuning.

The sequence is cumulative. Each tutorial introduces one main decision
in a time series forecasting study and keeps the code close to that
learning objective.

------------------------------------------------------------------------

## Thematic Example Collections

- [Time-series data
  utilities](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/tsdata/) -
  build `ts_data`, project windows into inputs and targets, and create
  train/test splits that preserve temporal order.
- [Datasets](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/datasets/) -
  inspect the packaged datasets documented in `R/data.R` and
  `R/tspredbench.R`, one dataset at a time.
- [Filtering](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/filter/) -
  compare identity baselines, smoothing methods, robust filters,
  decomposition methods, state-space filters, and seasonal adjustments.
- [Lag
  mapping](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/lagmapping/) -
  study how different lag-selection rules decide which past observations
  are exposed to the predictor.
- [Augmentation](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/augment/) -
  study when synthetic windows help, from simple perturbations to
  recency-aware transformations.
- [Normalization](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/normalization/) -
  inspect how scale, drift, adaptive transformations, and differencing
  affect the signal seen by the predictor.
- [Prediction](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/prediction/) -
  move from classical baselines to machine-learning and neural
  forecasting models, then to tuning.
- [Multivariate
  forecasting](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/multivariate/) -
  extend the pipeline to target-centered multivariate workflows by
  combining one model for `y` with auxiliary-variable pipelines.
- [Custom
  extensions](https://github.com/cefet-rj-dal/tspredit/tree/main/examples/custom/) -
  learn how to add custom predictors, filters, augmentations, and
  normalization methods without breaking the package contract.

------------------------------------------------------------------------

## Main Capabilities

- Time-aware data representation and train/test splitting.
- One-step, rolling-origin, and multi-step forecasting protocols.
- Classical, machine-learning, and neural forecasting models, including
  ARIMA, KNN, SVM, random forest, ELM, MLP, Conv1D, LSTM, DARIMA, and
  WARMA workflows.
- Filtering, smoothing, seasonal adjustment, and decomposition-based
  preprocessing.
- Lag mapping strategies based on recency, spacing, geometry,
  autocorrelation, partial autocorrelation, seasonal behavior, peaks,
  blocks, mutual information, and supervised feature selection.
- Data augmentation and normalization strategies for time series
  forecasting.
- Integrated tuning for input size, preprocessing choices, augmentation
  choices, and model hyperparameters.
- Support for multivariate forecasting workflows.

------------------------------------------------------------------------

## Course Material

The public course page includes a compact slide sequence that introduces
TSPredIT and demonstrates the main package workflows:

1.  [TSPredIT
    overview](https://github.com/eogasawara/series-temporais/blob/main/t01-tspredit.pdf)
2.  [Tutorial](https://github.com/eogasawara/series-temporais/blob/main/t02-tutorial.pdf)
3.  [Data
    utilities](https://github.com/eogasawara/series-temporais/blob/main/t03-data.pdf)
4.  [Datasets](https://github.com/eogasawara/series-temporais/blob/main/t04-datasets.pdf)
5.  [Filtering](https://github.com/eogasawara/series-temporais/blob/main/t05-filter.pdf)
6.  [Augmentation](https://github.com/eogasawara/series-temporais/blob/main/t06-augment.pdf)
7.  [Normalization](https://github.com/eogasawara/series-temporais/blob/main/t07-normalization.pdf)
8.  [Prediction](https://github.com/eogasawara/series-temporais/blob/main/t08-prediction.pdf)
9.  [Custom
    extensions](https://github.com/eogasawara/series-temporais/blob/main/t09-custom.pdf)

------------------------------------------------------------------------

## Related DAL Projects

- [DAL Toolbox](https://cefet-rj-dal.github.io/daltoolbox/)
- [harbinger](https://cefet-rj-dal.github.io/harbinger/)
- [Data Analytics Lab](https://eic.cefet-rj.br/~dal)

------------------------------------------------------------------------

## Playlist

[TSPredIT
videos](https://www.youtube.com/playlist?list=PLJb2qK1RWkbGlxUAljn-9eP2r_3m70aUC)

[![Watch the playlist on
YouTube](https://img.shields.io/badge/YouTube-Watch%20playlist-red?logo=youtube&logoColor=white)](https://www.youtube.com/playlist?list=PLJb2qK1RWkbGlxUAljn-9eP2r_3m70aUC)

------------------------------------------------------------------------

## Bug Reports and Feature Requests

Please report bugs, questions, and feature requests at:

<https://github.com/cefet-rj-dal/tspredit/issues>
