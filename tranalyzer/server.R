source("TradingEvaluator.R")

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
            paste0("Trade Signal: ", input$tradeSignal,
                   " | Fast SMA: ", input$fastSMA,
                   " | Slow Sma: ", input$slowSMA)
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
                         signalParms=c(fastDays=input$fastSMA,
                                       slowDays=input$slowSMA),
                         startBalance=input$accBalance)
        })
        
        output$trades <- renderTable({
            runSim()
        })
        
    }
)