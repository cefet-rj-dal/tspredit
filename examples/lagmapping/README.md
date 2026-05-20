## Lag Mapping

Lag mapping controls which lagged attributes are actually delivered to a
sliding-window predictor after the time series has been converted to `ts_data`.
The default behavior of `tspredit` is still available through `recent`, which
 keeps the most recent `input_size` observations.

The examples below show each mapping strategy in isolation while keeping the
same forecasting workflow.

Inside `ts_regsw` models, the lag mapper is fitted after preprocessing. So if a
preprocessor changes the window representation, the selected lag positions refer
to that transformed geometry rather than to the raw original window.

## Positional baselines

- [01-recent-lag-mapping.md](01-recent-lag-mapping.md) - keep the most recent lags and reproduce the historical behavior of the package.
- [02-even-lag-mapping.md](02-even-lag-mapping.md) - spread the selected lags evenly across the available window.
- [03-geometric-lag-mapping.md](03-geometric-lag-mapping.md) - emphasize recent history while still sampling farther lags.

## Correlation-driven mappings

- [04-acf-lag-mapping.md](04-acf-lag-mapping.md) - rank lags by autocorrelation magnitude.
- [05-pacf-lag-mapping.md](05-pacf-lag-mapping.md) - rank lags by partial autocorrelation magnitude.
- [06-peaks-lag-mapping.md](06-peaks-lag-mapping.md) - keep prominent local maxima from the correlation profile.
- [07-seasonal-lag-mapping.md](07-seasonal-lag-mapping.md) - prioritize seasonal multiples from an estimated or supplied period.
- [08-acf-seasonal-lag-mapping.md](08-acf-seasonal-lag-mapping.md) - mix seasonal lags with ACF completion.
- [09-pacf-seasonal-lag-mapping.md](09-pacf-seasonal-lag-mapping.md) - mix seasonal lags with PACF completion.
- [10-blocks-lag-mapping.md](10-blocks-lag-mapping.md) - expand neighborhoods around the strongest correlation centers.

## Supervised mappings

- [11-mi-lag-mapping.md](11-mi-lag-mapping.md) - rank lags by discretized mutual information with the target.
- [12-mrmr-lag-mapping.md](12-mrmr-lag-mapping.md) - balance relevance to the target with low redundancy among selected lags.

## Comparative view

- [13-lag-mapping-comparison.md](13-lag-mapping-comparison.md) - compare the selected lags on synthetic series with short-memory, seasonal, and multiscale behavior.
