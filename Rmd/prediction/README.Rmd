# Prediction Examples

This section is where the previous components come together into forecasting models. The examples are grouped by model family so the reader can first understand what each family assumes about the series and only after that move to tuning workflows.

A useful way to read this folder is to treat ARIMA as the baseline for protocol and comparison, then move through classical machine-learning regressors, then neural models, and finally inspect automated search. That sequence makes it clearer which gains come from the learner itself and which ones come from the surrounding pipeline.

## Classical baseline

- [01-arima-baseline.md](01-arima-baseline.md) - fit ARIMA with automatic order selection and recursive forecasting.

## Classical machine-learning regressors

- [02-knn-regression.md](02-knn-regression.md) - use nearest-neighbor regression on sliding windows.
- [03-svm-regression.md](03-svm-regression.md) - fit support vector regression for nonlinear forecasting.
- [04-random-forest-regression.md](04-random-forest-regression.md) - model nonlinear relationships with random forests.

## Feedforward neural models

- [05-mlp-regression.md](05-mlp-regression.md) - train a multilayer perceptron on lagged inputs.
- [06-elm-regression.md](06-elm-regression.md) - use an Extreme Learning Machine for fast neural regression.

## Sequence-oriented neural models

- [07-conv1d-regression.md](07-conv1d-regression.md) - detect local temporal motifs with a 1D convolutional network.
- [08-lstm-regression.md](08-lstm-regression.md) - model sequential dependencies with an LSTM network.

## Model search and integrated tuning

- [09-model-tuning.md](09-model-tuning.md) - search over model and window hyperparameters in a controlled workflow.
- [10-integrated-tuning.md](10-integrated-tuning.md) - optimize preprocessing, augmentation, and model parameters together.
