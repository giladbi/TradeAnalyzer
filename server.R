source("TradingEvaluator.R")

shinyServer(
    function(input, output) {
        output$oidstock <- renderPrint({input$ticker})
        
        strategyInput <- reactive({
            paste0("Trade Signal: ", input$tradeSignal,
                   " | Fast SMA: ", input$fastSMA,
                   " | Slow Sma: ", input$slowSMA)
        })
        
        dateRangeInput <- reactive({
            paste0("Query starts: ", input$queryDateRange[1],
                   " | Query ends: ", input$queryDateRange[2])
        })
        
        output$signalAndParams <- renderPrint({
            strategyInput()
        })
        
        output$oidBothQueryDates <- renderPrint({
            dateRangeInput()
        })
        
        runSim <- reactive({
            doSimulation(input$ticker)
        })
        
        output$trades <- renderTable({
            runSim()
        })
        
    }
)