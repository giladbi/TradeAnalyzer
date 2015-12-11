


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

## Makes a REST call to get historical stock prices from yahoo finance and
## returns a dataframe with the Date, High, Low, open, close and volume for 
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
getStockQuotes <- function(ticker,
                           startYYYY_MM_DD = as.character(Sys.Date() - 365),
                           endYYYY_MM_DD = as.character(Sys.Date()),
                           dataFrame=NULL) {
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
        df <- data.frame(Symbol=ticker, Date, High, Low, Open, Close, Volume)
        df <- arrange(df, Date)
    }
    else {
        temp <- data.frame(Symbol=ticker, Date, High, Low, Open, Close, Volume)
        temp <- arrange(temp, Date)
        df <- rbind(dataFrame, temp)
    }
    
    return(df)
}