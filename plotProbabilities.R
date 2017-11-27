# # import y_pred_asNumber - original
# hba1c_original <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_original.csv",header=FALSE,row.names=NULL)
# summary(hba1c_original)
# 
# sbp_original <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_original.csv",header=FALSE,row.names=NULL)
# summary(sbp_original)

# nil
hba1c_nil <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_nil.csv",header=FALSE,row.names=NULL)
summary(hba1c_nil)

sbp_nil <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_nil.csv",header=FALSE,row.names=NULL)
summary(sbp_nil)

bmi_nil <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_bmi_nil.csv",header=FALSE,row.names=NULL)
summary(bmi_nil)

# mf
hba1c_MF <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF)

sbp_MF <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF.csv",header=FALSE,row.names=NULL)
summary(sbp_MF)

bmi_MF <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_bmi_MF.csv",header=FALSE,row.names=NULL)
summary(bmi_MF)

# mf + su
hba1c_MF_SU <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_SU.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SU)

sbp_MF_SU <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_SU.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_SU)

bmi_MF_SU <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_bmi_MF_SU.csv",header=FALSE,row.names=NULL)
summary(bmi_MF_SU)

# mf + human basal ins
hba1c_MF_bdIns <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_bdIns.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_bdIns)

sbp_MF_bdIns <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_bdIns.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_bdIns)

bmi_MF_bIns <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_bmi_MF_bIns.csv",header=FALSE,row.names=NULL)
summary(bmi_MF_bIns)

# mf + sglt2
hba1c_MF_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_SGLT2.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SGLT2)

sbp_MF_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_SGLT2.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_SGLT2)

bmi_MF_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_bmi_MF_SGLT2.csv",header=FALSE,row.names=NULL)
summary(bmi_MF_SGLT2)

# mf + glp1
hba1c_MF_GLP1 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_GLP1.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_GLP1)

sbp_MF_GLP1 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_GLP1.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_GLP1)

bmi_MF_GLP1 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_bmi_MF_GLP1.csv",header=FALSE,row.names=NULL)
summary(bmi_MF_GLP1)

# mf + glp1 + sglt2
hba1c_MF_GLP1_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_GLP1_SGLT2.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_GLP1_SGLT2)

sbp_MF_GLP1_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_GLP1_SGLT2.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_GLP1_SGLT2)

bmi_MF_GLP1_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_bmi_MF_GLP1_SGLT2.csv",header=FALSE,row.names=NULL)
summary(bmi_MF_GLP1_SGLT2)

library(ggplot2)


# plotting
cexValue = 1
opacity = 0.05
plot(hba1c_nil[,1], sbp_nil[,1], pch = 16, cex = cexValue, col = rgb(1, 0, 0, opacity, maxColorValue = 1), xlim = c(0, 1), ylim = c(0, 1))
points(hba1c_MF_SU[, 1], sbp_MF_SU[, 1], pch = 16, cex = cexValue, col = rgb(0.2, 0.2, 0.2, opacity, maxColorValue = 1))
points(hba1c_MF_bIns[, 1], sbp_MF_bIns[, 1], pch = 16, cex = cexValue, col = rgb(0, 1, 0, opacity, maxColorValue = 1))
points(hba1c_MF_SGLT2[, 1], sbp_MF_SGLT2[, 1], pch = 16, cex = cexValue, col = rgb(0, 0, 1, opacity, maxColorValue = 1))

library(aplpack)
bagplot(hba1c_nil[,1], sbp_nil[,1])
bagplot(hba1c_MF_SU[,1], sbp_MF_SU[,1])
bagplot(hba1c_MF_SGLT2[,1], sbp_MF_SGLT2[,1])
bagplot(hba1c_MF_GLP1[,1], sbp_MF_GLP1[,1])

# a method of plotting x and y error bars
# need to generate plotting frame with x/y and max/min values for error bars from data

plotFrame <- as.data.frame(matrix(nrow = 6, ncol = 7))
colnames(plotFrame) <- c("labels", "hba1cMedian", "hba1c25", "hba1c75", "sbpMedian", "sbp25", "sbp75")
plotFrame$labels <- c("nil", "MF", "MF_SU", "MF_bdIns", "MF_SGLT2", "MF_GLP1")

hba1cConcatFrame <- cbind(hba1c_nil, hba1c_MF, hba1c_MF_SU, hba1c_MF_bdIns, hba1c_MF_SGLT2, hba1c_MF_GLP1)
sbpConcatFrame <- cbind(sbp_nil, sbp_MF, sbp_MF_SU, sbp_MF_bdIns, sbp_MF_SGLT2, sbp_MF_GLP1)

for (j in seq(1, nrow(plotFrame), 1)) {
    plotFrame[j, 2] <- quantile(hba1cConcatFrame[, j])[3]
    plotFrame[j, 3] <- quantile(hba1cConcatFrame[, j])[2]
    plotFrame[j, 4] <- quantile(hba1cConcatFrame[, j])[4]
    
    plotFrame[j, 5] <- quantile(sbpConcatFrame[, j])[3]
    plotFrame[j, 6] <- quantile(sbpConcatFrame[, j])[2]
    plotFrame[j, 7] <- quantile(sbpConcatFrame[, j])[4]
  
}

plot(sbpMedian ~ hba1cMedian,data=plotFrame, xlim = c(0, 0.5), ylim = c(0.1, 0.4))
arrows(x0=plotFrame$hba1cMedian,
       y0=plotFrame$sbp25,
       x1=plotFrame$hba1cMedian,
       y1=plotFrame$sbp75,
       angle=90,
       code=3,length=0.04,
       lwd=0.4)

