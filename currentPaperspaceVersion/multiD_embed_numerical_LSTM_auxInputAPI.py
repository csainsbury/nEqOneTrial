
from keras.layers import Input, Embedding, Reshape, merge, Dropout, Dense, LSTM, core, Activation
from keras.layers import TimeDistributed, Flatten, concatenate
from keras.layers.convolutional import Conv1D
from keras.layers.convolutional import MaxPooling1D

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
hba1cSet = set1_transformed
set1_concat = np.concatenate((set1_transformed, set1[:, 30:36]), axis = 1)

dataset_2 = pd.read_csv('./inputFiles/sbp_export.csv')
set2 = dataset_2.values

sc_sbp = StandardScaler()
set2_transformed = sc_sbp.fit_transform(set2[:, :30])
sbpSet = set2_transformed
set2_concat = np.concatenate((set2_transformed, set2[:, 30:36]), axis = 1)

dataset_8 = pd.read_csv('./inputFiles/dbp_export.csv')
set8 = dataset_8.values

sc_dbp = StandardScaler()
set8_transformed = sc_dbp.fit_transform(set8[:, :30])
dbpSet = set8_transformed
set8_concat = np.concatenate((set8_transformed, set8[:, 30:36]), axis = 1)

dataset_3 = pd.read_csv('./inputFiles/bmi_export.csv')
set3 = dataset_3.values

sc_bmi = StandardScaler()
set3_transformed = sc_bmi.fit_transform(set3[:, :30])
bmiSet = set3_transformed
set3_concat = np.concatenate((set3_transformed, set3[:, 30:36]), axis = 1)

# drug combination dataset. read in as numerical values - need to embed at later stage
dataset_4 = pd.read_csv('./inputFiles/drugExport.csv')
set4 = dataset_4.values
drugSet = set4

# auxilliary inputFiles
# aux 1 - age
dataset_5 = pd.read_csv('./inputFiles/age_export.csv')
set5 = dataset_5.values
# set5 = set5.reshape(-1, 1)

sc_age = StandardScaler()
set5_transformed = sc_age.fit_transform(set5[:, :30])
ageSet = set5_transformed

# aux 2 - gender
dataset_6 = pd.read_csv('./inputFiles/gender_export.csv')
set6 = dataset_6.values
genderSet = set6
'''
set6 = set6[:, 0]

# encode categorical data
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
labelencoder_gender = LabelEncoder()
set6 = labelencoder_gender.fit_transform(set6)
set6 = set6.reshape(-1, 1)
onehotencoder = OneHotEncoder(categorical_features = 'all')
set6 = onehotencoder.fit_transform(set6).toarray()
'''

# aux 3 - diabetes duration
dataset_7 = pd.read_csv('./inputFiles/duration_export.csv')
set7 = dataset_7.values

sc_duration = StandardScaler()
set7_transformed = sc_duration.fit_transform(set7[:, :30])
durationSet = set7_transformed
# set2_concat = np.concatenate((set2_transformed, set2[:, 30:36]), axis = 1)

# dataset_y = pd.read_csv('./boolean_y.csv')
dataset_y_hba1c = pd.read_csv('./outcomeFiles/hba1c_outcome.csv')
y_hba1c = dataset_y_hba1c.values

dataset_y_sbp = pd.read_csv('./outcomeFiles/sbp_outcome.csv')
y_sbp = dataset_y_sbp.values

#y = ((y < (60)) & (y > (48)))
y = (y_hba1c < (-5))
#y = (y == 1)
dataset_y_bmi = pd.read_csv('./outcomeFiles/bmi_outcome.csv')
y_bmi = dataset_y_bmi.values

#y = ((y1 < (-10)) | (y2 < 0))


# X = np.dstack([set1_concat, set2_concat, set3_concat])
X = np.dstack([hba1cSet, sbpSet, bmiSet, dbpSet, ageSet, genderSet, durationSet, drugSet])
y = y

