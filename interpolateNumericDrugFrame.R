library(imputeTS)


# set runin period of interest
startRuninPeriod <- '2011-10-01'
endRuninPeriod   <- '2016-10-01'

binLengthMonths = 1


numericDrugCombinations <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_withID_30bins_", startRuninPeriod, "_to_", endRuninPeriod, "_simplifiedDrugs_", binLengthMonths,"mBins.csv", sep=""))

firstColtable <- as.data.frame(table(numericDrugCombinations[, 1]))
firstColtable <- firstColtable[order(firstColtable$Freq), ]

zeroCode <- as.numeric(levels(tail(firstColtable, 1)$Var[1])[tail(firstColtable, 1)$Var[1]])

numericDrugCombinations[numericDrugCombinations == zeroCode] <- NA

# 
# # last value carry forward imputation of values
# timesetWordFrame[,1][is.na(timesetWordFrame[,1])] <- 0
# interpolatedTS <- as.data.frame(matrix(nrow = nrow(timesetWordFrame), ncol = (ncol(timesetWordFrame) - 1)))

for (jj in seq(1, nrow(numericDrugCombinations), 1)) {
  
  if(jj%%1000 == 0) {print(jj)}
  
  testVector <- c(0, numericDrugCombinations[jj, 1:(ncol(numericDrugCombinations))])
  # interpolatedTS[jj, ] <- na.interpolation(as.numeric(timesetWordFrame[jj, 1:(ncol(timesetWordFrame) - 1)]), option ="linear")
  
  # interpolatedTS[jj, ] <- na.interpolation(as.numeric(testVector), option ="linear")[2: length(testVector)]
  numericDrugCombinations[jj, ] <- na.locf(as.numeric(testVector), option ="locf")[2: length(testVector)]
}
# 
# interpolatedTS$LinkId <- timesetWordFrame$LinkId
# interpolatedTS$median <- medianFrame$median

write.table(numericDrugCombinations, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_30bins_", startRuninPeriod, "_to_", endRuninPeriod, "_simplifiedDrugs_", binLengthMonths,"mBins_interpolated.csv", sep=""), sep=",", row.names = FALSE)


drugCombinationData_numerical <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_30bins_", startRuninPeriod,"_to_", endRuninPeriod,"_simplifiedDrugs_1mBins_interpolated.csv", sep = ''), header = T)