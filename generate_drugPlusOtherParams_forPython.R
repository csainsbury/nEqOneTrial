library(data.table)

returnUnixDateTime<-function(date) {
  returnVal<-as.numeric(as.POSIXct(date, format="%Y-%m-%d", tz="GMT"))
  return(returnVal)
}

sequence <- seq(0, 1 , (1/60)) # inherit from generateDrugData_forRNN.R

# set runin period of interest # inherited from other files
startRuninPeriod <- '2011-10-01'
endRuninPeriod   <- '2016-10-01'

followupTimeInterval = returnUnixDateTime(endRuninPeriod) - returnUnixDateTime(startRuninPeriod)

drugCombinationData_numerical <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_withID_", (length(sequence) - 1),"bins_", startRuninPeriod,"_to_", endRuninPeriod,"_simplifiedDrugs_1mBins_interpolated.csv", sep = ''), header = T)

hba1cData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_hba1c_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", (length(sequence) - 1),"increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep = ''), header = T)
sbpData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_SBP_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", (length(sequence) - 1),"increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep = ''), header = T)
dbpData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_DBP_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", (length(sequence) - 1),"increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep = ''), header = T)
bmiData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_BMI_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", (length(sequence) - 1),"increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep = ''), header = T)
# ageData <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/age_data_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", startRuninPeriod, "_to_", endRuninPeriod, "_T2.csv", sep = ''), header = T)

# diagnosisDataset<-read.csv("../GlCoSy/SDsource/diagnosisDateDeathDate.txt")
diagnosisDataset<-read.csv("~/R/GlCoSy/SDsource/demogALL.txt", quote = "", 
                           row.names = NULL, 
                           stringsAsFactors = FALSE)
diagnosisDataset <- subset(diagnosisDataset, LinkId != "")

# extract gender data
genderSet <- data.frame(diagnosisDataset$LinkId, diagnosisDataset$CurrentGender_Mapped)
colnames(genderSet) <- c("LinkId", "Gender")
genderSet$numericalGender <- ifelse(genderSet$Gender == "Male", 1, 0)

# extract date of diagnosis data to calculate duration of diabetes
DMdurationSet <- data.frame(diagnosisDataset$LinkId, diagnosisDataset$DateOfDiagnosisDiabetes_Date)
colnames(DMdurationSet) <- c("LinkId", "diagnosisDate")
DMdurationSet$diagnosisDateUnix <- returnUnixDateTime(DMdurationSet$diagnosisDate)
DMdurationSet$durationAtStart <- (returnUnixDateTime(startRuninPeriod) - DMdurationSet$diagnosisDateUnix) / (60*60*24*365.25)
DMdurationSet$durationAtStart[is.na(DMdurationSet$durationAtStart)] <- 0
DMdurationSet$durationAtStart <- ifelse(DMdurationSet$durationAtStart > 70 | DMdurationSet$durationAtStart == 0, quantile(DMdurationSet$durationAtStart)[3], DMdurationSet$durationAtStart)


# extract date of diagnosis data to calculate duration of diabetes
ageSet <- data.frame(diagnosisDataset$LinkId, diagnosisDataset$BirthDate)
colnames(ageSet) <- c("LinkId", "BirthDate")
ageSet$dobUnix <- returnUnixDateTime(ageSet$BirthDate)
ageSet$ageAtStart <- (returnUnixDateTime(startRuninPeriod) - ageSet$dobUnix) / (60*60*24*365.25)
ageSet$ageAtStart[is.na(ageSet$ageAtStart)] <- median(ageSet$ageAtStart, na.rm = T)


# add identifiers to data frames:
addIdentifier <- function(inputFrame, nameVariable) {
  
  colnamesInputFrame <- colnames(inputFrame)
    
    for (j in seq(1, (length(sequence) - 1), 1)) {
      colnamesInputFrame[j] <- paste(nameVariable, 'V', j, sep = '')
    }
    
  colnames(inputFrame) <- colnamesInputFrame
  
  return(inputFrame)
  
}

drugCombinationData_numerical <- addIdentifier(drugCombinationData_numerical, 'drug_')
hba1cData <- addIdentifier(hba1cData, 'hba1c_')
sbpData <- addIdentifier(sbpData, 'sbp_')
dbpData <- addIdentifier(dbpData, 'dbp_')
bmiData <- addIdentifier(bmiData, 'bmi_')
# ageData <- addIdentifier(ageData, 'age_')

