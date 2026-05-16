# TSPredIT Examples

This directory contains the source R Markdown examples that generate the materials under `examples/`. They were reorganized to help the reader understand `tspredit` as a forecasting workflow rather than as a flat catalog of functions.

A good mental model for the package is this sequence: represent the series, define the time-aware split, optionally filter the signal, optionally augment the training windows, normalize the values, choose a predictor, and evaluate under an explicit forecasting protocol. The collections below follow that logic.

If you are new to the package, begin with the tutorial track. After that, use the thematic collections to deepen one stage of the pipeline at a time.

## Guided Entry Point

- [tutorial](/examples/tutorial/README.md) - the recommended starting point. It explains forecasting protocols first, then builds a complete MLP pipeline step by step, and finally shows model comparison and integrated tuning.

## Thematic Collections

- [tsdata](/examples/tsdata/README.md) - foundational objects and operations used by the rest of the package: `ts_data`, projection into `X` and `y`, and temporal train/test splitting.
- [datasets](/examples/datasets/README.md) - packaged datasets organized from the synthetic `tsd` example to forecasting benchmarks, public indicator collections, and financial series.
- [filter](/examples/filter/README.md) - filtering strategies organized from baseline and smoothing methods to robust, frequency-based, decomposition-based, state-space, and seasonal techniques.
- [augment](/examples/augment/README.md) - augmentation strategies organized from the no-augmentation baseline to shape perturbations and recency-aware schemes.
- [normalization](/examples/normalization/README.md) - normalization strategies organized from no scaling to global, local, adaptive, and differencing-based transformations.
- [prediction](/examples/prediction/README.md) - forecasting models organized from ARIMA baselines to machine-learning, neural, and tuning workflows.
- [custom](/examples/custom/README.md) - extension examples showing how to plug custom predictors, filters, augmentations, and normalizers into the same `tspredit` contract.

## Suggested Reading Order

Start with `tutorial` if you want the most didactic path.

If you prefer to assemble understanding by component, this order is usually the most productive:

1. `tsdata`
2. `tutorial`
3. `datasets`
4. `filter`, `augment`, and `normalization`
5. `prediction`
6. `custom`
