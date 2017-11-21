library(data.table)

# import X_test_drugs.csv
drugDataSet <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/X_test_drugs.csv",header=FALSE,row.names=NULL)
drugDataSet <- data.table(drugDataSet)

# import lookup table
lookupTable <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/lookupTable_2010-01-01_to_2015-01-01_simplifiedDrugs.csv",header=T,row.names=NULL)

# simple test - find all on MF only in last year
numberOFBinsToChange = 6
index = as.data.frame(matrix(0, nrow = nrow(drugDataSet), ncol = numberOFBinsToChange))
for (j in seq(1, nrow(drugDataSet), 1)) {
  for (i in seq(1, numberOFBinsToChange, 1))
  index[j, i] <- ifelse(drugDataSet[j, 24 + i] == 3023, 1, 0)
}

  for (j in seq(1, nrow(index), 1)) {
    index$testSUM[j] <- ifelse(sum(index[j, ]) == 6, 1, 0)
  }


fy_MF_only <- drugDataSet[index$testSUM == 1]
write.table(fy_MF_only, file = "~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/fy_MF_only.csv", sep=",", row.names = FALSE)


# MF and SU
fy_MF_only[, 25:30] <- 3076
fy_MF_SU = fy_MF_only
write.table(fy_MF_SU, file = "~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/fy_MF_SU.csv", sep=",", row.names = FALSE)


# MF and SU and basal insulin
fy_MF_only[, 25:30] <- 2854
fy_MF_SU_basalIns = fy_MF_only
write.table(fy_MF_SU_basalIns, file = "~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/fy_MF_SU_basalIns.csv", sep=",", row.names = FALSE)


# MF and SGLT2
fy_MF_only[, 25:30] <- 3065
fy_MF_SGLT2 = fy_MF_only
write.table(fy_MF_SGLT2, file = "~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/fy_MF_SGLT2.csv", sep=",", row.names = FALSE)


# MF and GLP1
fy_MF_only[, 25:30] <- 2417
fy_MF_GLP1 = fy_MF_only
write.table(fy_MF_only, file = "~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/fy_MF_GLP1.csv", sep=",", row.names = FALSE)


# nil
fy_MF_only[, 25:30] <- 3111
fy_nil = fy_MF_only
write.table(fy_nil, file = "~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/fy_nil.csv", sep=",", row.names = FALSE)










#####
# vectorised lookup table use
decodedDrugFrame <- as.data.frame(matrix(0, nrow = nrow(drugWordFrame_drugNames), ncol = ncol(drugWordFrame_drugNames)))

for (jj in seq(1, ncol(drugWordFrame_drugNames), 1)) {
  
  index <- match(drugWordFrame_drugNames[,jj], lookup$vectorWords)
  numericalDrugsFrame[,jj] <- lookup$vectorNumbers[index]
  
}