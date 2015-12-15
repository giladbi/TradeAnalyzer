

shinyServer(
    function(input, output) {
        output$oidstock <- renderPrint({input$ticker})
        output$oidfsma <- renderPrint({input$fastSMA})
        output$oidssma <- renderPrint({input$slowSMA})
        
        dateRangeInput <- reactive({
            paste0("Query starts: ", input$queryDateRange[1],
                   " | Query ends: ", input$queryDateRange[2])
        })
        
        output$oidBothQueryDates <- renderPrint({
            dateRangeInput()
        })
        
    }
)