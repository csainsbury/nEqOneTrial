library(data.table)
library(scales)

numberOfCombinations = 12

sampleVector <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_combinationNumber_0.csv", sep = ''),header=FALSE,row.names=NULL)

probabilityTable = as.data.frame(matrix(nrow = NROW(sampleVector), ncol = numberOfCombinations))

for (j in seq(0, numberOfCombinations - 1, 1)) {
  colNumber = j + 1
  probabilityTable[, colNumber] <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_combinationNumber_", j, ".csv", sep = ''),header=FALSE,row.names=NULL)
}

colnames(probabilityTable) <- c(paste("combination_", seq(1, numberOfCombinations, 1), sep=""))
probabilityTable$max = apply(probabilityTable, 1, which.max)

decoded_hba1c <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_hba1c.csv",header=FALSE,row.names=NULL)
decoded_bmi <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_bmi.csv",header=FALSE,row.names=NULL)
decoded_sbp <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_sbp.csv",header=FALSE,row.names=NULL)

decoded_age <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/X_test_age.csv",header=FALSE,row.names=NULL)

lastValueCol = 48

hba1c = decoded_hba1c[,lastValueCol]
bmi = decoded_bmi[, lastValueCol]
age = decoded_age

# analysisFrame <- cbind(apply(decoded_hba1c[, 1:lastValueCol], 1, median), apply(decoded_bmi[, 1:lastValueCol], 1, median), decoded_age, hba1c_MF_SU, hba1c_MF_SGLT2, hba1c_MF_GLP1, hba1c_MF_bdIns)
analysisFrame <- cbind(hba1c, bmi, age, probabilityTable)
analysisFrame <- data.table(analysisFrame)
# 
# analysisFrame$bmi <- ifelse(analysisFrame$bmi < 1, 0, analysisFrame$bmi)
# analysisFrame <- analysisFrame[bmi!=0]
# 
# 
# # hba1c vs bmi plot
# plot(analysisFrame[, 2], analysisFrame[, 1], ylim = c(30, 120), xlim = c(15, 50))
# boxplot(analysisFrame[, 2] ~ cut(analysisFrame[, 1], breaks = seq(15, 50, 1)))
# 
# analysisHbA1c = analysisFrame[, 1]
# analysisBMI = analysisFrame[, 2]


# plot
maxValueTable <- as.data.frame(table(analysisFrame$max))
transparency = 0.4
ylimVals = c(30, 120)
xlimVals = c(15, 50)
cex_size = 2

for (p in seq(1, nrow(maxValueTable), 1)) {
  
  plotSubSet <- analysisFrame[max == as.numeric(levels(maxValueTable$Var1[p]))[maxValueTable$Var1[p]]]
  
  if(p == 1) {
    colN1 = runif(1); colN2 = runif(1); colN3 = runif(1)
    plot(plotSubSet$bmi, plotSubSet$hba1c,  ylim = ylimVals, xlim = xlimVals, pch = 16, cex = cex_size, col = rgb(colN1,colN2,colN3, transparency, maxColorValue = 1))
#    plot(plotSubSet$bmi, plotSubSet$hba1c,  ylim = ylimVals, xlim = xlimVals, pch = 16, cex = cex_size, col = alpha(p, transparency))
    if(maxValueTable$Freq[p] > 1) {regression <- abline(lm(plotSubSet$hba1c ~ plotSubSet$bmi),col = rgb(colN1,colN2,colN3, transparency, maxColorValue = 1))}
  }
  if(p > 1) {
    colN1 = runif(1); colN2 = runif(1); colN3 = runif(1)
    points(plotSubSet$bmi, plotSubSet$hba1c, pch = 16, cex = cex_size, col = rgb(colN1,colN2,colN3, transparency, maxColorValue = 1))
    # points(plotSubSet$bmi, plotSubSet$hba1c, pch = 16, cex = cex_size, col = alpha(p, transparency))
    if(maxValueTable$Freq[p] > 1) {regression <- abline(lm(plotSubSet$hba1c ~ plotSubSet$bmi),col = rgb(colN1,colN2,colN3, transparency, maxColorValue = 1))}
  }
  
}




plot(analysisFrame$bmi, analysisFrame$hba1c, ylim = c(30, 120), xlim = c(15, 50), pch = 16, cex = 4, col = ifelse(analysisFrame$max == "SU", rgb(0, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "SGLT2", rgb(1, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "GLP1", rgb(0, 0, 1, transparency, maxColorValue = 1), rgb(0, 1, 0, transparency, maxColorValue = 1)))))
sglt2_regression <- abline(lm(subset(analysisFrame, max == "SGLT2")$hba1c ~ subset(analysisFrame, max == "SGLT2")$bmi), col = "red")
glp1_regression <- abline(lm(subset(analysisFrame, max == "GLP1")$hba1c ~ subset(analysisFrame, max == "GLP1")$bmi), col = "blue")
su_regression <- abline(lm(subset(analysisFrame, max == "SU")$hba1c ~ subset(analysisFrame, max == "SU")$bmi), col = "black")
su_regression <- abline(lm(subset(analysisFrame, max == "ins")$hba1c ~ subset(analysisFrame, max == "ins")$bmi), col = "green")

# 
# plot(log(analysisFrame$bmi), log(analysisFrame$hba1c), pch = 16, cex = 4, col = ifelse(analysisFrame$max == "SU", rgb(0, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "SGLT2", rgb(1, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "GLP1", rgb(0, 0, 1, transparency, maxColorValue = 1), rgb(0, 1, 0, transparency, maxColorValue = 1)))))
# 

# plots for talk:
plot(c(1:60), decoded_hba1c[160,], pch = 0, cex = 0, xlim = c(15, 46), ylim = c(60, 110)); lines(c(1:60), decoded_hba1c[160,],lwd = 3)
plot(c(1:60), decoded_bmi[160,], pch = 0, cex = 0, xlim = c(15, 46), ylim = c(22, 28)); lines(c(1:60), decoded_bmi[160,], lwd = 3)
plot(c(1:60), decoded_sbp[160,], pch = 0, cex = 0, xlim = c(15, 46), ylim = c(90, 140)); lines(c(1:60), decoded_sbp[160,], lwd = 3)

## drugs - to recreate subsets akin to trial data
drugs <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/X_test_drugs.csv",header=FALSE,row.names=NULL)
runinSet_drugs <- drugs[, 1 : lastValueCol]

startCol = 36
endCol= 48

runinSet_drugs$flagInterest <- 0

for (jj in seq(1, nrow(runinSet_drugs), 1)) {
  
  runinSet_drugs$flagInterest[jj] <- ifelse(sum(diff(as.numeric(runinSet_drugs[jj, startCol : endCol]))) == 0 &
                                              as.numeric(runinSet_drugs[jj, endCol]) == 693, 1, 0)
  
}

## hard coded example: mf then mf + su
mf_sub <- subset(decoded_hba1c, runinSet_drugs$flagInterest == 1)
mf_su_probs <- as.data.frame(subset(analysisFrame, runinSet_drugs$flagInterest == 1))
