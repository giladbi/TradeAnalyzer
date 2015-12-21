source("TradingEvaluator.R")
source("StrategySimulator.R")

shinyServer(
    function(input, output) {
        output$oidstock <- eventReactive(input$runSimButton, {
            input$ticker
        })
        
        dateRangeInput <- eventReactive(input$runSimButton, {
            paste0("Query starts: ", input$queryDateRange[1],
                   " | Query ends: ", input$queryDateRange[2])
        })
        
        strategyInput <- eventReactive(input$runSimButton, {
            parms <- paste0("Trade Signal: ", input$tradeSignal,
                            " | Fast SMA: ", input$fastSlowSma[1],
                            " | Slow SMA: ", input$fastSlowSma[2])
            parms <- c(parms, paste0("Position Management: ",
                                     input$posMgmt))
            parms
        })
        
        output$signalAndParams <- renderPrint({
            strategyInput()
        })
        
        output$oidTradeSignal <- renderText(
            paste0("Trade Signal: ", input$tradeSignal)
            )
        
        output$oidBothQueryDates <- renderPrint({
            dateRangeInput()
        })
        
        runSim <- eventReactive(input$runSimButton, {
            if(input$fastSlowSma[2] > input$fastSlowSma[1]) {
                doSimulation(input$ticker,
                             as.character(input$queryDateRange[1]),
                             as.character(input$queryDateRange[2]),
                             signalParms=c(fastDays=input$fastSlowSma[1],
                                           slowDays=input$fastSlowSma[2]),
                             startBalance=input$accBalance)
            } else {
                data.frame(
                    Error_Message=c("Slow SMA days must be larger than Fast SMA days.",
                                    "Fast SMA is the left circle slider and Slow SMA is the right.",
                                    "It looks like you put these circles on top of each other.",
                                    "Please make Slow SMA days larger than Fast SMA days and try again.")
                )
            }
            
        })
        
        output$trades <- renderTable({
            runSim()
        })
        
        output$oidTradesNet <- renderPrint(netStrategyPL(runSim()))
    }
)