# generate merged dataset
twoParamMerge <- merge(hba1cData, sbpData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
threeParamMerge <- merge(twoParamMerge, bmiData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
fourParamMerge <- merge(threeParamMerge, dbpData, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
fiveParamMerge <- merge(drugCombinationData_numerical, fourParamMerge, by.x = 'LinkId', by.y = 'interpolatedTS_mortality.LinkId')

# add gender data
fiveParamMerge <- merge(fiveParamMerge, genderSet, by.x = "LinkId", by.y = "LinkId")
fiveParamMerge <- merge(fiveParamMerge, DMdurationSet, by.x = "LinkId", by.y = "LinkId")
fiveParamMerge <- merge(fiveParamMerge, ageSet, by.x = "LinkId", by.y = "LinkId")


# generate outcome data for 1y delta hba1c
testPeriodYears <- 1
runinPeriodDurationYears <- 5
NumberOfTimeBins <- (length(sequence) - 1)

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
dbpDataOutcome <- paramDifference(dbpData, numberOfBinsMakingUpTestPeriod)
bmiDataOutcome <- paramDifference(bmiData, numberOfBinsMakingUpTestPeriod)

# merge parameter outcomes back into fiveParamMerge - hba1c
hba1cDataOutcome_export <- merge(fiveParamMerge, hba1cDataOutcome, by.x = 'LinkId', by.y = 'inputFrame.interpolatedTS_mortality.LinkId')
hba1cDataOutcome_export <- hba1cDataOutcome_export$difference

# merge parameter outcomes back into fiveParamMerge - sbp
sbpDataOutcome_export <- merge(fiveParamMerge, sbpDataOutcome, by.x = 'LinkId', by.y = 'inputFrame.interpolatedTS_mortality.LinkId')
sbpDataOutcome_export <- sbpDataOutcome_export$difference

# merge parameter outcomes back into fiveParamMerge - sbp
dbpDataOutcome_export <- merge(fiveParamMerge, dbpDataOutcome, by.x = 'LinkId', by.y = 'inputFrame.interpolatedTS_mortality.LinkId')
dbpDataOutcome_export <- dbpDataOutcome_export$difference

# merge parameter outcomes back into fiveParamMerge - bmi
bmiDataOutcome_export <- merge(fiveParamMerge, bmiDataOutcome, by.x = 'LinkId', by.y = 'inputFrame.interpolatedTS_mortality.LinkId')
bmiDataOutcome_export <- bmiDataOutcome_export$difference

# export the files for python import:
# needs to be improved. done manually for now
drug_export <- fiveParamMerge[ , grepl( "drug_" , names( fiveParamMerge ) ) ]
hba1c_export <- fiveParamMerge[ , grepl( "hba1c_" , names( fiveParamMerge ) ) ]
sbp_export <- fiveParamMerge[ , grepl( "sbp_" , names( fiveParamMerge ) ) ]
dbp_export <- fiveParamMerge[ , grepl( "dbp_" , names( fiveParamMerge ) ) ]
bmi_export <- fiveParamMerge[ , grepl( "bmi_" , names( fiveParamMerge ) ) ]
# age_export <- fiveParamMerge[, 134:163]

# frame to extract final hba1c value
hba1c_original <- hba1c_export

# generate gender_export
n = (NumberOfTimeBins - 1) #replicate n new columns
gender_export <- data.frame(fiveParamMerge$numericalGender); colnames(gender_export) <- c("gender")
gender_export30 = cbind(gender_export, replicate(n, gender_export$gender)) #replicate from column "Rate" in the df object

# generate duration_export
n = (NumberOfTimeBins - 1) #replicate n new columns
duration_export <- data.frame(fiveParamMerge$durationAtStart); colnames(duration_export) <- c("duration")
duration_export30 = cbind(duration_export, replicate(n, duration_export$duration)) #replicate from column "Rate" in the df object

# generate age_export
n = (NumberOfTimeBins - 1) #replicate n new columns
age_export <- data.frame(fiveParamMerge$ageAtStart); colnames(age_export) <- c("age")
age_export30 = cbind(age_export, replicate(n, age_export$age)) #replicate from column "Rate" in the df object

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
write.table(age_export30, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/age_export.csv", sep=",", row.names = FALSE)
write.table(gender_export30, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/gender_export.csv", sep=",", row.names = FALSE)
write.table(duration_export30, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/duration_export.csv", sep=",", row.names = FALSE)

# write out outcomes for python
write.table(hba1cDataOutcome_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/hba1c_outcome.csv", sep=",", row.names = FALSE)
write.table(sbpDataOutcome_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/sbp_outcome.csv", sep=",", row.names = FALSE)
write.table(bmiDataOutcome_export, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/bmi_outcome.csv", sep=",", row.names = FALSE)
write.table(hba1c_original[, 30], file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/finalHbA1c_outcome.csv", sep=",", row.names = FALSE)

## generate 1y mortality outcome
# load and process mortality data
deathData <- read.csv("~/R/GlCoSy/SDsource/diagnosisDateDeathDate.txt", sep=",")
deathData$unix_deathDate <- returnUnixDateTime(deathData$DeathDate)
deathData$unix_deathDate[is.na(deathData$unix_deathDate)] <- 0
deathData$isDead <- ifelse(deathData$unix_deathDate > 0, 1, 0)
deathData$unix_diagnosisDate <- returnUnixDateTime(deathData$DateOfDiagnosisDiabetes_Date)

deathMerge <- merge(fiveParamMerge, deathData, by.x = "drugWordFrame_forAnalysis.LinkId", by.y = "LinkId")
isDeadVector <- ifelse(deathMerge$isDead == 1 & (deathMerge$unix_deathDate > returnUnixDateTime(endRuninPeriod)), 1, 0)

write.table(isDeadVector, file = "~/R/_workingDirectory/nEqOneTrial/pythonTransfer/death_outcome.csv", sep=",", row.names = FALSE)







# manage last year of numerical paramters
# ? lvcf, ?na, ?zero value