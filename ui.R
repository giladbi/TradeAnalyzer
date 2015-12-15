# Get the symbols to populate the Company select box
dowUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/data/dow30.csv"
dowStocks <- read.csv(dowUrl, stringsAsFactors = FALSE)
tickers <- dowStocks$ticker
names(tickers) <- dowStocks$company_name
stockList <- as.list(tickers)
# Get the trading signals to populate Trade Signal select box
tradeSignalsUrl <- "http://raw.githubusercontent.com/MichaelSzczepaniak/TradeAnalyzer/master/data/trade_signals.csv"
tradeSignals <- read.csv(tradeSignalsUrl, stringsAsFactors = FALSE)
tradeSignalList <- as.list((tradeSignals$trade_signal))

pageWithSidebar(
    headerPanel("Trade Evaluator"),
    sidebarPanel(
        selectInput('ticker', label=h4("Company"),
                    choices=stockList, selected=1
        ),
        selectInput("tradeSignal", label=h4("Trade Signal:"),
            choices=tradeSignalList, selected=1
        ),
        numericInput('fastSMA', 'Fast SMA:', 9, min = 2, max = 250, step = 1),
        numericInput('slowSMA', 'Slow SMA:', 18, min = 3, max = 250, step = 1),
        dateInput('startQuery', "Start Date:"),
        dateInput('endQuery', "End Date:"),
        numericInput('accBalance', 'Starting Account Balance:',
                     10000, min = 5000, max = 1000000, step = 500)
    ),
    mainPanel(
        h4('Company Ticker:'),
        verbatimTextOutput("oidstock"),
        h4('Fast SMA:'),
        verbatimTextOutput("oidfsma"),
        h4('Slow SMA:'),
        verbatimTextOutput("oidssma"),
        h4('Query Start Date:'),
        verbatimTextOutput("oidsdate"),
        h4('Query End Date:'),
        verbatimTextOutput("oidedate")
    )
)