arrows(x0=plotFrame$hba1c25,
       y0=plotFrame$sbpMedian,
       x1=plotFrame$hba1c75,
       y1=plotFrame$sbpMedian,
       angle=90,
       code=3,
       length=0.04,
       lwd=0.4)
xlabelPlot <- plotFrame$hba1cMedian - 0.01
text(0, y = plotFrame$sbpMedian, labels = plotFrame$labels)

## plot for BMI
plotFrame <- as.data.frame(matrix(nrow = 6, ncol = 7))
colnames(plotFrame) <- c("labels", "hba1cMedian", "hba1c25", "hba1c75", "bmiMedian", "bmi25", "bmi75")
plotFrame$labels <- c("nil", "MF", "MF_SU", "MF_bIns", "MF_SGLT2", "MF_GLP1")

hba1cConcatFrame <- cbind(hba1c_nil, hba1c_MF, hba1c_MF_SU, hba1c_MF_bIns, hba1c_MF_SGLT2, hba1c_MF_GLP1)
bmiConcatFrame <- cbind(bmi_nil, bmi_MF, bmi_MF_SU, bmi_MF_bIns, bmi_MF_SGLT2, bmi_MF_GLP1)

for (j in seq(1, nrow(plotFrame), 1)) {
  plotFrame[j, 2] <- quantile(hba1cConcatFrame[, j])[3]
  plotFrame[j, 3] <- quantile(hba1cConcatFrame[, j])[2]
  plotFrame[j, 4] <- quantile(hba1cConcatFrame[, j])[4]
  
  plotFrame[j, 5] <- quantile(bmiConcatFrame[, j])[3]
  plotFrame[j, 6] <- quantile(bmiConcatFrame[, j])[2]
  plotFrame[j, 7] <- quantile(bmiConcatFrame[, j])[4]
  
}

plot(bmiMedian ~ hba1cMedian,data=plotFrame, xlim = c(0, 0.4), ylim = c(0, 0.2))
arrows(x0=plotFrame$hba1cMedian,
       y0=plotFrame$bmi25,
       x1=plotFrame$hba1cMedian,
       y1=plotFrame$bmi75,
       angle=90,
       code=3,length=0.04,
       lwd=0.4)

arrows(x0=plotFrame$hba1c25,
       y0=plotFrame$bmiMedian,
       x1=plotFrame$hba1c75,
       y1=plotFrame$bmiMedian,
       angle=90,
       code=3,
       length=0.04,
       lwd=0.4)
xlabelPlot <- plotFrame$hba1cMedian - 0.01
text(0, y = plotFrame$bmiMedian, labels = plotFrame$labels)

## characteristics by probability
hba1c_decoded <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_hba1c.csv",header=FALSE,row.names=NULL)
sbp_decoded <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_sbp.csv",header=FALSE,row.names=NULL)
bmi_decoded <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/decoded_Xtest_bmi.csv",header=FALSE,row.names=NULL)
age <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/X_test_age.csv",header=FALSE,row.names=NULL)

hba1c_median <- apply(hba1c_decoded, 1, median)
sbp_median <- apply(sbp_decoded, 1, median) 
bmi_median <- apply(bmi_decoded, 1, median) 

prob_char <- function(y_inputFrame) {
  # y_inputFrame = hba1c_MF_SU[,1]
  threshold = quantile(y_inputFrame)[3]
  
  print('hba1c')
  print(quantile(hba1c_median[y_inputFrame >= threshold]))
  print(quantile(hba1c_median[y_inputFrame < threshold]))
  print('sbp')
  print(quantile(sbp_median[y_inputFrame >= threshold]))
  print(quantile(sbp_median[y_inputFrame < threshold]))
  print('bmi')
  print(quantile(bmi_median[y_inputFrame >= threshold]))
  print(quantile(bmi_median[y_inputFrame < threshold]))
  
  
}

prob_char(hba1c_MF_GLP1[,1], quantile(hba1c_MF_GLP1[,1][3]))

prob_char(hba1c_MF_SU[,1], quantile(hba1c_MF_SU[,1][3]))


## best outcome per patient
perPatientOutcome_hba1c <- cbind(hba1c_nil, hba1c_MF, hba1c_MF_SU, hba1c_MF_bdIns, hba1c_MF_SGLT2, hba1c_MF_GLP1, hba1c_MF_GLP1_SGLT2)
colnames(perPatientOutcome_hba1c) <- c("hba1c_nil", "hba1c_MF", "hba1c_MF_SU", "hba1c_MF_bdIns", "hba1c_MF_SGLT2", "hba1c_MF_GLP1", "hba1c_MF_GLP1_SGLT2")
perPatientOutcome_hba1c$maxProb <- apply(perPatientOutcome_hba1c[, 1:7], 1, max)
summary(perPatientOutcome_hba1c)
boxplot(perPatientOutcome_hba1c, las=3)

perPatientOutcome_sbp <- cbind(sbp_nil, sbp_MF, sbp_MF_SU, sbp_MF_bdIns, sbp_MF_SGLT2, sbp_MF_GLP1, sbp_MF_GLP1_SGLT2)
colnames(perPatientOutcome_sbp) <- c("sbp_nil", "sbp_MF", "sbp_MF_SU", "sbp_MF_bdIns", "sbp_MF_SGLT2", "sbp_MF_GLP1", "sbp_MF_GLP1_SGLT2")
perPatientOutcome_sbp$maxProb <- apply(perPatientOutcome_sbp[, 1:7], 1, max)
summary(perPatientOutcome_sbp)
boxplot(perPatientOutcome_sbp, las=3)

## examine response
