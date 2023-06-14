# DAL Library
# version 2.1

# depends dal_transform.R
# depends ts_data.R
# depends ts_regression.R
# depends ts_preprocessing.R

# class ts_tmlp
# loadlibrary("reticulate")
# source_python('ts_tmlp.py')

import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from torch.utils.data import TensorDataset
import torch.nn.functional as F
import sys
import random


def savemodel(model, filename):
  torch.save(model, filename)
  

def loadmodel(filename):
  model = torch.load(filename)
  model.eval()
  return(model)


def savedf(data, filename):      
  data.to_csv(filename, index=False)
    

class MLPNet(nn.Module):
  def __init__(self, in_size, hidden_size, out_size):
    super(MLPNet,self).__init__()
    # hidden layer
    self.linear1 = nn.Linear(in_size, hidden_size)
    # output layer
    self.linear2 = nn.Linear(hidden_size, out_size)
      
  def forward(self, xb):
    # Get intermediate outputs using hidden layer
    out = self.linear1(xb)
    # Apply activation function
    out = F.relu(out)
    # Get predictions using output layer
    out = self.linear2(out)
    return out     


def torch_fit_mlp(epochs, lr, model, train_loader, opt_func=torch.optim.SGD, debug=False):
  # to track the training loss as the model trains
  
  train_losses = []
  # to track the average training loss per epoch as the model trains
  avg_train_losses = []
  
  criterion = nn.MSELoss()
  last_error = sys.float_info.max
  last_epoch = 0
  
  optimizer = opt_func(model.parameters(), lr)
  for epoch in range(epochs):
    ###################
    # train the model #
    ###################
    model.train() # prep model for training
    for data, target in train_loader:
      # clear the gradients of all optimized variables
      model.zero_grad()
      # forward pass: compute predicted outputs by passing inputs to the model
      output = model(data.float())
      
      #print('Going to compute loss...')
      # calculate the loss
      loss = criterion(output, target.float())
      
      #print('Done computing loss.')
      
      # backward pass: compute gradient of the loss with respect to model parameters
      loss.backward()
      # perform a single optimization step (parameter update)
      optimizer.step()
      # record training loss
      train_losses.append(loss.item())
    
    ######################    
    # validate the model #
    ######################
    model.eval() # prep model for evaluation
    
    # print training/validation statistics 
    # calculate average loss over an epoch
    train_loss = np.average(train_losses)
    avg_train_losses.append(train_loss)
    
    if (train_loss == 0):
      break
    
    if ((last_error - train_loss) > 0.001):
      last_error = train_loss
      last_epoch = epoch
      if debug:
        epoch_len = len(str(epochs))
        print_msg = (f'[{epoch:>{epoch_len}}/{epochs:>{epoch_len}}] ' +
                     f'train_loss: {train_loss:.5f}')
        print(print_msg)
        
    if (epoch - last_epoch > 100):
      break

    
    # clear lists to track next epoch
    train_losses = []
    
    if debug:
      epoch_len = len(str(epochs))
      print_msg = (f'[{epoch:>{epoch_len}}/{epochs:>{epoch_len}}] ' +
                   f'train_loss: {train_loss:.5f}')
      print(print_msg)

  return model, avg_train_losses


def create_torch_mlp(input_size, hidden_size):
  device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
  model = MLPNet(in_size=int(input_size), hidden_size=int(hidden_size), out_size=1).to(device)
  return(model)
	

def train_torch_mlp(model, df_train, n_epochs = 10000, deep_debug=False, reproduce=True):
  if (reproduce):
    torch.manual_seed(0)    
    np.random.seed(0)
    random.seed(0)

  n_epochs = int(n_epochs)
  X_train = df_train.drop('t0', axis=1).to_numpy()
  y_train = df_train.t0.to_numpy()
  
  X_train = X_train[:, :, np.newaxis]
  y_train = y_train[:, np.newaxis]
  
  train_x = torch.from_numpy(X_train)
  train_y = torch.from_numpy(y_train)
  
  train_x = train_x.squeeze()
  
  train_ds = TensorDataset(train_x, train_y)
  
  BATCH_SIZE = 8
  train_loader = torch.utils.data.DataLoader(train_ds, batch_size = BATCH_SIZE, shuffle = False)
  
  model = model.float()
  model, train_loss = torch_fit_mlp(n_epochs, 1e-5, model, train_loader, opt_func=torch.optim.Adam, debug = deep_debug)
  
  return model

	

def predict_torch_mlp(model, df_test):
  X_test = df_test.drop('t0', axis=1).to_numpy()
  y_test = df_test.t0.to_numpy()
  
  X_test = X_test[:, :, np.newaxis]
  y_test = y_test[:, np.newaxis]
  
  test_x = torch.from_numpy(X_test)
  test_y = torch.from_numpy(y_test)
  
  test_x = torch.squeeze(test_x, 2)

  test_ds = TensorDataset(test_x, test_y)
  
  BATCH_SIZE = 8
  test_loader = torch.utils.data.DataLoader(test_ds, batch_size = BATCH_SIZE, shuffle = False)
  
  outputs = []
  with torch.no_grad():
    for xb, yb in test_loader:
      output = model(xb.float())
      outputs.append(output)
  
  test_predictions = torch.vstack(outputs).squeeze(1)  
  test_predictions = test_predictions.numpy()
  
  return test_predictions
