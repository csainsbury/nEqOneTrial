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

# mf + su
hba1c_MF_SU <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_SU.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SU)

sbp_MF_SU <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_SU.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_SU)

# mf + human basal ins
hba1c_MF_bIns <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_bIns.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_bIns)

sbp_MF_bIns <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_bIns.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_bIns)

# mf + sglt2
hba1c_MF_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_SGLT2.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SGLT2)

sbp_MF_SGLT2 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_SGLT2.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_SGLT2)

# mf + glp1
hba1c_MF_GLP1 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_hba1c_MF_GLP1.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_GLP1)

sbp_MF_GLP1 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_MF_GLP1.csv",header=FALSE,row.names=NULL)
summary(sbp_MF_GLP1)

library(ggplot2)


# plotting
plot(hba1c_nil[,1], sbp_nil[,1], pch = 16, cex=0.3, col = 'red', xlim = c(0, 1), ylim = c(0, 1))
points(hba1c_MF_SU[, 1], sbp_MF_SU[, 1], pch = 16, cex = 0.3, col = 'black')
points(hba1c_MF_bIns[, 1], sbp_MF_bIns[, 1], pch = 16, cex = 0.3, col = 'green')
points(hba1c_MF_SGLT2[, 1], sbp_MF_SGLT2[, 1], pch = 16, cex = 0.3, col = 'blue')

library(aplpack)
bagplot(hba1c_nil[,1], sbp_nil[,1])
bagplot(hba1c_MF_SU[,1], sbp_MF_SU[,1])
bagplot(hba1c_MF_SGLT2[,1], sbp_MF_SGLT2[,1])
bagplot(hba1c_MF_GLP1[,1], sbp_MF_GLP1[,1])

# a method of plotting x and y error bars
# need to generate plotting frame with x/y and max/min values for error bars from data

plotFrame <- as.data.frame(matrix(nrow = 5, ncol = 7))
colnames(plotFrame) <- c("labels", "hba1cMedian", "hba1c25", "hba1c75", "sbpMedian", "sbp25", "sbp75")
plotFrame$labels <- c("nil", "MF_SU", "MF_bIns", "MF_SGLT2", "MF_GLP1")

hba1cConcatFrame <- cbind(hba1c_nil, hba1c_MF_SU, hba1c_MF_bIns, hba1c_MF_SGLT2, hba1c_MF_GLP1)
sbpConcatFrame <- cbind(sbp_nil, sbp_MF_SU, sbp_MF_bIns, sbp_MF_SGLT2, sbp_MF_GLP1)

for (j in seq(1, nrow(plotFrame), 1)) {
    plotFrame[j, 2] <- quantile(hba1cConcatFrame[, j])[3]
    plotFrame[j, 3] <- quantile(hba1cConcatFrame[, j])[2]
    plotFrame[j, 4] <- quantile(hba1cConcatFrame[, j])[4]
    
    plotFrame[j, 5] <- quantile(sbpConcatFrame[, j])[3]
    plotFrame[j, 6] <- quantile(sbpConcatFrame[, j])[2]
    plotFrame[j, 7] <- quantile(sbpConcatFrame[, j])[4]
  
}

plot(sbpMedian ~ hba1cMedian,data=plotFrame, xlim = c(0, 0.6), ylim = c(0, 0.6))
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

plot(c(5, 10, 20), )