# split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)

# generate train / test subgroups
X_train_values = X_train[:, :30, :]
X_test_values = X_test[:, :30, :]

X_train_numericalTS = X_train[:, :30, 0:4]
X_train_drugs = X_train[:, :30, 7]
# X_train_age = X_train[:, :30, 3]
X_train_age = X_train[:, 1, 4] # reduce age to a single value
X_train_age = X_train_age.reshape(-1, 1) # reshape to a (nrow, 1) array
#
X_train_gender = X_train[:, 1, 5] # reduce gender to a single value
X_train_gender = X_train_gender.reshape(-1, 1) # reshape to a (nrow, 1) array
#
X_train_duration = X_train[:, 1, 6] # reduce gender to a single value
X_train_duration = X_train_duration.reshape(-1, 1) # reshape to a (nrow, 1) array


X_test_numericalTS = X_test[:, :30, 0:4]
X_test_drugs = X_test[:, :30, 7]
# X_test_age = X_test[:, :30, 3]
X_test_age_forInverseTransform = X_test[:, :, 4]
X_test_age = X_test[:, 1, 4]
X_test_age = X_test_age.reshape(-1, 1)
#
X_test_gender = X_test[:, 1, 5]
X_test_gender = X_test_gender.reshape(-1, 1)
#
X_test_duration = X_test[:, 1, 6] # reduce gender to a single value
X_test_duration = X_test_duration.reshape(-1, 1) # reshape to a (nrow, 1) array


# concatenate non-TS elements to generate auxilliay input
aux_train = np.column_stack((X_train_age, X_train_gender, X_train_duration))
aux_test = np.column_stack((X_test_age, X_test_gender, X_test_duration))


'''
RNN setup and run
'''

# variables to feed into network
auxInput_ncols = len(aux_train[0])
denseLayerNodes = 64
lstm_layer_1 = 128
lstm_layer_2 = 8

# a = input the drug dataset (2-dimensional: IDs, timesteps)
drug_set = Input(shape = (30, ), dtype='int32', name = 'drug_set')
# embed drug layer
emb = Embedding(input_dim = 4000, output_dim = 8)(drug_set) # lower output dimensions seems better

# numericTS_set = input the numerical data (3-dimensional: IDs, timesteps, dimensions(n parameters))
numericTS_set = Input(shape = (30, 4), name = 'numericTS_set')

# merge embedded and numerical data
# merged = keras.layers.concatenate([emb, numericTS_set])
merged = merge([emb, numericTS_set], mode='concat')

lstm_out = LSTM(return_sequences=True, input_shape = (30, 12), units=lstm_layer_1)(merged)
lstm_out = Dropout(0.5)(lstm_out)
lstm_out = LSTM(return_sequences=False, units=lstm_layer_2)(lstm_out)

# auxiliary_output = Dense(1, activation='sigmoid', name='aux_output')(lstm_out)
auxiliary_output = Dense(y.shape[1])(lstm_out)

auxiliary_input = Input(shape=(auxInput_ncols,), name='aux_input')
# x = merge([lstm_out, auxiliary_input], mode = 'concat')
x = concatenate([lstm_out, auxiliary_input])

x = Dense(denseLayerNodes, activation='relu')(x)
x = Dropout(0.5)(x)
x = Dense(denseLayerNodes, activation='relu')(x)
x = Dropout(0.5)(x)
x = Dense(denseLayerNodes, activation='relu')(x)

# add the main logistic regression layer
main_output = Dense(1, activation='sigmoid', name='main_output')(x)

model = Model(inputs=[drug_set, numericTS_set, auxiliary_input], outputs=[main_output, auxiliary_output])

model.compile(optimizer='adam', loss='binary_crossentropy', loss_weights=[0.3, 0.4])

model.fit([X_train_drugs, X_train_numericalTS, aux_train], [y_train, y_train], epochs=6, batch_size=128)


