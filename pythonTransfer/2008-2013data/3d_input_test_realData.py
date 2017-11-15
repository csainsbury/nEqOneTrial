from keras.models import Sequential
from keras.layers import LSTM, core, Activation, Dense
from keras.layers import TimeDistributed, Flatten, Dropout
import numpy as np
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()


import pandas as pd
import numpy as np
# import numpy as np
dataset_1 = pd.read_csv('./interpolatedTS_mortality_hba1c_5y_2008-13.csv')
set1 = dataset_1.values
set1 = sc.fit_transform(set1)

dataset_2 = pd.read_csv('./interpolatedTS_mortality_sbp_5y_2008-13.csv')
set2 = dataset_2.values
set2 = sc.fit_transform(set2)

dataset_3 = pd.read_csv('./interpolatedTS_mortality_bmi_5y_2008-13.csv')
set3 = dataset_3.values
set3 = sc.fit_transform(set3)


# dataset_y = pd.read_csv('./boolean_y.csv')
dataset_y = pd.read_csv('./1y_mortality_5y_30bins_2008-13.csv')
y = dataset_y.values

X = np.dstack([set1, set2, set3])
y = y

print('X shape: ',X.shape)
print('{} samples, {} time steps, {} observations at each time step, per sample\n'.format(*X.shape))

print('y shape: ',y.shape)
print('{} samples, {} time steps, boolean outcome per observation\n'.format(*y.shape))

# split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)


# build RNN model
model = Sequential()

model.add(LSTM(return_sequences=True, input_shape=(30, 3), units=128))
model.add(Dropout(0.5))
# model.add(LSTM(16, return_sequences=True))
# model.add(Dropout(0.5))
model.add(LSTM(8))
model.add(Dropout(0.5))
# model.add(TimeDistributed(Dense(1, activation='sigmoid'))) # use if target is a boolean at each timestep
model.add(Dense(1, activation='sigmoid'))

# model.add(Flatten())
# compile model
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

model.fit(X_train, y_train, batch_size = 256, epochs = 4)
score = model.evaluate(X_test, y_test, batch_size=256)

y_pred_asNumber = model.predict(X_test)
from sklearn.metrics import roc_auc_score
roc_auc_score(y_test, y_pred_asNumber)

# plot ROC
from sklearn import metrics
import matplotlib.pyplot as plt

fpr, tpr, _ = metrics.roc_curve(y_test, y_pred_asNumber)

fpr = fpr # false_positive_rate
tpr = tpr # true_positive_rate

# This is the ROC curve
plt.plot(fpr,tpr)
# plt.show()
plt.savefig('roc_mortality.png')
auc = np.trapz(tpr, fpr)

print(auc)
