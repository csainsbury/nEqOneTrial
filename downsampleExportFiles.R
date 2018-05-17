## quick approach to downsampling classes based on prescribed drugs
library(data.table)

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

## process drug data to flag IDs with classes of prescription
## SU, MF, TZD, DPP4, SGLT2, GLP1, Insulin

classesToFind <- c("SU_", "Metformin_", "TZD_", "DPP4_", "SGLT2_", "GLP1_", "Insulin_")
classFrame <- as.data.frame(matrix(0, nrow = nrow(bmiD), ncol = length(classesToFind)))
colnames(classFrame) <- classesToFind
classFrame$ID <- seq(1, nrow(bmiD), 1)

# loop through drugs to find all combinations containing
for (c in seq(1, length(classesToFind), 1)) {
  print(c)
  class = classesToFind[c]
  vectorCombinations_withClass <- lookupD$vectorNumbers[grep(class, lookupD[, 1])]
  
  # loop through all IDs drug combinations to see if any of the matching combinations present
  for (d in seq(1, nrow(drugD), 1)) {
    if(d %% 1000 == 0) {print(d)} 
    testRow <- drugD[d, 1:60]
    matchOutput <- match(testRow, vectorCombinations_withClass)
    matchOutput[is.na(matchOutput)] <- 0
    matchResult = ifelse(sum(matchOutput) > 0, 1, 0)
    classFrame[d, c] = matchResult
  }
  
}

prescribedN <- colSums(classFrame)
minClass = min(prescribedN)

# generate sets of all ID indexes by prescribed class
# classFrame <- data.table(classFrame)
sampleFrame <- as.data.frame(matrix(0, nrow = minClass, ncol = length(classesToFind)))
colnames(sampleFrame) <- classesToFind

for (s in seq(1, ncol(sampleFrame), 1)) {
  sampleFrame[, s] <- sample(classFrame$ID[classFrame[, s] == 1], minClass)
}


