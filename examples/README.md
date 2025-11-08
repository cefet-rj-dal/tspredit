# Examples

This directory collects runnable examples for time series data preparation, filtering, normalization, and prediction. Use the category readmes below to navigate to specific examples.

- [augment/README.md](augment/README.md) — Data augmentation on time series windows and sequences, including recency-aware sampling, smoothing, jittering, flips, and temporal warping to expand training diversity while preserving structure.
- [data/README.md](data/README.md) — Construction and handling of `ts_data`, projection to inputs/targets, and time-ordered train/test splitting for reproducible pipelines.
- [filter/README.md](filter/README.md) — Signal denoising and decomposition techniques such as EMA/MA smoothing, LOWESS, splines, wavelets, HP, Kalman, and seasonal adjustment for cleaner inputs.
- [normalization/README.md](normalization/README.md) — Global and adaptive rescaling methods (min–max, sliding-window scaling, differencing, EAN/AN) to stabilize level/variance and emphasize shape.
- [prediction/README.md](prediction/README.md) — Forecasting/regression models ranging from ARIMA and kNN to neural approaches (Conv1D, MLP, LSTM), with tuning utilities and evaluation.

