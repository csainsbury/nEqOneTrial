library(data.table)

returnUnixDateTime<-function(date) {
  returnVal<-as.numeric(as.POSIXct(date, format="%Y-%m-%d", tz="GMT"))
  return(returnVal)
}

sequence <- seq(0, 1 , (1/30)) # inherit from generateDrugData_forRNN.R

# set runin period of interest # inherited from other files
startRuninPeriod <- '2010-01-01'
endRuninPeriod   <- '2015-01-01'

followupTimeInterval = returnUnixDateTime(endRuninPeriod) - returnUnixDateTime(startRuninPeriod)

drugCombinationData_numerical <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_withID_30bins_2010-01-01_to_2015-01-01_simplifiedDrugs.csv", header = T)

hba1cData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_hba1c_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_30increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep = ''), header = T)
sbpData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_SBP_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_30increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep = ''), header = T)
bmiData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_BMI_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_30increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep = ''), header = T)
ageData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/age_data_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", startRuninPeriod, "_to_", endRuninPeriod, "_T2.csv", sep = ''), header = T)

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
ageData <- addIdentifier(ageData, 'age_')

# generate merged dataset
twoParamMerge <- merge(hba1cData, sbpData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
threeParamMerge <- merge(twoParamMerge, bmiData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
fourParamMerge <- merge(threeParamMerge, ageData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'LinkId')
fiveParamMerge <- merge(drugCombinationData_numerical, fourParamMerge, by.x = 'drugWordFrame_forAnalysis.LinkId', by.y = 'interpolatedTS_mortality.LinkId')

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

# merge parameter outcomes back into fiveParamMerge
hba1cDataOutcome_export <- merge(fiveParamMerge, hba1cDataOutcome, by.x = 'drugWordFrame_forAnalysis.LinkId', by.y = 'inputFrame.interpolatedTS_mortality.LinkId')
hba1cDataOutcome_export <- hba1cDataOutcome_export$difference

# merge parameter outcomes back into fiveParamMerge
sbpDataOutcome_export <- merge(fiveParamMerge, sbpDataOutcome, by.x = 'drugWordFrame_forAnalysis.LinkId', by.y = 'inputFrame.interpolatedTS_mortality.LinkId')
sbpDataOutcome_export <- sbpDataOutcome_export$difference

# export the files for python import:
# needs to be improved. done manually for now
drug_export <- fiveParamMerge[, 2:31]
hba1c_export <- fiveParamMerge[, 32:61]
sbp_export <- fiveParamMerge[, 67:96]
bmi_export <- fiveParamMerge[, 102:131]
age_export <- fiveParamMerge[, 134:163]

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
write.table(age_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/age_export.csv", sep=",", row.names = FALSE)

# write out outcomes for python
write.table(hba1cDataOutcome_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/hba1c_outcome.csv", sep=",", row.names = FALSE)
write.table(sbpDataOutcome_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/sbp_outcome.csv", sep=",", row.names = FALSE)









# manage last year of numerical paramters
# ? lvcf, ?na, ?zero value