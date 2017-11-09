# generate imputed time series values from sci diabetes extract data

# function to output values
# numericValueColumnIndex = the column that the numeric value of interest is in (hba1c, sbp etc)
generateImputedTimeSeriesData <- function(inputFrame, input_deathData, startTime, endTime, input_binLengthMonths, label, numericValueColumnIndex) {

library(data.table)
library(imputeTS)

id_per_location <- function(ID) {
  return(length(unique(ID)))
}

flagMove <- function(ID, charL) {
  
  charLreport <- charL
  charLnumeric <- as.numeric(factor(charL))
  
  testFrame <- data.frame(charLreport, charLnumeric)
  
  testFrame$flagMove <- 0
  testFrame$flagMove[1:nrow(testFrame)-1] <- diff(testFrame$charLnumeric)
  testFrame$nextL <- c("spacer")
  testFrame$nextL[1:(nrow(testFrame)-1)] <- charLreport[2:length(charLreport)]
  
  testFrame$charLreport <- as.character(factor(charL))
  
  outputList <- list(testFrame$charLreport, testFrame$nextL, testFrame$flagMove)
  
  return(outputList)
  
}

returnUnixDateTime<-function(date) {
  returnVal<-as.numeric(as.POSIXct(date, format="%Y-%m-%d", tz="GMT"))
  return(returnVal)
}

findSimilarDrugs <- function(inputFrame) {
  
  # inputFrame <- interestSet
  # inputFrame <- inputFrame[1:10000,]
  
  inputFrame$DrugName.original <- inputFrame$DrugName
  inputFrame$DrugNameNew <- inputFrame$DrugName
  
  inputFrame <- subset(inputFrame, DrugNameNew != "Disposable")
  
  inputFrame$DrugNameNew[grep("Glucose", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose"
  inputFrame$DrugNameNew[grep("Glucogel", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose"
  
  inputFrame$DrugNameNew[grep("Glucagen Hypokit", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucagon"
  inputFrame$DrugNameNew[grep("Optium Plus", inputFrame$DrugName, ignore.case = TRUE)] <- "Test Strips"
  
  
  inputFrame$DrugNameNew[grep("Metformin", inputFrame$DrugName, ignore.case = TRUE)] <- "Metformin"
  inputFrame$DrugNameNew[grep("Glucophage", inputFrame$DrugName, ignore.case = TRUE)] <- "Metformin"
  
  inputFrame$DrugNameNew[grep("Gliclazide", inputFrame$DrugName, ignore.case = TRUE)] <- "Gliclazide"
  inputFrame$DrugNameNew[grep("Diamicron", inputFrame$DrugName, ignore.case = TRUE)] <- "Gliclazide"
  
  inputFrame$DrugNameNew[grep("Rosiglitazone", inputFrame$DrugName, ignore.case = TRUE)] <- "Rosiglitazone"
  inputFrame$DrugNameNew[grep("Avandia", inputFrame$DrugName, ignore.case = TRUE)] <- "Rosiglitazone"
  
  inputFrame$DrugNameNew[grep("Linagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "Linagliptin"
  
  inputFrame$DrugNameNew[grep("Victoza", inputFrame$DrugName, ignore.case = TRUE)] <- "Liraglutide"
  inputFrame$DrugNameNew[grep("Liraglutide", inputFrame$DrugName, ignore.case = TRUE)] <- "Liraglutide"
  
  inputFrame$DrugNameNew[grep("Pioglitazone", inputFrame$DrugName, ignore.case = TRUE)] <- "Pioglitazone"
  
  inputFrame$DrugNameNew[grep("Sitagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "Sitagliptin"
  inputFrame$DrugNameNew[grep("Januvia", inputFrame$DrugName, ignore.case = TRUE)] <- "Sitagliptin"
  
  inputFrame$DrugNameNew[grep("Dapagliflozin", inputFrame$DrugName, ignore.case = TRUE)] <- "Dapagliflozin"
  
  inputFrame$DrugNameNew[grep("Humalog Mix25", inputFrame$DrugName, ignore.case = TRUE)] <- "Humalog Mix 25"
  
  inputFrame$DrugNameNew[grep("Lantus", inputFrame$DrugName, ignore.case = TRUE)] <- "Insulin Glargine"
  inputFrame$DrugNameNew[grep("Levemir", inputFrame$DrugName, ignore.case = TRUE)] <- "Insulin Detemir"
  
  inputFrame$DrugNameNew[grep("Insulatard", inputFrame$DrugName, ignore.case = TRUE)] <- "Insulatard"
  
  inputFrame$DrugNameNew[grep("Actrapid", inputFrame$DrugName, ignore.case = TRUE)] <- "Actrapid"
  inputFrame$DrugNameNew[grep("Humalog 100units/ml solution", inputFrame$DrugName, ignore.case = TRUE)] <- "Humalog"
  
  inputFrame$DrugNameNew[grep("Novorapid", inputFrame$DrugName, ignore.case = TRUE)] <- "Novorapid"
  
  inputFrame$DrugNameNew[grep("Novomix 30", inputFrame$DrugName, ignore.case = TRUE)] <- "Novomix 30"
  
  inputFrame$DrugNameNew[grep("Mixtard 30", inputFrame$DrugName, ignore.case = TRUE)] <- "Mixtard 30"
  inputFrame$DrugNameNew[grep("Mixtard 20", inputFrame$DrugName, ignore.case = TRUE)] <- "Mixtard 20"
  
  inputFrame$DrugNameNew[grep("Humulin M3", inputFrame$DrugName, ignore.case = TRUE)] <- "Humulin M3"
  
  inputFrame$DrugNameNew[grep("Humalog Mix50", inputFrame$DrugName, ignore.case = TRUE)] <- "Humalog Mix50"
  
  inputFrame$DrugNameNew[grep("strip", inputFrame$DrugName, ignore.case = TRUE)] <- "Test Strips"
  
  inputFrame$DrugNameNew[grep("Bd-Microfine", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle"
  inputFrame$DrugNameNew[grep("Needle", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle"
  
  
  outputFrame <- inputFrame
  
  outputFrame$DrugName.original <- NULL
  outputFrame$DrugName <- outputFrame$DrugNameNew
  outputFrame$DrugNameNew <- NULL
  
  return(outputFrame)
}

# generate node and link files
cleanTSdata <- inputFrame
# cleanHbA1cData <- read.csv("~/R/GlCoSy/SD_workingSource/hba1cDTclean.csv", sep=",", header = TRUE, row.names = NULL)
cleanTSdata$timeSeriesDataPoint <- cleanTSdata[, numericValueColumnIndex]

timeSeriesData <- cleanTSdata

timeSeriesDataDT <- data.table(timeSeriesData)


# load and process mortality data
deathData <- input_deathData
# deathData <- read.csv("~/R/GlCoSy/SDsource/diagnosisDateDeathDate.txt", sep=",")
deathData$unix_deathDate <- returnUnixDateTime(deathData$DeathDate)
deathData$unix_deathDate[is.na(deathData$unix_deathDate)] <- 0
deathData$isDead <- ifelse(deathData$unix_deathDate > 0, 1, 0)
deathData$unix_diagnosisDate <- returnUnixDateTime(deathData$DateOfDiagnosisDiabetes_Date)

deathDataDT <- data.table(deathData)


# set runin period of interest
startRuninPeriod <- startTime
endRuninPeriod <- endTime
# startRuninPeriod <- '2010-01-01'
# endRuninPeriod   <- '2015-01-01'

# testDeathDate    <- '2013-01-01'

interestSetDT <- timeSeriesDataDT[dateplustime1 > returnUnixDateTime(startRuninPeriod) &
                                    dateplustime1 < returnUnixDateTime(endRuninPeriod)]

interestSetDF <- data.frame(interestSetDT)


###############################
## start data manipulation
###############################

# scale time to 0 to 1 range
interestSetDT$dateplustime1.original <- interestSetDT$dateplustime1
interestSetDT$dateplustime1 <- (interestSetDT$dateplustime1 - min(interestSetDT$dateplustime1)) / (max(interestSetDT$dateplustime1) - min(interestSetDT$dateplustime1))

interestSetDT <- transform(interestSetDT,id=as.numeric(factor(LinkId)))

# set time bins
# bin length in months
binLengthMonths = input_binLengthMonths
binLengthSeconds = (60*60*24*(365.25 / 12)) * binLengthMonths
unixRunInDuration = returnUnixDateTime(endRuninPeriod) - returnUnixDateTime(startRuninPeriod)
unixRunInDurationYears = round(unixRunInDuration / (60*60*24*365.25), 0)
numberOfBins = round(unixRunInDuration / binLengthSeconds, 0)

sequence <- seq(0, 1 , (1/numberOfBins))

# generate bag of drugs frame
timesetWordFrame <- as.data.frame(matrix(nrow = length(unique(interestSetDT$LinkId)), ncol = (length(sequence)-1) ))
colnames(timesetWordFrame) <- c(1:(length(sequence)-1))
timesetWordFrame$LinkId <- 0

medianFrame <- as.data.frame(matrix(nrow = length(unique(interestSetDT$LinkId)), ncol = 1 ))
colnames(medianFrame) <- c("median")


# function to generate drugwords for each time interval
returnIntervals <- function(LinkId, timeSeriesDataPoint, dateplustime1, sequence, id) {
  
  # timeSeriesDataPoint <- subset(interestSetDT, id == 2)$timeSeriesDataPoint; dateplustime1 <- subset(interestSetDT, id == 2)$dateplustime1; id = 2; LinkId <- subset(interestSetDT, id == 2)$LinkId
  
  inputSet <- data.table(timeSeriesDataPoint, dateplustime1)
  
  ## add nil values to fill time slots without any drugs
  nilFrame <- as.data.frame(matrix(nrow = length(sequence), ncol = ncol(inputSet)))
  colnames(nilFrame) <- colnames(inputSet)
  
  
  nilFrame$timeSeriesDataPoint <- 0
  nilFrame$dateplustime1 <- sequence
  
  outputSet <- rbind(nilFrame, inputSet)
  
  dataBreaks <- split(outputSet$timeSeriesDataPoint, cut(outputSet$dateplustime1, breaks = sequence))
  outputVector <- c(rep(0, length(sequence)- 1))
  
  # returns either 0, or the median of all values in the time bin
  for (kk in seq(1, length(dataBreaks), 1)) {
    values <- dataBreaks[[kk]]
    if (length(values) == 1) { outputVector[kk] = 0}
    if (length(values) > 0) { outputVector[kk] = quantile(values[values > 0])[3]}
  }
  
  return(c(outputVector, LinkId[1]))
  
}

print(max(interestSetDT$id))

for (j in seq(1, max(interestSetDT$id), 1)) {
  # for (j in seq(1 ,1000, )) {
  
  if(j%%100 == 0) {print(j)}
  
  injectionSet <- interestSetDT[id == j]
  timesetWordFrame[j, ] <- returnIntervals(injectionSet$LinkId, injectionSet$timeSeriesDataPoint, injectionSet$dateplustime1, sequence, j)
  medianFrame$median[j] <- quantile(injectionSet$hba1cNumeric)[3]
}

# write out timesetWordFrame for analysis
# write.table(timesetWordFrame, file = "~/R/_workingDirectory/bagOfDrugs/local_py/dataFiles/10y_30increments_2004-2014_hba1c_TS.csv", sep=",", row.names = FALSE)
# timesetWordFrame <- read.csv("~/R/_workingDirectory/bagOfDrugs/local_py/hba1c_TS.csv")

# last value carry forward imputation of values
timesetWordFrame[,1][is.na(timesetWordFrame[,1])] <- 0
interpolatedTS <- as.data.frame(matrix(nrow = nrow(timesetWordFrame), ncol = (ncol(timesetWordFrame) - 1)))

for (jj in seq(1, nrow(timesetWordFrame), 1)) {
  
  if(jj%%1000 == 0) {print(jj)}
  
  testVector <- c(0, timesetWordFrame[jj, 1:(ncol(timesetWordFrame) - 1)])
  # interpolatedTS[jj, ] <- na.interpolation(as.numeric(timesetWordFrame[jj, 1:(ncol(timesetWordFrame) - 1)]), option ="linear")
  
  # interpolatedTS[jj, ] <- na.interpolation(as.numeric(testVector), option ="linear")[2: length(testVector)]
  interpolatedTS[jj, ] <- na.locf(as.numeric(testVector), option ="locf")[2: length(testVector)]
}

interpolatedTS$LinkId <- timesetWordFrame$LinkId
interpolatedTS$median <- medianFrame$median


# write out timesetWordFrame for analysis
# write.table(interpolatedTS, file = "~/R/_workingDirectory/bagOfDrugs/local_py/dataFiles/interpolatedTS_hba1c_10y_30increments_2004-2014_locf.csv", sep=",", row.names = FALSE)




# write.table(drugWordFrame, file = "~/R/GlCoSy/MLsource/drugWordFrame_withID_2005_2015.csv", sep=",")
# drugWordFrame <- read.csv("~/R/GlCoSy/MLsource/drugWordFrame.csv", stringsAsFactors = F, row.names = NULL); drugWordFrame$row.names <- NULL

# here do analysis to select rows (IDs) for later analysis

# mortality outcome at 2017-01-01
interpolatedTS_mortality <- merge(interpolatedTS, deathData, by.x = "LinkId", by.y= "LinkId")

# type 2 diabetes only
interpolatedTS_mortality <- subset(interpolatedTS_mortality, DiabetesMellitusType_Mapped == 'Type 2 Diabetes Mellitus')

# type 1 diabetes only
# interpolatedTS_mortality <- subset(interpolatedTS_mortality, DiabetesMellitusType_Mapped == 'Type 1 Diabetes Mellitus')

# remove those dead before end of FU
# analysis frame = those who are not dead, or those who have died after the end of the runin period. ie all individuals in analysis alive at the end of the runin period
interpolatedTS_mortality <- subset(interpolatedTS_mortality, isDead == 0 | (isDead == 1 & unix_deathDate > returnUnixDateTime(endRuninPeriod)) )
# remove those diagnosed after the end of the runin period
interpolatedTS_mortality <- subset(interpolatedTS_mortality, unix_diagnosisDate <= returnUnixDateTime(endRuninPeriod) )
# remove those diagnosed after the start of the runin period
interpolatedTS_mortality <- subset(interpolatedTS_mortality, unix_diagnosisDate <= returnUnixDateTime(startRuninPeriod) )

interpolatedTS_mortality$age_at_startOfFollowUp <- (returnUnixDateTime(startRuninPeriod) - returnUnixDateTime(as.character(interpolatedTS_mortality$BirthDate))) / (60*60*24*365.25)

# remove those diagnosed after the beginning of the runin period ie all in analysis have had DM throughout followup period
# drugWordFrame_mortality <- subset(drugWordFrame_mortality, unix_diagnosisDate <= returnUnixDateTime(startRuninPeriod) )

interpolatedTS_forAnalysis <- interpolatedTS_mortality[, 2:length(sequence)]

mean = apply(interpolatedTS_forAnalysis, 1, mean)
stdev = apply(interpolatedTS_forAnalysis, 1, sd)
cv = stdev / mean


values_plusID_forExport <- data.frame(interpolatedTS_forAnalysis, interpolatedTS_mortality$LinkId, interpolatedTS_mortality$unix_deathDate, interpolatedTS_mortality$age_at_startOfFollowUp, interpolatedTS_mortality$median, cv)
write.table(values_plusID_forExport, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_", label, "_", unixRunInDurationYears,"y_", numberOfBins, "increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep=""), sep=",", row.names = FALSE)




y_vector <- interpolatedTS_mortality$isDead
y_vector_isType1 <- ifelse(interpolatedTS_mortality$DiabetesMellitusType_Mapped == 'Type 1 Diabetes Mellitus', 1, 0)
y_vector_deadAt_1_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (1 * 365.25 * 24 * 60 * 60)), 1, 0)
y_vector_deadAt_2_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (2 * 365.25 * 24 * 60 * 60)), 1, 0)
y_vector_deadAt_3_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (3 * 365.25 * 24 * 60 * 60)), 1, 0)
y_vector_deadAt_4_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (4 * 365.25 * 24 * 60 * 60)), 1, 0)
y_vector_deadAt_5_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (5 * 365.25 * 24 * 60 * 60)), 1, 0)

# write out sequence for analysis
# write.table(interpolatedTS_forAnalysis, file = "~/R/_workingDirectory/bagOfDrugs/local_py/hba1c_5y_30increments_2008-2013_locf_T1.csv", sep=",", row.names = FALSE)

# write out sequence for analysis with LinkId
# write.table(timesetWordFrame_mortality, file = "~/R/GlCoSy/MLsource/hba1c_5y_30increments_2008-2013_chained_y_rawWithId.csv", sep=",", row.names = FALSE)

# write out dep variable (y)
#write.table(y_vector, file = "~/R/GlCoSy/MLsource/hba1c_5y_mortality_y_10y_2002to2012_6mBins_10y_chained_y.csv", sep = ",", row.names = FALSE)
#write.table(y_vector_isType1, file = "~/R/GlCoSy/MLsource/isType1_for_hb1ac_10y_2002to2012_6mBins_10y_chained_y.csv", sep = ",", row.names = FALSE)
#
write.table(y_vector_deadAt_1_year, paste("~/R/_workingDirectory/nEqOneTrial/sourceData/", label, "_1y_mortality", unixRunInDurationYears,"y_", numberOfBins, "increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep=""), sep = ",", row.names = FALSE)
#write.table(y_vector_deadAt_2_year, file = "~/R/GlCoSy/MLsource/hba1c_2y_mortality_y_10y_2002to2012_6mBins_10y_chained_y.csv", sep = ",", row.names = FALSE)
write.table(y_vector_deadAt_3_year, paste("~/R/_workingDirectory/nEqOneTrial/sourceData/", label, "_3y_mortality", unixRunInDurationYears,"y_", numberOfBins, "increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep=""), sep = ",", row.names = FALSE)
#
write.table(y_vector_deadAt_4_year, paste("~/R/_workingDirectory/nEqOneTrial/sourceData/", label,"_4y_mortality", unixRunInDurationYears,"y_", numberOfBins, "increments_", startRuninPeriod, "_to_", endRuninPeriod, "_locf.csv", sep=""), sep = ",", row.names = FALSE)

}


##
# execution code
# load in raw data required
deathData <- read.csv("~/R/GlCoSy/SDsource/diagnosisDateDeathDate.txt", sep=",")

cleanHbA1cData <- read.csv("~/R/GlCoSy/SD_workingSource/hba1cDTclean.csv", sep=",", header = TRUE, row.names = NULL)
cleanSBPData <- read.csv("~/R/GlCoSy/SD_workingSource/SBPsetDTclean.csv", sep=",", header = TRUE, row.names = NULL)
cleanBMIData <- read.csv("~/R/GlCoSy/SD_workingSource/SBPsetDTclean.csv", sep=",", header = TRUE, row.names = NULL)

##
# set variables
runInStartDate = "2010-01-01"
runInEndDate = "2015-01-01"
binLength_months = 2

generateImputedTimeSeriesData(cleanHbA1cData, deathData, runInStartDate, runInEndDate, binLength_months, "hba1c", 8)
generateImputedTimeSeriesData(cleanSBPData, deathData, runInStartDate, runInEndDate, binLength_months, "SBP", 8)
generateImputedTimeSeriesData(cleanBMIData, deathData, runInStartDate, runInEndDate, binLength_months, "BMI", 8)






