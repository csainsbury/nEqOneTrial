import numpy as np
import pandas as pd

x = np.array([20, 30, 10, 40, 45, 45, 45])
r = np.array([2, 4, 8, 16])

# task is to progressively replace the 45s with 2, 4, 8 and 16

lengthOfVector = len(x)
nToReplace = 3

for r_count in range(0, len(r), 1):
    for x_count in range((lengthOfVector - nToReplace), lengthOfVector):
        x[x_count] = r[r_count]
    print(x)


# import lookup table
lookup = pd.read_csv('./inputFiles/lookup.csv')
lookup = lookup.sort_values('vectorNumbers')

therapyFrame = lookup.loc[(lookup['vectorWords'] == 'Metformin_') | # 1st line
(lookup['vectorWords'] == 'Metformin_SU_') |    # 2nd line
(lookup['vectorWords'] == 'DPP4_Metformin_') |
(lookup['vectorWords'] == 'Metformin_SGLT2_') |
(lookup['vectorWords'] == 'GLP1_Metformin_') |
(lookup['vectorWords'] == 'humanBDmixInsulin_Metformin_') |
(lookup['vectorWords'] == 'analogueBDmixInsulin_Metformin_') |
(lookup['vectorWords'] == 'humanBasalInsulin_Metformin_') |
(lookup['vectorWords'] == 'analogueBasalInsulin_Metformin_') |
(lookup['vectorWords'] == 'DPP4_Metformin_SU_') |   # 3rd line
(lookup['vectorWords'] == 'Metformin_SGLT2_SU_') |
(lookup['vectorWords'] == 'GLP1_Metformin_SU_') |
(lookup['vectorWords'] == 'humanBDmixInsulin_Metformin_SU_') |
(lookup['vectorWords'] == 'analogueBDmixInsulin_Metformin_SU_') |
(lookup['vectorWords'] == 'humanBasalInsulin_Metformin_SU_') |
(lookup['vectorWords'] == 'analogueBasalInsulin_Metformin_SU_')]

therapyArray = np.array(therapyFrame['vectorNumbers'])

numberTimeSteps = 60
nTimeStepsToReplace = 12
startTS = (numberTimeSteps - nTimeStepsToReplace)

for r_count in range(0, len(therapyArray), 1):
    print(r_count)
    X_test_drugs_substitute = X_test_drugs
    X_test_drugs_substitute[:, startTS:numberTimeSteps] = therapyArray[r_count]
    print(X_test_drugs_substitute)
    y_pred_asNumber_substitute = model.predict([X_test_drugs_substitute, X_test_numericalTS, X_test_age])
    np.savetxt('./pythonOutput/y_pred_asNumber_combinationNumber_' + str(r_count) + '.csv', y_pred_asNumber_substitute[0], fmt='%.18e', delimiter=',')





# MF only therapy for last year


#np.savetxt('./pythonOutput/y_pred_asNumber_hba1c_MF.csv', y_pred_asNumber_MF[0], fmt='%.18e', delimiter=',')
np.savetxt('./pythonOutput/y_pred_asNumber_' + var + '.csv', y_pred_asNumber_MF[0], fmt='%.18e', delimiter=',')
