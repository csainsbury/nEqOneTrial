# source("~/R/_workingDirectory/_perAdmissionRewriteDataTableFunctions.R")
# library(gtools)
# library(igraph)
library(data.table)

id_per_location <- function(ID) {
  return(length(unique(ID)))
}

flagMove <- function(ID, charL) {
  
  charLreport <- charL
  charLnumeric <- as.numeric(factor(charL))
  
  testFrame <- data.frame(charLreport, charLnumeric)
  
  testFrame$flagMove <- 0
  testFrame$flagMove[1:nrow(testFrame)-1] <- diff(testFrame$charLnumeric)
  testFrame$nextL <- c("spacer")
  testFrame$nextL[1:(nrow(testFrame)-1)] <- charLreport[2:length(charLreport)]
  
  testFrame$charLreport <- as.character(factor(charL))
  
  outputList <- list(testFrame$charLreport, testFrame$nextL, testFrame$flagMove)
  
  return(outputList)
  
}

returnUnixDateTime<-function(date) {
  returnVal<-as.numeric(as.POSIXct(date, format="%Y-%m-%d", tz="GMT"))
  return(returnVal)
}

findSimilarDrugs <- function(inputFrame) {
  
  # inputFrame <- interestSet
  # inputFrame <- inputFrame[1:10000,]
  
  inputFrame$DrugName.original <- inputFrame$DrugName
  inputFrame$DrugNameNew <- inputFrame$DrugName
  
  inputFrame <- subset(inputFrame, DrugNameNew != "Disposable")
  
  inputFrame$DrugNameNew[grep("Glucose", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose"
  inputFrame$DrugNameNew[grep("Glucogel", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose"
  
  inputFrame$DrugNameNew[grep("Glucagen Hypokit", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucagon"
  inputFrame$DrugNameNew[grep("Optium Plus", inputFrame$DrugName, ignore.case = TRUE)] <- "Test Strips"
  
  
  inputFrame$DrugNameNew[grep("Metformin", inputFrame$DrugName, ignore.case = TRUE)] <- "Metformin"
  inputFrame$DrugNameNew[grep("Glucophage", inputFrame$DrugName, ignore.case = TRUE)] <- "Metformin"
  
  inputFrame$DrugNameNew[grep("Gliclazide", inputFrame$DrugName, ignore.case = TRUE)] <- "Gliclazide"
  inputFrame$DrugNameNew[grep("Diamicron", inputFrame$DrugName, ignore.case = TRUE)] <- "Gliclazide"
  
  inputFrame$DrugNameNew[grep("Rosiglitazone", inputFrame$DrugName, ignore.case = TRUE)] <- "Rosiglitazone"
  inputFrame$DrugNameNew[grep("Avandia", inputFrame$DrugName, ignore.case = TRUE)] <- "Rosiglitazone"
  
  inputFrame$DrugNameNew[grep("Linagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "Linagliptin"
  
  inputFrame$DrugNameNew[grep("Victoza", inputFrame$DrugName, ignore.case = TRUE)] <- "Liraglutide"
  inputFrame$DrugNameNew[grep("Liraglutide", inputFrame$DrugName, ignore.case = TRUE)] <- "Liraglutide"
  
  inputFrame$DrugNameNew[grep("Pioglitazone", inputFrame$DrugName, ignore.case = TRUE)] <- "Pioglitazone"
  
  inputFrame$DrugNameNew[grep("Sitagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "Sitagliptin"
  inputFrame$DrugNameNew[grep("Januvia", inputFrame$DrugName, ignore.case = TRUE)] <- "Sitagliptin"
  
  inputFrame$DrugNameNew[grep("Dapagliflozin", inputFrame$DrugName, ignore.case = TRUE)] <- "Dapagliflozin"
  
  inputFrame$DrugNameNew[grep("Humalog Mix25", inputFrame$DrugName, ignore.case = TRUE)] <- "Humalog Mix 25"
  
  inputFrame$DrugNameNew[grep("Lantus", inputFrame$DrugName, ignore.case = TRUE)] <- "Insulin Glargine"
  inputFrame$DrugNameNew[grep("Levemir", inputFrame$DrugName, ignore.case = TRUE)] <- "Insulin Detemir"
  
  inputFrame$DrugNameNew[grep("Insulatard", inputFrame$DrugName, ignore.case = TRUE)] <- "Insulatard"
  
  inputFrame$DrugNameNew[grep("Actrapid", inputFrame$DrugName, ignore.case = TRUE)] <- "Actrapid"
  inputFrame$DrugNameNew[grep("Humalog 100units/ml solution", inputFrame$DrugName, ignore.case = TRUE)] <- "Humalog"
  
  inputFrame$DrugNameNew[grep("Novorapid", inputFrame$DrugName, ignore.case = TRUE)] <- "Novorapid"
  
  inputFrame$DrugNameNew[grep("Novomix 30", inputFrame$DrugName, ignore.case = TRUE)] <- "Novomix 30"
  
  inputFrame$DrugNameNew[grep("Mixtard 30", inputFrame$DrugName, ignore.case = TRUE)] <- "Mixtard 30"
  inputFrame$DrugNameNew[grep("Mixtard 20", inputFrame$DrugName, ignore.case = TRUE)] <- "Mixtard 20"
  
  inputFrame$DrugNameNew[grep("Humulin M3", inputFrame$DrugName, ignore.case = TRUE)] <- "Humulin M3"
  
  inputFrame$DrugNameNew[grep("Humalog Mix50", inputFrame$DrugName, ignore.case = TRUE)] <- "Humalog Mix50"
  
  inputFrame$DrugNameNew[grep("strip", inputFrame$DrugName, ignore.case = TRUE)] <- "Test Strips"
  
  inputFrame$DrugNameNew[grep("Bd-Microfine", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle"
  inputFrame$DrugNameNew[grep("Needle", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle"
  
  
  outputFrame <- inputFrame
  
  outputFrame$DrugName.original <- NULL
  outputFrame$DrugName <- outputFrame$DrugNameNew
  outputFrame$DrugNameNew <- NULL
  
  return(outputFrame)
}

simplifyDrugs <- function(inputFrame) {
  
  # inputFrame <- interestSet
  # inputFrame <- inputFrame[1:100000,]
  
  inputFrame$DrugName.original <- inputFrame$DrugName
  inputFrame$DrugNameNew <- inputFrame$DrugName
  
  inputFrame <- subset(inputFrame, DrugNameNew != "Disposable")
  
  inputFrame$DrugNameNew[grep("Glucose", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose_"
  inputFrame$DrugNameNew[grep("Glucogel", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose_"
  inputFrame$DrugNameNew[grep("Dextrogel", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose_"
  inputFrame$DrugNameNew[grep("DEXTROSE", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucose_"
  
  
  inputFrame$DrugNameNew[grep("Glucagen Hypokit", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucagon_"
  inputFrame$DrugNameNew[grep("Glucagon", inputFrame$DrugName, ignore.case = TRUE)] <- "Glucagon_"
  
  inputFrame$DrugNameNew[grep("Optium Plus", inputFrame$DrugName, ignore.case = TRUE)] <- "Test Strips"
  
  inputFrame$DrugNameNew[grep("Acarbose", inputFrame$DrugName, ignore.case = TRUE)] <- "Acarbose_"
  inputFrame$DrugNameNew[grep("Glucobay", inputFrame$DrugName, ignore.case = TRUE)] <- "Acarbose_"
  
  inputFrame$DrugNameNew[grep("REPAGLINIDE", inputFrame$DrugName, ignore.case = TRUE)] <- "meglitinide_"
  inputFrame$DrugNameNew[grep("Repaglinide", inputFrame$DrugName, ignore.case = TRUE)] <- "meglitinide_"
  inputFrame$DrugNameNew[grep("Nateglinide", inputFrame$DrugName, ignore.case = TRUE)] <- "meglitinide_"
  
  inputFrame$DrugNameNew[grep("Metformin", inputFrame$DrugName, ignore.case = TRUE)] <- "Metformin_"
  inputFrame$DrugNameNew[grep("Glucophage", inputFrame$DrugName, ignore.case = TRUE)] <- "Metformin_"
  
  inputFrame$DrugNameNew[grep("Gliclazide", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"
  inputFrame$DrugNameNew[grep("Glipizide", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"
  inputFrame$DrugNameNew[grep("Glibenese", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"
  inputFrame$DrugNameNew[grep("Amaryl", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"
  inputFrame$DrugNameNew[grep("Glimepiride", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"
  inputFrame$DrugNameNew[grep("GLIMEPIRIDE", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"
  inputFrame$DrugNameNew[grep("Glibenclamide", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"
  inputFrame$DrugNameNew[grep("Daonil", inputFrame$DrugName, ignore.case = TRUE)] <- "SU_"

  inputFrame$DrugNameNew[grep("Rosiglitazone", inputFrame$DrugName, ignore.case = TRUE)] <- "TZD_"
  inputFrame$DrugNameNew[grep("Pioglitazone", inputFrame$DrugName, ignore.case = TRUE)] <- "TZD_"
  inputFrame$DrugNameNew[grep("Actos", inputFrame$DrugName, ignore.case = TRUE)] <- "TZD_"
  
  inputFrame$DrugNameNew[grep("Linagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4_"
  inputFrame$DrugNameNew[grep("Sitagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4_"
  inputFrame$DrugNameNew[grep("Vildagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4_"
  inputFrame$DrugNameNew[grep("Galvus", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4_"
  inputFrame$DrugNameNew[grep("Saxagliptin", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4_"
  inputFrame$DrugNameNew[grep("SAXAGLIPTIN", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4_"
  inputFrame$DrugNameNew[grep("Dulaglutide", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4_"
  
  
  inputFrame$DrugNameNew[grep("Liraglutide", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  inputFrame$DrugNameNew[grep("Exenatide", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  inputFrame$DrugNameNew[grep("Byetta", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  inputFrame$DrugNameNew[grep("BYETTA", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  inputFrame$DrugNameNew[grep("Bydureon", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  inputFrame$DrugNameNew[grep("Lixisenatide", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  inputFrame$DrugNameNew[grep("Lyxumia", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  inputFrame$DrugNameNew[grep("Dulaglutide", inputFrame$DrugName, ignore.case = TRUE)] <- "GLP1_"
  
  
  inputFrame$DrugNameNew[grep("Dapagliflozin", inputFrame$DrugName, ignore.case = TRUE)] <- "SGLT2_"
  inputFrame$DrugNameNew[grep("Canagliflozin", inputFrame$DrugName, ignore.case = TRUE)] <- "SGLT2_"
  inputFrame$DrugNameNew[grep("Empagliflozin", inputFrame$DrugName, ignore.case = TRUE)] <- "SGLT2_"
  
  # combinations
  inputFrame$DrugNameNew[grep("Avandamet", inputFrame$DrugName, ignore.case = TRUE)] <- "MetforminTZD_"
  inputFrame$DrugNameNew[grep("Competact", inputFrame$DrugName, ignore.case = TRUE)] <- "MetforminTZD_"
  inputFrame$DrugNameNew[grep("Eucreas", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4Metformin_"
  inputFrame$DrugNameNew[grep("EUCREAS", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4Metformin_"
  inputFrame$DrugNameNew[grep("Janumet", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4Metformin_"
  inputFrame$DrugNameNew[grep("JANUMET", inputFrame$DrugName, ignore.case = TRUE)] <- "DPP4Metformin_"
  
  
  # SSRI
  inputFrame$DrugNameNew[grep("Duloxetine", inputFrame$DrugName, ignore.case = TRUE)] <- "SSRI_"
  inputFrame$DrugNameNew[grep("DULOXETINE", inputFrame$DrugName, ignore.case = TRUE)] <- "SSRI_"
  
  
  # bd mix insulins
  inputFrame$DrugNameNew[grep("Humalog Mix", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBDmixInsulin_"
  inputFrame$DrugNameNew[grep("Novomix", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBDmixInsulin_"
  inputFrame$DrugNameNew[grep("Mixtard", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBDmixInsulin_"
  inputFrame$DrugNameNew[grep("Humulin M4", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBDmixInsulin_"
  
  inputFrame$DrugNameNew[grep("Humulin M3", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBDmixInsulin_"
  inputFrame$DrugNameNew[grep("Humulin M2", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBDmixInsulin_"
  inputFrame$DrugNameNew[grep("Humulin M1", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBDmixInsulin_"
  
  inputFrame$DrugNameNew[grep("HUMULIN M2", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBDmixInsulin_"
  inputFrame$DrugNameNew[grep("HUMULIN M1", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBDmixInsulin_"
  
  inputFrame$DrugNameNew[grep("Humalog Mix", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBDmixInsulin_"
  
  # basal insulins
  inputFrame$DrugNameNew[grep("Insulin Glargine", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBasalInsulin_"
  inputFrame$DrugNameNew[grep("degludec", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBasalInsulin_"
  inputFrame$DrugNameNew[grep("Degludec", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBasalInsulin_"
  inputFrame$DrugNameNew[grep("Tresiba", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBasalInsulin_"
  inputFrame$DrugNameNew[grep("Insulin Detemir", inputFrame$DrugName, ignore.case = TRUE)] <- "analogueBasalInsulin_"
  inputFrame$DrugNameNew[grep("Insulatard", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBasalInsulin_"
  inputFrame$DrugNameNew[grep("ULTRATARD", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBasalInsulin_"  
  inputFrame$DrugNameNew[grep("MONOTARD", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBasalInsulin_"
  inputFrame$DrugNameNew[grep("Humulin I", inputFrame$DrugName, ignore.case = TRUE)] <- "humanBasalInsulin_"
  
  # prandial insulins
  inputFrame$DrugNameNew[grep("Actrapid", inputFrame$DrugName, ignore.case = TRUE)] <- "humanPrandialInsulin_"
  inputFrame$DrugNameNew[grep("Humalog", inputFrame$DrugName, ignore.case = TRUE)] <- "analoguePrandialInsulin_"
  inputFrame$DrugNameNew[grep("Insulin Lispro", inputFrame$DrugName, ignore.case = TRUE)] <- "analoguePrandialInsulin_"
  
  inputFrame$DrugNameNew[grep("Novorapid", inputFrame$DrugName, ignore.case = TRUE)] <- "analoguePrandialInsulin_"
  inputFrame$DrugNameNew[grep("Apidra", inputFrame$DrugName, ignore.case = TRUE)] <- "analoguePrandialInsulin_"
  inputFrame$DrugNameNew[grep("Humulin S", inputFrame$DrugName, ignore.case = TRUE)] <- "humanPrandialInsulin_"
  
  # animal insulins
  inputFrame$DrugNameNew[grep("Bovine", inputFrame$DrugName, ignore.case = TRUE)] <- "bovineInsulin_"
  inputFrame$DrugNameNew[grep("BOVINE", inputFrame$DrugName, ignore.case = TRUE)] <- "bovineInsulin_"
  inputFrame$DrugNameNew[grep("Porcine", inputFrame$DrugName, ignore.case = TRUE)] <- "porcineInsulin_"
  
  
  inputFrame$DrugNameNew[grep("lancet", inputFrame$DrugName, ignore.case = TRUE)] <- "lancet_"
  inputFrame$DrugNameNew[grep("Lancet", inputFrame$DrugName, ignore.case = TRUE)] <- "lancet_"
  inputFrame$DrugNameNew[grep("LANCET", inputFrame$DrugName, ignore.case = TRUE)] <- "lancet_"
  inputFrame$DrugNameNew[grep("Accu", inputFrame$DrugName, ignore.case = TRUE)] <- "lancet_"
  inputFrame$DrugNameNew[grep("ACCU", inputFrame$DrugName, ignore.case = TRUE)] <- "lancet_"
  inputFrame$DrugNameNew[grep("accu", inputFrame$DrugName, ignore.case = TRUE)] <- "lancet_"
  
  
  inputFrame$DrugNameNew[grep("pen", inputFrame$DrugName, ignore.case = TRUE)] <- "pen_"
  inputFrame$DrugNameNew[grep("Insulin Syringe", inputFrame$DrugName, ignore.case = TRUE)] <- "pen_"
  
    
  inputFrame$DrugNameNew[grep("strip", inputFrame$DrugName, ignore.case = TRUE)] <- "TestStrips_"
  
  inputFrame$DrugNameNew[grep("Bd-Microfine", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle_"
  inputFrame$DrugNameNew[grep("BD Micro-Fine", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle_"
  inputFrame$DrugNameNew[grep("Needle", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle_"
  inputFrame$DrugNameNew[grep("need", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle_"
  inputFrame$DrugNameNew[grep("ndle", inputFrame$DrugName, ignore.case = TRUE)] <- "Needle_"
  
  
  inputFrame$DrugNameNew[grep("Bd Safe-Clip", inputFrame$DrugName, ignore.case = TRUE)] <- "ClippingDevice_"
  
  
  x <- as.data.frame(table(inputFrame$DrugNameNew))
  x = x[order(x$Freq), ]
  
  outputFrame <- inputFrame
  
  outputFrame$DrugName.original <- NULL
  outputFrame$DrugName <- outputFrame$DrugNameNew
  outputFrame$DrugNameNew <- NULL
  
  return(outputFrame)
}


# generate node and link files
drugDataSet <- read.csv("~/R/GlCoSy/SDsource/Export_all_diabetes_drugs.txt",header=TRUE,row.names=NULL)

# load and process mortality data
deathData <- read.csv("~/R/GlCoSy/SDsource/diagnosisDateDeathDate.txt", sep=",")
deathData$unix_deathDate <- returnUnixDateTime(deathData$DeathDate)
deathData$unix_deathDate[is.na(deathData$unix_deathDate)] <- 0
deathData$isDead <- ifelse(deathData$unix_deathDate > 0, 1, 0)
deathData$unix_diagnosisDate <- returnUnixDateTime(deathData$DateOfDiagnosisDiabetes_Date)

# drugDataSet <- read.csv("~/R/GlCoSy/SDsource/test_drug_out_second100kIDs_allTime.txt",header=TRUE,row.names=NULL)
drugDataSet$BNFCode <- as.character(drugDataSet$BNFCode)
drugDataSet$DrugName <- as.character(drugDataSet$DrugName)
drugDataSet$LinkId <- as.numeric(levels(drugDataSet$LinkId))[drugDataSet$LinkId]
# drugDataSet$LinkId <- as.numeric(drugDataSet$LinkId)
# drugDataSet <- read.csv("./test_drug_out_second100kIDs_allTime.txt",header=TRUE,row.names=NULL)

# restrict to diabetes drugs
interestSet <- subset(drugDataSet, substr(drugDataSet$BNFCode,1,3) == "6.1" | substr(drugDataSet$BNFCode,1,4) == "0601")
interestSet <- findSimilarDrugs(interestSet)
interestSet <- simplifyDrugs(interestSet)

interestSetDT <- data.table(interestSet)
interestSetDT$prescription_dateplustime1 <- returnUnixDateTime(interestSetDT$PrescriptionDateTime)

# remove nonsense dates
interestSetDT = interestSetDT[prescription_dateplustime1 < 1574121600]
interestSetDT = interestSetDT[prescription_dateplustime1 > (0)]

# set runin period of interest
startRuninPeriod <- '2010-01-01'
endRuninPeriod   <- '2015-01-01'
interestSetDT <- interestSetDT[prescription_dateplustime1 > returnUnixDateTime(startRuninPeriod) &
                                 prescription_dateplustime1 < returnUnixDateTime(endRuninPeriod)]

interestSetDF <- data.frame(interestSetDT)

# generate a top-100 etc list for merging back
# meeds a bit of data cleaning - merging synonymous drugs etc
n = 25
topNdrugs_DrugNames <- as.data.frame(table(interestSetDF$DrugName))
topNdrugs_DrugNames <- topNdrugs_DrugNames[order(topNdrugs_DrugNames$Freq), ]

topNdrugs <- tail(topNdrugs_DrugNames, n)

topNdrugs$Var1 <- gsub(" ", "", topNdrugs$Var1, fixed = TRUE)
topNdrugs$Var1 <- gsub("/", "", topNdrugs$Var1, fixed = TRUE)
topNdrugs$Var1 <- gsub("-", "", topNdrugs$Var1, fixed = TRUE)

# plot zipf's law
# topNdrugs$rank = c(nrow(topNdrugs):1)
# plot(log(topNdrugs$rank), log(topNdrugs$Freq))

# merge top drugs back with interestSet to generate working data frame:
interestSet_topN_merge <- merge(interestSetDF, topNdrugs, by.x="DrugName", by.y="Var1")

###############################
## start drug data manipulation
###############################

drugsetDT <- data.table(interestSet_topN_merge)
drugsetDT$prescription_dateplustime1 <- returnUnixDateTime(drugsetDT$PrescriptionDateTime)
drugsetDT_original <-drugsetDT # preserve an original full dataset incase needed
# drugsetDT$LinkId <- as.numeric(levels(drugsetDT$LinkId))[drugsetDT$LinkId]

# scale time to 0 to 1 range
drugsetDT$prescription_dateplustime1.original <- drugsetDT$prescription_dateplustime1
drugsetDT$prescription_dateplustime1 <- (drugsetDT$prescription_dateplustime1 - min(drugsetDT$prescription_dateplustime1)) / (max(drugsetDT$prescription_dateplustime1) - min(drugsetDT$prescription_dateplustime1))
    # drugsetDT$LinkId<-as.numeric(levels(drugsetDT$LinkId))[drugsetDT$LinkId]
    # drugsetDT$LinkId[is.na(drugsetDT$LinkId)] <- 0
    # drugsetDT <-  drugsetDT[LinkId > 0]

# read out and in for testing
# write.table(drugsetDT, file = "~/R/GlCoSy/MLsource/drugsetDT_2005to15.csv", sep=",")
# drugsetDT <- read.csv("~/R/GlCoSy/MLsource/drugsetDT.csv", stringsAsFactors = F, row.names = NULL); drugsetDT$row.names <- NULL; drugsetDT$diffLinkId <- NULL; drugsetDT <- data.table(drugsetDT)

drugsetDT <- transform(drugsetDT,id=as.numeric(factor(LinkId)))

# drugsetDT <- drugsetDT[prescription_dateplustime1.original > returnUnixDateTime('2005-01-01') & prescription_dateplustime1.original < returnUnixDateTime('2015-01-01')]


    # set time bins
    sequence <- seq(0, 1 , (1/30)) # for 5 year f/u gives 2 month bins - matches hba1c etc
    
    # generate bag of drugs frame
    drugWordFrame <- as.data.frame(matrix(nrow = length(unique(drugsetDT$LinkId)), ncol = (length(sequence)-1) ))
    colnames(drugWordFrame) <- c(1:(length(sequence)-1))
    drugWordFrame$LinkId <- 0
    
    # function to generate drugwords for each time interval
    returnIntervals <- function(LinkId, DrugName, prescription_dateplustime1, sequence, id) {
      
      # DrugName <- subset(drugsetDT, id == 2)$DrugName; prescription_dateplustime1 <- subset(drugsetDT, id == 2)$prescription_dateplustime1; id = 2; LinkId <- subset(drugsetDT, id == 2)$LinkId
      
          inputSet <- data.table(DrugName, prescription_dateplustime1)
      
          ## add nil values to fill time slots without any drugs
          nilFrame <- as.data.frame(matrix(nrow = length(sequence), ncol = ncol(inputSet)))
          colnames(nilFrame) <- colnames(inputSet)
          
          nilFrame$DrugName <- 'nil'
          nilFrame$prescription_dateplustime1 <- sequence
          
          outputSet <- rbind(nilFrame, inputSet)
          
      ## generate drug words
          
      interimSet <- outputSet
      
      interimSet <- interimSet[, interv := cut(prescription_dateplustime1, sequence)][, .(drugs = (unique(DrugName))), by = interv]
      interimSet[, drugWord := paste(drugs, collapse = ''), by = interv]
      
      interimSet <- interimSet[order(interimSet$interv), ]
      interimSet[, drugSequenceNumber := seq(1, .N, 1), by = interv]
      
      reportSet <- interimSet[drugSequenceNumber == 1]
      reportSet$drugWord <- ifelse(substr(reportSet$drugWord,1,3) == 'nil' & nchar(reportSet$drugWord) == 3, reportSet$drugWord, substr(reportSet$drugWord,4,nchar(reportSet$drugWord)))
      
      reportSet <- reportSet[1:nrow(reportSet)-1, ]
      reportSet$intervalNumber <- c(1:nrow(reportSet))
      
#      print(reportSet$drugWord)
      
      return(c(reportSet$drugWord, LinkId[1]))
      

    }
    
    for (j in seq(1, max(drugsetDT$id), )) {
      
      if(j%%100 == 0) {print(j)}
      
      injectionSet <- drugsetDT[id == j]
      drugWordFrame[j, ] <- returnIntervals(injectionSet$LinkId, injectionSet$DrugName, injectionSet$prescription_dateplustime1, sequence, j)
    }
    
    # write.table(drugWordFrame, file = "~/R/GlCoSy/MLsource/drugWordFrame_withID_2005_2015.csv", sep=",")
    # drugWordFrame <- read.csv("~/R/GlCoSy/MLsource/drugWordFrame.csv", stringsAsFactors = F, row.names = NULL); drugWordFrame$row.names <- NULL
    
      # here do analysis to select rows (IDs) for later analysis
      
      # mortality outcome at 2017-01-01
      drugWordFrame_mortality <- merge(drugWordFrame, deathData, by.x = "LinkId", by.y= "LinkId")
      # remove those dead before end of FU
      # analysis frame = those who are not dead, or those who have died after the end of the runin period. ie all individuals in analysis alive at the end of the runin period
      drugWordFrame_mortality <- subset(drugWordFrame_mortality, isDead == 0 | (isDead == 1 & unix_deathDate > returnUnixDateTime(endRuninPeriod)) )
      # remove those diagnosed after the end of the runin period
      drugWordFrame_mortality <- subset(drugWordFrame_mortality, unix_diagnosisDate <= returnUnixDateTime(endRuninPeriod) )
    
    # set up drug sentences for analysis
      
      drugWordFrame_forAnalysis <- drugWordFrame_mortality
      
      drugWordFrame_drugNames <- drugWordFrame_forAnalysis[, 2:(1+(length(sequence)-1)) ]
      
    drugSentenceFrame <- as.data.frame(matrix(nrow = nrow(drugWordFrame_forAnalysis), ncol = 1))
    colnames(drugSentenceFrame) <- c("drugSentence")
    
    vectorWords <- as.vector(as.matrix(drugWordFrame_drugNames))
    vectorNumbers <- as.numeric(as.factor(vectorWords))
    lookup <- data.frame(vectorWords, vectorNumbers)
    lookup <- unique(lookup)
    lookup <- data.table(lookup)
    
    # write out lookup table
    write.table(lookup, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/lookupTable_", startRuninPeriod, "_to_", endRuninPeriod, "_simplifiedDrugs.csv", sep=""), sep=",", row.names = FALSE)
    

    # vectorised lookup table use
    numericalDrugsFrame <- as.data.frame(matrix(0, nrow = nrow(drugWordFrame_drugNames), ncol = ncol(drugWordFrame_drugNames)))
    
    for (jj in seq(1, ncol(drugWordFrame_drugNames), 1)) {
      
      index <- match(drugWordFrame_drugNames[,jj], lookup$vectorWords)
      numericalDrugsFrame[,jj] <- lookup$vectorNumbers[index]
      
    }
    
    y_vector <- drugWordFrame_forAnalysis$isDead
    

    # write out sequence for analysis
    write.table(numericalDrugsFrame, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_30bins_", startRuninPeriod, "_to_", endRuninPeriod, "_simplifiedDrugs.csv", sep=""), sep=",", row.names = FALSE)
    # write out sequence for analysis
    write.table(drugWordFrame_mortality, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/drugWordFrame_mortality_30bins_", startRuninPeriod, "_to_", endRuninPeriod, "_simplifiedDrugs.csv", sep=""), sep=",", row.names = FALSE)
    
    numericalDrugsFrame_withID <- data.frame(numericalDrugsFrame, drugWordFrame_forAnalysis$LinkId)
    # write out sequence for analysis
    write.table(numericalDrugsFrame_withID, file = paste("~/R/_workingDirectory/nEqOneTrial/sourceData/numericalDrugsFrame_withID_30bins_", startRuninPeriod, "_to_", endRuninPeriod, "_simplifiedDrugs.csv", sep=""), sep=",", row.names = FALSE)
    
    
    
    
    
    # # write out dep variable (y)
    # write.table(y_vector, file = "./3y_mortality_y_for_numericalDrugsFrame_15y_6mBins_chained_y.csv", sep = ",", row.names = FALSE)
    
    
    
    # featureFrame_deathMerge <- merge(featureFrame, deathData, by.x= "LinkId", by.y = "LinkId", all.x = TRUE)
    # death_outcome <- featureFrame_deathMerge$deadPostEndOfDrugData
    # death_outcome[is.na(death_outcome)] <- 0
    # 
    # write.table(death_outcome, file = "~/R/GlCoSy/MLsource/deathOutcome_for_numericalDrugsFrame_20.csv", sep = ",")
    # 
    # # write.table(numericalDrugsFrame, file = "~/R/GlCoSy/MLsource/numericalDrugsFrame_20.csv", sep=",", row.names = FALSE)
    # # numericalDrugsFrame <- read.csv("~/R/GlCoSy/MLsource/numericalDrugsFrame_20.csv", stringsAsFactors = F, row.names = FALSE); numericalDrugsFrame$row.names <- NULL
    # 
    # # runif(10, 0, 1)
    # # random y_train and y_test
    # random_y <- runif(nrow(numericalDrugsFrame), 0, 1)
    # random_y <- ifelse(random_y < 0.5, 0, 1)
    # 
    # write.table(random_y, file = "~/R/GlCoSy/MLsource/random_y.csv", sep = ",")
    # 
    # # generate(test_train)
    # X_train <- numericalDrugsFrame[1:1000, ]
    # y_train <- random_y[1:1000]
    # 
    # X_test <- numericalDrugsFrame[1001:2001, ]
    # y_test <- random_y[1001:2001]
    # 
    
    
## need to convert words to numbers - use text proc library, and feed into rnn


