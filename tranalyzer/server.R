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
        
        runSim <- eventReactive(input$runSimButton, {
            doSimulation(input$ticker,
                         as.character(input$queryDateRange[1]),
                         as.character(input$queryDateRange[2]),
                         signalParms=c(fastDays=input$fastSMA,
                                       slowDays=input$slowSMA))
        })
        
        output$trades <- renderTable({
            runSim()
        })
        
#         observeEvent(input$runSimButton, {
#             output$trades <- renderTable({
#                 doSimulation(input$ticker,
#                              as.character(input$queryDateRange[1]),
#                              as.character(input$queryDateRange[2]),
#                              signalParms=c(fastDays=input$fastSMA,
#                                            slowDays=input$slowSMA))
#             })
#         })
        
        
    }
)