y_pred_asNumber = model.predict([X_test_drugs, X_test_numericalTS, aux_test])
from sklearn.metrics import roc_auc_score
mainOutput = roc_auc_score(y_test, y_pred_asNumber[0])
auxOutput = roc_auc_score(y_test, y_pred_asNumber[1])

print(mainOutput)
print(auxOutput)

# write out y_pred_asNumber files for plotting
# original
# np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_original.csv', y_pred_asNumber[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_original.csv', y_pred_asNumber[0], fmt='%.18e', delimiter=',')

# nil therapy for last year
X_test_drugs_nil = X_test_drugs
X_test_drugs_nil[:, 24:30] = 784
y_pred_asNumber_nil = model.predict([X_test_drugs_nil, X_test_numericalTS, aux_test])
# np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_nil.csv', y_pred_asNumber_nil[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_nil.csv', y_pred_asNumber_nil[0], fmt='%.18e', delimiter=',')

# MF only therapy for last year
X_test_drugs_MF = X_test_drugs
X_test_drugs_MF[:, 24:30] = 756
y_pred_asNumber_MF = model.predict([X_test_drugs_MF, X_test_numericalTS, aux_test])
#np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF.csv', y_pred_asNumber_MF[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF.csv', y_pred_asNumber_MF[0], fmt='%.18e', delimiter=',')

# MF only therapy for last year
X_test_drugs_SU = X_test_drugs
X_test_drugs_SU[:, 24:30] = 794
y_pred_asNumber_SU = model.predict([X_test_drugs_SU, X_test_numericalTS, aux_test])
#np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF.csv', y_pred_asNumber_MF[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_SU.csv', y_pred_asNumber_SU[0], fmt='%.18e', delimiter=',')

# MF and SU only therapy for last year
X_test_drugs_MF_SU = X_test_drugs
X_test_drugs_MF_SU[:, 24:30] = 775
y_pred_asNumber_MF_SU = model.predict([X_test_drugs_MF_SU, X_test_numericalTS, aux_test])
#np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_SU.csv', y_pred_asNumber_MF_SU[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_SU.csv', y_pred_asNumber_MF_SU[0], fmt='%.18e', delimiter=',')

# MF and bd Insulin only therapy for last year
X_test_drugs_MF_bdIns = X_test_drugs
X_test_drugs_MF_bdIns[:, 24:30] = 720
y_pred_asNumber_MF_bdIns = model.predict([X_test_drugs_MF_bdIns, X_test_numericalTS, aux_test])
#p.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_bIns.csv', y_pred_asNumber_MF_bIns[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_bdIns.csv', y_pred_asNumber_MF_bdIns[0], fmt='%.18e', delimiter=',')

# MF and SGLT2 only therapy for last year
X_test_drugs_MF_SGLT2 = X_test_drugs
X_test_drugs_MF_SGLT2[:, 24:30] = 765
y_pred_asNumber_MF_SGLT2 = model.predict([X_test_drugs_MF_SGLT2, X_test_numericalTS, aux_test])
#np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_SGLT2.csv', y_pred_asNumber_MF_SGLT2[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_SGLT2.csv', y_pred_asNumber_MF_SGLT2[0], fmt='%.18e', delimiter=',')

# MF and GLP1 only therapy for last year
X_test_drugs_MF_GLP1 = X_test_drugs
X_test_drugs_MF_GLP1[:, 24:30] = 646
y_pred_asNumber_MF_GLP1 = model.predict([X_test_drugs_MF_GLP1, X_test_numericalTS, aux_test])
#np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_GLP1.csv', y_pred_asNumber_MF_GLP1[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_GLP1.csv', y_pred_asNumber_MF_GLP1[0], fmt='%.18e', delimiter=',')

