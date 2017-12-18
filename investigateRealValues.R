
# set runin period of interest
startRuninPeriod <- '2011-10-01'
endRuninPeriod   <- '2016-10-01'

# drugs in whole set
drugCombinations_training <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/inputFiles/drugExport.csv",header=FALSE,row.names=NULL)

drugsAsSingleVector = as.vector(t(drugCombinations_training))
freqTable <- as.data.frame(table(drugsAsSingleVector))
freqTable <- freqTable[order(freqTable$Freq), ]

tail(freqTable, 20)

# read in lookup table
lookup <- read.csv(paste("~/R/_workingDirectory/nEqOneTrial/sourceData/lookupTable_", startRuninPeriod, "_to_", endRuninPeriod, "_simplifiedDrugs.csv", sep=""))

index <- match(freqTable$drugsAsSingleVector, lookup$vectorNumbers)
freqTable$names <- lookup$vectorWords[index]

# last drug comb continued
hba1c_last <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_lastComb.csv",header=FALSE,row.names=NULL)
summary(hba1c_last)

# mf + su
hba1c_MF_SU <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_SU.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SU)

# mf + sglt2
hba1c_MF_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_SGLT2.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SGLT2)

# mf + glp1
hba1c_MF_GLP1 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_GLP1.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_GLP1)

# mf + bdIns
hba1c_MF_bdIns <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_bIns.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_bdIns)

# mf + sglt2
decoded_hba1c <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_hba1c.csv",header=FALSE,row.names=NULL)
decoded_bmi <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_bmi.csv",header=FALSE,row.names=NULL)
decoded_sbp <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_sbp.csv",header=FALSE,row.names=NULL)

decoded_age <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/X_test_age.csv",header=FALSE,row.names=NULL)

lastValueCol = 48

# analysisFrame <- cbind(apply(decoded_hba1c[, 1:lastValueCol], 1, median), apply(decoded_bmi[, 1:lastValueCol], 1, median), decoded_age, hba1c_MF_SU, hba1c_MF_SGLT2, hba1c_MF_GLP1, hba1c_MF_bdIns)
analysisFrame <- cbind(decoded_hba1c[,lastValueCol], decoded_bmi[, lastValueCol], decoded_age, hba1c_MF_SU, hba1c_MF_SGLT2, hba1c_MF_GLP1, hba1c_MF_bdIns)

colnames(analysisFrame) <- c("hba1c", "bmi", "age", "MF_SU", "MF_SGLT2", "MF_GLP1", "MF_bdIns")


# analysisFrame <- cbind(apply(decoded_hba1c[, 1:lastValueCol], 1, median), apply(decoded_bmi[, 1:lastValueCol], 1, median), decoded_age, hba1c_MF_SU, hba1c_MF_SGLT2, hba1c_MF_GLP1, hba1c_MF_bdIns)
summaryFrame <- cbind(decoded_hba1c[,lastValueCol], decoded_bmi[, lastValueCol], decoded_age, hba1c_last, hba1c_MF_SU, hba1c_MF_SGLT2, hba1c_MF_GLP1, hba1c_MF_bdIns)

colnames(summaryFrame) <- c("hba1c", "bmi", "age", ,"hba1c_last", "MF_SU", "MF_SGLT2", "MF_GLP1", "MF_bdIns")

TS_dataFrame <- cbind(apply(decoded_hba1c[, 1:lastValueCol], 1, median), apply(decoded_bmi[, 1:lastValueCol], 1, median), decoded_age, hba1c_MF_SU, hba1c_MF_SGLT2, hba1c_MF_GLP1, hba1c_MF_bdIns)
colnames(TS_dataFrame) <- c("hba1c", "bmi", "age", "MF_SU", "MF_SGLT2", "MF_GLP1", "MF_bdIns")

decoded_hba1c$SUaboveSGLT2 <- ifelse(TS_dataFrame$MF_SU > TS_dataFrame$MF_SGLT2, 1, 0)
decoded_hba1c$SGLT2aboveSU <- ifelse(TS_dataFrame$MF_SU < TS_dataFrame$MF_SGLT2, 1, 0)

SUsub <- subset(decoded_hba1c, SUaboveSGLT2 == 1)
SGLT2sub <- subset(decoded_hba1c, SGLT2aboveSU == 1)

