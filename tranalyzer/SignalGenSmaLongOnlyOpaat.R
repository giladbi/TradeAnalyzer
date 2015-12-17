###############################################################################
## SignalGenSmaLongOnlyOpaat.R
## Signal Generator for the Simple Moving Average SMA cross-over strategy
## Details:
## 1) Only long entry postions (LongOnly) are allowed
## 2) Only one position at a time (Opaat) is allowed. In other words, a
##    currently open postion must be closed before another can be opened.
## BUY Signal is generated when fast SMA rises above slow SMA
## SELL Signal is generated when fast SMA drops below slow SMA
## HOLD signal is generated when under two conditions:
##  i. a position is open and fast SMA is near or above the slow SMA
## ii. no position is open and slow SMA is near or above the fast SMA
###############################################################################

source("TechIndicators.R")

## Adds 2 columns used as signal parameters to the stockPrices data frame:
## a fast simple moving average (SMA): FastSma and a slow SMA: SlowSma
## 
## stockPrices - a dataframe or object created from a call to getSymbols
##               in the quantmod package (xts object)
## fastDays - integer number of days to create the fast SMA over
## slowDays - integer number of days to create the slow SMA over
## fixColNames - Should prepended ticker symbol be removed from columns names?
##               Set this option to TRUE if getting quotes using getSymbols
## calcCol - name of the column that SMA will be calculated on. Possible values:
##           Open, High, Low, Close, Volume.
## IMPORTANT: slowDays > fastDays
configureSignalParms <- function(stockPrices,
                                 signalParms=c(fastDays=8, slowDays=16),
                                 fixColNames=FALSE, calcCol="Close") {
    fastDays <- signalParms["fastDays"]
    slowDays <- signalParms["slowDays"]
    if(fixColNames) { normalizeColNames(stockPrices) }
    calcPrices <- stockPrices[, as.character(calcCol)]
    fastName <- "FastSma" #paste0("FastSma", fastDays)
    slowName <- "SlowSma" #paste0("SlowSma", slowDays)
    
    stockPrices[, fastName] <- calcSma(calcPrices, fastDays)
    stockPrices[, slowName] <- calcSma(calcPrices, slowDays)
    
    return(stockPrices)
}

## Returns an integer vector corresponding to an SMA cross-over strategy. For
## each fastSma in fastSmas and slowSma in slowSmas, values calc'd as follows:
##    1 if (fastSma - slowSma) >  tol * price, i.e. fast SMA is above slow SMA
##   -1 if (slowSma - fastSma) >  tol * price, i.e. slow SMA is above fast SMA
##    0 if |fastSma - slowSma| <= tol * price, fast & slow SMA close together OR
##      fastSma in NaN OR slow SMA is NaN
## fastSmas - vector of fast SMA values
## slowSmas - vector of slow SMA values
## tol - tolerance which is used to determine whether fast and slow SMAs are 
##       different enough to be considered being above or below one another.
##       When |fastSma - slowSma| <= (price * tol), fastSma and slowSma are
##       considered to be the same from a signal perspective.
getSmaSignals <- function(prices, fastSmas, slowSmas, tol) {
    fastSmaPositions <- vector(mode="integer", length=length(prices)) # init 0's
    for(i in 1:length(prices)) {
        if(is.nan(fastSmas[i]) || is.nan(slowSmas[i])) { next }
        if((fastSmas[i] - slowSmas[i]) >  tol * prices[i]) {
            fastSmaPositions[i] <- 1
        }
        else if((slowSmas[i] - fastSmas[i]) >  tol * prices[i]) {
            fastSmaPositions[i] <- -1
        }
    }
    
    return(fastSmaPositions)
}

## Appends a column to the passed in dataframe named Signal.
## Signal - integer vector, 1 if (fastSma - slowSma) >  tol * price
##                          0 if |fastSma - slowSma| <= tol * price
##                         -1 if (slowSma - fastSma) >  tol * price
## 
## stockPrices is assumed to have at least 4 columns:
## "Date", "FastSma", "SlowSma", and one named whatever is passed in for
## for the calcCol parameter.
appendSignals <- function(stockPrices, calcCol="Close", tol=0.003) {
    prices <- stockPrices[, as.character(calcCol)]
    smaPos <- getSmaSignals(prices, stockPrices$FastSma,
                            stockPrices$SlowSma, tol)
    stockPrices[, "Signal"] <- smaPos
    
    return(stockPrices)
}

## Appends two columns: Action and Open_Position to pricesWithSignal data frame.
## pricesWithSignal is expected to have the following columns at minimum:
## Date and Signal
## 
## Signal will be either -1, 0 or +1. When Signal goes from -1 to +1,
## the recommended Action is BUY on the day that signal goes to +1.
##
## When Signal goes from +1 to -1, the recommended Action is SELL on the
## day that signal goes to -1.
## 
## The Action is always HOLD under the following 3 conditions:
## 1) when it is not BUY or SELL or
## 2) on the first 2 trading days in the priceWithSignal data
## 
getActionsBHS <- function(pricesWithSignal) {
    actions <- rep("HOLD", length(pricesWithSignal$Signal))
    openPosition <- rep(FALSE, length(pricesWithSignal$Signal))
    sampleCount <- length(pricesWithSignal$Signal)
    for(i in 3:sampleCount) {
        signalDayMinus0 <- pricesWithSignal$Signal[i]
        signalDayMinus1 <- pricesWithSignal$Signal[i-1]
        if(openPosition[i-1]) {  # only HOLD or SELL allowable
            if(signalDayMinus1 < 0) { actions[i] <- "UNREACHABLE_STATE1" }
            if(signalDayMinus1 == 0) {
                if(signalDayMinus0 < 0) {
                    actions[i] <- "SELL"
                    # reset downstream states, will be reset after next BUY
                    openPosition[i:sampleCount] <- FALSE
                }
                else {
                    # signalDayMinus0 = 0 or 1, leave action as HOLD, but
                    # reset openPositions downstream to the previous value
                    openPosition[i:sampleCount] <- openPosition[i-1]
                }
                
            }
            else {  # signalDayMinus1 > 0
                if(signalDayMinus0 < 0) {
                    actions[i] <- "SELL"
                    # reset downstream states, will be reset after next BUY
                    openPosition[i:sampleCount] <- FALSE
                }
                else {
                    # signalDayMinus0 = 0 or 1, leave action as HOLD, but
                    # reset openPositions downstream to the previous value
                    openPosition[i:sampleCount] <- openPosition[i-1]
                }
            }
        }
        else {  # openPosition[i-1] == FALSE, only HOLD or BUY allowable
            if(signalDayMinus1 > 0) { actions[i] <- "UNREACHABLE_STATE2" }
            if(signalDayMinus1 == 0) {
                if(signalDayMinus0 > 0) {
                    actions[i] <- "BUY"
                    # reset downstream states, will be reset after sell
                    openPosition[i:sampleCount] <- TRUE
                }
                else {
                    openPosition[i:sampleCount] <- openPosition[i-1]
                }
            }
            else {  # signalDayMinus1 < 0
                if(signalDayMinus0 > 0) {
                    actions[i] <- "BUY"
                    # reset downstream states, will be reset after sell
                    openPosition[i:sampleCount] <- TRUE
                }
                else {
                    openPosition[i:sampleCount] <- openPosition[i-1]
                }
            }
        }
    }
    pricesWithSignal[, "Actions"] <- as.factor(actions)
    pricesWithSignal[, "Open_Position"] <- openPosition
    
    return(pricesWithSignal)
}

