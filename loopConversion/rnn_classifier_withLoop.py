from numpy.random import seed
seed(1)
from tensorflow import set_random_seed
set_random_seed(2)

from keras.layers import Input, Embedding, Reshape, merge, Dropout, Dense, LSTM, core, Activation
from keras.layers import TimeDistributed, Flatten, concatenate

from keras.engine import Model
from keras.models import Sequential

from keras import layers, optimizers

import numpy as np
import pandas as pd

from sklearn.preprocessing import StandardScaler
from sklearn import preprocessing

sc = StandardScaler()

'''
data prep
'''

# import numpy as np
dataset_1 = pd.read_csv('./inputFiles/downsampled_hba1c_export.csv')
set1 = dataset_1.values
hba1cSet = set1

# hba1cScaler = preprocessing.StandardScaler().fit(set1_hba1c)
# hba1cSet = hba1cScaler.transform(set1_hba1c)
# to apply to test set : X_test = scaler.transform(X_test)

dataset_2 = pd.read_csv('./inputFiles/downsampled_sbp_export.csv')
set2 = dataset_2.values
sbpSet = set2


dataset_3 = pd.read_csv('./inputFiles/downsampled_bmi_export.csv')
set3 = dataset_3.values
bmiSet = set3

# drug combination dataset. read in as numerical values - need to embed at later stage
dataset_4 = pd.read_csv('./inputFiles/downsampled_drugExport.csv')
set4 = dataset_4.values
drugSet = set4

# auxilliary inputFiles
# aux 1 - age
dataset_5 = pd.read_csv('./inputFiles/downsampled_age_export.csv')
set5 = dataset_5.values
ageSet = set5

# aux 2 - gender
dataset_6 = pd.read_csv('./inputFiles/downsampled_gender_export.csv')
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


# dataset_y = pd.read_csv('./boolean_y.csv')
#
dataset_y_hba1cFinal = pd.read_csv('./outcomeFiles/downsampled_finalHba1c_outcome.csv')
dataset_y_sbpFinal = pd.read_csv('./outcomeFiles/finalSBP_outcome.csv')

#
dataset_y = pd.read_csv('./outcomeFiles/downsampled_hba1c_outcome.csv')
#
dataset_y_sbp = pd.read_csv('./outcomeFiles/sbp_outcome.csv')
#
dataset_y_bmi = pd.read_csv('./outcomeFiles/bmi_outcome.csv')

y = dataset_y.values
bmi_y = dataset_y_bmi.values
sbp_y = dataset_y_sbp.values
hba1c_final_y = dataset_y_hba1cFinal.values
sbp_final_y = dataset_y_sbpFinal.values
#
#
#
y = (y < (-5))
#y = (y == 1)
#
#y = ((hba1c_final_y > 48) & (hba1c_final_y < 60) & (sbp_final_y < 140) & (bmi_y < 0))
#y = (y < (-10))
#
#y = hba1c_final_y
#y = sbp_final_y
#y = (hba1c_final_y > 48) & (hba1c_final_y <= 60)
#y = ((hba1c_final_y <= (60)) & (bmi_y <(1)))
#y = ((hba1c_final_y <= (60)) & (sbp_y <(1)) & (bmi_y <(1)))
#y = ((hba1c_final_y <= (60)) & (sbp_y <(-10)))

#y = (sbp_final_y < 140)



# X = np.dstack([set1_concat, set2_concat, set3_concat])
X = np.dstack([hba1cSet, sbpSet, bmiSet, ageSet, genderSet, drugSet])
y = y

# cut to smaller size for testing
#nsamples = X.shape[0]
#
nsamples = 120
Xsmall = X[0:nsamples, :, :]
ysmall = y[0:nsamples]

## comment out for full set1
X = Xsmall
y = ysmall

numberTimeSteps = len(set1[0])

# split
from sklearn.model_selection import train_test_split
# X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 0)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=1)
X_train, X_val, y_train, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=1)

# generate train / test subgroups
X_train_values = X_train[:, :numberTimeSteps, :]
X_test_values = X_test[:, :numberTimeSteps, :]
X_val_values = X_val[:, :numberTimeSteps, :]

