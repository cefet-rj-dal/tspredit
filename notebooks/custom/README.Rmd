# Custom Examples

This section shows how to extend `tspredit` without abandoning the package workflow. The key idea is that the forecasting pipeline remains stable while the user plugs a new component into a small integration contract.

The examples are ordered from the most central extension point to the surrounding pipeline components. Start with a custom predictor to understand the main learning contract, then move to filters, augmentations, and normalization.

## Recommended reading order

- [01-custom-prediction.md](/examples/custom/01-custom-prediction.md) - create a custom predictor based on `RSNNS::mlp` and fit it through `ts_regsw`.
- [02-custom-filter.md](/examples/custom/02-custom-filter.md) - create a custom median filter for spike-like noise.
- [03-custom-augmentation.md](/examples/custom/03-custom-augmentation.md) - implement a custom magnitude-warp augmentation for sliding windows.
- [04-custom-normalization.md](/examples/custom/04-custom-normalization.md) - build a custom adaptive normalization that rescales values with moving statistics.
