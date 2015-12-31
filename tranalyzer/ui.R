source("TranalyzerUserGuide.R")

# Get all 30 DJIA symbols to populate the Company select box
# dow30Url <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/tranalyzer/data/dow30.csv"
# dow30Stocks <- read.csv(dow30Url, stringsAsFactors = FALSE)

# Get 4 ticker symbols for demo
#tickersUrl <- "./data/demo4Tickers.csv"
#demoStocks <- read.csv(tickersUrl, stringsAsFactors = FALSE)

# Get position management strategies
# posMgmtStratsUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/tranalyzer/data/positionStrats.csv"
posMgmtStratsUrl <- "./data/positionStrats.csv"
posMgmtStrats <- read.csv(posMgmtStratsUrl, stringsAsFactors = FALSE)
posMgmtStratsList <- as.list((posMgmtStrats$Position_Sizing_Strategy))

#tickers <- demoStocks$ticker
#names(tickers) <- paste0(demoStocks$ticker, " = ", demoStocks$company_name)
#stockList <- as.list(tickers)

# Get the trading signals to populate Trade Signal select box
# tradeSignalsUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/tranalyzer/data/trade_signals.csv"
tradeSignalsUrl <- "./data/signals/trade_signals.csv"
tradeSignals <- read.csv(tradeSignalsUrl, stringsAsFactors = FALSE)
tradeSignalList <- as.list((tradeSignals$trade_signal))

## description(s) of signals - TODO This needs to be generalized to handle multiple strategies
strategyUrl <- paste0("./data/signals/", tradeSignals$description_file[1])
signalContent <- readChar(strategyUrl, file.info(strategyUrl)$size)

## Returns the date that's 10 years ago today in the format:
## yyyy-mm-dd.
tenYearsAgoToday <- function() {
    today <- as.POSIXlt(Sys.Date())
    today$year <- today$year - 10
    return(as.character(today))
}

# Dates to use for demo mode
# demoStartDateMin <- "2005-12-15"; demoEndDateMax <- "2015-12-14"
# simStartDate <- as.character(as.Date(demoEndDateMax)-365)
# simEndDate <- as.character(as.Date(demoEndDateMax))

# Default dates to use with live data
simEndDate <- as.character(Sys.Date())
simStartDate <- as.character(Sys.Date() - 365)
simStartDateMin <- tenYearsAgoToday(); simEndDateMax <- simEndDate

fluidPage(
    headerPanel("Trade Analyzer"),
    sidebarPanel(
        textInput('ticker', label=h4("Company")),
        selectInput('tradeSignal', label=h4("Trade Signal:"),
                    choices=tradeSignalList, selected=1),
        sliderInput('fastSlowSma', h4("Fast (left) & Slow (right) SMA Days"),
                    min = 2, max = 100, value = c(9,18)),
        dateRangeInput('queryDateRange', label = h4("Quote Date Range:"),
                       start=simStartDate, end=simEndDate,
                       min=simStartDateMin, max=simEndDateMax),
        numericInput('accBalance', 'Starting Account Balance:',
                     10000, min = 5000, max = 1000000, step = 500),
        selectInput('posMgmt', label=h4("Position Management:"),
                    choices=posMgmtStratsList, selected=1),
        actionButton('runSimButton', 'Run Simulation')
    ),
    mainPanel(
        tabsetPanel(
#             tabPanel('User Guide', h4('Overview'),
#                      p(getOverviewP1(), strong('Run Simulation'),
#                        getOverviewP2(), strong('Analyzer'),
#                        getOverviewP3(), strong('Graphics'), 'tab.',
#                        getOverviewP4(), strong('Signal'), 'tab.'),
#                      h3('Fields'),
#                      p(strong('Company - '),
#                        getFieldsCompanyP1(), strong('Demo mode'),
#                        getFieldsCompanyP2()),
#                      p(strong('Trade Signal - '), getFieldsTradeSignalP1(),
#                        strong('SMA cross-over'), getFieldsTradeSignalP2()),
#                      p(getFieldsTradeSignalP3(), getFieldsTradeSignalP4()),
#                      p(strong('Quote Date Range - '), getQDateRangeP1()),
#                      p(strong('Starting Account Balance - '),
#                        getStartAccountBalP1()),
#                      p(strong('Postion Management - '), getPositionMgmtP1(),
#                        em(getPositionMgmtP2()))
#             ),
            tabPanel("Analyzer",
                h4('Company Ticker:'),
                verbatimTextOutput("oidstock"),
                h4('Signal Parameters & Position Management:'),
                verbatimTextOutput("signalAndParams"),
                h4('Query Start & End Dates:'),
                verbatimTextOutput("oidBothQueryDates"),
                h4("Trades using this signal and position management:"),
                h6("(ProfitLoss calculation assumes $10 commission for each buy or sell)"),
                div(style='height:240px; overflow-y: scroll',
                    tableOutput("trades")
                ),
                h4('Net Trading Profit/Loss:'),
                verbatimTextOutput("oidTradesNet")
            ),
            tabPanel("Graphics", h3("Trades identified using this signal:"),
                     h5(paste0("In the chart below, BUY signal triangles are ",
                               "shifted down and SELL triangles are shifted ",
                               "up so signals are more visible:")),
                     plotOutput("oidTradeSignalsPlot"),
                     h3("Simulated trade results using identified trades:"),
                     plotOutput("oidTradesResultsHist")
            ),
            tabPanel("Signal", h3(textOutput("oidTradeSignal")),
                     HTML(signalContent)  # https://gist.github.com/jcheng5/4052973
            )
        )
    )
)