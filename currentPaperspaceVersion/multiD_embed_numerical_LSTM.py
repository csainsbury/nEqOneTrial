
from keras.layers import Input, Embedding, Reshape, merge, Dropout, Dense, LSTM, core, Activation
from keras.layers import TimeDistributed, Flatten

from keras.engine import Model
from keras.models import Sequential

import numpy as np
import pandas as pd

from sklearn.preprocessing import StandardScaler
sc = StandardScaler()

'''
data prep
'''

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
X = np.dstack([set1_transformed, set2_transformed, set3_transformed, set4])
y = y

# split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)

# generate test subgroups
X_train_values = X_train[:, :30, :]
X_test_values = X_test[:, :30, :]

'''
X_train_set1 = X_train[:, :30, 0]
X_train_set2 = X_train[:, :30, 1]
X_train_set3 = X_train[:, :30, 2]
X_train_set4 = X_train[:, :30, 3]
'''

X_train_set1_to_3 = X_train[:, :30, 0:3]
X_train_set4 = X_train[:, :30, 3]

X_test_set1_to_3 = X_test[:, :30, 0:3]
X_test_set4 = X_test[:, :30, 3]

'''
RNN setup and run
'''

# a = input the drug dataset (2-dimensional: IDs, timesteps)
a = Input(shape = (30, ), dtype='int16')
# embed drug layer
emb = Embedding(1200,1200)(a)

# b = input the numerical data (3-dimensional: IDs, timesteps, dimensions(n parameters))
b = Input(shape = (30, 3))

# merge embedded and numerical data
merged = merge([emb, b], mode='concat')


# build the RNN model
rnn = Sequential([
    LSTM(return_sequences=True, input_shape = (30, 1203), units=128),
    Dropout(0.5),
    LSTM(32, return_sequences = True),
    Dropout(0.5),
    LSTM(4),
    Dropout(0.5),
    Dense(1, activation='sigmoid'),
])(merged)

M = Model(input=[a,b], output=[rnn])

M.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

## fit and evaluate
M.fit([X_train_set4, X_train_set1_to_3], y_train, batch_size = 64, epochs = 8)
score = M.evaluate([X_test_set4, X_test_set1_to_3], y_test, batch_size=64)

y_pred_asNumber = M.predict([X_test_set4, X_test_set1_to_3])
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
