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
        
        output$oidBothQueryDates <- renderPrint({
            dateRangeInput()
        })
        
        runSim <- eventReactive(input$runSimButton, {
            doSimulation(input$ticker,
                         as.character(input$queryDateRange[1]),
                         as.character(input$queryDateRange[2]),
                         signalParms=c(fastDays=input$fastSlowSma[1],
                                       slowDays=input$fastSlowSma[2]),
                         startBalance=input$accBalance)
        })
        
        output$trades <- renderTable({
            runSim()
        })
        
        output$oidTradesNet <- renderPrint(netStrategyPL(runSim()))
    }
)