library(data.table)

drugCombinationData_numerical <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_withID_2008-13.csv", header = T)

hba1cData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/hba1c_data_5y_2008-13_T2.csv", header = T)
sbpData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/sbp_data_5y_2008-13_T2.csv", header = T)
bmiData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/bmi_data_5y_2008-13_T2.csv", header = T)

