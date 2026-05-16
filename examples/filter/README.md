# Filtering Examples

Filtering is useful when the raw series contains noise, spikes, or seasonal components that can distract the predictor from the structure that really matters. This section groups filters by purpose so the reader can compare related ideas before moving to a more advanced family.

The recommended way to study this folder is to keep the baseline in mind and then move gradually from simple smoothing to more specialized decompositions and state-space ideas. That makes it easier to ask the right question: what type of unwanted variation is each filter trying to remove?

## Baseline and progressive smoothing

- [01-no-filter.md](01-no-filter.md) - keep the signal unchanged so later filters can be judged against a true baseline.
- [02-moving-average-filter.md](02-moving-average-filter.md) - smooth the series with a fixed local average.
- [03-exponential-moving-average-filter.md](03-exponential-moving-average-filter.md) - smooth while giving more weight to recent observations.
- [04-smoothing-filter.md](04-smoothing-filter.md) - apply a generic smoothing routine for light denoising.
- [05-lowess-filter.md](05-lowess-filter.md) - use local regression to follow flexible trends.
- [06-spline-filter.md](06-spline-filter.md) - control smoothness with spline fitting.

## Robust filters for spikes and irregular noise

- [07-winsor-filter.md](07-winsor-filter.md) - cap extreme values to reduce the leverage of outliers.
- [08-qes-filter.md](08-qes-filter.md) - apply a robust smoothing strategy designed for noisy fluctuations.

## Frequency and decomposition methods

- [09-fft-filter.md](09-fft-filter.md) - suppress high-frequency components in the frequency domain.
- [10-wavelet-filter.md](10-wavelet-filter.md) - denoise the signal at multiple scales with wavelets.
- [11-emd-filter.md](11-emd-filter.md) - decompose the series into intrinsic mode functions and reconstruct a cleaner signal.
- [12-robust-emd-filter.md](12-robust-emd-filter.md) - use a more robust EMD variant when noise and outliers are stronger.

## Trend, state, and seasonality

- [13-hp-filter.md](13-hp-filter.md) - separate trend and cyclical behavior with the Hodrick-Prescott filter.
- [14-kalman-filter.md](14-kalman-filter.md) - smooth the series with a state-space Kalman filter.
- [15-seasonal-adjustment-filter.md](15-seasonal-adjustment-filter.md) - remove recurring seasonal effects before forecasting.
