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

# generate merged dataset
twoParamMerge <- merge(hba1cData, sbpData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
threeParamMerge <- merge(twoParamMerge, bmiData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
fourParamMerge= merge(drugCombinationData_numerical, threeParamMerge, by.x = 'drugWordFrame_forAnalysis.LinkId', by.y = 'interpolatedTS_mortality.LinkId')

# generate outcome data for 1y delta hba1c
testPeriodYears <- 1
runinPeriodDurationYears <- 5
NumberOfTimeBins <- 30

numberOfBinsMakingUpTestPeriod <- (NumberOfTimeBins / runinPeriodDurationYears) * testPeriodYears

paramDifference <- function(inputFrame, numberOfBins) {
  
   lastBin = (length(sequence) - 1)
   firstBin = lastBin - numberOfBins
   
   difference <- inputFrame[, lastBin] - inputFrame[, firstBin]
   
   differenceFrame <- data.frame(inputFrame$interpolatedTS_mortality.LinkId, difference)
   
   return(differenceFrame)
}

# these are outcomes for the full hba1c set - need to merge back with drug dataset
hba1cDataOutcome <- paramDifference(hba1cData, numberOfBinsMakingUpTestPeriod)
sbpDataOutcome <- paramDifference(sbpData, numberOfBinsMakingUpTestPeriod)
bmiDataOutcome <- paramDifference(bmiData, numberOfBinsMakingUpTestPeriod)

# merge parameter outcomes back into fourParamMerge
hba1cDataOutcome_export <- merge(fourParamMerge, hba1cDataOutcome, by.x = 'drugWordFrame_forAnalysis.LinkId', by.y = 'inputFrame.interpolatedTS_mortality.LinkId')
hba1cDataOutcome_export <- hba1cDataOutcome_export$difference

# export the files for python import:
# needs to be improved. done manually for now
drug_export <- fourParamMerge[, 2:31]
hba1c_export <- fourParamMerge[, 32:61]
sbp_export <- fourParamMerge[, 67:96]
bmi_export <- fourParamMerge[, 102:131]

## zero the last n bins for final export:
zeroFinalBins <- function(inputFrame, numberOfBinsToZero) {
  startZero <- (ncol(inputFrame) - numberOfBinsToZero) + 1
  inputFrame[, startZero : ncol(inputFrame)] = 0
  
  return(inputFrame)
}

hba1c_export <- zeroFinalBins(hba1c_export, numberOfBinsMakingUpTestPeriod)
sbp_export <- zeroFinalBins(sbp_export, numberOfBinsMakingUpTestPeriod)
bmi_export <- zeroFinalBins(bmi_export, numberOfBinsMakingUpTestPeriod)

## write out files for python
write.table(drug_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/drugExport.csv", sep=",", row.names = FALSE)
write.table(hba1c_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/hba1c_export.csv", sep=",", row.names = FALSE)
write.table(sbp_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/sbp_export.csv", sep=",", row.names = FALSE)
write.table(bmi_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/bmi_export.csv", sep=",", row.names = FALSE)

# write out outcomes for python
write.table(hba1cDataOutcome_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/hba1c_outcome.csv", sep=",", row.names = FALSE)









# manage last year of numerical paramters
# ? lvcf, ?na, ?zero value