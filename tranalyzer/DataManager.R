


## Returns a character vector of ticker symbols for stocks currently listed
## on the S&P 500 index
getSP500Tickers <- function() {
    # This may not be up-to-date, but at it's something.  This data appears
    # to be amazingly hard to find. Only 494 tickers in this data: good enough
    # http://data.okfn.org/data/core/s-and-p-500-companies/r/constituents.csv
    sp500url <- "https://www.dropbox.com/s/fiy9tvp527xebxf/sp500.csv?dl=1"
    #sp500url <- "http://data.okfn.org/data/core/s-and-p-500-companies/r/constituents.csv"
    sp500tickers <- read.csv(sp500url)
}

## Returns the number of query periods between startDate and endDate where
## the number of days in all but the most recent (last) query period are
## maxAllowableDays.  The most recent period which will usually be less than
## maxAllowableDays because it will typically be a partial period.
getQueryPeriods <- function(startDate, endDate, maxAllowableDays) {
    queryDays <- ceiling(
                     as.integer(
                         difftime(as.Date(endDate),
                         as.Date(startDate),
                         units="days")
                     ) / maxAllowableDays)
    
    return(queryDays)
}

## Returns the number of completed years between startDate and endDate where:
## startDate - date further back in time from endDate
## endDate - further forward in time than startDate
getCompletedYearsBetweenDates <- function(startDate, endDate) {
    d1 <- as.Date(startDate)
    d2 <- as.Date(endDate)
    #http://stackoverflow.com/questions/19687334/is-it-possible-to-count-the-distance-between-two-dates-in-months-or-years/19687995#19687995
    completedYears <- length(seq(from=d1, to=d2, by='year')) - 1
    
    return(completedYears)
}

## This function is used to break a date range into a list of component date
## ranges.  It returns a list of character vectors where each vector contains
## two strings of the form yyyy-mm-dd.
##
## The first string in each character vector is the starting date of a query
## period.  The second is the ending date of the period.
## 
## If the number of days between startDate and endDate is less than
## maxAllowableDays, then a list with a single vector containing startDate and
## endDate will be returned.
##
## If the number of days between startDate and endDate is greater than
## maxAllowableDays, then a list with 2 or more vectors will be returned.  Each
## vector in this case will span at most a maxAllowableDays number of days in a
## portion of the range between startDate and endDate.
## 
getDateRanges <- function(startDate, endDate,
                          maxAllowableDays=360, maxAllowableYears=10) {
    dateIntervals <- list(c(start=startDate, end=endDate))
    
    if(getCompletedYearsBetweenDates(startDate, endDate) >= maxAllowableYears) {
        adjustedStart <- as.POSIXlt(as.Date(endDate))
        adjustedStart$year <- adjustedStart$year - 10
        adjustedStart <- as.Date(adjustedStart)
        adjustedStart <- as.character(adjustedStart)
        dateIntervals <- list(c(start=adjustedStart, end=endDate))
        startDate <- adjustedStart
        queryPeriods <- getQueryPeriods(startDate, endDate, maxAllowableDays)
    }
    
    queryPeriods <- getQueryPeriods(startDate, endDate, maxAllowableDays)
    
    if(queryPeriods > 1) {
        firstEnd <- as.Date(startDate) + maxAllowableDays
        dateIntervals <- list(c(start=startDate, end=as.character(firstEnd)))
        for(i in 2:queryPeriods) {
            dateInterval <- dateIntervals[[i-1]]
            nextStart <- as.Date(dateInterval["end"]) + 1
            newEnd <- nextStart + maxAllowableDays
            if(i >= queryPeriods) {
                dateIntervals[[i]] <- c(start=as.character(nextStart),
                                        end=endDate)
            }
            else {
                dateIntervals[[i]] <- c(start=as.character(nextStart),
                                        end=as.character(newEnd))
            }
            
        }
    }
    
    return(dateIntervals)
}

