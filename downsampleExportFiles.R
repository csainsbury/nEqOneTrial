## quick approach to downsampling classes based on prescribed drugs

## load in all export data
bmiD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/bmi_export.csv", header = TRUE)
sbpD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/sbp_export.csv", header = TRUE)
hba1cD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/hba1c_export.csv", header = TRUE)

drugD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/drugExport.csv", header = TRUE)
lookupD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/lookup.csv", header = TRUE)

genderD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/gender_export.csv", header = TRUE)
durationD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/duration_export.csv", header = TRUE)
ageD = read.csv("~/R/_workingDirectory/nEqOneTrial/paperspaceVersion110518/inputFiles/age_export.csv", header = TRUE)

## add unique ID to each file
nID = nrow(bmiD)
bmiD$uniqueID <- seq(1, nID, 1)
sbpD$uniqueID <- seq(1, nID, 1)
hba1cD$uniqueID <- seq(1, nID, 1)
drugD$uniqueID <- seq(1, nID, 1)
genderD$uniqueID <- seq(1, nID, 1)
durationD$uniqueID <- seq(1, nID, 1)
ageD$uniqueID <- seq(1, nID, 1)
