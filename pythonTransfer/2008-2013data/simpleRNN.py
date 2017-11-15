from keras.models import Sequential
from keras.layers import Dense, Dropout
from keras.layers import Embedding
from keras.layers import LSTM
import sklearn


import pandas as pd
import numpy as np
# import numpy as np
dataset = pd.read_csv('./interpolatedTS_hba1c_5y_30increments_2008-2013_locf.csv')
# dataset = pd.read_csv('./hba1c_10y_2002to2012_3mBins_locf.csv')
ts_dataset = dataset.values

random_y_set = pd.read_csv('./hba1c_1y_mortality_y_5y_30increments_2008-2013_locf.csv')
random_y = random_y_set.values

# split
from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(ts_dataset, random_y, test_size = 0.2, random_state = 0)

# once done, extract the LinkIds used in the train/test set:
#
Xtest_LinkIds = X_test[:, 30:35]
np.savetxt('./Xtest_LinkIds.csv', Xtest_LinkIds, fmt='%.18e', delimiter=',')

#
Xtrain_linkIds = X_train[:, 30:35]
np.savetxt('./Xtrain_linkIds.csv', Xtrain_linkIds, fmt='%.18e', delimiter=',')

# and then subset the X_train/test to just the hba1c values using
#
X_test = X_test[:, :30]
#
X_train = X_train[:, :30]

# feature scaling
# from sklearn.preprocessing import StandardScaler
# sc = StandardScaler()
# X_train = sc.fit_transform(X_train)
# X_test = sc.transform(X_test)
#
# X_train = sklearn.preprocessing.normalize(X_train)
# X_test = sklearn.preprocessing.normalize(X_test)

model = Sequential()
model.add(Embedding(200, output_dim=256))
model.add(LSTM(16))
model.add(Dropout(0.5))
model.add(Dense(1, activation='sigmoid'))

model.compile(loss='binary_crossentropy',
              optimizer='rmsprop',
              metrics=['accuracy'])

model.fit(X_train, y_train, batch_size=32, epochs=4)
score = model.evaluate(X_test, y_test, batch_size=32)

print("Accuracy: %.2f%%" % (score[1]*100))

# predict test set results
y_pred_asNumber = model.predict(X_test)
y_pred = (y_pred_asNumber > 0.11)
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(y_test, y_pred)

print(cm)


from sklearn.metrics import roc_auc_score
roc_auc_score(y_test, y_pred_asNumber)

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

np.savetxt('./y_pred.csv', y_pred_asNumber, fmt='%.18e', delimiter=',')
