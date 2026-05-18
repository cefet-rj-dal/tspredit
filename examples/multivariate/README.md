# Multivariate Forecasting Examples

This section introduces the multivariate workflow added to `tspredit` 2.0. The
guiding idea is still target-centered forecasting: the package keeps one series
as the main prediction target `y`, while the auxiliary variables `x1, ..., xn`
receive their own forecasting pipelines and feed the recursive multistep
process.

The examples in this folder explain the new abstractions in the order a reader
typically needs them:

- first the aligned multivariate data object
- then the variable-specific pipeline specification
- then the multivariate orchestrator that reuses the existing univariate learners

## Current examples

### Block 1: Data and alignment

- [01-build-ts-data-mv.md](01-build-ts-data-mv.md) - construct the aligned multivariate object and inspect how `y` and `x1, ..., xn` remain synchronized over time.

### Block 2: Forecasting workflow

- [02-target-centered-regression.md](02-target-centered-regression.md) - build a complete multivariate forecasting system from an existing benchmark in the package and inspect one-step and multistep prediction.
