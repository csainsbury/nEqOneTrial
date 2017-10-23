library(data.table)

sequence <- seq(0, 1 , (1/30)) # inherit from generateDrugData_forRNN.R

drugCombinationData_numerical <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_withID_2008-13.csv", header = T)

hba1cData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/hba1c_data_5y_2008-13_T2.csv", header = T)
sbpData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/sbp_data_5y_2008-13_T2.csv", header = T)
bmiData <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/bmi_data_5y_2008-13_T2.csv", header = T)

# add identifiers to data frames:
addIdentifier <- function(inputFrame, nameVariable) {
  
  colnamesInputFrame <- colnames(inputFrame)
    
    for (j in seq(1, (length(sequence) - 1), 1)) {
      colnamesInputFrame[j] <- paste(nameVariable, 'V', j, sep = '')
    }
    
  colnames(inputFrame) <- colnamesInputFrame
  
  return(inputFrame)
  
}
hba1cData <- addIdentifier(hba1cData, 'hba1c_')
sbpData <- addIdentifier(sbpData, 'sbp_')
bmiData <- addIdentifier(bmiData, 'bmi_')

twoParamMerge <- merge(hba1cData, sbpData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
threeParamMerge <- merge(twoParamMerge, bmiData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')

x = merge(drugCombinationData_numerical, hba1cData, )


# generate merged dataset


# generate outcome data for 1y delta hba1c

# manage last year of numerical paramters
# ? lvcf, ?na, ?zero value