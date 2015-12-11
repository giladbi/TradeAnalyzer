

## Returns a vector of simple moving averages of the price.
## prices - numeric vector of price data
## smaInterval - period of the simple moving average.
## NOTE: SMA values for first (smaInterval - 1) days are NaN
calcSma <- function(prices, smaInterval) {
    smavgs <- vector(mode = "numeric", length = length(prices))
    for(i in 1:(smaInterval - 1)) { smavgs[i] <- NaN }
    for(j in smaInterval:length(prices)) {
        smavgs[j] <- mean(prices[(1 + j - smaInterval):j])
    }
    
    return(smavgs)
}