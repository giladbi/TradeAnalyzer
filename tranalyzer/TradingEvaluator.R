

## Development convenience method. Just changes working dir to where it needs
## to be for this project.  Add salt to taste...
setWorking <- function(laptopSys=TRUE) {
    dirSys <- "C:/data/"  # laptop
    if(!laptopSys) { dirSys <- "D:/" }  # workstation
    dirProject <- "dev/TradeAnalyzer"
    dirWorking <- paste0(dirSys, dirProject)
    setwd(dirWorking)
}

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