# MF and GLP1 only therapy for last year
X_test_drugs_MF_GLP1_SGLT2 = X_test_drugs
X_test_drugs_MF_GLP1_SGLT2[:, 24:30] = 653
y_pred_asNumber_MF_GLP1_SGLT2 = model.predict([X_test_drugs_MF_GLP1_SGLT2, X_test_numericalTS, aux_test])
#np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_GLP1.csv', y_pred_asNumber_MF_GLP1[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF_GLP1_SGLT2.csv', y_pred_asNumber_MF_GLP1_SGLT2[0], fmt='%.18e', delimiter=',')


# write out X_test_drugs to send back to R for decoding/recoding
np.savetxt('./pythonOutput/X_test_drugs.csv', X_test_drugs, fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/decoded_Xtest_hba1c.csv', sc_hba1c.inverse_transform(X_test_numericalTS[:, :, 0]), fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/decoded_Xtest_sbp.csv', sc_sbp.inverse_transform(X_test_numericalTS[:, :, 1]), fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/decoded_Xtest_bmi.csv', sc_bmi.inverse_transform(X_test_numericalTS[:, :, 2]), fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/decoded_Xtest_dbp.csv', sc_dbp.inverse_transform(X_test_numericalTS[:, :, 3]), fmt='%.18e', delimiter=',')

np.savetxt('./pythonOutput/X_test_age.csv', sc_age.inverse_transform(X_test_age_forInverseTransform), fmt='%.18e', delimiter=',')

np.savetxt('./pythonOutput/y_pred_asNumber.csv', y_pred_asNumber, fmt='%.18e', delimiter=',')

'''
# sandbox test
rowN = 21
MFalone_drugs = X_test_drugs[rowN, ]
MFalone_drugs = MFalone_drugs.reshape(1, -1)

# add SU for last year: MFalone_drugs[0,25:31] = 3076
# add BDmix for last year: MFalone_drugs[0,25:31] = 2117
# add SGLT2 for last year: MFalone_drugs[0,25:31] = 3065
# add basalIns + SU for last year: MFalone_drugs[0,25:31] = 2854
# MF analogue basal ins MFalone_drugs[0,25:31] = 911
# nil  MFalone_drugs[0,25:31] = 3111

MFalone_numeric = np.dstack([X_test_numericalTS[rowN, :, 0], X_test_numericalTS[rowN, :, 2], X_test_numericalTS[rowN, :, 2]])

MFalone_age = X_test_age[rowN, ]

sandbox_y_pred_asNumber = model.predict([MFalone_drugs, MFalone_numeric, MFalone_age])
sandbox_y_pred_asNumber
'''



'''
# build the RNN model
rnn = Sequential([
    LSTM(return_sequences=True, input_shape = (30, 11), units=128),
    Dropout(0.5),
    LSTM(16),
    Dropout(0.5),
#    LSTM(4),
#    Dropout(0.5),
    Dense(1, activation='sigmoid'),
])(merged)

M = Model(input=[a,b], output=[rnn])

M.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

## fit and evaluate
M.fit([X_train_set4, X_train_set1_to_3], y_train, batch_size = 128, epochs = 4)
score = M.evaluate([X_test_set4, X_test_set1_to_3], y_test, batch_size=128)

y_pred_asNumber = M.predict([X_test_set4, X_test_set1_to_3])
from sklearn.metrics import roc_auc_score
roc_auc_score(y_test, y_pred_asNumber)

'''

# plot ROC
from sklearn import metrics
import matplotlib.pyplot as plt

fpr, tpr, _ = metrics.roc_curve(y_test, y_pred_asNumber[0])

fpr = fpr # false_positive_rate
tpr = tpr # true_positive_rate

# This is the ROC curve
plt.plot(fpr,tpr)
# plt.show()
plt.savefig('roc_mortality.png')
plt.clf()
auc = np.trapz(tpr, fpr)

print(auc)

plt.hist(y_pred_asNumber[0], bins = 100)
plt.savefig('y_pred_distribution')
plt.clf()
