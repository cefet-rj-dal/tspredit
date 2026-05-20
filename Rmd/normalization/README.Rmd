# Normalization Examples

Normalization changes the numerical scale presented to the forecasting model. In time series, this is more than a cosmetic choice: a scaling strategy can emphasize shape, preserve level, or react to drift and trend over time.

The examples below are organized as a progression. Begin with the no-normalization baseline, then compare global and local scaling, and finally inspect adaptive and differencing-based strategies that are more appropriate when the series changes its distribution over time.

For the adaptive family implemented by `ts_norm_an()`, the reference level and reference scale are estimated from the full supervised window passed to the transform. In other words, the operator is applied to the same complete window geometry that later reaches the model.

## Baseline and global scaling

- [01-no-normalization.md](01-no-normalization.md) - keep the values unchanged to create the reference case for later comparisons.
- [02-global-minmax-normalization.md](02-global-minmax-normalization.md) - rescale the training series globally to the `[0, 1]` interval.

## Local stabilization before adaptive normalization

- [03-sliding-window-minmax-normalization.md](03-sliding-window-minmax-normalization.md) - normalize each window locally so the model focuses more on shape than on absolute level.
- [04-differencing-normalization.md](04-differencing-normalization.md) - difference the series to reduce trend effects and stabilize the mean before scaling.

## Adaptive normalization family

The adaptive-normalization examples below are all instances of the same family
implemented by `ts_norm_an()`. They differ only in the operator used to compare
each full supervised window against its adaptive reference level and adaptive reference scale.

- [05-adaptive-normalization.md](05-adaptive-normalization.md) - use divisive adaptive normalization to compare local patterns across different levels.
- [06-adaptive-subtraction-normalization.md](06-adaptive-subtraction-normalization.md) - remove the adaptive local level when near-zero windows make ratios unstable.
- [07-adaptive-softdivide-normalization.md](07-adaptive-softdivide-normalization.md) - blend additive and relative normalization through a stabilized denominator.
- [08-adaptive-asinh-normalization.md](08-adaptive-asinh-normalization.md) - use a smooth nonlinear bridge between additive and log-like relative normalization.
- [09-adaptive-normalization-comparison.md](09-adaptive-normalization-comparison.md) - compare the adaptive operators on synthetic series designed to expose their different theoretical regimes.