## Makes a single REST call to get historical stock prices from yahoo finance 
## and returns a dataframe with the Date, High, Low, open, close and volume for 
## the symbol passed in over the requested date range.
##
## IF NO DATA COULD BE FOUND FOR TICKER, AN EMPTY DATAFRAME WILL BE RETURNED!
##
## ticker - ticker symbol to get quotes for
## startYYYY_MM_DD - starting date for the quote in format yyyy-mm-dd
## endYYYY_MM_DD - ending date for the quote in format yyyy-mm-dd
## 
## YQL queries like this were entered into the YQL console to generate
## the REST call:
##
## select * from yahoo.finance.historicaldata where symbol = "YHOO" and
##          startDate = "2015-01-01" and endDate = "2015-12-01"
##
## Resulting generated call looked like this:
##
## https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.historicaldata%20where%20symbol%20%3D%20%22AAPL%22%20and%20startDate%20%3D%20%222015-01-01%22%20and%20endDate%20%3D%20%222015-12-01%22&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys
## !!!! HAD TO CHANGE https TO http FOR THE CALL TO xmlTreeParse TO WORK !!!!
getSinglePeriodYqlQuotes <- function(ticker, startYYYY_MM_DD,
                                     endYYYY_MM_DD, dataFrame=NULL) {
    #install.packages("XML"); install.packages("dplyr")
    library(XML)
    library(dplyr)
    # change https to http stackoverflow.com/questions/23584514/23584751#23584751
    baseQuery <- paste0("http://query.yahooapis.com/v1/public/yql",
                        "?q=select%20*%20from%20yahoo.finance.historicaldata")
    symbolClause <- paste0("%20where%20symbol%20%3D%20%22", ticker, "%22%20and")
    dateClause <- paste0("%20startDate%20%3D%20%22", startYYYY_MM_DD,
                         "%22%20and%20endDate%20%3D%20%22", endYYYY_MM_DD)
    yqlSuffix <- paste0("%22&diagnostics=true",
                        "&env=store%3A%2F%2Fdatatables.org",
                        "%2Falltableswithkeys")
    
    yqlCall <- paste0(baseQuery, symbolClause, dateClause, yqlSuffix)
    
    doc <- xmlTreeParse(yqlCall, useInternalNodes = TRUE)
    rootNode <- xmlRoot(doc)
    quotes <- xpathSApply(rootNode, "//quote")
    High <- as.numeric(xpathSApply(rootNode, "//High", xmlValue))
    Low <- as.numeric(xpathSApply(rootNode, "//Low", xmlValue))
    Open <- as.numeric(xpathSApply(rootNode, "//Open", xmlValue))
    Close <- as.numeric(xpathSApply(rootNode, "//Close", xmlValue))
    Volume <- as.numeric(xpathSApply(rootNode, "//Volume", xmlValue))
    date.format <- "%Y-%m-%d"
    Date <- as.Date(xpathSApply(rootNode, "//Date", xmlValue), date.format)
    # If we pass in a populated dataframe, assume we need to append to it
    if(is.null(dataFrame)) {
        df <- data.frame(Symbol=ticker, Date=as.character(Date),
                         High, Low, Open, Close, Volume)
        df <- arrange(df, Date)
    }
    else {
        temp <- data.frame(Symbol=ticker, Date=as.character(Date),
                           High, Low, Open, Close, Volume)
        temp <- arrange(temp, Date)
        df <- rbind(dataFrame, temp)
    }
    
    return(df)
}

## Returns a dataframe with quotes between startDate and endDate
## for ticker symbol ticker.  endDate defaults to todays date.
getStockQuotes <- function(ticker, startDate, 
                           endDate=as.character(Sys.Date())) {
    dateRanges <- getDateRanges(startDate, endDate)
    quoteCount <- length(dateRanges)
    sdate <- dateRanges[[1]]["start"]
    edate <- dateRanges[[1]]["end"]
    quotes <- getSinglePeriodYqlQuotes(ticker, sdate, edate)
    if(quoteCount > 1) {
        for(i in 2:quoteCount) {
            sdate <- dateRanges[[i]]["start"]
            edate <- dateRanges[[i]]["end"]
            quotes <- rbind(quotes,
                            getSinglePeriodYqlQuotes(ticker, sdate, edate))
        }
    }
    
    return(quotes)
}

## Writes downloaded quotes to a csv file to be reread later
## tickers - vector of ticker symbols
## startDate - starting date for the quote in format yyyy-mm-dd
## endDate - ending date for the quote in format yyyy-mm-dd
writeQuotes <- function(tickers, startDate, endDate=as.character(Sys.Date())) {
    for(i in 1:length(tickers)) {
        quotes <- getStockQuotes(tickers[i], startDate, endDate)
        filePath <- paste0("./data/", tickers[i], ".csv")
        write.csv(quotes, filePath)
        cat("Completed writing ", filePath)
    }
}

## Lower risk way to to get data for demo purposes. This reads a csv from the 
## project repo rather than querying finance.yahoo for the data
getDemoQuotes <- function(ticker, startDate,
                          endDate=as.character(Sys.Date())) {
    library(dplyr)
    # Next 3 lines working running shiny thru loopback, but not deployed
#     demoQuotesPrefix <- "http://raw.githubusercontent.com/MichaelSzczepaniak/"
#     projectQuoteData <- "TradeAnalyzer/master/tranalyzer/data/"
#     demoQuotesPrefix <- paste0(demoQuotesPrefix, projectQuoteData)
    demoQuotesPrefix <- "./data/"
    demoQuotesPath <- paste0(demoQuotesPrefix, ticker, ".csv")
    
    quotes <- read.csv(demoQuotesPath, stringsAsFactors = FALSE)[, -1]
    quotes$Date <- as.Date(quotes$Date)
    quotes <- filter(quotes, Date >= as.Date(startDate) & Date <=as.Date(endDate))
    quotes$Date <- as.character(quotes$Date)
    
    return(quotes)
}