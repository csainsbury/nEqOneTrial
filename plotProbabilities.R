# import y_pred_asNumber - original
hba1c_original <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_original.csv",header=FALSE,row.names=NULL)
summary(hba1c_original)

sbp_original <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/y_pred_asNumber_sbp_original.csv",header=FALSE,row.names=NULL)
summary(sbp_original)

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
plot(hba1c_nil[,1], sbp_nil[,1], pch = 16, cex=0.1, col = 'red', xlim = c(0, 1), ylim = c(0, 1))
points(hba1c_MF_SU[, 1], sbp_MF_SU[, 1], pch = 16, cex = 0.1, col = 'black')
points(hba1c_MF_bIns[, 1], sbp_MF_bIns[, 1], pch = 16, cex = 0.1, col = 'green')
points(hba1c_MF_SGLT2[, 1], sbp_MF_SGLT2[, 1], pch = 16, cex = 0.1, col = 'blue')

library(aplpack)
attach(mtcars)
bagplot(hba1c_nil[,1], sbp_nil[,1])
bagplot(hba1c_MF_SU[,1], sbp_MF_SU[,1])
bagplot(hba1c_MF_SGLT2[,1], sbp_MF_SGLT2[,1])
bagplot(hba1c_MF_GLP1[,1], sbp_MF_GLP1[,1])





