# Time Series Data Utilities

This folder explains the internal time-series representation that makes the rest of `tspredit` possible. Before discussing models, it is important to understand how the package turns a sequential series into a structure that supports supervised forecasting experiments.

The three examples below should be read in order. First you learn how the series becomes a `ts_data` object, then how that object is projected into inputs and targets, and only after that how the temporal split is defined for evaluation.

## Recommended progression

- [01-build-ts-data.md](/examples/tsdata/01-build-ts-data.md) - create a `ts_data` object and understand how lagged observations are stored as rows and columns.
- [02-project-ts-data.md](/examples/tsdata/02-project-ts-data.md) - convert `ts_data` into the input matrix (`X`) and target vector (`y`) consumed by forecasting models.
- [03-train-test-split.md](/examples/tsdata/03-train-test-split.md) - separate train and test segments while preserving time order, which is essential for valid forecasting experiments.
