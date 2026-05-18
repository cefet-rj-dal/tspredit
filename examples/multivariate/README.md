# Multivariate Forecasting Examples

This section introduces the multivariate workflow added to `tspredit` 2.0. The
guiding idea is still target-centered forecasting: the package keeps one series
as the main prediction target `y`, while the auxiliary variables `x1, ..., xn`
receive their own forecasting pipelines and feed the recursive multistep
process.

The examples in this folder explain the new abstractions in the order a reader
typically needs them:

- the aligned multivariate data object
- the variable-specific pipeline specification
- the multivariate orchestrator that reuses the existing univariate learners

## Current examples

- [01-target-centered-regression.md](01-target-centered-regression.md) - build a complete multivariate forecasting system from an existing benchmark in the package and inspect one-step and multistep prediction.