transparency = 0.1
for (s in seq(1, nrow(SUsub), 1)) {
  if(s == 1) {
    plot(c(1:lastValueCol), SUsub[s, 1:lastValueCol], ylim = c(0, 200), cex = 0, col = rgb(0, 0, 0, transparency, maxColorValue = 1))
    lines(c(1:lastValueCol), SUsub[s, 1:lastValueCol], col = rgb(0, 0, 0, transparency, maxColorValue = 1))
         }
  if(s>1) {
    points(c(1:lastValueCol), SUsub[s, 1:lastValueCol], cex = 0, col = rgb(0, 0, 0, transparency, maxColorValue = 1))
    lines(c(1:lastValueCol), SUsub[s, 1:lastValueCol], col = rgb(0, 0, 0, transparency, maxColorValue = 1))
    
    points(c(1:lastValueCol), SGLT2sub[s, 1:lastValueCol], cex = 0, col = rgb(1, 0, 0, transparency, maxColorValue = 1))
    lines(c(1:lastValueCol), SGLT2sub[s, 1:lastValueCol], col = rgb(1, 0, 0, transparency, maxColorValue = 1))

    
           }
}

testSub <- SUsub
testSub <- SGLT2sub
transparency = 1
for (s in seq(1, nrow(testSub), 1)) {
  if(s == 1) {
    plot(c(1:lastValueCol), testSub[s, 1:lastValueCol], ylim = c(0, 200), cex = 0, col = rgb(0, 0, 0, transparency, maxColorValue = 1))
    lines(c(1:lastValueCol), testSub[s, 1:lastValueCol], col = rgb(0, 0, 0, transparency, maxColorValue = 1))
  }
  if(s>1) {
    points(c(1:lastValueCol), testSub[s, 1:lastValueCol], cex = 0, col = rgb(0, 0, 0, transparency, maxColorValue = 1))
    lines(c(1:lastValueCol), testSub[s, 1:lastValueCol], col = rgb(0, 0, 0, transparency, maxColorValue = 1))
    
  }
}


decoded_hba1c$end50 <- ifelse(decoded_hba1c[, lastValueCol] > 45 & decoded_hba1c[, lastValueCol] < 55, 1, 0)
decoded_hba1c$end73 <- ifelse(decoded_hba1c[, lastValueCol] > 65 & decoded_hba1c[, lastValueCol] < 87, 1, 0)
end50stats <- boxplot(subset(decoded_hba1c, end50 == 1)[, 1:lastValueCol])
end73stats <- boxplot(subset(decoded_hba1c, end73 == 1)[, 1:lastValueCol])

SUsubStats <- boxplot(SUsub[, 1:lastValueCol])
SGLT2subStats <- boxplot(SGLT2sub[, 1:lastValueCol])

plot(end50stats$stats[3, ], ylim = c(30, 100)); lines(end50stats$stats[3, ], col = 'grey')
  points(end50stats$stats[2, ], cex = 0); lines(end50stats$stats[2, ], col = 'grey', lty = 3)
  points(end50stats$stats[4, ], cex = 0); lines(end50stats$stats[4, ], col = 'grey', lty = 3)
  
points(SUsubStats$stats[3, ]); lines(SUsubStats$stats[3, ], col = 'black')
  points(SUsubStats$stats[2, ], cex = 0); lines(SUsubStats$stats[2, ], col = 'black', lty = 3)
  points(SUsubStats$stats[4, ], cex = 0); lines(SUsubStats$stats[4, ], col = 'black', lty = 3)

points(end73stats$stats[3, ]); lines(end73stats$stats[3, ], col = 'red')
  points(end73stats$stats[2, ], cex = 0); lines(end73stats$stats[2, ], col = 'red', lty = 3)
  points(end73stats$stats[4, ], cex = 0); lines(end73stats$stats[4, ], col = 'red', lty = 3)

points(SGLT2subStats$stats[3, ]); lines(SGLT2subStats$stats[3, ], col = 'blue')
  points(SGLT2subStats$stats[2, ], cex = 0); lines(SGLT2subStats$stats[2, ], col = 'blue', lty = 3)
  points(SGLT2subStats$stats[4, ], cex = 0); lines(SGLT2subStats$stats[4, ], col = 'blue', lty = 3)







breakn = 10

su_hb <- boxplot(analysisFrame$MF_SU ~ cut(analysisFrame$hba1c, breaks = seq(30, 150, 2)), varwidth = T)
sglt2_hb <- boxplot(analysisFrame$MF_SGLT2 ~ cut(analysisFrame$hba1c, seq(30, 150, 2)), varwidth = T)
glp1_hb <- boxplot(analysisFrame$MF_GLP1 ~ cut(analysisFrame$hba1c, seq(30, 150, 2)), varwidth = T)

plot(su_hb$stats[3,],  cex = (sqrt(su_hb$n) / 10)); lines(su_hb$stats[3,])
points(sglt2_hb$stats[3,], col = 'red', cex = (sqrt(sglt2_hb$n) / 10)); lines(sglt2_hb$stats[3,], col = 'red')
points(glp1_hb$stats[3,], col = 'blue', cex = (sqrt(glp1_hb$n) / 10)); lines(glp1_hb$stats[3,], col = 'blue')


