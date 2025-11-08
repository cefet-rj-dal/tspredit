# Augmentation Examples

This folder contains time series data augmentation examples. Each example shows how to transform windows or sequences to diversify training data while preserving useful structure.

- [ts_aug_awareness.md](ts_aug_awareness.md) — Prioritizes recent samples via time-decay weighting/sampling to emphasize up-to-date dynamics.
- [ts_aug_awaresmooth.md](ts_aug_awaresmooth.md) — Combines recency-aware selection with smoothing to reduce noise while focusing on current regimes.
- [ts_aug_flip.md](ts_aug_flip.md) — Mirrors windows around a central tendency to create symmetric pattern variations.
- [ts_aug_jitter.md](ts_aug_jitter.md) — Adds small random noise (jitter) to increase robustness without changing global structure.
- [ts_aug_none.md](ts_aug_none.md) — Baseline with no augmentation; helpful for comparisons.
- [ts_aug_shrink.md](ts_aug_shrink.md) — Shrinks amplitude or time scale to simulate lower-energy patterns.
- [ts_aug_stretch.md](ts_aug_stretch.md) — Stretches amplitude or time scale to simulate higher-energy or elongated patterns.
- [ts_aug_wormhole.md](ts_aug_wormhole.md) — Replaces some lags with older values (temporal warping) to create plausible alternative histories.

