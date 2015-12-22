## Functions that supply the content for User Guide

getOverviewP1 <- function() {
    content <- "The left pane is used to set the values required for the strategy that you want to simulate.  Each parameter has a default which can be left as is or changed.  After selecting your settings, click the "
    return(content);
}

getOverviewP2 <- function() {
    content <- "button at the bottom of the pane.  Your settings and the results of your simulation will be displayed in the"
    return(content);
}

getOverviewP3 <- function() {
    content <- "tab.  A chart showing the trades that your simulation selected along with a histogram of the results of each trade are displayed in the"
    return(content);
}

getOverviewP4 <- function() {
    content <- "  A description of how the selected trade signal works is described in the "
}

getFieldsCompanyP1 <- function() {
    content <- "If a drop down is visible, you are running in"
    return(content);
}

getFieldsCompanyP2 <- function() {
    content <- " and four company tickers will be available: Apple (default), GE, Home Depot, and Johnson & Johnson."
    return(content);
}

getFieldsTradeSignalP1 <- function() {
    content <- "This is this list of implementations that create the signals that tells the simulator when to buy, sell, or hold a position. Only the "
    return(content);
}

getFieldsTradeSignalP2 <- function() {
    content <- " is implemented in the demo.  The SMA days must be different or you will get an error."
    return(content);
}

getFieldsTradeSignalP3 <- function() {
    content <- "Under Trade Signal will be one or more controls to specify the parameters specific to the selected signal.  "
    return(content);
}

getFieldsTradeSignalP4 <- function() {
    content <- "Since there is only one signal implemented in the demo, only the controls to set the fast and slow SMA days will be displayed."
    return(content);
}

getQDateRangeP1 <- function() {
    content <- "Specifies the starting and ending dates to run the simulation over.  The latest ending date (the date on the right) allowed in the demo is December 14, 2015.  The earliest starting date allowed (the date on the left) is December 15, 2005 even though the default start date is set 1 year prior to the latest allowed ending date in the demo."
    return(content);
}

getStartAccountBalP1 <- function() {
    content <- "This field tells the simulator how much money (USD) is available to buy shares.  The larger the balance, the more shares the simulator can purchase."
}

getPositionMgmtP1 <- function() {
    content <- "Only the default value AIAO-OPAAT-OL is implemented in the demo.  This stands for "
}

getPositionMgmtP2 <- function() {
    content <- "All In All Out - One Position At A Time - Only Long (positions allowed)."
}