su_bmi <- boxplot(analysisFrame$MF_SU ~ cut(analysisFrame$bmi, breaks = seq(25, 40, 1)), varwidth = T)
sglt2_bmi <- boxplot(analysisFrame$MF_SGLT2 ~ cut(analysisFrame$bmi, seq(25, 40, 1)), varwidth = T)
glp1_bmi <- boxplot(analysisFrame$MF_GLP1 ~ cut(analysisFrame$bmi, seq(25, 40, 1)), varwidth = T)

plot(su_bmi$stats[3,], ylim = c(0.05, 1), cex = (sqrt(su_bmi$n) / 10)); lines(su_bmi$stats[3,])
points(sglt2_bmi$stats[3,], col = 'red', cex = (sqrt(sglt2_bmi$n) / 10)); lines(sglt2_bmi$stats[3,], col = 'red')
points(glp1_bmi$stats[3,], col = 'blue', cex = (sqrt(glp1_bmi$n) / 10)); lines(glp1_bmi$stats[3,], col = 'blue')


su_age <- boxplot(analysisFrame$MF_SU ~ cut(analysisFrame$age, breaks = seq(30, 80, 2)), varwidth = T)
sglt2_age <- boxplot(analysisFrame$MF_SGLT2 ~ cut(analysisFrame$age, seq(30, 80, 2)), varwidth = T)
glp1_age <- boxplot(analysisFrame$MF_GLP1 ~ cut(analysisFrame$age, seq(30, 80, 2)), varwidth = T)

plot(su_age$stats[3,], ylim = c(0.05, 0.3), cex = (sqrt(su_age$n) / 10)); lines(su_age$stats[3,])
points(sglt2_age$stats[3,], col = 'red', cex = (sqrt(su_age$n) / 10)); lines(sglt2_age$stats[3,], col = 'red')
points(glp1_age$stats[3,], col = 'blue', cex = (sqrt(su_age$n) / 10)); lines(glp1_age$stats[3,], col = 'blue')


# hba1c vs bmi plot
plot(analysisFrame$bmi, analysisFrame$hba1c, ylim = c(30, 120), xlim = c(15, 50))
boxplot(analysisFrame$hba1c ~ cut(analysisFrame$bmi, breaks = seq(15, 50, 1)))

for (j in seq(1, nrow(analysisFrame), 1)) {
  maxVal <- max(analysisFrame[j, 4:7])
  analysisFrame$max[j] <- ifelse(analysisFrame[j, 4] == maxVal, "SU", "")
  analysisFrame$max[j] <- ifelse(analysisFrame[j, 5] == maxVal, "SGLT2", analysisFrame$max[j])
  analysisFrame$max[j] <- ifelse(analysisFrame[j, 6] == maxVal, "GLP1", analysisFrame$max[j])
  analysisFrame$max[j] <- ifelse(analysisFrame[j, 7] == maxVal, "ins", analysisFrame$max[j])
}

transparency = 0.1
plot(analysisFrame$bmi, analysisFrame$hba1c, ylim = c(30, 120), xlim = c(15, 50), pch = 16, cex = 4, col = ifelse(analysisFrame$max == "SU", rgb(0, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "SGLT2", rgb(1, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "GLP1", rgb(0, 0, 1, transparency, maxColorValue = 1), rgb(0, 1, 0, transparency, maxColorValue = 1)))))
sglt2_regression <- abline(lm(subset(analysisFrame, max == "SGLT2")$hba1c ~ subset(analysisFrame, max == "SGLT2")$bmi), col = "red")
glp1_regression <- abline(lm(subset(analysisFrame, max == "GLP1")$hba1c ~ subset(analysisFrame, max == "GLP1")$bmi), col = "blue")
su_regression <- abline(lm(subset(analysisFrame, max == "SU")$hba1c ~ subset(analysisFrame, max == "SU")$bmi), col = "black")
su_regression <- abline(lm(subset(analysisFrame, max == "ins")$hba1c ~ subset(analysisFrame, max == "ins")$bmi), col = "green")

# 
# plot(log(analysisFrame$bmi), log(analysisFrame$hba1c), pch = 16, cex = 4, col = ifelse(analysisFrame$max == "SU", rgb(0, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "SGLT2", rgb(1, 0, 0, transparency, maxColorValue = 1), ifelse(analysisFrame$max == "GLP1", rgb(0, 0, 1, transparency, maxColorValue = 1), rgb(0, 1, 0, transparency, maxColorValue = 1)))))
# 

