
from keras.layers import Input, Embedding, Reshape, merge
from keras.engine import Model

import numpy as np

a = Input((1,), dtype='int16')

b = Input((1,))

b2 = Reshape((1,1))(b)

emb = Embedding(4,20)(a)

merged = merge([emb, b2], mode='concat')

from keras.layers import LSTM

from keras.engine import Model

rnn = LSTM(1)(merged)

M = Model(input=[a,b], output=[rnn])

M.compile(loss='MSE', optimizer='SGD')

testA = np.random.randint(0,4,(6,1))

testB = np.random.random((6,1))

testY = np.random.random((6,1))

M.evaluate([testA, testB], testY)
