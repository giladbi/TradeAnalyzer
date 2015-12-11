

## Returns a vector of simple moving averages of the price.
## prices - numeric vector of price data
## smaInterval - period of the simple moving average.
## NOTE: SMA values for first (smaInterval - 1) days are calculated on all
##       available starting data.
calcSma <- function(prices, smaInterval) {
    smavgs <- vector(mode = "numeric", length = length(prices))
    for(i in 1:smaInterval) {
        smavgs[i] <- mean(prices[1:i])
    }
    for(j in (smaInterval+1):length(prices)) {
        smavgs[j] <- mean(prices[(j-smaInterval+1):j])
    }
    
    return(smavgs)
}