
## Simulates a ALL IN / ALL OUT / ONE AT A TIME position sizing strategy with
## only LONG positions allowed.
##
## Appends 3 columns to priceSignalsAction dataframe: Share, Cash_Balance, and
##                                                    Account_Value.
## Basic position sizing strategy:
##   i. Assumes signals are generated such that entry is into only one LONG
##      position at a time.
##  ii. On entry, buy as many shares as account balance allows.
## iii. On exit, sell all shares purchased on entry.
##
## priceSignalsAction must contain the following 2 columns/fields:
## 1) column with name specified in calcCol
## 2) Action
allInAllOutOaatOnlyLong <- function(priceSignalsAction,
                                    startAmt, calcCol="Close") {
    prices <- priceSignalsAction[, as.character(calcCol)]
    sampleCount <- length(priceSignalsAction$Action)
    shares <- vector(mode="integer", length=sampleCount)
    balance <- vector(mode="numeric", length=sampleCount)
    balance[1] <- startAmt
    value <- vector(mode="numeric", length=sampleCount)
    value[1] <- startAmt
    for(i in 2:sampleCount) {
        if(priceSignalsAction$Action[i] == "HOLD") {
            shares[i] <- shares[i-1]
            balance[i] <- balance[i-1]
            val <- balance[i-1] + (shares[i] * prices[i])
            value[i] <- floor(val * 100) / 100
        }
        else if(priceSignalsAction$Action[i] == "BUY") {
            shares[i] <- as.integer(balance[i-1]/prices[i])
            bal <- balance[i-1] - (shares[i] * prices[i])
            balance[i] <- floor(bal * 100) / 100
            val <- balance[i] + (shares[i] * prices[i])
            value[i] <- floor(val * 100) / 100
        }
        else if(priceSignalsAction$Action[i] == "SELL") {
            # sell all shares
            sold <- shares[i-1]
            shares[i] <- 0
            bal <- balance[i-1] + (sold * prices[i]) # all cash
            balance[i] <- floor(bal * 100) / 100
            value[i] <- balance[i]
        }
        else {  # should be unreachable
            shares[i] <- NaN
            balance[i] <- NaN
            value[i] <- Nan
        }
    }
    priceSignalsAction[, "Shares"] <- shares
    priceSignalsAction[, "Cash_Balance"] <- balance
    priceSignalsAction[, "Account_Value"] <- value
    
    return(priceSignalsAction)
}

getNetTable <- function(simResults, priceCol="Close",
                        buyComm=10.00, sellComm=10.00,
                        ignoreCurrentOpenPos=TRUE) {
    library(dplyr)
    sells <- filter(simResults, Actions=="SELL")
    exitDates <- sells$Date;
    sellPrices <- sells$Close
    completeCount <- length(sells$Shares)
    exitDates <- sells$Date;
    sellPrices <- sells[, as.character(priceCol)]
    # ignore possible currently open position
    buys <- filter(simResults, Actions=="BUY")[1:completeCount, ]
    entryDates <- buys$Date;
    buyPrices <- buys[, as.character(priceCol)]
    netPLs <- buys$Shares * (sells[, as.character(priceCol)] -
                             buys[, as.character(priceCol)])
    netPLs <- (floor(netPLs * 100) / 100) - (buyComm + sellComm)
    netTable <- data.frame(BuyOn=entryDates, BuyPrice=buyPrices,
                           Shares=as.integer(buys$Shares),
                           SellOn=exitDates, SellPrice=sellPrices, 
                           ProfitLoss=netPLs, stringsAsFactors = FALSE)
    
    return(netTable)
}

netStrategyPL <- function(netTable) {
    return(sum(netTable$ProfitLoss))
}