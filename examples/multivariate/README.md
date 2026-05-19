# Multivariate Forecasting Examples

This section introduces the multivariate workflow added to `tspredit` 2.0. The
guiding idea is still target-centered forecasting: the package keeps one series
as the main prediction target `y`, while the auxiliary variables `x1, ..., xn`
either enter as aligned regressors in the singular branch (`sw = 1`) or receive
their own forecasting pipelines in the sliding-window branch (`sw > 1`).

The examples in this folder now follow the most didactic order:

- first the aligned multivariate data object
- then the singular multivariate branch built on `ts_reg_mv`
- then the sliding-window multivariate branch built on `ts_regsw_mv`

## Current examples

### Block 1: Data and alignment

- [01-build-ts-data-mv.md](01-build-ts-data-mv.md) - construct the aligned multivariate object and inspect how `y` and `x1, ..., xn` remain synchronized over time.
- [02-singular-train-test-split-mv.md](02-singular-train-test-split-mv.md) - inspect how aligned multivariate observations are split for the singular branch (`sw = 1`).

### Block 2: Singular multivariate branch (`ts_reg_mv`)

- [03-linear-regression-mv.md](03-linear-regression-mv.md) - use a formula-based linear regression as the simplest target-centered singular multivariate model.
- [04-arimax-regression-mv.md](04-arimax-regression-mv.md) - extend the ARIMA branch to aligned auxiliaries through `ts_arimax()` and auxiliary support models.
- [05-vector-autoregression-mv.md](05-vector-autoregression-mv.md) - fit a vector autoregression over the whole system while preserving a distinguished target `y`.

### Block 3: Sliding-window multivariate branch (`ts_regsw_mv`)

- [06-materialize-windows-mv.md](06-materialize-windows-mv.md) - materialize the lagged multivariate blocks and inspect the individual delayed terms exposed to the learners.
- [07-train-test-split-windowed-mv.md](07-train-test-split-windowed-mv.md) - inspect how the lagged multivariate representation should be split for sliding-window forecasting.
- [08-deterministic-auxiliary-models.md](08-deterministic-auxiliary-models.md) - inspect when auxiliary variables should use deterministic pipelines such as `ts_deterministic()`, `ts_periodic()`, and `ts_persist()`.
- [09-target-centered-regression.md](09-target-centered-regression.md) - build a complete multivariate forecasting system with deterministic auxiliary variables and inspect one-step and multistep prediction.
- [10-stock-close-regression.md](10-stock-close-regression.md) - forecast stock closing prices from non-deterministic auxiliary variables and inspect a mixed workflow with MLP, ELM, DARIMA, and WARMA submodels.
- [11-stock-close-knn-regression.md](11-stock-close-knn-regression.md) - keep the stock scenario fixed and use KNN as the target learner.
- [12-stock-close-svm-regression.md](12-stock-close-svm-regression.md) - keep the stock scenario fixed and use SVM as the target learner.
- [13-stock-close-random-forest-regression.md](13-stock-close-random-forest-regression.md) - keep the stock scenario fixed and use Random Forest as the target learner.
- [14-stock-close-mlp-regression.md](14-stock-close-mlp-regression.md) - keep the stock scenario fixed and use MLP as the target learner.
- [15-stock-close-elm-regression.md](15-stock-close-elm-regression.md) - keep the stock scenario fixed and use ELM as the target learner.
- [16-stock-close-conv1d-regression.md](16-stock-close-conv1d-regression.md) - keep the stock scenario fixed and use Conv1D as the target learner.
- [17-stock-close-lstm-regression.md](17-stock-close-lstm-regression.md) - keep the stock scenario fixed and use LSTM as the target learner.

### Block 4: Singular stock battery (`ts_reg_mv`)

- [18-stock-close-linear-regression-mv.md](18-stock-close-linear-regression-mv.md) - revisit the stock scenario in the singular branch with formula-based multivariate linear regression.
- [19-stock-close-arimax-regression-mv.md](19-stock-close-arimax-regression-mv.md) - revisit the stock scenario in the singular branch with `ts_arimax()` and univariate support models for the auxiliaries.
- [20-stock-close-vector-autoregression-mv.md](20-stock-close-vector-autoregression-mv.md) - revisit the stock scenario in the singular branch with a joint vector autoregression that still keeps `close` as the distinguished target.
