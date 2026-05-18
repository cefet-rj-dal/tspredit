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
- [02-materialize-windows-mv.md](02-materialize-windows-mv.md) - materialize the lagged multivariate blocks and inspect the individual delayed terms exposed to the learners.
- [03-train-test-split-mv.md](03-train-test-split-mv.md) - inspect how the aligned object and its lagged materializations behave across the time-aware train/test split.

### Block 2: Forecasting workflow

- [04-deterministic-auxiliary-models.md](04-deterministic-auxiliary-models.md) - inspect when auxiliary variables should use deterministic pipelines such as `ts_deterministic()`, `ts_periodic()`, and `ts_persist()`.
- [05-target-centered-regression.md](05-target-centered-regression.md) - build a complete multivariate forecasting system with deterministic auxiliary variables and inspect one-step and multistep prediction.
- [06-stock-close-regression.md](06-stock-close-regression.md) - forecast stock closing prices from non-deterministic auxiliary variables and inspect a mixed workflow with MLP, ELM, DARIMA, and WARMA submodels.
