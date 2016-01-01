
# https://cran.r-project.org/web/packages/timeDate/timeDate.pdf
install.packages("timeDate")

## explore:
## http://stackoverflow.com/questions/13215246/function-to-calculate-nyse-trading-day-of-month

# dev data
jnjData <- read.csv("./data/JNJ.csv")

## Returns number of trading days in the period between startDate and endDate.
##
## startDate - string of format "yyyy-mm-dd", start date of period
## endDate - string of format "yyyy-mm-dd", end date of period
##
## NOTE: startDate must be before endDate.
##
## NYSE sets a trading schedule most other markets follow:
## 1) Monday through Friday
## 2) Closed 9 holidays: New Year's Day, Martin Luther King Day in January,
##                       President's Day in February, Good Friday, Memorial Day,
##                       Independence Day, Labor Day, Thanksgiving and Christmas
##
## This function does a simple estimation by calculating the total number of
## days between startDate and endDate and then subtracts out the number of
## weekend days (Saturdays and Sundays), and finally subtracts out any holidays
## that may fall within the period.
tradingDays <- function(startDate, endDate) {
    
}

getMaTrainSet <- function() {
    
}