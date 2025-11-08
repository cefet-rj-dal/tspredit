# Normalization Examples

This folder contains examples for rescaling and stabilizing time series before modeling, including global and adaptive schemes.

- [ts_norm_an.md](ts_norm_an.md) — Adaptive normalization using time-varying statistics (e.g., moving/EMA) to handle drift.
- [ts_norm_diff.md](ts_norm_diff.md) — Differencing to remove trend and stabilize the mean for modeling.
- [ts_norm_ean.md](ts_norm_ean.md) — Exponential Adaptive Normalization (EAN) using exponentially weighted statistics per window.
- [ts_norm_gminmax.md](ts_norm_gminmax.md) — Global min–max scaling fit on train, applied consistently to validation/test.
- [ts_norm_none.md](ts_norm_none.md) — Baseline with no normalization; helpful for comparisons.
- [ts_norm_swminmax.md](ts_norm_swminmax.md) — Sliding-window min–max scaling to emphasize local shape over absolute level.

