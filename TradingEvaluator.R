

## Development convenience method. Just changes working dir to where it needs
## to be for this project.  Add salt to taste...
setWorking <- function(laptopSys=TRUE) {
    dirSys <- "C:/data/"  # laptop
    if(!laptopSys) { dirSys <- "D:/" }  # workstation
    dirProject <- "dev/TradeAnalyzer"
    dirWorking <- paste0(dirSys, dirProject)
    setwd(dirWorking)
}

## Returns a data frame of the results of a simulation for a stock of a given
## ticker, from startDate to endDate, using strategy.
## ticker - ticker symbol for stock to run strategy on (e.g. JNJ, AAPL, etc.)
## signalParms - Vector of named values used by strategy to generate signals
##               Default is a vector with the fast and slow SMA periods used by
##               SignalGenSmaLongOnlyOpaat.R strategy
## startDate - Starting date of the simulation. Default is 365 day prior today
## endDate - ending date of the simulation, default is today
## strategy - R source file used to implement the strategy to use for the
##            simulation. Default is SignalGenSmaLongOnlyOpaat.R
doSimulation <- function(ticker, signalParms=c(fastDays=9, slowDays=18),
                         startDate = as.character(Sys.Date()-365),
                         endDate = as.character(Sys.Date()),
                         strategy = "SignalGenSmaLongOnlyOpaat.R") {
    source(strategy)
    source("DataManager.R")
    priceData <- getStockQuotes(ticker, startDate, endDate)
    priceData <- configureSignalParms(priceData, signalParms)
    priceData <- appendSignals(priceData)
    priceData <- getActionsBHS(priceData)
    priceData <- simulateStrategy(priceData)
    
    return(priceData)
}

getBuys <- function(simResults) {
    #install.packages("dplyr")
    library(dplyr)
    return(filter(simResults, Actions=="BUY"))
}

getSells <- function(simResults) {
    #install.packages("dplyr")
    library(dplyr)
    return(filter(simResults, Actions=="SELL"))
}