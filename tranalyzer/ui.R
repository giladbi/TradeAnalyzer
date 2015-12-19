# Get all 30 DJIA symbols to populate the Company select box
# dow30Url <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/tranalyzer/data/dow30.csv"
# dow30Stocks <- read.csv(dow30Url, stringsAsFactors = FALSE)

# Get 4 ticker symbols for demo
#demo4TickersUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/tranalyzer/data/demo4Tickers.csv"
demo4TickersUrl <- "./data/demo4Tickers.csv"
demoStocks <- read.csv(demo4TickersUrl, stringsAsFactors = FALSE)

# Get position management strategies
# posMgmtStratsUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/tranalyzer/data/positionStrats.csv"
posMgmtStratsUrl <- "./data/positionStrats.csv"
posMgmtStrats <- read.csv(posMgmtStratsUrl, stringsAsFactors = FALSE)
posMgmtStratsList <- as.list((posMgmtStrats$Position_Sizing_Strategy))

# tickers <- dowStocks$ticker
tickers <- demoStocks$ticker
names(tickers) <- paste0(demoStocks$ticker, " = ", demoStocks$company_name)
stockList <- as.list(tickers)
# Get the trading signals to populate Trade Signal select box
# tradeSignalsUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/tranalyzer/data/trade_signals.csv"
tradeSignalsUrl <- "./data/trade_signals.csv"
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
demoStartDateMin <- "2005-12-15"; demoEndDateMax <- "2015-12-14"
demoStartDate <- as.character(as.Date(demoEndDateMax)-365)
demoEndDate <- as.character(as.Date(demoEndDateMax))

pageWithSidebar(
    headerPanel("Trade Evaluator"),
    sidebarPanel(
        selectInput('ticker', label=h4("Company"),
                    choices=stockList, selected=1),
        selectInput("tradeSignal", label=h4("Trade Signal:"),
            choices=tradeSignalList, selected=1),
        sliderInput("fastSlowSma", h4("Fast & Slow SMA"),
                    min = 2, max = 100, value = c(9,18)),
        dateRangeInput('queryDateRange', label = h4("Quote Date Range:"),
                       start=demoStartDate, end=demoEndDate,
                       min=demoStartDateMin, max=demoEndDateMax),
        numericInput('accBalance', 'Starting Account Balance:',
                     10000, min = 5000, max = 1000000, step = 500),
        selectInput('posMgmt', label=h4("Position Management:"),
                    choices=posMgmtStratsList, selected=1),
        actionButton('runSimButton', 'Run Simulation')
    ),
    mainPanel(
        h4('Company Ticker:'),
        verbatimTextOutput("oidstock"),
        h4('Signal Parameters & Position Management:'),
        verbatimTextOutput("signalAndParams"),
        h4('Query Start & End Dates:'),
        verbatimTextOutput("oidBothQueryDates"),
        h4("Trades using this signal and position management:"),
        h5("(Assumes $10 commission for each buy or sell)"),
        tableOutput("trades"),
        h4('Net Trading Profit/Loss:'),
        verbatimTextOutput("oidTradesNet")
    )
)