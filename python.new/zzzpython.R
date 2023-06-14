## Imports dos arquivos Python (os três tem os mesmos imports):
# import torch
# import torch.nn as nn
# from torch.utils.data import Dataset, DataLoader
# import pandas as pd
# import numpy as np
# import matplotlib.pyplot as plt
# import os
# from torch.utils.data import TensorDataset
# import torch.nn.functional as F
# import sys
# import random

## Pacotes instalados no Python (instalação feita via prompt),até conseguir dar source no arquivo:
# python3 -m pip install --upgrade pip setuptools wheel
# apt install python3.10-venv
# pip3 install --upgrade pip
# pip3 install -U torch
# pip3 install -U pyreadr
# pip3 install -U matplotlib

## Depois disso é possível rodar o exemplo:
# https://nbviewer.org/github/eogasawara/mydal/blob/main/examples_timeseries/ts_tlstm.ipynb

## Documentação sobre o uso do reticulate em pacotes R
# https://rstudio.github.io/reticulate/articles/package.html

## global reference to environment
python_env <- NULL

#'@import reticulate
.onLoad <- function(libname, pkgname) {
  # if (! reticulate::py_module_available('torch')) {
  #   print('Módulo torch indisponível.')
  #   print('Instale manualmente ou use dal::install_python_dependencies()')
  # }
  # if (! reticulate::py_module_available('pyreadr')) {
  #   print('Módulo pyreadr indisponível.')
  #   print('Instale manualmente ou use dal::install_python_dependencies()')
  # }
  # if (! reticulate::py_module_available('matplotlib')) {
  #   print('Módulo matplotlib indisponível.')
  #   print('Instale manualmente ou use dal::install_python_dependencies()')
  # }

  ## use superassignment to update global reference
  python_env <<- new.env()

  ## loads scripts to environment
  path <- system.file(package="dal")

  reticulate::source_python(paste(path, "python/ts_tconv1d.py", sep="/"), envir=python_env)
  reticulate::source_python(paste(path, "python/ts_tlstm.py", sep="/"), envir=python_env)
  reticulate::source_python(paste(path, "python/ts_tmlp.py", sep="/"), envir=python_env)
}


#'@title
#'@description
#'@details
#'
#'@param method
#'@param conda
#'@return
#'@examples
#'@import reticulate
#'@export
install_python_dependencies <- function(method = "auto", conda = "auto") {
  reticulate::py_install("torch", method = method, conda = conda)
  reticulate::py_install("pandas", method = method, conda = conda)
  reticulate::py_install("numpy", method = method, conda = conda)
  reticulate::py_install("matplotlib", method = method, conda = conda)
  reticulate::py_install("os", method = method, conda = conda)
  reticulate::py_install("sys", method = method, conda = conda)
  reticulate::py_install("random", method = method, conda = conda)
}