# training sets
X_train_numericalTS = X_train[:, :numberTimeSteps, 0:3]
X_train_drugs = X_train[:, :numberTimeSteps, 5]
# X_train_age = X_train[:, :numberTimeSteps, 3]
X_train_age = X_train[:, 1, 3] # reduce age to a single value
X_train_age = X_train_age.reshape(-1, 1) # reshape to a (nrow, 1) array
#
X_train_gender = X_train[:, 1, 4] # reduce gender to a single value
X_train_gender = X_train_gender.reshape(-1, 1) # reshape to a (nrow, 1) array

# test sets
X_test_numericalTS = X_test[:, :numberTimeSteps, 0:3]
X_test_drugs = X_test[:, :numberTimeSteps, 5]
# X_test_age = X_test[:, :numberTimeSteps, 3]
X_test_age = X_test[:, 1, 3]
X_test_age = X_test_age.reshape(-1, 1)
#
X_test_gender = X_test[:, 1, 4]
X_test_gender = X_test_gender.reshape(-1, 1)

# validation set
X_val_numericalTS = X_val[:, :numberTimeSteps, 0:3]
X_val_drugs = X_val[:, :numberTimeSteps, 5]
# X_test_age = X_test[:, :numberTimeSteps, 3]
X_val_age = X_val[:, 1, 3]
X_val_age = X_val_age.reshape(-1, 1)
#
X_val_gender = X_val[:, 1, 4]
X_val_gender = X_val_gender.reshape(-1, 1)

# concatenate non-TS elements to generate auxilliay input
aux_train = np.column_stack((X_train_age, X_train_gender))
aux_test = np.column_stack((X_test_age, X_test_gender))
aux_val = np.column_stack((X_val_age, X_val_gender))


auxInput_ncols = len(aux_train[0])

# scale inputs
# hba1c - numerical input 0
hba1cScaler = preprocessing.StandardScaler().fit(X_train_numericalTS[:, :numberTimeSteps, 0])
X_train_numericalTS[:, :numberTimeSteps, 0] = hba1cScaler.transform(X_train_numericalTS[:, :numberTimeSteps, 0])

X_test_numericalTS[:, :numberTimeSteps, 0] = hba1cScaler.transform(X_test_numericalTS[:, :numberTimeSteps, 0])
X_val_numericalTS[:, :numberTimeSteps, 0] = hba1cScaler.transform(X_val_numericalTS[:, :numberTimeSteps, 0])

# sbp - numerical input 1
sbpScaler = preprocessing.StandardScaler().fit(X_train_numericalTS[:, :numberTimeSteps, 1])
X_train_numericalTS[:, :numberTimeSteps, 1] = sbpScaler.transform(X_train_numericalTS[:, :numberTimeSteps, 1])

X_test_numericalTS[:, :numberTimeSteps, 1] = sbpScaler.transform(X_test_numericalTS[:, :numberTimeSteps, 1])
X_val_numericalTS[:, :numberTimeSteps, 1] = sbpScaler.transform(X_val_numericalTS[:, :numberTimeSteps, 1])

# bmi - numerical input 2
bmiScaler = preprocessing.StandardScaler().fit(X_train_numericalTS[:, :numberTimeSteps, 2])
X_train_numericalTS[:, :numberTimeSteps, 2] = bmiScaler.transform(X_train_numericalTS[:, :numberTimeSteps, 2])

X_test_numericalTS[:, :numberTimeSteps, 2] = bmiScaler.transform(X_test_numericalTS[:, :numberTimeSteps, 2])
X_val_numericalTS[:, :numberTimeSteps, 2] = bmiScaler.transform(X_val_numericalTS[:, :numberTimeSteps, 2])

# age
ageScaler = preprocessing.StandardScaler().fit(X_train_age)
X_train_age = ageScaler.transform(X_train_age)

X_test_age = ageScaler.transform(X_test_age)
X_val_age = ageScaler.transform(X_val_age)


# scale target
## hba1c - numerical input 0
#yScaler = preprocessing.StandardScaler().fit(y_train)
#y_train = yScaler.transform(y_train)

#y_test = yScaler.transform(y_test)
#y_val = yScaler.transform(y_val)


# to apply to test set : X_test = scaler.transform(X_test)


'''
RNN setup and run
'''
dense_node_n = 32
embedding_dimensions = 64
nTimeSeries = 3
LSTM_layer1 = 128
LSTM_layer2 = 8
lstm_dropout_1 = 0.2
lstm_dropout_2 = 0.8
ann_dropout = 0.8

n_epochs = 65
n_batch_size = 256
numberOfLoops = 2

#numberOfLoops = (numberOfLoops + 1)

