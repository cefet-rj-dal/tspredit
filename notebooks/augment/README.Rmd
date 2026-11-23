# Augmentation Examples

Augmentation creates additional training windows so the predictor can see plausible variations of the recent history instead of learning from a single observed path only. In forecasting, this must be done carefully: the synthetic windows need to preserve temporal meaning rather than act as arbitrary noise.

The grouping below reflects that learning goal. Start with the baseline case, then inspect local perturbations that modify shape, and finish with the methods that explicitly emphasize recent behavior.

## Baseline for comparison

- [01-no-augmentation.md](01-no-augmentation.md) - keep the original windows unchanged so every later gain can be compared with the reference case.

## Local perturbations and shape changes

- [02-jitter-augmentation.md](02-jitter-augmentation.md) - add small random perturbations to improve robustness to measurement noise.
- [03-flip-augmentation.md](03-flip-augmentation.md) - mirror windows to create symmetric local variations.
- [04-stretch-augmentation.md](04-stretch-augmentation.md) - amplify variations inside the window to simulate stronger local movements.
- [05-shrink-augmentation.md](05-shrink-augmentation.md) - compress variations inside the window to simulate milder patterns.
- [06-wormhole-augmentation.md](06-wormhole-augmentation.md) - replace some lags with older values to create plausible alternative histories.

## Recency-aware augmentation

- [07-awareness-augmentation.md](07-awareness-augmentation.md) - bias the augmented training set toward more recent patterns.
- [08-aware-smoothing-augmentation.md](08-aware-smoothing-augmentation.md) - combine recency emphasis with smoothing so recent structure is preserved with less noise.
