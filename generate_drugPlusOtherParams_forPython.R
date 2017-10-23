library(data.table)

sequence <- seq(0, 1 , (1/30)) # inherit from generateDrugData_forRNN.R

drugCombinationData_numerical <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_withID_2008-13.csv", header = T)

hba1cData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/hba1c_data_5y_2008-13_T2.csv", header = T)
sbpData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/sbp_data_5y_2008-13_T2.csv", header = T)
bmiData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/bmi_data_5y_2008-13_T2.csv", header = T)

# generate merged dataset

# generate outcome data for 1y delta hba1c

# manage last year of numerical paramters
# ? lvcf, ?na, ?zero value