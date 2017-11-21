# check zipf law

numericalData <- drugCombinationData_numerical[, 1:30]

library(reshape2)
data_col = melt(numericalData)

tableOfCombinations <- as.data.frame(table(data_col$value))
tableOfCombinations <- tableOfCombinations[order(tableOfCombinations$Freq), ]

tableOfCombinations$rank <- c(nrow(tableOfCombinations) : 1)

plot(log(tableOfCombinations$rank), log(tableOfCombinations$Freq))

