from keras.models import Sequential
from keras.layers import LSTM, core, Activation, Dense
from keras.layers import TimeDistributed, Flatten, Dropout
import numpy as np


import pandas as pd
import numpy as np
# import numpy as np
dataset_1 = pd.read_csv('./frame2D_set1.csv')
set1 = dataset_1.values

dataset_2 = pd.read_csv('./frame2D_set2.csv')
set2 = dataset_2.values

dataset_3 = pd.read_csv('./frame2D_set3.csv')
set3 = dataset_3.values

# dataset_y = pd.read_csv('./boolean_y.csv')
dataset_y = pd.read_csv('./gen_y.csv')
y = dataset_y.values

X = np.dstack([set1, set2, set3])
y = y

print('X shape: ',X.shape)
print('{} samples, {} time steps, {} observations at each time step, per sample\n'.format(*X.shape))

print('y shape: ',y.shape)
print('{} samples, {} time steps, boolean outcome per observation\n'.format(*y.shape))

print(X[0][2], X[0][55])
print(y[0][2], y[0][92])


model = Sequential()

model.add(LSTM(return_sequences=False, input_shape=(93, 3), units=10))
model.add(Dropout(0.5))
# model.add(TimeDistributed(Dense(1, activation='sigmoid'))) # use if target is a boolean at each timestep
model.add(Dense(1, activation='sigmoid'))

# model.add(Flatten())

model.compile(loss='binary_crossentropy', optimizer='adam')

model.fit(X, y, batch_size = 32, epochs = 100, verbose=2)
