library(data.table)
library(imputeTS)

# functions
returnUnixDateTime<-function(date) {
  returnVal<-as.numeric(as.POSIXct(date, format="%Y-%m-%d", tz="GMT"))
  return(returnVal)
}

# read data files
hba1c_interpolated <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_hba1c_5y_30increments_2010-01-01_to_2015-01-01_locf.csv")
hba1c_interpolated$median <- NULL

sbp_interpolated <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_SBP_5y_30increments_2010-01-01_to_2015-01-01_locf.csv")
sbp_interpolated$median <- NULL

bmi_interpolated <- read.csv("~/R/_workingDirectory/nEqOneTrial/sourceData/interpolatedTS_BMI_5y_30increments_2010-01-01_to_2015-01-01_locf.csv")
bmi_interpolated$median <- NULL

# merge files to give single frame
hb_sbp_merge <- merge(hba1c_interpolated, sbp_interpolated, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')
hb_sbp_bmi_merge <- merge(hb_sbp_merge, bmi_interpolated, by.x = 'interpolatedTS_mortality.LinkId', by.y = 'interpolatedTS_mortality.LinkId')

## bring in other data to code
# load and process mortality data
deathData <- read.csv("~/R/GlCoSy/SDsource/diagnosisDateDeathDate.txt", sep=",")
deathData$unix_deathDate <- returnUnixDateTime(deathData$DeathDate)
deathData$unix_deathDate[is.na(deathData$unix_deathDate)] <- 0
deathData$isDead <- ifelse(deathData$unix_deathDate > 0, 1, 0)
deathData$unix_diagnosisDate <- returnUnixDateTime(deathData$DateOfDiagnosisDiabetes_Date)

deathDataDT <- data.table(deathData)

# set runin period of interest
startRuninPeriod <- '2010-01-01'
endRuninPeriod   <- '2015-01-01'

sequence <- seq(0, 1 , (1/30))

# mortality outcome at 2017-01-01
interpolatedTS_mortality <- merge(hb_sbp_bmi_merge, deathData, by.x = "interpolatedTS_mortality.LinkId", by.y= "LinkId")

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

seqL = (length(sequence))

interpolatedTS_mortality_hba1c <- interpolatedTS_mortality[, 2:seqL]
interpolatedTS_mortality_sbp   <- interpolatedTS_mortality[, (seqL + 5):((seqL + 5) + (seqL - 2))]
interpolatedTS_mortality_bmi   <- interpolatedTS_mortality[, ((seqL * 2) + 8): ((seqL * 3) + 6)]

summaryStats <- function(inputFrame, nameVariable) {
  
  meanName <- paste(nameVariable, 'mean', sep = '')
  stdevName <- paste(nameVariable, 'stdev', sep = '')
  cvName <- paste(nameVariable, 'cv', sep = '')
  
  inputFrame[[meanName]] = apply(inputFrame, 1, mean)
  inputFrame[[stdevName]] = apply(inputFrame, 1, sd)
  inputFrame[[cvName]] =  inputFrame[[stdevName]] / inputFrame[[meanName]]
  
  return(inputFrame)
  
}

hba1c_data <- summaryStats(interpolatedTS_mortality_hba1c, 'hba1c_')
sbp_data <- summaryStats(interpolatedTS_mortality_sbp, 'sbp_')
bmi_data <- summaryStats(interpolatedTS_mortality_bmi, 'bmi_')

# interesting crossplotting
boxplot(bmi_data$bmi_cv ~ cut(hba1c_data$hba1c_cv, breaks = 100))
boxplot(sbp_data$sbp_cv ~ cut(hba1c_data$hba1c_cv, breaks = 100))

# generate age as a time-series metric
interpolatedTS_mortality_age <- as.data.frame(matrix(nrow = nrow(interpolatedTS_mortality), ncol = (length(sequence) - 1)))
interpolatedTS_mortality_age$V1 <- interpolatedTS_mortality$age_at_startOfFollowUp
followupTimeInterval <- returnUnixDateTime(endRuninPeriod)- returnUnixDateTime(startRuninPeriod)
stepIncrement <- followupTimeInterval / (length(sequence) - 1)

# propagate age forward throught the runin period
for (j in seq(2, ncol(interpolatedTS_mortality_age), 1)) {
  if(j == 2) {
    interpolatedTS_mortality_age[, j] = interpolatedTS_mortality_age[, 1] + (stepIncrement / (60*60*24*365.25))
  }
  if(j > 2) {
    interpolatedTS_mortality_age[, j] = interpolatedTS_mortality_age[, (j-1)] + (stepIncrement / (60*60*24*365.25))
  }
}

interpolatedTS_mortality_age$LinkId <- interpolatedTS_mortality$interpolatedTS_mortality.LinkId


# write.table(hba1c_data, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/hba1c_data_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", startRuninPeriod, "_to_", endRuninPeriod, "_T2.csv", sep = ''), sep=",", row.names = FALSE)
# write.table(sbp_data, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/sbp_data_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", startRuninPeriod, "_to_", endRuninPeriod, "_T2.csv", sep = ''), sep=",", row.names = FALSE)
# write.table(bmi_data, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/bmi_data_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", startRuninPeriod, "_to_", endRuninPeriod, "_T2.csv", sep = ''), sep=",", row.names = FALSE)
write.table(interpolatedTS_mortality_age, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/age_data_", round(followupTimeInterval / (60*60*24*365.25), 0), "y_", startRuninPeriod, "_to_", endRuninPeriod, "_T2.csv", sep = ''), sep=",", row.names = FALSE)


# mean = apply(interpolatedTS_forAnalysis, 1, mean)
# stdev = apply(interpolatedTS_forAnalysis, 1, sd)
# cv = stdev / mean


# values_plusID_forExport <- data.frame(interpolatedTS_forAnalysis, interpolatedTS_mortality$LinkId, interpolatedTS_mortality$unix_deathDate, interpolatedTS_mortality$age_at_startOfFollowUp, interpolatedTS_mortality$median, cv)
# write.table(values_plusID_forExport, file = "~/R/_workingDirectory/bagOfDrugs/local_py/interpolatedTS_hba1c_10y_30increments_2004-2014_locf.csv", sep=",", row.names = FALSE)

# 
# 
# y_vector <- interpolatedTS_mortality$isDead
# y_vector_isType1 <- ifelse(interpolatedTS_mortality$DiabetesMellitusType_Mapped == "Type 1 Diabetes Mellitus", 1, 0)
# y_vector_deadAt_1_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (1 * 365.25 * 24 * 60 * 60)), 1, 0)
# y_vector_deadAt_2_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (2 * 365.25 * 24 * 60 * 60)), 1, 0)
# y_vector_deadAt_3_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (3 * 365.25 * 24 * 60 * 60)), 1, 0)
# y_vector_deadAt_4_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (4 * 365.25 * 24 * 60 * 60)), 1, 0)
# y_vector_deadAt_5_year <- ifelse(interpolatedTS_mortality$isDead == 1 & interpolatedTS_mortality$unix_deathDate < (returnUnixDateTime(endRuninPeriod) + (5 * 365.25 * 24 * 60 * 60)), 1, 0)
# 
# # write out sequence for analysis
# # write.table(interpolatedTS_forAnalysis, file = "~/R/_workingDirectory/bagOfDrugs/local_py/hba1c_5y_30increments_2008-2013_locf_T1.csv", sep=",", row.names = FALSE)
# 
# # write out sequence for analysis with LinkId
# # write.table(timesetWordFrame_mortality, file = "~/R/GlCoSy/MLsource/hba1c_5y_30increments_2008-2013_chained_y_rawWithId.csv", sep=",", row.names = FALSE)
# 
# # write out dep variable (y)
# #write.table(y_vector, file = "~/R/GlCoSy/MLsource/hba1c_5y_mortality_y_10y_2002to2012_6mBins_10y_chained_y.csv", sep = ",", row.names = FALSE)
# #write.table(y_vector_isType1, file = "~/R/GlCoSy/MLsource/isType1_for_hb1ac_10y_2002to2012_6mBins_10y_chained_y.csv", sep = ",", row.names = FALSE)
# #
# write.table(y_vector_deadAt_1_year, file = "~/R/_workingDirectory/bagOfDrugs/3d_input/1y_mortality_5y_30bins_2008-13_T2.csv", sep = ",", row.names = FALSE)
# #write.table(y_vector_deadAt_2_year, file = "~/R/GlCoSy/MLsource/hba1c_2y_mortality_y_10y_2002to2012_6mBins_10y_chained_y.csv", sep = ",", row.names = FALSE)
# write.table(y_vector_deadAt_3_year, file = "~/R/_workingDirectory/bagOfDrugs/local_py/hba1c_3y_mortality_y_10y_30increments_2004-2014_locf.csv", sep = ",", row.names = FALSE)
# #
# write.table(y_vector_deadAt_4_year, file = "~/R/_workingDirectory/bagOfDrugs/local_py/hba1c_4y_mortality_y_10y_30increments_2004-2014_locf.csv", sep = ",", row.names = FALSE)

