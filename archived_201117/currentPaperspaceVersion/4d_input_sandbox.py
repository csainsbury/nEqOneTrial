from keras.models import Sequential
from keras.layers import LSTM, core, Activation, Dense
from keras.layers import TimeDistributed, Flatten, Dropout
import numpy as np
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()


import pandas as pd
import numpy as np
# import numpy as np
dataset_1 = pd.read_csv('./inputFiles/hba1c_export.csv')
set1 = dataset_1.values

sc_hba1c = StandardScaler()
set1_transformed = sc_hba1c.fit_transform(set1[:, :30])
set1_concat = np.concatenate((set1_transformed, set1[:, 30:36]), axis = 1)

dataset_2 = pd.read_csv('./inputFiles/sbp_export.csv')
set2 = dataset_2.values

sc_sbp = StandardScaler()
set2_transformed = sc_sbp.fit_transform(set2[:, :30])
set2_concat = np.concatenate((set2_transformed, set2[:, 30:36]), axis = 1)

dataset_3 = pd.read_csv('./inputFiles/bmi_export.csv')
set3 = dataset_3.values

sc_bmi = StandardScaler()
set3_transformed = sc_bmi.fit_transform(set3[:, :30])
set3_concat = np.concatenate((set3_transformed, set3[:, 30:36]), axis = 1)

# drug combination dataset. read in as numerical values - need to embed at later stage
dataset_4 = pd.read_csv('./inputFiles/drugExport.csv')
set4 = dataset_4.values

# dataset_y = pd.read_csv('./boolean_y.csv')
dataset_y = pd.read_csv('./outcomeFiles/hba1c_outcome.csv')
y = dataset_y.values
y = (y < (-10))

# X = np.dstack([set1_concat, set2_concat, set3_concat])
X = np.dstack([set1, set2, set3, set4])
y = y

# X[:, :, 0] - hba1c data # X[:, :, 1] - sbp data # X[:, :, 2] - bmi data

print('X shape: ',X.shape)
print('{} samples, {} time steps, {} observations at each time step, per sample\n'.format(*X.shape))

print('y shape: ',y.shape)
print('{} samples, {} time steps, boolean outcome per observation\n'.format(*y.shape))

# split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)

# generate test subgroups
X_train_values = X_train[:, :30, :]
X_test_values = X_test[:, :30, :]

#X_test_hba1c_data = X_test[:, 30:36, 0]
#X_test_sbp_data = X_test[:, 30:36, 1]
#X_test_bmi_data = X_test[:, 30:36, 2]

# save out summary data for use in survival analysis etc
#np.savetxt('./X_test_hba1cReference.csv', X_test_hba1c_data, fmt='%.18e', delimiter=',')
#np.savetxt('./X_test_sbpReference.csv', X_test_sbp_data, fmt='%.18e', delimiter=',')
#np.savetxt('./X_test_bmiReference.csv', X_test_bmi_data, fmt='%.18e', delimiter=',')
#np.savetxt('./y_test.csv', y_test, fmt='%.18e', delimiter=',')

from keras.layers import Input, Embedding, Reshape, merge, Flatten
from keras.engine import Model

# explicitly set parameters for debugginh
numberOfIDs = 23072
numberOfCols = 30
embedding_vector_length = 32
numberOfCombinations = 1000

a = Input(shape = (23072, 30))
b = Input(shape = (23072, 30))
c = Input(shape = (23072, 30))
d = Input(shape = (23072, 30))

em = Embedding(numberOfCombinations, output_dim = 256)(a)
b2 = Reshape((23072, 30, 1))(b)
c2 = Reshape((23072, 30, 1))(c)
d2 = Reshape((23072, 30, 1))(d)

merged = merge([em, b2, c2, d2], mode = 'concat')

rnn = LSTM(128)(merged)



# build RNN model
rnn = Sequential()

rnn.add(LSTM(return_sequences=True, input_shape=(30, 3), units=128))
rnn.add(Dropout(0.5))
# model.add(LSTM(16, return_sequences=True))
# model.add(Dropout(0.5))
rnn.add(LSTM(8))
rnn.add(Dropout(0.5))
# model.add(TimeDistributed(Dense(1, activation='sigmoid'))) # use if target is a boolean at each timestep
rnn.add(Dense(1, activation='sigmoid'))

model = Model(input = [a,b,c, d], output = [rnn])

# model.add(Flatten())
# compile model
model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

model.fit(X_train_values, y_train, batch_size = 32, epochs = 24)
score = model.evaluate(X_test_values, y_test, batch_size=32)

y_pred_asNumber = model.predict(X_test_values)
from sklearn.metrics import roc_auc_score
roc_auc_score(y_test, y_pred_asNumber)

# save out prediction
#np.savetxt('./X_test_prediction.csv', y_pred_asNumber, fmt='%.18e', delimiter=',')


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
