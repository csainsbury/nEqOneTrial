
# mf + su
hba1c_MF_SU_5 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus5/y_pred_asNumber_hba1c_MF_SU.csv",header=FALSE,row.names=NULL)
hba1c_MF_SU_10 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus10/y_pred_asNumber_hba1c_MF_SU.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SU_10)
hba1c_MF_SU_20 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus20/y_pred_asNumber_hba1c_MF_SU.csv",header=FALSE,row.names=NULL)
summary(hba1c_MF_SU_20)

# mf + sglt2
hba1c_MF_SGLT2_5 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus5/y_pred_asNumber_hba1c_MF_SGLT2.csv",header=FALSE,row.names=NULL)
hba1c_MF_SGLT2_10 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus10/y_pred_asNumber_hba1c_MF_SGLT2.csv",header=FALSE,row.names=NULL)
hba1c_MF_SGLT2_20 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus20/y_pred_asNumber_hba1c_MF_SGLT2.csv",header=FALSE,row.names=NULL)

# mf + sglt2
hba1c_MF_GLP1_5 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus5/y_pred_asNumber_hba1c_MF_GLP1.csv",header=FALSE,row.names=NULL)
hba1c_MF_GLP1_10 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus10/y_pred_asNumber_hba1c_MF_GLP1.csv",header=FALSE,row.names=NULL)
hba1c_MF_GLP1_20 <- read.csv("~/R/_workingDirectory/nEqOneTrial/currentPaperspaceVersion/pythonOutput/hba1c_minus20/y_pred_asNumber_hba1c_MF_GLP1.csv",header=FALSE,row.names=NULL)



hba1c_MF_SU_5 = log(hba1c_MF_SU_5)
hba1c_MF_SU_10 = log(hba1c_MF_SU_10)
hba1c_MF_SU_20 = log(hba1c_MF_SU_20)

hba1c_MF_SGLT2_5 = log(hba1c_MF_SGLT2_5)
hba1c_MF_SGLT2_10 = log(hba1c_MF_SGLT2_10)
hba1c_MF_SGLT2_20 = log(hba1c_MF_SGLT2_20)

hba1c_MF_GLP1_5 = log(hba1c_MF_GLP1_5)
hba1c_MF_GLP1_10 = log(hba1c_MF_GLP1_10)
hba1c_MF_GLP1_20 = log(hba1c_MF_GLP1_20)


plot(c(5, 10, 20), c(quantile(hba1c_MF_SU_5[,1], na.rm = T)[3], quantile(hba1c_MF_SU_10[,1], na.rm = T)[3], quantile(hba1c_MF_SU_20[,1], na.rm = T)[3]), ylim = c(-5, 0))
  lines(c(5, 10, 20), c(quantile(hba1c_MF_SU_5[,1], na.rm = T)[3], quantile(hba1c_MF_SU_10[,1], na.rm = T)[3], quantile(hba1c_MF_SU_20[,1], na.rm = T)[3]))
    lines(c(5, 10, 20), c(quantile(hba1c_MF_SU_5[,1], na.rm = T)[2], quantile(hba1c_MF_SU_10[,1], na.rm = T)[2], quantile(hba1c_MF_SU_20[,1], na.rm = T)[2]), lty = 3)
    lines(c(5, 10, 20), c(quantile(hba1c_MF_SU_5[,1], na.rm = T)[4], quantile(hba1c_MF_SU_10[,1], na.rm = T)[4], quantile(hba1c_MF_SU_20[,1], na.rm = T)[4]), lty = 3)
    
points(c(5, 10, 20), c(quantile(hba1c_MF_SGLT2_5[,1], na.rm = T)[3], quantile(hba1c_MF_SGLT2_10[,1], na.rm = T)[3], quantile(hba1c_MF_SGLT2_20[,1], na.rm = T)[3]), col = 'red')
  lines(c(5, 10, 20), c(quantile(hba1c_MF_SGLT2_5[,1], na.rm = T)[3], quantile(hba1c_MF_SGLT2_10[,1], na.rm = T)[3], quantile(hba1c_MF_SGLT2_20[,1], na.rm = T)[3]), col = 'red')
    lines(c(5, 10, 20), c(quantile(hba1c_MF_SGLT2_5[,1], na.rm = T)[2], quantile(hba1c_MF_SGLT2_10[,1], na.rm = T)[2], quantile(hba1c_MF_SGLT2_20[,1], na.rm = T)[2]), col = 'red', lty = 3)
    lines(c(5, 10, 20), c(quantile(hba1c_MF_SGLT2_5[,1], na.rm = T)[4], quantile(hba1c_MF_SGLT2_10[,1], na.rm = T)[4], quantile(hba1c_MF_SGLT2_20[,1], na.rm = T)[4]), col = 'red', lty = 3)
    
  
  points(c(5, 10, 20), c(quantile(hba1c_MF_GLP1_5[,1], na.rm = T)[3], quantile(hba1c_MF_GLP1_10[,1], na.rm = T)[3], quantile(hba1c_MF_GLP1_20[,1], na.rm = T)[3]), col = 'blue')
  lines(c(5, 10, 20), c(quantile(hba1c_MF_GLP1_5[,1], na.rm = T)[3], quantile(hba1c_MF_GLP1_10[,1], na.rm = T)[3], quantile(hba1c_MF_GLP1_20[,1], na.rm = T)[3]), col = 'blue')
    lines(c(5, 10, 20), c(quantile(hba1c_MF_GLP1_5[,1], na.rm = T)[2], quantile(hba1c_MF_GLP1_10[,1], na.rm = T)[2], quantile(hba1c_MF_GLP1_20[,1], na.rm = T)[2]), col = 'blue', lty = 3)
    lines(c(5, 10, 20), c(quantile(hba1c_MF_GLP1_5[,1], na.rm = T)[4], quantile(hba1c_MF_GLP1_10[,1], na.rm = T)[4], quantile(hba1c_MF_GLP1_20[,1], na.rm = T)[4]), col = 'blue', lty = 3)
    
  
  
