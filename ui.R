# Get all 30 DJIA symbols to populate the Company select box
dow30Url <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/data/dow30.csv"
dow30Stocks <- read.csv(dow30Url, stringsAsFactors = FALSE)

# Get 4 ticker symbols for demo
demo4TickersUrl <- "https://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/data/demo4Tickers.csv"
demoStocks <- read.csv(demo4TickersUrl, stringsAsFactors = FALSE)

# tickers <- dowStocks$ticker
tickers <- demoStocks$ticker
# names(tickers) <- dowStocks$company_name
names(tickers) <- demoStocks$company_name
stockList <- as.list(tickers)
# Get the trading signals to populate Trade Signal select box
tradeSignalsUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/data/trade_signals.csv"
#tradeSignalsUrl <- "./data/trade_signals.csv"
tradeSignals <- read.csv(tradeSignalsUrl, stringsAsFactors = FALSE)
tradeSignalList <- as.list((tradeSignals$trade_signal))

## Returns the date that's 10 years ago today in the format:
## yyyy-mm-dd.
tenYearsAgoToday <- function() {
    today <- as.POSIXlt(Sys.Date())
    today$year <- today$year - 10
    return(as.character(today))
}

# Dates to use for demo mode
demoStartDate <- "2014-12-14"; demoEndDate <- "2015-12-14"

pageWithSidebar(
    headerPanel("Trade Evaluator"),
    sidebarPanel(
        selectInput('ticker', label=h4("Company"),
                    choices=demoStocks, selected=1
        ),
        selectInput("tradeSignal", label=h4("Trade Signal:"),
            choices=tradeSignalList, selected=1
        ),
        numericInput('fastSMA', 'Fast SMA:', 9, min = 2, max = 250, step = 1),
        numericInput('slowSMA', 'Slow SMA:', 18, min = 3, max = 250, step = 1),
        dateRangeInput('queryDateRange', label = h3("Quote Date Range:"),
                       start=demoStartDate, end=demoEndDate,
                       min=demoStartDate, max=demoEndDate),
        numericInput('accBalance', 'Starting Account Balance:',
                     10000, min = 5000, max = 1000000, step = 500),
        actionButton('runSimButton', 'Run Simulation')
    ),
    mainPanel(
        h4('Company Ticker:'),
        verbatimTextOutput("oidstock"),
        h4('Signal & Parameters:'),
        verbatimTextOutput("signalAndParams"),
        h4('Query Start & End Dates:'),
        verbatimTextOutput("oidBothQueryDates"),
        h4('Trades Using This Strategy:'),
        tableOutput("trades")
    )
)