# add looping statement to start multiple runs
for loopn in range(1, numberOfLoops):
    LSTMinputDim = (embedding_dimensions + nTimeSeries)

    # a = input the drug dataset (2-dimensional: IDs, timesteps)
    drug_set = Input(shape = (len(set1[0]), ), dtype='int16', name = 'drug_set')
    # embed drug layer
    emb = Embedding(input_dim = 1000, output_dim = embedding_dimensions)(drug_set) # lower output dimensions seems better

    # numericTS_set = input the numerical data (3-dimensional: IDs, timesteps, dimensions(n parameters))
    numericTS_set = Input(shape = (len(set1[0]), 3), name = 'numericTS_set')

    # merge embedded and numerical data
    # merged = keras.layers.concatenate([emb, numericTS_set])
    merged = merge([emb, numericTS_set], mode='concat')

    #lstm_out = LSTM(return_sequences=True, input_shape = (len(set1[0]), 1027), units=64, recurrent_dropout = 0.5)(merged
    #lstm_out = LSTM(units = 128)(lstm_out)
    lstm_out = LSTM(return_sequences=True, input_shape = (len(set1[0]), LSTMinputDim), units=LSTM_layer1, dropout = lstm_dropout_1, recurrent_dropout = lstm_dropout_2)(merged)
    lstm_out = LSTM(units = LSTM_layer2, dropout = lstm_dropout_1, recurrent_dropout = lstm_dropout_2)(lstm_out)

    auxiliary_output = Dense(1, activation = 'sigmoid', name='aux_output')(lstm_out)
    auxiliary_input = Input(shape=(1,), name='aux_input')

    # x = merge([lstm_out, auxiliary_input], mode = 'concat')
    x = concatenate([lstm_out, auxiliary_input])

    x = Dense(dense_node_n, activation='relu')(x)
    x = Dropout(ann_dropout)(x)
    #x = Dense(dense_node_n, activation='relu')(x)
    #x = Dropout(0.5)(x)

    x = Dense(dense_node_n)(x)

    # And finally we add the main logistic regression layer
    main_output = Dense(1, activation = 'sigmoid', name='main_output')(x)

    model = Model(inputs=[drug_set, numericTS_set, auxiliary_input], outputs=[main_output, auxiliary_output])
    adam = optimizers.Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=None, decay=0.0)
    model.compile(optimizer='adam', loss='binary_crossentropy', loss_weights=[0.2, 0.4])
    history = model.fit([X_train_drugs, X_train_numericalTS, X_train_age], [y_train, y_train], epochs=n_epochs, batch_size=n_batch_size, validation_data = ([[X_val_drugs, X_val_numericalTS, X_val_age], [y_val, y_val]]))

    # plot losses
    import matplotlib.pyplot as plt
    loss = history.history['loss']
    val_loss = history.history['val_loss']
    #acc = history.history['acc']
    #val_acc = history.history['val_acc']
    epochs = range(1, len(loss) + 1)

    plt.plot(epochs, loss, 'bo', label = 'Training loss')
    plt.plot(epochs, val_loss, 'b', label = 'Validation loss')
    plt.legend()
    plt.savefig('loss_valLoss_%s.png' % loopn, dpi = 300)
    plt.clf()

    #plt.plot(epochs, acc, 'bo', label = 'Training acc')
    #plt.plot(epochs, val_acc, 'b', label = 'Validation acc')
    #plt.legend()
    #plt.savefig('loss_valAcc.png', dpi = 300)
    #plt.clf()
    #
    y_pred_asNumber = model.predict([X_test_drugs, X_test_numericalTS, X_test_age])
    #from sklearn.metrics import roc_auc_score
    #mainOutput = roc_auc_score(y_test, y_pred_asNumber[0])
    #auxOutput = roc_auc_score(y_test, y_pred_asNumber[1])

    #print(mainOutput)
    #print(auxOutput)


    # plot ROC
    from sklearn import metrics
    import matplotlib.pyplot as plt

    fpr, tpr, _ = metrics.roc_curve(y_test, y_pred_asNumber[0])

    fpr = fpr # false_positive_rate
    tpr = tpr # true_positive_rate

    # This is the ROC curve
    plt.plot(fpr,tpr)
    # plt.show()
    plt.savefig('roc_mortality_%s.png' % loopn)
    plt.clf()
    auc = np.trapz(tpr, fpr)

    print(auc)

    plt.hist(y_pred_asNumber[0], bins = 100)
    plt.savefig('y_pred_distribution')
    plt.clf()


    y_pred_asNumber = model.predict([X_test_drugs, X_test_numericalTS, X_test_age])
    from sklearn.metrics import roc_auc_score
    mainOutput = roc_auc_score(y_test, y_pred_asNumber[0])
    auxOutput = roc_auc_score(y_test, y_pred_asNumber[1])

    print(mainOutput)
    print(auxOutput)

    ## change final year of therapy and output probabilities
    # import lookup table
    lookup = pd.read_csv('./inputFiles/lookup.csv')
    lookup = lookup.sort_values('vectorNumbers')

    therapyFrame = lookup.loc[(lookup['vectorWords'] == 'Metformin_') | # 1st line
    (lookup['vectorWords'] == 'Metformin_SU_') |    # 2nd line
    (lookup['vectorWords'] == 'DPP4_Metformin_') |
    (lookup['vectorWords'] == 'Metformin_SGLT2_') |
    (lookup['vectorWords'] == 'SU_') |
    (lookup['vectorWords'] == 'humanBDmixInsulin_Metformin_') |

    (lookup['vectorWords'] == 'GLP1_Metformin_')] # additional line added with termination of expression
    '''
    (lookup['vectorWords'] == 'GLP1_Metformin_') |
    (lookup['vectorWords'] == 'DPP4_Metformin_SU_') |   # 3rd line - MF/SU base
    (lookup['vectorWords'] == 'DPP4_Metformin_SGLT2_') |
    (lookup['vectorWords'] == 'DPP4_GLP1_Metformin_') |
    (lookup['vectorWords'] == 'Metformin_SGLT2_SU_') |
    (lookup['vectorWords'] == 'GLP1_Metformin_SU_') |
    (lookup['vectorWords'] == 'Metformin_TZD_') |
    (lookup['vectorWords'] == 'DPP4_Metformin_TZD_') |
    (lookup['vectorWords'] == 'GLP1_Metformin_SGLT2_')]
    '''

    therapyArray = np.array(therapyFrame['vectorNumbers'])
    print(therapyArray)

    np.savetxt('./pythonOutput/therapyArray.csv', therapyArray, fmt='%.18e', delimiter=',')

    numberTimeSteps = 60
    nTimeStepsToReplace = 12
    startTS = (numberTimeSteps - nTimeStepsToReplace)

    for r_count in range(0, len(therapyArray), 1):
        print(r_count)
        X_test_drugs_substitute = X_test_drugs
        X_test_drugs_substitute[:, startTS:numberTimeSteps] = therapyArray[r_count]
        print(X_test_drugs_substitute)
        y_pred_asNumber_substitute = model.predict([X_test_drugs_substitute, X_test_numericalTS, X_test_age])
        np.savetxt('./pythonOutput/y_pred_asNumber_combinationNumber_' + str(r_count) + '_runN_%s.csv' % loopn, y_pred_asNumber_substitute[0], fmt='%.18e', delimiter=',')

    # write out X_test_drugs to send back to R for decoding/recoding
    np.savetxt('./pythonOutput/X_test_drugs.csv', X_test_drugs, fmt='%.18e', delimiter=',')
    np.savetxt('./pythonOutput/decoded_Xtest_hba1c.csv', hba1cScaler.inverse_transform(X_test_numericalTS[:, :, 0]), fmt='%.18e', delimiter=',')
    np.savetxt('./pythonOutput/decoded_Xtest_sbp.csv', sbpScaler.inverse_transform(X_test_numericalTS[:, :, 1]), fmt='%.18e', delimiter=',')
    np.savetxt('./pythonOutput/decoded_Xtest_bmi.csv', bmiScaler.inverse_transform(X_test_numericalTS[:, :, 2]), fmt='%.18e', delimiter=',')

    np.savetxt('./pythonOutput/X_test_age.csv', X_test_age, fmt='%.18e', delimiter=',')

    np.savetxt('./pythonOutput/y_pred_asNumber.csv', y_pred_asNumber, fmt='%.18e', delimiter=',')

    loopN_array = np.repeat(numberOfLoops, 100)
    np.savetxt('./pythonOutput/numberOfLoops.csv', loopN_array, fmt='%.18e', delimiter=',')

# need to work out how to save out lookup from here
# np.savetxt('./pythonOutput/lookup.csv', lookup, delimiter=',')



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
'''
