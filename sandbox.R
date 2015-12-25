

getDateIntervals <- function(startDate, endDate, maxYqlDays=360) {
    dateIntervals <- list(c(start=startDate, end=endDate))
    done <- as.integer(
                difftime(as.Date(endDate), as.Date(startDate), units="days")
            ) < maxYqlDays
    
    queryPeriods <- ceiling(
        as.integer(
            difftime(as.Date(endDate),
                     as.Date(startDate),
                     units="days")
        ) / queryDays)
    
    
    while(!done) {
        dateInterval <- dateIntervals[[i]]
        newEnd <- as.Date(dateInterval["start"]) + maxYqlDays
        nextStart <- newEnd + 1
        lastInterval <- (nextStart + maxYqlDays) > as.Date(endDate)
        cat(i, dateInterval, newEnd, nextStart, lastInterval, "\n")
        if(lastInterval) {
            dateIntervals <- list(dateIntervals, 
                                  c(start=as.character(nextStart), end=endDate))
            done <- TRUE
        }
        else {
            cat("not on last interval", "\n")
            newEnd <- newStart + maxYqlDays
            dateIntervals <- c(start=as.character(nextStart), end=newEnd)
            i <- i + 1
        }
        cat("------------", "\n")
    }
    
    return(dateIntervals)
}

d1 <- "1998-07-11"
d2 <- "2015-12-12"
startDate <- d1
endDate <- d2

demoStartDateMin <- "2005-12-15"; demoEndDateMax <- "2015-12-14"
demoStartDate <- as.character(as.Date(demoEndDateMax)-365)
demoEndDate <- as.character(as.Date(demoEndDateMax))
jnj_2014.12.14to2015.12.14 <- doSimulation("JNJ", demoStartDate, demoEndDate)
ge_2014.12.14to2015.12.14 <- doSimulation("GE", demoStartDate, demoEndDate)
hd_2014.12.14to2015.12.14 <- doSimulation("HD", demoStartDate, demoEndDate)
aapl_2014.12.14to2015.12.14 <- doSimulation("AAPL", demoStartDate, demoEndDate)