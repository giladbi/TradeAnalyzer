

## Development convenience method. Just changes working dir to where it needs
## to be for this project.  Add salt to taste...
# setWorking <- function(laptopSys=TRUE) {
#     dirSys <- "C:/data/"  # laptop
#     if(!laptopSys) { dirSys <- "D:/" }  # workstation
#     dirProject <- "dev/TradeAnalyzer"
#     dirWorking <- paste0(dirSys, dirProject)
#     setwd(dirWorking)
# }

addSimColumns <- function(prices, signalGen, sigParms, startBalance) {
    source(signalGen)
    priceData <- configureSignalParms(prices, sigParms)
    priceData <- appendSignals(priceData)
    priceData <- getActionsBHS(priceData)
    source("StrategySimulator.R")
    priceData <- allInAllOutOaatOnlyLong(priceData, startBalance)
    
    return(priceData)
}

## Returns a data frame of the results of a simulation for a stock of a given
## ticker, from startDate to endDate, using the strategy specified by the 
## signal generator signalGen.
##
## ticker - ticker symbol for stock to run signalGen on (e.g. JNJ, AAPL, etc.)
## signalParms - Vector of named values used by signalGen to generate signals.
##               Default is a vector with the fast and slow SMA periods used by
##               SignalGenSmaLongOnlyOpaat.R
## startDate - Character array of the format: yyyy-mm-dd designating the
##             starting date of the simulation. Default is 365 day prior today.
## endDate - Character array of the format: yyyy-mm-dd designating the
##           ending date of the simulation. Default is today
## signalGen - R source file used to implement the signal generator to use for
##             the simulation. Default is SignalGenSmaLongOnlyOpaat.R
##
doSimulation <- function(ticker,
                         startDate = as.character(Sys.Date()-365),
                         endDate = as.character(Sys.Date()),
                         signalParms=c(fastDays=9, slowDays=18),
                         signalGen = "SignalGenSmaLongOnlyOpaat.R",
                         startBalance = 10000,
                         priceData=NULL) {
    if(is.null(priceData)) {
        source("DataManager.R")
        # priceData <- getStockQuotes(ticker, startDate, endDate) # query yahoo
        priceData <- getDemoQuotes(ticker, startDate, endDate) # read repo csv
    }
    
    # next line sources StrategySimulator.R for addSimColumns & getNetTable
    priceData <- addSimColumns(priceData, signalGen, signalParms, startBalance)
    
    return(getNetTable(priceData))
}

## Create plot that identifies the trades called out by the signal
## shift - fraction amount to shift buy signal point down and sell signal up
makeTradeSignalsPlot <- function(ticker, startDate,endDate, signalParms,
                                 signalGen, startBalance, shift) {
    source("DataManager.R")
    priceData <- getDemoQuotes(ticker, startDate, endDate) # read repo csv
    priceData <- addSimColumns(priceData, signalGen, signalParms, startBalance)
    x <- as.Date(priceData$Date) # x axis values
    plot(x, y=priceData$Close, type="l", lwd=2,
         col='black', xlab="Date", ylab="Price ($ USD)")
    title(paste0("Completed trades for ", ticker, " using SMA cross-over"))
    lines(x, y=priceData$FastSma, col='red')
    lines(x, y=priceData$SlowSma, col='blue')
    # get the sell points
    sells <- filter(priceData, Actions=="SELL")
    exitDates <- as.Date(sells$Date)
    sellSignals <- pmax(sells$FastSma, sells$SlowSma) * (1 + shift)
    points(exitDates, sellSignals, pch=6, cex=1.75, col='red', lwd=2)
    completeCount <- length(sells$Shares)
    buys <- filter(priceData, Actions=="BUY")[1:completeCount, ]
    entryDates <- as.Date(buys$Date)
    buySignals <- pmin(buys$FastSma, buys$SlowSma) * (1 - shift)
    points(entryDates, buySignals, pch=2, cex=1.75, col='green', lwd=2)
    legend('bottom',
           c("Close Price", "Fast SMA", "Slow SMA", "Buy Signal", "Sell Signal"),
           lty=c(1,1,1,0,0), pch=c(NA, NA, NA, 2, 6),
           col=c('black', 'red', 'blue', 'green', 'red'))
}

makeTradesResultsHist <- function(ticker, startDate,endDate,
                                  signalParms, signalGen, startBalance) {
    sim <- doSimulation(ticker, startDate, endDate,
                        signalParms, signalGen, startBalance)
    histTitle <- paste0("Results of ", ticker, " trades using SMA cross-over")
    hist(sim$ProfitLoss, main=histTitle, xlab="Trade Net ($ USD)",
         ylab="Trade Count", yaxt='n')
    axis(2, at=0:length(sim$ProfitLoss))
}